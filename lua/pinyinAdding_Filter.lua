-- pinyinAdding_Filter.lua
-- Copyright (C) 2023 yaoyuan.dou <douyaoyuan@126.com>
--[[
这个过滤器的主要作用是，逐一检查候选项中的组词，如果在pinyinAddingModule中发现所检察的词组存在有注音记录，则添加其注音信息
]]
local pinyinAddingModuleEnable, pinyinAddingModule = pcall(require, 'pinyinAddingModule')

local logEnable, log = pcall(require, "runLog")
if logEnable then
	log.writeLog('')
	log.writeLog('log from pinyinAdding_Filter.lua')
	log.writeLog('pinyinAddingModuleEnable:'..tostring(pinyinAddingModuleEnable))
end

local phraseShown = ''

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
		local txtWithPy = pinyinAddingModule.pinyinAdding(cand.text)
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
