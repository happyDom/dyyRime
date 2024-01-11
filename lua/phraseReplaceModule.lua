-- phraseReplaceModule.lua
-- Copyright (C) 2023 yaoyuan.dou <douyaoyuan@126.com>

local M={}
local dict={}
local dbgFlg = false

--引入系统变更处理模块
local sysInfoEnable, sysInfo = pcall(require, 'sysInfo')

local logEnable, log = pcall(require, "runLog")
if logEnable then
	log.writeLog('')
	log.writeLog('log from phraseReplaceModule.lua')
	log.writeLog('sysInfoEnable:'..tostring(sysInfoEnable))
end

local currentDir = sysInfo.currentDir
local userName = sysInfo.userName

--设置 dbg 开关
local function setDbg(flg)
	dbgFlg = flg
	sysInfo.setDbg(flg)
	
	print('phraseReplace dbgFlg is '..tostring(dbgFlg))
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
			local key,val = string.match(line,"(.+)\t(%C*)")
			if nil == key then
				key = string.match(line,'(%S+)')
				val = ''
			end
			if nil ~= key then
				--此处，如果key 已经存在，则使用后来的值顶替旧的值
				thisDict[key] = val
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
		print('phraseReplace test starting...')
		
		sysInfo.test(printPrefix..' ')
		
		for k,v in pairs(dict) do
			if dbgFlg then
				print(printPrefix..k..'\t'..v)
			end
		end
	end
end

--获取字典中的phrase
local function getShownPhrase(k)
	if nil == k then
		return ''
	elseif '' == k then
		return ''
	end
	
	--尝试获取 dictPhraseList 中 k 的列表
	return dict[k]
end

function M.init(...)
	local files={...}
	--文件名不支持中文，其中 # 开始的行为注释行
	table.insert(files,"phraseReplace.txt")
	
	for i,v in next, files do
		files[i] = currentDir().."/".. v
	end
	dict= dictload(table.unpack(files))
	
	--抛出功能函数
	M.getShownPhrase = getShownPhrase
	M.userName = userName
	M.setDbg = setDbg
	M.test = test
end

M.init()

return M