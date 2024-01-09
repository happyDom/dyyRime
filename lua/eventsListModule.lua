-- eventsListModule.lua
-- Copyright (C) 2023 yaoyuan.dou <douyaoyuan@126.com>
local M={}
local dbgFlg = false
--按照公历日期建立的事件索引表
local eventsDicBySolarDates={}
--按照关键字建立的事件索引表
local eventsDicListByKeyW={}

--[[事件是一个结构体，每一个事件的结构如下：
e.c1：文档第一列的内容
e.c2：文档第二列的内容，如果没有内容，此为空
e.c3：文档第三列的内容，如果没有内容，此为空
e.kWs：这是文档第二列的内容通过空格切分后的关键字列表
e.time：这是事件的时间值
e.solarDate：这是事件的日期：20230102
]]

--一个农历日期表，用于根据农历反查对应阳历时间，提高查询效率
local lunarDatesList = {}

--引入系统变更处理模块
local ok, sysInfoRes = pcall(require, 'sysInfo')

--引入农历计算模块
local ok, lunar = pcall(require, 'lunarModule')

--引入日期时间计算模块
local ok, dt = pcall(require,'dateTimeModule')

--设置 dbg 开关
local function setDbg(flg)
	flg = flg or dbgFlg
	
	dbgFlg = flg
	sysInfoRes.setDbg(flg)
	lunar.setDbg(flg)
	dt.setDbg(flg)
	
	print('eventsListModule dbgFlg is '..tostring(dbgFlg))
end

--将这附串拆散成 table
local function stringSplit(str,sp,sp1)
	sp=(type(sp)=="string") and sp or " "
	if 0==#sp then
		sp="([%z\1-\127\194-\244][\128-\191]*)"
	elseif 1==#sp then
		sp="[^"..(sp=="%" and "%%" or sp).."]*"
	else
		sp1=sp1 or "^"
		str=str:gsub(sp,sp1)
		sp="[^"..sp1.."]*"
	end
	
	local tab={}
	for v in str:gmatch(sp) do
		if ''~=v then
			table.insert(tab,v)
		end
	end
	return tab
end

--将一个日期字符串转换为时间值，'20230125' -> xxxxxx
local function dateStr2Time(dateStr)
	dateStr = dateStr or ''
	if #dateStr ~= 8 then
		dateStr = os.date("%Y%m%d")
	end
	
	local year = tonumber(string.sub(dateStr,1,4))
	local month = tonumber(string.sub(dateStr,5,6))
	local day = tonumber(string.sub(dateStr,7,8))
	
	return os.time({year=year,month=month,day=day})
end

--根据指定的天数偏移量，建立农历日期序列表，以借后期快速查询农历对应的阳历日期
local function lunarDatesListBuild(preDays,posDays)
	if nil == preDays then
		preDays = 100
	end
	if nil == posDays then
		posDays = 365
	end
	preDays = math.max(preDays,1)
	posDays = math.max(posDays,1)
	
	local idx = 0
	local todayTime = os.date("*t")
	local tmpLunar,tmpSolar,tmpTime
	
	--以昨天为base，计算前preDays日期内的日期序列
	for idx = 1, preDays do
		tmpTime = os.time({year=todayTime.year,month=todayTime.month,day=todayTime.day - idx})
		tmpSolar = os.date("%Y%m%d",tmpTime)
		tmpLunar = lunar.solar2LunarByTime(tmpTime)
		
		lunarDatesList[tmpLunar.lunarDate_YYYYMMDD..(tmpLunar.leap and '.1' or '.0')] = tmpSolar
	end
	--以今天为base，计算后posDays日期内的日期序列
	for idx = 0, posDays do
		tmpTime = os.time({year=todayTime.year,month=todayTime.month,day=todayTime.day + idx})
		tmpSolar = os.date("%Y%m%d",tmpTime)
		tmpLunar = lunar.solar2LunarByTime(tmpTime)
		
		lunarDatesList[tmpLunar.lunarDate_YYYYMMDD..(tmpLunar.leap and '.1' or '.0')] = tmpSolar
	end
end

