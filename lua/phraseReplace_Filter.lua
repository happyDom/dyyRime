-- phraseReplace_Filter.lua
-- Copyright (C) 2023 yaoyuan.dou <douyaoyuan@126.com>
--[[
这个过滤器的主要作用是，对于候选项中命中的选项(OR 内容)，用其指定的内容来代替，如果没有指定，则使用 * 替换
由于这个过滤器会改变候选项的内容（主要是会减少候选项数量），所以请将这个过滤器放在其它过滤器的最前端使用
]]
local phraseReplaceModuleEnable, phraseReplaceModule = pcall(require, 'phraseReplaceModule')

local logEnable, log = pcall(require, "runLog")
if logEnable then
	log.writeLog('')
	log.writeLog('log from phraseReplace_Filter.lua')
	log.writeLog('phraseReplaceModuleEnable:'..tostring(phraseReplaceModuleEnable))
end

local getShownPhrase = phraseReplaceModule.getShownPhrase

local phraseShown = ''
--最长的comment长度限制
local maxLenOfComment = 250

local function phraseReplace_Filter(input, env)
	--获取选项敏感词替换开关状态
	local on = env.engine.context:get_option("phraseReplace")
	local candsHasBeenHidden = {}
	local candStart,candEnd
	
	for cand in input:iter() do
		candStart = cand.start
		candEnd = cand._end
		
		local candTxt = cand.text:gsub("%s","") or ""
		
		phraseShown = getShownPhrase(candTxt)
		
		if nil ~= phraseShown then
			--不管是否开启选项替换，如果该选项是被命中的替换项，则加上替换标记 👙
			cand.comment = '👙'..cand.comment
			if '' ~= phraseShown then
				if on then
					--如果开启了选项替换功能，且存在替换内容
					yield(Candidate("word", cand.start, cand._end, phraseShown, cand.comment))
				else
					--如果未开启选项替换功能
					yield(cand)
				end
			else
				if on then
					--如果开启了选项替换功能，且这个选项应该被隐藏
					table.insert(candsHasBeenHidden,candTxt)
				else
					--如果未开启选项替换功能
					yield(cand)
				end
			end
		else
			yield(cand)
		end
	end
	
	--如果有被隐藏的选项，则抛出一个 * 选项提示
	if 0 < #candsHasBeenHidden then
		yield(Candidate("word", candEnd-1, candEnd, '*', '👙'))
	end
end

return phraseReplace_Filter
