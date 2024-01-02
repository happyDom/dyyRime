-- spaceAppending.lua
-- Copyright (C) 2023 yaoyuan.dou <douyaoyuan@126.com>
--[[
	这个脚本，作为filter来用，需要结合inputShow的在translator阶段的处理信息进行工作
--]]
local function _inputShow(input, env)
	local cands = {}
	local candsSelflg=false
	local candsInput = {}
	local inputInfo = {str='',len=0,flg=false,candsCntLimitForLen={15,25}}
	local candsCnt = 0
	
	for cand in input:iter() do
		if cand.comment == 'inputShowStr' then
			--这个选项表明了前端的输入编码信息
			inputInfo.str = string.sub(cand.text,4)
			inputInfo.len = string.len(inputInfo.str)
		elseif cand.comment == 'inputShow' then
			--这是一个转换后需要展示的选项
			inputInfo.flg = true
			
			local thisCand = {}
			thisCand.start = cand.start
			thisCand._end = cand._end
			thisCand.text = cand.text
			thisCand.comment = cand.comment
			
			table.insert(candsInput,cand)
			candsCnt = candsCnt + 1
		else
			--这是一个没有转换的选项
			table.insert(cands,cand)
			
			if string.find(cand.comment,'☯') then
				--标记选项中存在自造词
				candsSelflg = true
			end
			
			candsCnt = candsCnt + 1
		end
		
		if inputInfo.flg and 0~=inputInfo.len then
			--如果已经捕获取了inputShow选项
			--根据输入的编码的长度，判断候选项数量是否已经够用
			if nil~=inputInfo.candsCntLimitForLen[inputInfo.len] then
				if candsCnt >= inputInfo.candsCntLimitForLen[inputInfo.len] then
					break
				end
			end
		end
	end
	
	if 0==inputInfo.len then
		inputInfo.flg = false
	end
	
	local candsHasBeenYield=0
	
	--下面开始抛出候选项
	--第一步，如果存在自造词，则先抛出自造词
	local candsFor2nd = {}
	for idx=1,#cands do
		if inputInfo.flg then
			if string.find(cands[idx].comment,'☯') then
				yield(cands[idx])
				candsHasBeenYield = candsHasBeenYield + 1
			else
				table.insert(candsFor2nd,cands[idx])
			end
		else
			--如果不需要处理 inputShow，则不做处理，进行转存
			table.insert(candsFor2nd,cands[idx])
		end
	end
	
	--第二步，把编码完全项抛出，即没有comment(此处指的是编码提示的comment内容)的选项，以供优先选用
	local candsFor4th = {}
	for idx=1,#candsFor2nd do
		if inputInfo.flg then
			if candsFor2nd[idx].comment == '' then
				yield(candsFor2nd[idx])
				candsHasBeenYield = candsHasBeenYield + 1
			else
				table.insert(candsFor4th,candsFor2nd[idx])
			end
		else
			--如果不需要处理 inputShow，则不做处理，进行转存
			table.insert(candsFor4th,candsFor2nd[idx])
		end
	end
	
	--第三步，如果有的话,抛出inputShow的选项
	for idx=1,#candsInput do
		local thisC = candsInput[idx]
		--此处的comment是 inputShow,为了不为后续造成干扰，此处需要清除comment内容
		thisC:get_genuine().comment = ''
		yield(thisC)
		
		candsHasBeenYield = candsHasBeenYield + 1
	end
	
	--第四步，如果还有其它选项，则抛出其它选项
	for idx=1,#candsFor4th do
		if nil==inputInfo.candsCntLimitForLen[inputInfo.len] then
			yield(candsFor4th[idx])
		elseif candsHasBeenYield<inputInfo.candsCntLimitForLen[inputInfo.len] then
			yield(candsFor4th[idx])
		else
			break
		end
		
		candsHasBeenYield = candsHasBeenYield + 1
	end
end

local function inputShow(input, env)
	--获取debug选项开关状态
	--local debugSwitchSts = env.engine.context:get_option("debug")
	
	_inputShow(input,env)
end

return inputShow
