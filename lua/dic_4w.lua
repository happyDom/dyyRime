-- dic_4w.lua
-- Copyright (C) 2023 yaoyuan.dou <douyaoyuan@126.com>
local sysInfoEnable, sysInfo = pcall(require, 'sysInfo')
local logEnable, log = pcall(require, "runLog")
if logEnable then
	log.writeLog('')
	log.writeLog('log from dic_4w.lua')
	log.writeLog('sysInfoEnable:'..tostring(sysInfoEnable))
end

local currentDir = sysInfo.currentDir

local function files_to_lines(...)
	print("--->files_to_lines called here")
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
	
	print("--->files_to_lines completed here")
	return tab
end

local function dictload(...) -- filename)
	print("-->dictload called here")
	
	local lines=files_to_lines(...)
	local dict={}
	for i,line in next ,lines do
		if not line:match("^%s*#") then  -- 第一字 # 为注释行
			local key,val = string.match(line,"(.+)\t(%C+)")
			if nil ~= key then
				--此处，相同的key，后加载的内容将覆盖前面加载的内容
				dict[key] = val
			end
		end
	end
	
	print("-->dictload completed here")
	return dict
end

--   Module
local M={}
local dict={}
local function getVal(s)
  return dict[s]
end

function M.init(...)
	print("-> M.init called here")
	
	local files={...}
	--以下files文件的顺序，后面的内容优先级高于前面的，
	--即后面文件中同一key的value将覆盖前面文件内同一key的value
	--文件名不支持中文
	table.insert(files,"dic_4w_cn.txt")
	table.insert(files,"dic_4w_en.txt")
	
	for i,v in next, files do
		files[i] = currentDir().."/".. v
	end
	dict= dictload(table.unpack(files))
	
	M.getVal=getVal
	print("->M.init completed here")
end

M.init()

return M