--以指定时间为基准，计算并把该基准前 or 后指定周数的周序对应的时间值
local function timeOfWeekDayBaseOnTime0(t,wCnt,wCntType,wDay)
	t = t or os.time()
	local tBase = os.time()
	if type(t)==type(tBase) then
		tBase = t
	end
	wCnt = wCnt or 0
	if 0==wCnt then
		wCnt = 1
	end
	wCntType = wCntType or 'w'
	if 'w'~=wCntType and 'W'~=wCntType then
		wCntType = 'w'
	end
	wDay = wDay or 0
	if wDay < 0 or wDay > 6 then
		wDay = 0
	end
	
	local fakeSolarDateTime = tBase
	local fakeSolarDate_wDay = tonumber(os.date("%w",fakeSolarDateTime))
	if wCnt > 0 then
		--找描点之后第 wCnt 周的位置
		if fakeSolarDate_wDay <= wDay then
			fakeSolarDateTime=fakeSolarDateTime+(wDay-fakeSolarDate_wDay+7*(wCnt-1))*86400
			if 'W'==wCntType and 0~=fakeSolarDate_wDay then
				--如果要求整周且初一不为周日，则需要额外加7天
				fakeSolarDateTime = fakeSolarDateTime + 7*86400
			end
		else
			fakeSolarDateTime=fakeSolarDateTime+(wDay-fakeSolarDate_wDay+7*wCnt)*86400
		end
	else
		--找描点之前第 wCnt 周的位置
		if fakeSolarDate_wDay <= wDay then
			fakeSolarDateTime = fakeSolarDateTime + (wDay-fakeSolarDate_wDay+7*wCnt)*86400
		else
			fakeSolarDateTime = fakeSolarDateTime + (wDay-fakeSolarDate_wDay+7*(wCnt+1))*86400
			if 'W'==wCntType and 0~=fakeSolarDate_wDay then
				--如果要求整周且初一不为周日，则需要额外减7天
				fakeSolarDateTime = fakeSolarDateTime - 7*86400
			end
		end
	end
	
	return fakeSolarDateTime
end

