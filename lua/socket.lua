-- socket.lua
-- Copyright (C) 2023 yaoyuan.dou <douyaoyuan@126.com>
-- 这个模块仅用于导入 socket/core.dll 模块
-- 要求本 socket.lua 文件与 socket 文件夹位于同一路径下，core.dll 文件位于socket文件夹内
-- 使用时请注意 socket/core.dll 的版本 lua程序的版本是否一致
-- 使用时请注意 x86 与 x64 的区别

-- 导入log模块记录日志
local logEnable, log = pcall(require, "runLog")

-- 定义一个模块
local M = {}

-- 获取本 socket.lua文件的路径
local current_path = string.sub(debug.getinfo(1).source, 2, string.len("/socket.lua") * -1)

local pathSpace = "\\"
if string.find(current_path,'/') then
    pathSpace = '/'
end

current_path = current_path:gsub(pathSpace..'$','')

local x86x64 = 'x86'

-- 添加 cpath 路径，以使 lua 可以找到 current_path 路径下的 dll 库
local cpath = "\\luaSocket\\x86\\lua5.4\\?.dll"  -- 引入 x86 lua54 版 socket.core

if 'Lua 5.3' == _VERSION then
	cpath = string.gsub(cpath, 'Lua 5.4', 'Lua 5.3')  -- 调整版本
else if 'Lua 5.2' == _VERSION then
	cpath = string.gsub(cpath, 'Lua 5.4', 'Lua 5.2')  -- 调整版本
end

if 'x64' == x86x64 then
	cpath = string.gsub(cpath, 'x86', 'x64')  -- 调整为 x64 版
end

package.cpath = package.cpath..';'..current_path..cpath

local socketEnable, socket = pcall(require, "socket.core") -- 加载socket库

M.socketEnable = socketEnable
M.socket = socket

if logEnable then
	log.writeLog('')
	log.writeLog('log from socket.lua:')
	log.writeLog('logEnable:'..tostring(socketEnable))
	if not socketEnable then
		log.writeLog('_VERSION: '.._VERSION)
		log.writeLog('package.cpath: '..package.cpath)
        log.writeLog(socket)
    end
end

return M