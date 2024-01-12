-- pinyin_Filter.lua
-- Copyright (C) 2023 yaoyuan.dou <douyaoyuan@126.com>
--[[
这个过滤器的主要作用是，在拼音候选词组的尾部，增加一个空格
]]

local logEnable, log = pcall(require, "runLog")
if logEnable then
	log.writeLog('')
	log.writeLog('log from pinyin_Filter.lua')
end

local function pinyin_Filter(input, env)
	--获取选项space(空格)开关状态
	local spaceSwitchFlg = env.engine.context:get_option("space") or false
	
	for cand in input:iter() do
		if spaceSwitchFlg then
			yield(Candidate("word", cand.start, cand._end, cand.text..' ', cand.comment))
		else
			yield(cand)
		end
	end
end

return pinyin_Filter