--[[对传入的锚点信息进行解码：[solar][Y]0315
函数返回一个锚点结构体，说明如下：
anchor.desc：锚点的描述
anchor.lunarFlg：锚点是否 base农历
anchor.solarFlg：锚点是否 base公历
anchor.yearFlg：锚点是否以 年 为循环周期
anchor.monthFlg：锚点是否以 月 为循环周期
anchor.weekFlg：锚点是否以 周 为循环周期
anchor.dayFlg：锚点是否为指定日期事件
anchor.jqFlg：锚点是否 base节气
anchor.eventFlg：锚点是否 base事件
anchor.solarDatesList：锚点解析的事件日期序列
]]
local function anchorDecode(anchorStr)
	local anchor = {}
	anchor.desc = ''
	anchor.lunarFlg = false
	anchor.solarFlg = false
	anchor.yearFlg = false
	anchor.monthFlg = false
	anchor.weekFlg = false
	anchor.dayFlg = false
	anchor.jqFlg = false
	anchor.eventFlg = false
	anchor.solarDatesList = {}
	
	anchorStr = anchorStr or ''
	if '' == anchorStr then
		return anchor
	end
	anchor.desc = anchorStr
	
	--1.1解码公历指定日期的事件
	do
		local solarDate = string.match(anchor.desc,"%[solar%]%[D%](%d%d%d%d%d%d%d%d)")
		if nil ~= solarDate then
			table.insert(anchor.solarDatesList,solarDate)
			anchor.solarFlg = true
			anchor.dayFlg = true
			return anchor
		end
	end
	
	--2.1/2解码农历指定日期的事件
	do
		local lunarDate = string.match(anchor.desc,"%[lunar%]%[D%](%d%d%d%d%d%d%d%d)")
		if nil ~= lunarDate then
			local solarDateOfThisLunarDate
			if string.find(anchor.desc,lunarDate..'%.1') then
				--这是一个带有.1标记的农历日期
				solarDateOfThisLunarDate = lunarDatesList[lunarDate..'.1']
			else
				--这是一个没有.1标记的农历日期
				solarDateOfThisLunarDate = lunarDatesList[lunarDate..'.0']
			end
			if nil ~= solarDateOfThisLunarDate then
				table.insert(anchor.solarDatesList,solarDateOfThisLunarDate)
				anchor.lunarFlg = true
				anchor.dayFlg = true
			end
			return anchor
		end
	end
	
	--3.1/2/3解码周循环事件
	do
		local weekDay = string.match(anchor.desc,"%[solar%]%[[Ww]%]([0-9]+)$")
		if nil == weekDay then
			weekDay = string.match(anchor.desc,"%[lunar%]%[[Ww]%]([0-6]+)$")
		end
		if nil ~= weekDay then
			weekDay = tonumber(weekDay)
			if weekDay>6 then
				weekDay = nil
			end
		end
		if nil ~= weekDay then
			--获取今天的周序值，距离周日的天数
			local daysToSundayToday = tostring(os.date('%w'))
			local timeBase = os.date("*t")
			timeBase.day = timeBase.day + weekDay - daysToSundayToday
			
			local tmpTime
			local idx
			--前查5周的日期
			local preWs = 5
			--后查10周的日期
			local posWs = 10
			for idx = 1,preWs do
				tmpTime = os.date("*t",os.time(timeBase))
				tmpTime.day = tmpTime.day - 7*(preWs-idx+1)
				table.insert(anchor.solarDatesList,os.date("%Y%m%d",os.time(tmpTime)))
			end
			for idx = 0,posWs do
				tmpTime = os.date("*t",os.time(timeBase))
				tmpTime.day = tmpTime.day + 7*idx
				table.insert(anchor.solarDatesList,os.date("%Y%m%d",os.time(tmpTime)))
			end
			
			if 0<#anchor.solarDatesList then
				anchor.solarFlg = true
				anchor.weekFlg = true
			end
			return anchor
		end
	end
	
	--4.1/2解码公历月循环事件
	do
		local daysOffset = string.match(anchor.desc,"%[solar%]%[[Mm]%](-*[0-9]+)$")
		if nil ~= daysOffset then
			daysOffset = tonumber(daysOffset)
			if 0==daysOffset or daysOffset<-31 or daysOffset>31 then
				daysOffset = nil
			end
		end
		if nil ~= daysOffset then
			local timeBase = os.date("*t")
			timeBase = os.time({year=timeBase.year,month=timeBase.month,day=1})
			
			local fakeTime
			local anchorMonth
			local idx
			--前查12个月的日期
			local preMs = 12
			--后查12个月的日期
			local posMs = 10
			
			for idx = 1,preMs do
				fakeTime = os.date('*t',timeBase)
				fakeTime.month = fakeTime.month - (preMs-idx+1)
				local t = os.time(fakeTime)
				
				anchorMonth = tonumber(os.date("%m",t))
				
				t = t + (daysOffset-(daysOffset>0 and 1 or 0))*86400
				if daysOffset > 0 then
					if tonumber(os.date('%m',t)) == anchorMonth then
						table.insert(anchor.solarDatesList,os.date("%Y%m%d",t))
					end
				elseif daysOffset < 0 then
					if tonumber(os.date('%m',t)) == (anchorMonth==1 and 12 or anchorMonth-1) then
						table.insert(anchor.solarDatesList,os.date("%Y%m%d",t))
					end
				end
			end
			for idx = 0,posMs do
				fakeTime = os.date('*t',timeBase)
				fakeTime.month = fakeTime.month + idx
				local t = os.time(fakeTime)
				
				anchorMonth = tonumber(os.date("%m",t))
				
				t = t + (daysOffset-(daysOffset>0 and 1 or 0))*86400
				if daysOffset > 0 then
					if tonumber(os.date('%m',t)) == anchorMonth then
						table.insert(anchor.solarDatesList,os.date("%Y%m%d",t))
					end
				elseif daysOffset < 0 then
					if tonumber(os.date('%m',t)) == (anchorMonth==1 and 12 or anchorMonth-1) then
						table.insert(anchor.solarDatesList,os.date("%Y%m%d",t))
					end
				end
			end
			
			if 0<#anchor.solarDatesList then
				anchor.solarFlg = true
				anchor.monthFlg = true
			end
			return anchor
		end
	end
	
	--5.1/2解码农历月循环事件
	do
		local daysOffset = string.match(anchor.desc,"%[lunar%]%[[Mm]%](-*[0-9]+)$")
		if nil ~= daysOffset then
			daysOffset = tonumber(daysOffset)
			if 0==daysOffset or daysOffset<-31 or daysOffset>31 then
				daysOffset = nil
			end
		end
		if nil ~= daysOffset then
			local lunarYear = tonumber(os.date("%Y"))
			local fakeLunarDatesList = {}
			
			--合成去年1-9月度的月度字符串
			for idx = 1,9 do
				table.insert(fakeLunarDatesList,(lunarYear-1)..'0'..idx..'01.0')
			end
			--合成去年10-12月度的月度字符串
			for idx = 10,12 do
				table.insert(fakeLunarDatesList,(lunarYear-1)..idx..'01.0')
			end
			--合成今年1-9月度的月度字符串
			for idx = 1,9 do
				table.insert(fakeLunarDatesList,lunarYear..'0'..idx..'01.0')
			end
			--合成今年10-12月度的月度字符串
			for idx = 10,12 do
				table.insert(fakeLunarDatesList,lunarYear..idx..'01.0')
			end
			--合成明年1-9月度的月度字符串
			for idx = 1,9 do
				table.insert(fakeLunarDatesList,(lunarYear+1)..'0'..idx..'01.0')
			end
			--合成明年10-12月度的月度字符串
			for idx = 10,12 do
				table.insert(fakeLunarDatesList,(lunarYear+1)..idx..'01.0')
			end
			
			local fakeSolarDate
			for idx=1,#fakeLunarDatesList do
				fakeSolarDate = lunarDatesList[fakeLunarDatesList[idx]]
				local t = dateStr2Time(fakeSolarDate)
				local anchorMonth = tonumber(string.sub(fakeLunarDatesList[idx],5,6))
				t = t + (daysOffset-(daysOffset>0 and 1 or 0))*86400
				
				local lunarCheck = lunar.solar2LunarByTime(t)
				
				if daysOffset>0 then
					if anchorMonth == lunarCheck.month and false==lunarCheck.leap then
						table.insert(anchor.solarDatesList,os.date("%Y%m%d",t))
					end
				elseif daysOffset<0 then
					if lunarCheck.month==(anchorMonth==1 and 12 or anchorMonth-1) then
						table.insert(anchor.solarDatesList,os.date("%Y%m%d",t))
					end
				end
			end
			
			if 0<#anchor.solarDatesList then
				anchor.lunarFlg = true
				anchor.monthFlg = true
			end
			return anchor
		end
	end
	
	--6.1解码农历年循环事件
	do
		local lunarYearMonth = string.match(anchor.desc,"%[lunar%]%[[Yy]%](%d%d%d%d)")
		if nil ~= lunarYearMonth then
			local lm,ld = string.match(anchor.desc,"%[lunar%]%[Y%](%d%d)(%d%d)")
			local ly = tonumber(os.date("%Y"))
			--预查前2年，后2年以及本年的农历日期，不考虑闰月
			local fakeLunarDatesList = {(ly-2)..lm..ld..'.0',
										(ly-1)..lm..ld..'.0',
										(ly-0)..lm..ld..'.0',
										(ly+1)..lm..ld..'.0',
										(ly+2)..lm..ld..'.0'}
			local thisSolarDate
			for idx = 1,#fakeLunarDatesList do
				thisSolarDate = lunarDatesList[fakeLunarDatesList[idx]]
				if nil ~= thisSolarDate then
					table.insert(anchor.solarDatesList,thisSolarDate)
				end
			end
			
			if 0<#anchor.solarDatesList then
				anchor.lunarFlg = true
				anchor.yearFlg = true
			end
			return anchor
		end
	end
	
	--7.1解码公历年循环事件
	do
		local solarYearMonth = string.match(anchor.desc,"%[solar%]%[[Yy]%](%d%d%d%d)")
		if nil ~= solarYearMonth then
			local m,d = string.match(anchor.desc,"%[solar%]%[Y%](%d%d)(%d%d)")
			local y = tonumber(os.date("%Y"))
			local fakeDateStr
			--定义去年的事件
			fakeDateStr = (y - 1)..m..d
			if fakeDateStr == os.date("%Y%m%d",dateStr2Time(fakeDateStr)) then
				table.insert(anchor.solarDatesList,fakeDateStr)
			end
			--定义今年的事件
			fakeDateStr = y..m..d
			if fakeDateStr == os.date("%Y%m%d",dateStr2Time(fakeDateStr)) then
				table.insert(anchor.solarDatesList,fakeDateStr)
			end
			--定义明年的事件
			fakeDateStr = (y + 1)..m..d
			if fakeDateStr == os.date("%Y%m%d",dateStr2Time(fakeDateStr)) then
				table.insert(anchor.solarDatesList,fakeDateStr)
			end
			
			if 0<#anchor.solarDatesList then
				anchor.solarFlg = true
				anchor.yearFlg = true
			end
			return anchor
		end
	end
	
	--8.1/2解码锚定在农历月份+指定周序上的事件
	--[lunar][Y][M05][1Ww]4
	do
		local anchorLunarMonth,anchorWCnt,anchorWType,anchorWDay = string.match(anchor.desc,"%[[Ll]unar%]%[[Yy]%]%[[Mm]([0-9]+)%]%[(-*[0-9]+)([Ww])%]([0-9]+)$")
		if nil~=anchorLunarMonth and nil~=anchorWCnt and nil~=anchorWType and nil~=anchorWDay then
			anchorLunarMonth = tonumber(anchorLunarMonth)
			if anchorLunarMonth<1 or anchorLunarMonth>12 then
				anchorLunarMonth = nil
			elseif anchorLunarMonth<10 then
				anchorLunarMonth = '0'..anchorLunarMonth
			else
				anchorLunarMonth = tostring(anchorLunarMonth)
			end
			anchorWCnt = tonumber(anchorWCnt)
			if 0==anchorWCnt then
				anchorWCnt = nil
			end
			anchorWDay = tonumber(anchorWDay)
			if anchorWDay<0 or anchorWDay>6 then
				anchorWDay = nil
			end
		end
		if nil~=anchorLunarMonth and nil~=anchorWCnt and nil~=anchorWType and nil~=anchorWDay then
			local fakeLunarYear = 0
			local fakeSolarDate = ''
			local fakeSolarDateTime = ''
			local fakeLunarDate = ''
			local idx = 0
			
			--处理去年，今年，明天三年内的事件
			for idx=1,3 do
				fakeLunarYear = tonumber(os.date('%Y'))+(idx-2)
				--找到农历对应月的初一，做为基准日期
				fakeLunarDate = fakeLunarYear..anchorLunarMonth..'01.0'
				fakeSolarDate = lunarDatesList[fakeLunarDate]
				if nil ~= fakeSolarDate then
					table.insert(anchor.solarDatesList,os.date('%Y%m%d',timeOfWeekDayBaseOnTime0(dateStr2Time(fakeSolarDate),anchorWCnt,anchorWType,anchorWDay)))
				end
			end
			
			if 0<#anchor.solarDatesList then
				anchor.lunarFlg = true
				anchor.yearFlg = true
			end
			return anchor
		end
	end
	
	--9.1/2解码锚定在公历月份+指定周序上的事件
	--[solar][Y][M05][1Ww]4
	do
		local anchorSolarMonth,anchorWCnt,anchorWType,anchorWDay = string.match(anchor.desc,"%[[Ss]olar%]%[[Yy]%]%[[Mm]([0-9]+)%]%[(-*[0-9]+)([Ww])%]([0-9]+)$")
		if nil~=anchorSolarMonth and nil~=anchorWCnt and nil~=anchorWType and nil~=anchorWDay then
			anchorSolarMonth = tonumber(anchorSolarMonth)
			if anchorSolarMonth<1 or anchorSolarMonth>12 then
				anchorSolarMonth = nil
			elseif anchorSolarMonth<10 then
				anchorSolarMonth = '0'..anchorSolarMonth
			else
				anchorSolarMonth = tostring(anchorSolarMonth)
			end
			anchorWCnt = tonumber(anchorWCnt)
			if 0==anchorWCnt then
				anchorWCnt = nil
			end
			anchorWDay = tonumber(anchorWDay)
			if anchorWDay<0 or anchorWDay>6 then
				anchorWDay = nil
			end
		end
		if nil~=anchorSolarMonth and nil~=anchorWCnt and nil~=anchorWType and nil~=anchorWDay then
			local fakeSolarYear = 0
			local fakeSolarDate = ''
			local fakeSolarDateTime = ''
			local idx = 0
			
			--处理去年，今年，明天三年内的事件
			for idx=1,3 do
				fakeSolarYear = tonumber(os.date('%Y'))+(idx-2)
				--以每指定月的1号作为指定的基准日期
				fakeSolarDate = fakeSolarYear..anchorSolarMonth..'01'
				if nil ~= fakeSolarDate then
					table.insert(anchor.solarDatesList,os.date('%Y%m%d',timeOfWeekDayBaseOnTime0(dateStr2Time(fakeSolarDate),anchorWCnt,anchorWType,anchorWDay)))
				end
			end
			
			if 0<#anchor.solarDatesList then
				anchor.solarFlg = true
				anchor.yearFlg = true
			end
			return anchor
		end
	end
	
	--10.1/2/3/4解码锚定在节气上的+指定周序上的事件
	--[lunar][Y][JQ清明][1w]4
	do
		local anchorJqName,anchorWCnt,anchorWType,anchorWDay = string.match(anchor.desc,"%[[Ll]unar%]%[[Yy]%]%[[Jj][Qq](.+)%]%[(-*[0-9]+)([Ww])%]([0-9]+)$")
		if nil~=anchorJqName and nil~=anchorWCnt and nil~=anchorWType and nil~=anchorWDay then
			if 0==lunar.jqIdxByName(anchorJqName) then
				anchorJqName = nil
			end
			anchorWCnt = tonumber(anchorWCnt)
			if 0==anchorWCnt then
				anchorWCnt = nil
			end
			anchorWDay = tonumber(anchorWDay)
			if anchorWDay<0 or anchorWDay>6 then
				anchorWDay = nil
			end
		end
		if nil~=anchorJqName and nil~=anchorWCnt and nil~=anchorWType and nil~=anchorWDay then
			local jqInfo = lunar.jqInfoByName(anchorJqName)
			if #jqInfo.jqTimeList>0 then
				local idx
				for idx =1,#jqInfo.jqTimeList do
					--以每一个节气的时间为指定的基准时间
					table.insert(anchor.solarDatesList,os.date('%Y%m%d',timeOfWeekDayBaseOnTime0(jqInfo.jqTimeList[idx],anchorWCnt,anchorWType,anchorWDay)))
				end
			end
			
			if 0<#anchor.solarDatesList then
				anchor.lunarFlg = true
				anchor.yearFlg = true
				anchor.jqFlg = true
			end
			return anchor
		end
	end
	
	--11.1/2/3/4解码锚定在公历每月+指定周序上的事件
	--[solar][M][2w]2
	do
		local anchorWCnt,anchorWType,anchorWDay = string.match(anchor.desc,"%[[Ss]olar%]%[[Mm]%]%[(-*[0-9]+)([Ww])%]([0-9]+)$")
		if nil~=anchorWCnt and nil~=anchorWType and nil~=anchorWDay then
			anchorWCnt = tonumber(anchorWCnt)
			if 0==anchorWCnt then
				anchorWCnt = nil
			end
			anchorWDay = tonumber(anchorWDay)
			if anchorWDay<0 or anchorWDay>6 then
				anchorWDay = nil
			end
		end
		if nil~=anchorWCnt and nil~=anchorWType and nil~=anchorWDay then
			local solarDateBase = os.date('*t')
			solarDateBase = os.date('*t',os.time({year=solarDateBase.year,month=solarDateBase.month,day=1}))
			local idx = 0
			local fakeSolarDate
			for idx=1,24 do
				fakeSolarDate = os.date('*t',os.time(solarDateBase))
				fakeSolarDate.month = fakeSolarDate.month + (idx - 13)
				
				table.insert(anchor.solarDatesList,os.date('%Y%m%d',timeOfWeekDayBaseOnTime0(os.time(fakeSolarDate),anchorWCnt,anchorWType,anchorWDay)))
			end
			
			if 0<#anchor.solarDatesList then
				anchor.solarFlg = true
				anchor.monthFlg = true
			end
			return anchor
		end
	end
	
	--12.1/2/3/4解码锚定在农历每月+指定周序上的事件
	--[lunar][M][2w]2
	do
		local anchorWCnt,anchorWType,anchorWDay = string.match(anchor.desc,"%[[Ll]unar%]%[[Mm]%]%[(-*[0-9]+)([Ww])%]([0-9]+)$")
		if nil~=anchorWCnt and nil~=anchorWType and nil~=anchorWDay then
			anchorWCnt = tonumber(anchorWCnt)
			if 0==anchorWCnt then
				anchorWCnt = nil
			end
			anchorWDay = tonumber(anchorWDay)
			if anchorWDay<0 or anchorWDay>6 then
				anchorWDay = nil
			end
		end
		if nil~=anchorWCnt and nil~=anchorWType and nil~=anchorWDay then
			local lunarDateBase = lunar.solar2LunarByTime(os.time())
			local fakeLunarDate = ''
			local fakeSolarDate = ''
			local idx
			
			--处理前12个月以及后12个月的事件
			--第一步，处理去年的月份事件
			for idx=lunarDateBase.month,12 do
				if idx < 10 then
					fakeSolarDate = lunarDatesList[(lunarDateBase.year-1)..'0'..idx..'01.0']
				else
					fakeSolarDate = lunarDatesList[(lunarDateBase.year-1)..idx..'01.0']
				end
				if nil ~= fakeSolarDate then
					table.insert(anchor.solarDatesList,os.date('%Y%m%d',timeOfWeekDayBaseOnTime0(dateStr2Time(fakeSolarDate),anchorWCnt,anchorWType,anchorWDay)))
				end
			end
			--第二步，处理今年的月份事件
			for idx=1,12 do
				if idx < 10 then
					fakeSolarDate = lunarDatesList[lunarDateBase.year..'0'..idx..'01.0']
				else
					fakeSolarDate = lunarDatesList[lunarDateBase.year..idx..'01.0']
				end
				if nil ~= fakeSolarDate then
					table.insert(anchor.solarDatesList,os.date('%Y%m%d',timeOfWeekDayBaseOnTime0(dateStr2Time(fakeSolarDate),anchorWCnt,anchorWType,anchorWDay)))
				end
			end
			--第三步，处理明年的月份事件
			for idx=1,lunarDateBase.month do
				if idx < 10 then
					fakeSolarDate = lunarDatesList[(lunarDateBase.year+1)..'0'..idx..'01.0']
				else
					fakeSolarDate = lunarDatesList[(lunarDateBase.year+1)..idx..'01.0']
				end
				if nil ~= fakeSolarDate then
					table.insert(anchor.solarDatesList,os.date('%Y%m%d',timeOfWeekDayBaseOnTime0(dateStr2Time(fakeSolarDate),anchorWCnt,anchorWType,anchorWDay)))
				end
			end
			
			if 0<#anchor.solarDatesList then
				anchor.lunarFlg = true
				anchor.monthFlg = true
			end
			return anchor
		end
	end
	--13.1解码锚定在农历指定月+指定天数上的事件
	--[lunar][Y][M05]4
	do
		local anchorMonth,anchorDayOffset = string.match(anchor.desc,"%[[Ll]unar%]%[[Yy]%]%[[Mm]([0-9]+)%](-*[0-9]+)$")
		if nil~=anchorMonth and nil~=anchorDayOffset then
			anchorMonth = tonumber(anchorMonth)
			if anchorMonth<1 or anchorMonth>12 then
				anchorMonth = nil
			end
			anchorDayOffset = tonumber(anchorDayOffset)
			if 0==anchorDayOffset then
				anchorDayOffset = nil
			end
		end
		if nil~=anchorMonth and nil~=anchorDayOffset then
			local lunarDateBase = lunar.solar2LunarByTime(os.time())
			local fakeSolarDate = ''
			
			--第一步，处理去年的事件
			if anchorMonth < 10 then
				fakeSolarDate = lunarDatesList[(lunarDateBase.year-1)..'0'..anchorMonth..'01.0']
			else
				fakeSolarDate = lunarDatesList[(lunarDateBase.year-1)..anchorMonth..'01.0']
			end
			if nil ~= fakeSolarDate then
				fakeSolarDate = os.date('*t',dateStr2Time(fakeSolarDate))
				fakeSolarDate.day = fakeSolarDate.day + anchorDayOffset - (anchorDayOffset>0 and 1 or 0)
				
				table.insert(anchor.solarDatesList,os.date('%Y%m%d',os.time(fakeSolarDate)))
			end
			
			--第二步，处理今年的事件
			if anchorMonth < 10 then
				fakeSolarDate = lunarDatesList[lunarDateBase.year..'0'..anchorMonth..'01.0']
			else
				fakeSolarDate = lunarDatesList[lunarDateBase.year..anchorMonth..'01.0']
			end
			if nil ~= fakeSolarDate then
				fakeSolarDate = os.date('*t',dateStr2Time(fakeSolarDate))
				fakeSolarDate.day = fakeSolarDate.day + anchorDayOffset - (anchorDayOffset>0 and 1 or 0)
				
				table.insert(anchor.solarDatesList,os.date('%Y%m%d',os.time(fakeSolarDate)))
			end
			--第三步，处理明年的事件
			if anchorMonth < 10 then
				fakeSolarDate = lunarDatesList[(lunarDateBase.year+1)..'0'..anchorMonth..'01.0']
			else
				fakeSolarDate = lunarDatesList[(lunarDateBase.year+1)..anchorMonth..'01.0']
			end
			if nil ~= fakeSolarDate then
				fakeSolarDate = os.date('*t',dateStr2Time(fakeSolarDate))
				fakeSolarDate.day = fakeSolarDate.day + anchorDayOffset - (anchorDayOffset>0 and 1 or 0)
				
				table.insert(anchor.solarDatesList,os.date('%Y%m%d',os.time(fakeSolarDate)))
			end
			
			if 0<#anchor.solarDatesList then
				anchor.lunarFlg = true
				anchor.yearFlg = true
			end
			return anchor
		end
	end
	
	--14.1解码锚定在公历指定月+指定天数上的事件
	--[solar][Y][M05]4
	do
		local anchorMonth,anchorDayOffset = string.match(anchor.desc,"%[[Ss]olar%]%[[Yy]%]%[[Mm]([0-9]+)%](-*[0-9]+)$")
		if nil~=anchorMonth and nil~=anchorDayOffset then
			anchorMonth = tonumber(anchorMonth)
			if anchorMonth<1 or anchorMonth>12 then
				anchorMonth = nil
			end
			anchorDayOffset = tonumber(anchorDayOffset)
			if 0==anchorDayOffset then
				anchorDayOffset = nil
			end
		end
		if nil~=anchorMonth and nil~=anchorDayOffset then
			local solarDateBase = os.date('*t')
			
			local fakeSolarDate
			--第一步，处理去年的事件
			fakeSolarDate = os.date('*t',os.time({year=solarDateBase.year,month=anchorMonth,day=1}))
			fakeSolarDate.year = fakeSolarDate.year - 1
			fakeSolarDate.day = fakeSolarDate.day + anchorDayOffset - (anchorDayOffset>0 and 1 or 0)
			table.insert(anchor.solarDatesList,os.date('%Y%m%d',os.time(fakeSolarDate)))
			
			
			--第二步，处理今年的事件
			fakeSolarDate = os.date('*t',os.time({year=solarDateBase.year,month=anchorMonth,day=1}))
			fakeSolarDate.day = fakeSolarDate.day + anchorDayOffset - (anchorDayOffset>0 and 1 or 0)
			table.insert(anchor.solarDatesList,os.date('%Y%m%d',os.time(fakeSolarDate)))
			
			--第三步，处理明年的事件
			fakeSolarDate = os.date('*t',os.time({year=solarDateBase.year,month=anchorMonth,day=1}))
			fakeSolarDate.year = fakeSolarDate.year + 1
			fakeSolarDate.day = fakeSolarDate.day + anchorDayOffset - (anchorDayOffset>0 and 1 or 0)
			table.insert(anchor.solarDatesList,os.date('%Y%m%d',os.time(fakeSolarDate)))
			
			if 0<#anchor.solarDatesList then
				anchor.solarFlg = true
				anchor.yearFlg = true
			end
			return anchor
		end
	end
	
	--15.1/2解码锚定在指定节气+指定天数上的事件
	--[lunar][Y][JQ春分]4
	do
		local anchorJqName,anchorDayOffset = string.match(anchor.desc,"%[[Ll]unar%]%[[Yy]%]%[[Jj][Qq](.+)%](-*[0-9]+)$")
		if nil~=anchorJqName and nil~=anchorDayOffset then
			if 0==lunar.jqIdxByName(anchorJqName) then
				anchorJqName = nil
			end
			anchorDayOffset = tonumber(anchorDayOffset)
			if 0==anchorDayOffset then
				anchorDayOffset = nil
			end
		end
		if nil~=anchorJqName and nil~=anchorDayOffset then
			local jqInfo = lunar.jqInfoByName(anchorJqName)
			if #jqInfo.jqTimeList>0 then
				local idx
				local t
				for idx =1,#jqInfo.jqTimeList do
					--以每一个节气的时间为指定的基准时间
					t = jqInfo.jqTimeList[idx]
					t = t + (anchorDayOffset - (anchorDayOffset>0 and 1 or 0))*86400
					table.insert(anchor.solarDatesList,os.date('%Y%m%d',t))
				end
			end
			
			if 0<#anchor.solarDatesList then
				anchor.lunarFlg = true
				anchor.yearFlg = true
				anchor.jqFlg = true
			end
			return anchor
		end
	end
	
	return anchor
