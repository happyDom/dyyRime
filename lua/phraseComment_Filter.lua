-- phraseComment_Filter.lua
-- Copyright (C) 2023 yaoyuan.dou <douyaoyuan@126.com>
-- 这个滤镜的作用，是在候选项列表中出现关键字时，将对应的注释内容添加到该候选词条上

local dbgFlg = false

local logEnable, log = pcall(require, 'runLog')

local phraseCommentModuleEnable, phraseCommentModule = pcall(require, 'phraseComment_Module')

if logEnable then
	log.writeLog('')
	log.writeLog('log from phraseComment_Filter.lua:')
	log.writeLog('phraseCommentModuleEnable:'..tostring(phraseCommentModuleEnable))
end

local getVal = phraseCommentModule.getVal

local function phraseComment_Filter(input, env)
	--获取选项评论开关状态
	local on = env.engine.context:get_option("phraseComment")
	
	for cand in input:iter() do
		if on then
			local candTxt = cand.text or ""
			local thisComment = cand.comment
			local bottomLineLen = 0
			
			if candTxt ~= "" then
				--获取字典释义
				thisComment = getVal(candTxt)
				if nil == thisComment then
					thisComment = cand.comment
				end
				
				if cand.comment ~= "" then
					if thisComment ~= cand.comment then
						if utf8.len(cand.comment) < 5 then
							if '💡' == cand.comment then
								thisComment = cand.comment..thisComment
							else
								thisComment = cand.comment..'✔'..thisComment
							end
						else
							thisComment = cand.comment..'<br>💡'..thisComment
						end
					end
				end
			end
			cand:get_genuine().comment = thisComment
		end
		yield(cand)
	end
end

return phraseComment_Filter
