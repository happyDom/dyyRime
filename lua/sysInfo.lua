-- 导入log模块记录日志
local logEnable, log = pcall(require, "runLog")

local M={}
local dbgFlg = false

--设置 dbg 开关
M.setDbg = function(flg)
	dbgFlg = flg
	print('sysInfo dbgFlg is '..tostring(dbgFlg))
end

M.homePath = function()
	local tmpVar = os.getenv("HOMEPATH") or os.getenv("HOME")
	if nil == tmpVar then
		tmpVar = '未知'
	end
	return tmpVar
end

M.computerName = function()
	local tmpVar = os.getenv("COMPUTERNAME") or os.getenv("HOSTNAME")
	if nil == tmpVar then
		tmpVar = '未知'
	end
	return tmpVar
end

M.userName = function()
	local tmpVar = os.getenv("USERNAME") or os.getenv("USER")
	if nil == tmpVar then
		tmpVar = '未知'
	end
	return tmpVar
end

M.osName = function()
	local tmpVar = os.getenv("OS")
	if nil == tmpVar then
		tmpVar = 'UnixLike'
	end
	return tmpVar
end

M.NUMBER_OF_PROCESSORS = function()
	local tmpVar = os.getenv("NUMBER_OF_PROCESSORS")
	if nil == tmpVar then
		tmpVar = '未知'
	end
	return tmpVar
end

M.pwd = function()
	local tmpVar = os.getenv("PWD")
	if nil == tmpVar then
		tmpVar = '未知'
	end
	return tmpVar
end

M.oldPwd = function()
	local tmpVar = os.getenv("OLDPWD")
	if nil == tmpVar then
		tmpVar = '未知'
	end
	return tmpVar
end

M.PROCESSOR_IDENTIFIER = function()
	local tmpVar = os.getenv("PROCESSOR_IDENTIFIER")
	if nil == tmpVar then
		tmpVar = '未知'
	end
	return tmpVar
end

M.PROGRAMDATA = function()
	local tmpVar = os.getenv("PROGRAMDATA")
	if nil == tmpVar then
		tmpVar = '未知'
	end
	return tmpVar
end

M.PROGRAMFILES = function()
	local tmpVar = os.getenv("PROGRAMW6432")
	if nil == tmpVar then
		tmpVar = '未知'
	end
	return tmpVar
end
M.PROGRAMFILESx86 = function()
	local tmpVar = os.getenv("PROGRAMFILES(X86)")
	if nil == tmpVar then
		tmpVar = '未知'
	end
	return tmpVar
end

M.APPDATA = function()
	local tmpVar = os.getenv("APPDATA(X86)")
	if nil == tmpVar then
		tmpVar = '未知'
	end
	return tmpVar
end

M.WINDIR = function()
	local tmpVar = os.getenv("WINDIR")
	if nil == tmpVar then
		tmpVar = '未知'
	end
	return tmpVar
end

M.COMMONPROGRAMFILES = function()
	local tmpVar = os.getenv("COMMONPROGRAMFILES")
	if nil == tmpVar then
		tmpVar = '未知'
	end
	return tmpVar
end

M.COMMONPROGRAMFILESx86 = function()
	local tmpVar = os.getenv("COMMONPROGRAMFILES(x86)")
	if nil == tmpVar then
		tmpVar = '未知'
	end
	return tmpVar
end

M.TEMP = function()
	local tmpVar = os.getenv("TEMP")
	if nil == tmpVar or '' == tmpVar then
		tmpVar = os.getenv("TMP")
	end
	
	if nil == tmpVar then
		tmpVar = '未知'
	end
	return tmpVar
end

M.SYSTEMDRIVE = function()
	local tmpVar = os.getenv("SYSTEMDRIVE")
	if nil == tmpVar then
		tmpVar = '未知'
	end
	return tmpVar
end

M.currentDir = function()
	local info = debug.getinfo(2) --debug.getinfo(2), 2: 返回调用 currentDir 的函数的信息
	
	--解析info.source所在的路径
	local path = info.source
	path = string.sub(path, 2, -1) -- 去掉开头的"@"
	path = string.gsub(path,'\\','/') -- 路径格式由 c:\\Users\\san.zhang\\ 转换为 c:/Users/san.zhang/
	path = string.match(path, "^(.*)/") -- 捕获最后一个 "/" 之前的部分 就是我们最终要的目录部分
	
	return path
end

M.writeLog = function(printPrefix)
	printPrefix = printPrefix or ''
	
	if logEnable then
		log.writeLog(printPrefix..'homePath: '..M.homePath())
		log.writeLog(printPrefix..'computerName: '..M.computerName())
		log.writeLog(printPrefix..'userName: '..M.userName())
		log.writeLog(printPrefix..'osName: '..M.osName())
		log.writeLog(printPrefix..'pwd: '..M.pwd())
		log.writeLog(printPrefix..'oldPwd: '..M.oldPwd())
		log.writeLog(printPrefix..'numberOfProcessors: '..M.NUMBER_OF_PROCESSORS())
		log.writeLog(printPrefix..'progressorIdentifier: '..M.PROCESSOR_IDENTIFIER())
		log.writeLog(printPrefix..'programData: '..M.PROGRAMDATA())
		log.writeLog(printPrefix..'programFiles: '..M.PROGRAMFILES())
		log.writeLog(printPrefix..'programFilesx86: '..M.PROGRAMFILESx86())
		log.writeLog(printPrefix..'appData: '..M.APPDATA())
		log.writeLog(printPrefix..'winDir: '..M.WINDIR())
		log.writeLog(printPrefix..'commonProgramFiles: '..M.COMMONPROGRAMFILES())
		log.writeLog(printPrefix..'commonProgramFilesx86: '..M.COMMONPROGRAMFILESx86())
		log.writeLog(printPrefix..'temp: '..M.TEMP())
		log.writeLog(printPrefix..'systemDrive: '..M.SYSTEMDRIVE())
		log.writeLog(printPrefix..'currentDir: '..M.currentDir())
	end
end

return M