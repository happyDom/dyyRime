-- Upper_Filter.lua
-- Copyright (C) 2023 yaoyuan.dou <douyaoyuan@126.com>
-- 这个脚本，用于为英文单词提供一个首字母大写的候选项

-- 如果需要debug，可以在这里进行函数功能调试
local function _specialFunc(input, env)
	for cand in input:iter() do
		yield(cand)
	end
end

local function _upperFilter(input, env)
	local cands = {}
	local idx, idxSelf
	local selfFlg
	local candTxtLen
	
	idx = 0
	idxSelf = 0
	for cand in input:iter() do
		idx = idx + 1 --索引位置
		selfFlg = cand.comment:find('☯')
		if selfFlg then
			--自动造词数量
			idxSelf = idxSelf + 1
		end
		
		--匹配英文字母
		local s,e = string.find(cand.text,"^[a-z]+$")
		if nil == s then
			--匹配失败，说明不是英文单词
			if selfFlg then
				--对于自动造词选项，使用如下逻辑
				if idxSelf == 1 and idx == idxSelf then
					--对于第一条自动造词选项，不加干涉
					yield(cand)
				else
					--对于非第一条自动造词选项，限制其长度
					--candTxtLen = utf8.len(cand.text)
					yield(cand)
				end
			else
				--对于非自动造的词，则正常输出
				yield(cand)
			end
		else
			--匹配成功，说明是英文单词
			yield(cand)
			
			if idx == 1 then
				--如果这是第一个候选词，提供一个首字母大写的选项
				local thisTxt=cand.text:gsub("^%l",string.upper)
				yield(Candidate("word", cand.start, cand._end, thisTxt, ''))
				
				--idx额外加1
				idx = idx + 1
			end
		end
	end
end

local function upperFilter(input, env)
	--获取debug选项开关状态
	local debugSwitchSts = env.engine.context:get_option("debug")

	if debugSwitchSts then
		_specialFunc(input,env)
	else
		_upperFilter(input, env)
	end
end

return _upperFilter
