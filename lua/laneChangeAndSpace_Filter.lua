-- laneChangeAndSpace_Filter.lua
-- Copyright (C) 2023 yaoyuan.dou <douyaoyuan@126.com>
-- 这个过滤器的作用有二：
-- 1、当候选项的候选词或者注释中出现 <br> 时，将其处理成 \r 以实现换行效果
-- 2、当候选项的候选词或者注释中出现 &nbsp 时，将其处理成空格，以实现空格效果

local dbgFlg = false

local logEnable, log = pcall(require, "runLog")
if logEnable then
	log.writeLog('')
	log.writeLog('log from laneChangeAndSpace_Filter.lua')
end

--过滤器
local function laneChangeAndSpace_Filter(input, env)
	local candTxt
	local candComment
	local candNewFlg
	
	for cand in input:iter() do
		--读取选项候选词
		candTxt = cand.text or ""
		--读取选项注释内容
		candComment = cand.comment or ""
		
		candNewFlg = false
		if nil ~= string.find(candTxt,"<br>") or nil ~= string.find(candTxt,"&nbsp") then
			-- candTxt 存在 <br> 或者 &nbsp
			candNewFlg = true
			candTxt = candTxt: gsub("<br>","\r"):gsub("&nbsp"," ")
		end
		if nil ~= string.find(candComment,"<br>") or nil ~= string.find(candComment,"&nbsp") then
			-- candComment 存在 <br> 或者 &nbsp
			candNewFlg = true
			candComment = candComment: gsub("<br>","\r"):gsub("&nbsp"," ")
		end
		
		if candNewFlg then
			yield(Candidate("word", cand.start, cand._end, candTxt, candComment))
		else
			yield(cand)
		end
	end
end

return laneChangeAndSpace_Filter
