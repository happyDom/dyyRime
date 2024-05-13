-- phraseComment_Filter.lua
-- Copyright (C) 2023 yaoyuan.dou <douyaoyuan@126.com>
-- 这个滤镜的作用，是在候选项列表中出现关键字时，将对应的注释内容添加到该候选词条上

local dbgFlg = false
--comment单行最长长度限制
local maxLenOfComment = 150

local logEnable, log = pcall(require, 'runLog')

local phraseCommentModuleEnable, phraseCommentModule = pcall(require, 'phraseComment_Module')

--引入 utf8String 处理字符串相关操作
local utf8StringEnable, utf8String = pcall(require, 'utf8String')

if logEnable then
	log.writeLog('')
	log.writeLog('log from phraseComment_Filter.lua:')
	log.writeLog('phraseCommentModuleEnable:'..tostring(phraseCommentModuleEnable))
	log.writeLog('utf8StringEnable:'..tostring(utf8StringEnable))
end

local utf8Split = utf8String.utf8Split
local utf8Sub = utf8String.utf8Sub
local utf8Len = utf8String.utf8Len
local utf8PunctuationsTrim = utf8String.utf8PunctuationsTrim
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
				else
					--需要限制释义长度为 maxLenOfComment
					if nil == string.find(thisComment,"<br>") then
						--注释中不存在换行符
						bottomLineLen = utf8Len(thisComment)
						thisComment = utf8Sub(thisComment, 1, maxLenOfComment)
					else
						--注释中存在换行符
						local subStrList = utf8Split(thisComment,"<br>","$")
						local subStrTrimedList = {}
						for idx=1,#subStrList do
							bottomLineLen = utf8Len(subStrList[idx])
							if bottomLineLen > maxLenOfComment then
								table.insert(subStrTrimedList,utf8Sub(subStrList[idx], 1, maxLenOfComment).."...")
							else
								table.insert(subStrTrimedList,subStrList[idx])
							end
						end
						
						thisComment = table.concat(subStrTrimedList,"<br>")
					end
					
					--去除首尾空格 和 符号
					thisComment = utf8PunctuationsTrim(thisComment)
					if bottomLineLen > maxLenOfComment then
						thisComment = thisComment.."..."
					end
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
