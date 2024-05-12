-- phraseComment_Filter.lua
-- Copyright (C) 2023 yaoyuan.dou <douyaoyuan@126.com>
local logEnable, log = pcall(require, 'runLog')

local phraseCommentModuleEnable, phraseCommentModule = pcall(require, 'phraseCommentModule')
local getVal = phraseCommentModule.getVal

local ok, utf8String = pcall(require, 'utf8String')

if logEnable then
	log.writeLog('')
	log.writeLog('log from phraseComment_Filter.lua:')
	log.writeLog('phraseCommentModuleEnable:'..tostring(phraseCommentModuleEnable))
end

--最长的comment长度限制
local maxLenOfComment = 150

local function phraseComment_Filter(input, env)
	--获取选项评论开关状态
	local on = env.engine.context:get_option("phraseComment")
	
	for cand in input:iter() do
		if on then
			local candTxt = cand.text or ""
			local thisComment = cand.comment
			
			--将candTxt中的 \r 反替换成 <br>, 空格反替换成&nbsp
			candTxt = candTxt:gsub("\r","<br>"):gsub(" ","&nbsp")
			
			if candTxt ~= "" then
				--获取字典释义
				thisComment = getVal(candTxt)
				if nil == thisComment then
					thisComment = cand.comment
				else
					--成功获取了释义，下面进行一些格式化处理
					local brFlg = false
					if string.find(thisComment,'<br>') then
						brFlg = true
					end
					--替换 <br> 为换行符
					if brFlg then
						thisComment = thisComment:gsub("<br>","\r")
					end
					--替换 &nbsp 为空格
					thisComment = thisComment:gsub("&nbsp"," ")
					--需要限制释义长度为 maxLenOfComment
					if brFlg then
						thisComment = string.sub(thisComment, 1, math.max(maxLenOfComment,500))
					else
						thisComment = string.sub(thisComment, 1, maxLenOfComment)
					end
					--去除首尾空格 和 符号
					thisComment = utf8String.utf8PunctuationsTrim(thisComment)
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
							thisComment = cand.comment..'\r💡'..thisComment
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
