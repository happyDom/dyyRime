local M={}
local dbgFlg = false

--设置 dbg 开关
M.setDbg = function(flg)
	dbgFlg = flg
	print('sysInfo dbgFlg is '..tostring(dbgFlg))
end

M.homePath = function()
	return os.getenv("HOMEPATH")
end

M.computerName = function()
	return os.getenv("COMPUTERNAME")
end

M.userName = function()
	return os.getenv("USERNAME")
end

M.osName = function()
	return os.getenv("OS")
end

M.NUMBER_OF_PROCESSORS = function()
	return os.getenv("NUMBER_OF_PROCESSORS")
end

M.PROCESSOR_IDENTIFIER = function()
	return os.getenv("PROCESSOR_IDENTIFIER")
end

M.PROGRAMDATA = function()
	return os.getenv("PROGRAMDATA")
end
M.PROGRAMFILES = function()
	return os.getenv("PROGRAMW6432")
end
M.PROGRAMFILESx86 = function()
	return os.getenv("PROGRAMFILES(X86)")
end
M.APPDATA = function()
	return os.getenv("APPDATA")
end
M.WINDIR = function()
	return os.getenv("WINDIR")
end
M.COMMONPROGRAMFILES = function()
	return os.getenv("COMMONPROGRAMFILES")
end
M.COMMONPROGRAMFILESx86 = function()
	return os.getenv("COMMONPROGRAMFILES(x86)")
end
M.TEMP = function()
	local path = os.getenv("TEMP")
	if nil == path or '' == path then
		path = os.getenv("TMP")
	end
	return path
end
M.SYSTEMDRIVE = function()
	return os.getenv("SYSTEMDRIVE")
end

M.currentDir = function()
	local info = debug.getinfo(2) --debug.getinfo(2), 2: 返回调用 currentDir 的函数的信息
	
	--解析info.source所在的路径
	local path = info.source
	path = string.sub(path, 2, -1) -- 去掉开头的"@"
	path = string.gsub(path,'\\','/') -- 路径格式由 c:\\Users\\san.zhang 转换为 c:/Users/san.zhang
	path = string.match(path, "^(.*)/") -- 捕获最后一个 "\" 之前的部分 就是我们最终要的目录部分
	
	return path
end

M.test = function(printPrefix)
	if nil == printPrefix then
		printPrefix = ' '
	end
	
	if dbgFlg then
		print(printPrefix..'sysInfo test starting...')
		
		print(printPrefix, 'currentDir is：', M.currentDir())
		print(printPrefix, 'computerName is：', M.computerName())
		print(printPrefix, 'homePath is：', M.homePath())
		print(printPrefix, 'userName is：', M.userName())
	end
end

return M