-- pinyinAddingModule.lua
-- Copyright (C) 2023 yaoyuan.dou <douyaoyuan@126.com>

local M={}
local dict={}
local dbgFlg = true

--引入系统变更处理模块
local ok, sysInfoRes = pcall(require, 'sysInfo')
local currentDir = sysInfoRes.currentDir
local userName = sysInfoRes.userName
--引入utf8String，用于处理utf8字符串
local of,utf8Str = pcall(require, 'utf8String')
local utf8Sub = utf8Str.utf8Sub
local utf8Len = utf8Str.utf8Len

--设置 dbg 开关
local function setDbg(flg)
	dbgFlg = flg
	sysInfoRes.setDbg(flg)
	
	print('pinyinAddingModule dbgFlg is '..tostring(dbgFlg))
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

local function dictload(...) -- filename)
	if dbgFlg then
		print("-->dictload called here")
	end
	
	local lines=files_to_lines(...)
	local thisDict={}
	
	for i,line in next ,lines do
		if not line:match("^%s*#") then  -- 第一字 # 为注释行
			local key,val = string.match(line,"(.+)\t(%C+)")
			if nil ~= key then
				--此处，如果key 已经存在，则使用后来的值顶替旧的值
				if ''~=val then
					thisDict[key] = val
				end
			end
		end
	end
	
	if dbgFlg then
		print("-->dictload completed here")
	end
	return thisDict
end

--===========================test========================
local function test(printPrefix)
	if nil == printPrefix then
		printPrefix = ' '
	end
	if dbgFlg then
		print(printPrefix,'pinyinAddingModule test starting...')
		
		sysInfoRes.test(printPrefix..' ')
		
		for k,v in pairs(dict) do
			if dbgFlg then
				print(printPrefix..k..'\t'..v)
			end
		end
	end
end

--这是一个递归函数，用于在给定的字符串中查找最大能匹配的子串
local function getItmInDicByStr(Str)
	Str = Str or ''
	if ''==Str then
		--返回子串值，匹配值，匹配长度
		return '','',0
	end
	local itmKey,itmLen,itmVal,strLen,flg
	strLen = utf8Len(Str)
	flg=false
	
	for idx=strLen,1,-1 do
		itmKey = utf8Sub(Str,1,idx)
		if''~=itmKey then
			itmVal = dict[itmKey]
			if nil~=itmVal then
				itmLen = idx
				flg = true
				break
			end
		end
	end
	
	if flg then
		return itmKey,itmVal,itmLen
	else
		return '','',0
	end
end

local function pinyinAdding(k)
	k = k or ''
	if ''==k then
		return k
	end
	
	local valStr,kLen
	local subK,subKVal,subKLen
	local matchPosition
	
	valStr = ''
	kLen = utf8Len(k)
	matchPosition = 1
	while matchPosition <= kLen do
		subK,subKVal,subKLen = getItmInDicByStr(utf8Sub(k,matchPosition,kLen))
		
		if ''==subK then
			valStr = valStr..utf8Sub(k,matchPosition,1)
			matchPosition = matchPosition + 1
		else
			valStr =valStr..subKVal
			matchPosition = matchPosition + subKLen
		end
	end
	
	return valStr
end

function M.init(...)
	local files={...}
	--文件名不支持中文，其中 # 开始的行为注释行
	table.insert(files,"pinyinAdding.txt")
	
	for i,v in next, files do
		files[i] = currentDir().."/".. v
	end
	dict= dictload(table.unpack(files))
	
	--抛出功能函数
	M.pinyinAdding = pinyinAdding
	M.pinyinAddingT = pinyinAdding
	M.setDbg = setDbg
	M.test = test
end

M.init()

return M