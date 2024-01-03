-- spaceAppending.lua
-- Copyright (C) 2023 yaoyuan.dou <douyaoyuan@126.com>
local ok, res = pcall(require, 'dic_4w')
local getVal = res.getVal

local ok, utf8String = pcall(require, 'utf8String')

--最长的comment长度限制
local maxLenOfComment = 100

local function dic_4w_Filter(input, env)
	--获取中英对照开关状态
	local on = env.engine.context:get_option("encnDic")
	
	for cand in input:iter() do
		if on then
			local candTxt = cand.text:gsub("%s","") or ""
			local thisComment = cand.comment
			
			if candTxt ~= "" then
				--获取字典释义
				thisComment = getVal(candTxt)
				if nil == thisComment then
					thisComment = cand.comment
				else
					--成功获取了释义，下面进行一些格式化处理
					--替换 <br> 为换行符
					thisComment = thisComment:gsub("<br>","\r")
					--替换 &nbsp 为空格
					thisComment = thisComment:gsub("&nbsp"," ")
					--需要限制释义长度为 maxLenOfComment
					thisComment = string.sub(thisComment, 1, maxLenOfComment)
					--去除首尾空格 和 符号
					thisComment = utf8String.utf8PunctuationsTrim(thisComment)
				end
				if cand.comment ~= "" then
					if thisComment ~= cand.comment then
						if utf8.len(cand.comment) < 5 then
							if '💡'==cand.comment then
								thisComment = cand.comment..thisComment
							else
								thisComment = cand.comment..'✔'..thisComment
							end
						else
							thisComment = cand.comment..'\r'..thisComment
						end
					end
				end
			end
			cand:get_genuine().comment = thisComment
		end
		yield(cand)
	end
end

return dic_4w_Filter
