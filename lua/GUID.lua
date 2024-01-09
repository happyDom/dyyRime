--[[
Descripttion: 
version: 
Author: douyaoyuan
Date: 2023-06-01 08:48:23
LastEditors: douyaoyuan
LastEditTime: 2023-06-01 11:12:53
--]]
--GUID.lua
--这个模块主要用于处理一些utf8字符串相关的操作

local M={}
local dbgFlg = false

--设置 dbg 开关
local function setDbg(flg)
	dbgFlg = flg
	print('GUID dbgFlg is '..tostring(dbgFlg))
end

--返回一个 GUID 字符串
function guid()
	local seed={'e','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'}
	local tb={}
	for i=1,32 do
		table.insert(tb,seed[math.random(1,16)])
	end
	local sid=table.concat(tb)
	return string.format('%s-%s-%s-%s-%s',
						string.sub(sid,1,8),
						string.sub(sid,9,12),
						string.sub(sid,13,16),
						string.sub(sid,17,20),
						string.sub(sid,21,32)
						)
end

--[[返回一个 guidInfo 结构，结构体如下：
guidInfo.guid：正常的GUID
guidInfo.noPunctuations：只包含字母和数字的GUID
guidInfo.withUnderline：分隔符是下划线的 guid
]]
function guidInfo()
	local id = {}
	local tmpId = guid()

	id.guid = tmpId
	id.noPunctuations = string.gsub(tmpId,"-","")
	id.withUnderline = string.gsub(tmpId,"-","_")

	return id
end

--这是测试函数
function test()
	local s=0
	local start_time=os.clock()
	while s<50000 do
		s=s+1
		print(s,guid())
	end
	print('execute_time='..tostring(os.clock()-start_time))
end

--Module
function M.init(...)
	M.guidInfo = guidInfo
	
	M.setDbg = setDbg
	M.test = test
end

M.init()

return M