end

--将文档处理成行数组
local function files_to_lines(...)
	if dbgFlg then
		print("--->files_to_lines called here")
	end
	local tab=setmetatable({},{__index=table})
	local index=1
	for i,filename in next,{...} do
		local fn = io.open(filename)
		if fn then
			for line in fn:lines() do
				if not line or #line > 0 then
					tab:insert(line)
				end
			end
			fn:close()
		end
	end
	
	if dbgFlg then
		print("--->files_to_lines completed here")
	end
	return tab
end

--根据加载的文档，创建事件字典，以公历日期为索引
local function eventsDicBySolarDatesBuild(...)
	if dbgFlg then
		print("-->eventsDicBySolarDatesBuild called here")
	end
	
	local lines=files_to_lines(...)
	
	for i,line in next ,lines do
		if dbgFlg then
			print('line is: ', line)
		end
		if not line:match("^%s*#") then  -- 第一字 # 为注释行
			local d,kW,c = string.match(line,"(.+)\t(%C*)\t(%C*)")
			if nil ~= d then
				local thisEvent = {}
				thisEvent.d = d
				thisEvent.kW = kW or ''
				thisEvent.c = c or thisEvent.kW
				
				if '' ~= thisEvent.kW then
					thisEvent.kWs = stringSplit(thisEvent.kW,' ')
				end
				if nil == thisEvent.kWs then
					thisEvent.kWs = {thisEvent.kW}
				end
				
				local anchorInfo = anchorDecode(thisEvent.d)
				local thisKw = ''
				for idx = 1,#anchorInfo.solarDatesList do
					local subEvent = {}
					subEvent.c1 = thisEvent.d
					subEvent.c2 = thisEvent.kW
					subEvent.c3 = thisEvent.c
					subEvent.kWs = thisEvent.kWs
					
					local thisSolarDate = anchorInfo.solarDatesList[idx]
					subEvent.time = dateStr2Time(thisSolarDate)
					subEvent.solarDate = thisSolarDate
					
					local tDiff = dt.timeDiff(subEvent.time)
					if tDiff.monthsDiff<-1 then
						--如果这个事件的时间点已经过去大于一个月了，则不做处理
						if dbgFlg then
							print('这个事件放弃：',subEvent.c1,thisSolarDate)
						end
					else
						--添加一个新的事件
						if nil == eventsDicBySolarDates[thisSolarDate] then
							eventsDicBySolarDates[thisSolarDate] = {subEvent}
						else
							table.insert(eventsDicBySolarDates[thisSolarDate],subEvent)
						end
						
						for subIdx = 1, #subEvent.kWs do
							thisKw = subEvent.kWs[subIdx] or ''
							if ''~=thisKw then
								if nil == eventsDicListByKeyW[thisKw] then
									--这是一个新的 kW
									eventsDicListByKeyW[thisKw] = {subEvent}
								else
									--这不是一个新的 kW
									table.insert(eventsDicListByKeyW[thisKw],subEvent)
								end
							end
						end
					end
				end
			end
		end
	end
	
	if dbgFlg then
		print("-->eventsDicBySolarDatesBuild completed here")
	end
