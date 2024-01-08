-- phraseReplace_Filter.lua
-- Copyright (C) 2023 yaoyuan.dou <douyaoyuan@126.com>
--[[
这个过滤器的主要作用是，对于候选项中命中的选项(OR 内容)，用其指定的内容来代替，如果没有指定，则使用 * 替换
由于这个过滤器会改变候选项的内容（主要是会减少候选项数量），所以请将这个过滤器放在其它过滤器的最前端使用
]]
local phraseShown = ''

local ok, py = pcall(require, 'pinyinAddingModule')

--最长的comment长度限制
local maxLenOfComment = 250

local function pinyinAdding(input, env)
	--获取选项pinyin开关状态
	local pySwitchFlg = env.engine.context:get_option("pinyin") or false
	--如果pySwitchFlg是true状态，则替换原选项，如果是false状态，则在comment中注音
	local pyInCommentFlg = true
	if pySwitchFlg then
		pyInCommentFlg = false
	end
	for cand in input:iter() do
		local txtWithPy = py.pinyinAdding(cand.text)
		if nil == txtWithPy then
			--没有获取到 txtWithPy，则不做处理
			yield(cand)
		elseif txtWithPy == cand.text then
			--txtWithPy 与 原候选词一致，则不做处理
			yield(cand)
		else
			--获取到了 txtWithPy,且不与原候选词一致
			if pyInCommentFlg or string.find(cand.comment,'☯') then
				--如果需要加到comment里，或者这是一个自造词，为了不影响自造词功能，也需要加到commnet里
				if ''==cand.comment then
					cand:get_genuine().comment = txtWithPy
				else
					if utf8.len(cand.comment) < 5 then
						cand:get_genuine().comment = cand.comment..'✔'..txtWithPy
					else
						cand:get_genuine().comment = cand.comment..'\r✔'..txtWithPy
					end
				end
				yield(cand)
			else
				--如果不加到comment，则替换原选项，注意，替换原选项，会影响自动调频功能
				cand.text = txtWithPy
				if cand.text == txtWithPy then
					yield(cand)
				else
					yield(Candidate("word", cand.start, cand._end, txtWithPy, cand.comment))
				end
			end
		end
	end
end

return pinyinAdding
