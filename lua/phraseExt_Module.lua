-- phraseExt_Module.lua
-- Copyright (C) 2023 yaoyuan.dou <douyaoyuan@126.com>
local M={}
local dict={}
local dictPhraseList={}
local dbgFlg = false

--引入系统变更处理模块
local sysInfoEnable, sysInfo = pcall(require, 'sysInfo')

local logEnable, log = pcall(require, "runLog")
if logEnable then
	log.writeLog('')
	log.writeLog('log from phraseExt_Module.lua')
	log.writeLog('sysInfoEnable:'..tostring(sysInfoEnable))
end

local currentDir = sysInfo.currentDir

--设置 dbg 开关
local function setDbg(flg)
	dbgFlg = flg
	sysInfo.setDbg(flg)
	
	print('myPhrase dbgFlg is '..tostring(dbgFlg))
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

--将文档处理成行数组
local function files_to_lines(...)
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
	return tab
end

local function dictload(...) -- filename)
	local lines=files_to_lines(...)
	local thisDict={}
	
	for i,line in next ,lines do
		if not line:match("^%s*#") then  -- 第一字 # 为注释行
			local keys,val = string.match(line,"(.+)\t(%C+)")
			if nil ~= keys and nil ~= val then
				--尝试对关键字进行空格分割
				local keyList = stringSplit(keys,' ')
				local key=''
				for idx=1,#keyList do
					key = keyList[idx]
					if nil ~= thisDict[key] then
						--如果该key已经存在，追加在后面，注意加一个空格
						thisDict[key] = thisDict[key]..' '..val
					else
						thisDict[key] = val
					end
				end
			end
		end
	end
	return thisDict
end

--===========================test========================
local function test(printPrefix)
	if nil == printPrefix then
		printPrefix = ' '
	end
	
	if dbgFlg then
		print('myPhrase test starting...')
	end
	sysInfo.test(printPrefix..' ')
	
	for k,v in pairs(dict) do
		if dbgFlg then
			print(printPrefix..k..'\t'..v)
		end
	end
end

--获取字典中的phraseList
local function getPhraseList(k)
	if nil == k then
		return {}
	elseif '' == k then
		return {}
	end
	
	--尝试获取 dictPhraseList 中 k 的列表
	local phraseList = dictPhraseList[k]
	if nil == phraseList then
		--phraseList 获取失败，尝试获取 dict 中 k 的字符串
		local thisPhrase = dict[k]
		if nil == thisPhrase then
			--这个 k 在dict中不存在
			phraseList={}
		elseif thisPhrase == '' then
			--这个 k 在dict中是空的
			phraseList={}
		else
			--将获取的 thisPhrase 序列化到 dictPhraseList 中
			dictPhraseList[k]=stringSplit(thisPhrase,' ')
			
			--再次从 dictPhraseList 中获取 k 的序列
			phraseList = dictPhraseList[k]
		end
	end
	
	return phraseList
end

function M.init(...)
	local files={...}
	--文件名不支持中文，其中 # 开始的行为注释行
	table.insert(files,"phraseExt commonPhrase.txt")
	table.insert(files,"phraseExt esAppEmoji.txt")
	table.insert(files,"phraseExt esUnicode.txt")
	table.insert(files,"phraseExt personal.txt")
	
	for i,v in next, files do
		files[i] = currentDir().."/".. v
	end
	dict= dictload(table.unpack(files))
	
	--抛出功能函数
	M.getPhraseList = getPhraseList
	M.setDbg = setDbg
	M.test = test
end

M.init()

return M