end

--通过keyWord来获取对应的事件列表
local function getEventsByKw(kW)
	local eventsList = {}
	kW = kW or ''
	if '' == kW then
		return eventsList
	end
	
	if nil==eventsDicListByKeyW then
		eventsList = {}
	else
		eventsList = eventsDicListByKeyW[kW] or {}
	end
	
	--需要进行一个排序处理，以方便后端使用
	if #eventsList > 0 then
		--做一个排序，按time升序排列
		table.sort(eventsList,
		function(a,b)
			if a.time < b.time then
				return true
			end
			return false
		end)
	end
	
	return eventsList
end

--通过时间来获取对应的事件列表
local function getEventsByTime(t)
	local eventsList = {}
	if nil == t then
		t = os.time()
	end
	
	if nil==eventsDicBySolarDates then
		eventsList = {}
	else
		eventsList = eventsDicBySolarDates[os.date('%Y%m%d',t)]
	end
	
	return eventsList or {}
end

--===========================test========================
local function test(printPrefix)
	if nil == printPrefix then
		printPrefix = ' '
	end
	
	if dbgFlg then
		print('eventsListModule test starting...')
	end
	
	--sysInfoRes.test(printPrefix..' ')
	--lunar.test(printPrefix..' ')
	--dt.test(printPrefix..' ')
	
	for k,v in pairs(eventsDicBySolarDates) do
		if dbgFlg then
			print(printPrefix..k..'\t'..v)
		end
	end
end

function M.init(...)
	--准备日期序列，包括去年一整年，以及将来一整年的日期在内
	local daysCntThisYear = tonumber(os.date("%j"))
	lunarDatesListBuild(370+daysCntThisYear,740-daysCntThisYear)
	--创建节气表
	lunar.jqListBuild()
	
	--加载文档中的事件信息
	local files={...}
	--文件名不支持中文，其中 # 开始的行为注释行
	table.insert(files,"eventsList.txt")
	
	for i,v in next, files do
		files[i] = sysInfoRes.currentDir().."/".. v
	end
	eventsDicBySolarDatesBuild(table.unpack(files))
	
	--抛出功能函数
	M.getEventsByKw = getEventsByKw
	M.getEventsByTime = getEventsByTime
	
	M.setDbg = setDbg
	M.test = test
end

M.init()

return M