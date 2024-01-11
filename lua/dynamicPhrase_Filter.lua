--[[
Descripttion: 
version: 
Author: douyaoyuan
Date: 2023-06-01 08:48:23
LastEditors: douyaoyuan
LastEditTime: 2023-06-09 13:27:57
--]]
--dynamicPhrase_Filter.lua
--Copyright (C) 2023 yaoyuan.dou <douyaoyuan@126.com>
--本脚本主要用于提供一些与运行环境有关的词条信息

--引入支持模块
local GUIDEnable, GUID = pcall(require, 'GUID')
local sysInfoEnable, sysInfo = pcall(require, 'sysInfo')
local socketEnable, socket = pcall(require, "socket")
local utf8StrEnable, utf8Str = pcall(require, 'utf8String')

if socketEnable then
	socketEnable = socket.socketEnable
	socket = socket.socket
end

local logEnable, log = pcall(require, "runLog")
if logEnable then
	log.writeLog('')
	log.writeLog('log from dynamicPhrase_Filter.lua')
	log.writeLog('GUIDEnable:'..tostring(GUIDEnable))
	log.writeLog('sysInfoEnable:'..tostring(sysInfoEnable))
	log.writeLog('socketEnable:'..tostring(socketEnable))
	log.writeLog('utf8StrEnable:'..tostring(utf8StrEnable))
end

local cands
local theCands
local candTxt_lower
local thisTxt
local thisComment

local function Filter(input, env)
	cands={}
	
	for cand in input:iter() do
		--抛出原选项
		if nil == cands[cand.text] then
			yield(cand)
			cands[cand.text]=true
		end

		theCands={}
		if true then
			candTxt_lower = cand.text:lower()
			
			if ({['id']=true,['标识']=true})[candTxt_lower] then
				--添加选项
				if GUIDEnable then
					local guidInfo = GUID.guidInfo()

					table.insert(theCands,{guidInfo.noPunctuations,'💡GUID'})
					table.insert(theCands,{guidInfo.guid,'💡GUID'})
					table.insert(theCands,{guidInfo.withUnderline,'💡GUID'})
				end
			elseif ({['电脑']=true,['系统']=true,['本机']=true})[candTxt_lower] then
				if sysInfoEnable then
					--添加选项
					if ({['电脑']=true,['本机']=true})[candTxt_lower] then
						local computerName = sysInfo.computerName()
						if '未知' ~= computerName then
							table.insert(theCands,{computerName,'💡电脑名'})
						end
						
						local cpu = sysInfo.PROCESSOR_IDENTIFIER()
						if '未知' ~= cpu then
							table.insert(theCands,{cpu,'💡CPU'})
						end
						
						local coreCnt = sysInfo.NUMBER_OF_PROCESSORS()
						if '未知' ~= coreCnt then
							table.insert(theCands,{coreCnt..'核','💡Core'})
						end
					end
					table.insert(theCands,{sysInfo.osName(),'💡系统'})
				end
			elseif ({['ip']=true})[candTxt_lower] then
				if socketEnable then
					--添加选项
					local ip = socket.dns.toip(socket.dns.gethostname())
					if ip then
						table.insert(theCands,{ip,'💡ipv4'})
					end
					
					local addrinfo = socket.dns.getaddrinfo(socket.dns.gethostname(), nil, {family = "inet6"})
					if addrinfo then
	 					for _, info in ipairs(addrinfo) do
							if info.family == "inet6" then
								table.insert(theCands,{info.addr,'💡ipv6'})
							end
	 					end
					end
				end
			elseif ({['用户']=true,['路径']=true})[candTxt_lower] then
				if sysInfoEnable then
					--添加选项
					if ({['用户']=true})[candTxt_lower] then
						local userName = sysInfo.userName()
						if '未知' ~= userName then
							table.insert(theCands,{userName,'💡用户名'})
						end
						local homePath = sysInfo.homePath()
						if '未知' ~= homePath then
							table.insert(theCands,{homePath,'💡用户路径'})
						end
					end
					if ({['路径']=true})[candTxt_lower] then
						local WINDIR = sysInfo.WINDIR()
						if '未知' ~= sysInfo.WINDIR() then
							table.insert(theCands,{WINDIR,'💡WINDIR'})
						end
						
						local homePath = sysInfo.homePath()
						if '未知' ~= homePath then
							table.insert(theCands,{homePath,'💡用户路径'})
						end
						
						local pwd = sysInfo.pwd()
						if '未知' ~= pwd then
							table.insert(theCands,{pwd,'💡pwd'})
						end
						
						local oldPwd = sysInfo.oldPwd()
						if '未知' ~= oldPwd then
							table.insert(theCands,{oldPwd,'💡oldPwd'})
						end
						
						local PROGRAMDATA = sysInfo.PROGRAMDATA()
						if '未知' ~= PROGRAMDATA then
							table.insert(theCands,{PROGRAMDATA,'💡PROGRAMDATA'})
						end
						
						local PROGRAMFILES = sysInfo.PROGRAMFILES()
						if '未知' ~= PROGRAMFILES then
							table.insert(theCands,{PROGRAMFILES,'💡PROGRAMFILES'})
						end
						
						local PROGRAMFILESx86 = sysInfo.PROGRAMFILESx86()
						if '未知' ~= PROGRAMFILESx86 then
							table.insert(theCands,{PROGRAMFILESx86,'💡PROGRAMFILES(x86)'})
						end
						
						local COMMONPROGRAMFILESx86 = sysInfo.COMMONPROGRAMFILESx86()
						if '未知' ~= COMMONPROGRAMFILESx86 then
							table.insert(theCands,{COMMONPROGRAMFILESx86,'💡COMMONPROGRAMFILES(x86)'})
						end
						
						local TEMP = sysInfo.TEMP()
						if '未知' ~= TEMP then
							table.insert(theCands,{TEMP,'💡TEMP'})
						end
						
						local APPDATA = sysInfo.APPDATA()
						if '未知' ~= APPDATA then
							table.insert(theCands,{APPDATA,'💡APPDATA'})
						end
					end
				end
			elseif ({['随机']=true, ['密码']=true})[candTxt_lower] then
				if '随机' == candTxt_lower then
					--添加选项，返回一个随机数
					table.insert(theCands,{math.random(),'💡0-1伪随机数'})
				end
				if utf8StrEnable then
					table.insert(theCands, {utf8Str.newPwd(6), '💡6位随机密码'})
					table.insert(theCands, {utf8Str.newPwd(8), '💡8位随机密码'})
					table.insert(theCands, {utf8Str.newPwd(10, false), '💡10位随机密码'})
					table.insert(theCands, {utf8Str.newPwd(14), '💡14位随机密码'})
					table.insert(theCands, {utf8Str.newPwd(16), '💡16位随机密码'})
					table.insert(theCands, {utf8Str.newPwd(18), '💡18位随机密码'})
				end
			end
		end
		
		--抛出选项
		for idx = 1, #theCands do
			thisTxt = theCands[idx][1]
			thisComment = theCands[idx][2]
			
			if nil ~= thisTxt and '' ~= thisTxt then
				if nil == cands[thisTxt] then
					yield(Candidate("word", cand.start, cand._end, thisTxt, thisComment))
					cands[thisTxt] = true
				end
			end
		end
	end
end

return Filter
