--lua语言中的注释用“--”
--[[
pinyin_translator.lua
-- Copyright (C) 2023 yaoyuan.dou <douyaoyuan@126.com>
这是一个lua translator 翻译器，负责将用户输入的拼音生成带有声调的拼音，例如 pīn yīn
]]

local logEnable, log = pcall(require, "runLog")
if logEnable then
	log.writeLog('')
	log.writeLog('log from pinyin_translator.lua')
end

local a = {'ā','á','ǎ','à','a'}
local o = {'ō','ó','ǒ','ò','o'}
local e = {'ē','é','ě','è','e'}
local i = {'ī','í','ǐ','ì','i'}
local u = {'ū','ú','ǔ','ù','u'}
local v = {'ǖ','ǘ','ǚ','ǜ','ü'}
local iu = {'iū','iú','iǔ','iù','iu'}
local ui = {'uī','uí','uǐ','uì','ui'}

local aoeListDict = {['a']=a,
					['o']=o,
					['e']=e,
					['i']=i,
					['u']=u,
					['ü']=v,
					['iu']=iu,
					['ui']=ui}

local aoeList = {'a','o','e','ui','iu','i','u','ü'}

function translator(input, seg)
	local inputStr = input
	
	inputStr = string.gsub(inputStr,'jv','ju')
	inputStr = string.gsub(inputStr,'qv','qu')
	inputStr = string.gsub(inputStr,'xv','xu')
	inputStr = string.gsub(inputStr,'yv','yu')
	inputStr = string.gsub(inputStr,'v','ü')
	
	-- 遍历检查韵母, 找到对应的 aoeKey 值
	local aoeKey = ''
	for j,aoeK in ipairs(aoeList) do
		if string.match(inputStr,'.*'..aoeK..'.*') then
			aoeKey = aoeK
			break
		end
	end
	
	-- 如果没有 aoeKey，则在input后面加入一个 a，以提供有效的拼音选项
	if '' == aoeKey then
		if string.find(inputStr,'[a-z]') then
			aoeKey = 'a'
			inputStr = inputStr ..'a'
		end
	end
	
	if '' == aoeKey then
		yield(Candidate("pinyin", seg.start, seg._end,input,''))
	else
		--这个 aoeK 存在于 input 中，则将 input 中第一个 aoeK 替换成对应的注音字符，然后抛出作为选项
		local aoeL = aoeListDict[aoeKey]
		for j,aoe in ipairs(aoeL) do
			yield(Candidate("pinyin", seg.start, seg._end,string.gsub(inputStr,aoeKey,aoe,1),''))
			if 4 == j and false then
			-- 如果这是第四个选项（四声），则填充5个None选项,目的是为了使轻声出现在序号为 0 的位置, 如果你希望这样，请将判定中的 false 改为true
				for kk=5,9 do
					yield(Candidate("pinyin", seg.start, seg._end,'None'..tostring(kk),''))
				end
			end
			
			if 4 == j and true then
			--是否输出轻声选项，如果不想输出轻声选项（如果拼音中不包含 v，轻声可以通过 Enter 键直接将字母上屏即可），请保持判断条件为true
				if string.find(input,'v') < 1 then
				--如果确实没有 v 的存在，则可以跳过轻声选项
					break
				end
			end
		end
	end
end

return translator
