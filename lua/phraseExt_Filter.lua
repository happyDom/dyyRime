-- phraseExt_Filter.lua
-- Copyright (C) 2023 yaoyuan.dou <douyaoyuan@126.com>
local dbgFlg = false

local phraseExt_ModuleEnable, phraseExt_Module = pcall(require, 'phraseExt_Module')

local logEnable, log = pcall(require, "runLog")
if logEnable then
	log.writeLog('')
	log.writeLog('log from phraseExt_Filter.lua')
	log.writeLog('phraseExt_ModuleEnable:'..tostring(phraseExt_ModuleEnable))
end

local getPhraseList = phraseExt_Module.getPhraseList

--最长的comment长度限制
local maxLenOfComment = 250

--设置 dbg 开关
local function setDbg(dbgFlg)
	phraseExt_Module.setDbg(dbgFlg)
end

--过滤器
local function phraseExt_Filter(input, env)
	--获取选项增强开关状态
	local on = env.engine.context:get_option("phraseExt")
	--获取应用程序标记状态[由于飞书暂不支持文本转表情的输入，帮使用 and false 将其关闭]
	local feishuFlg = env.engine.context:get_option("feishuFlg") and false
	local wechatFlg = env.engine.context:get_option("wechatFlg")
	local qqFlg = env.engine.context:get_option("qqFlg")
	local dingdingFlg = env.engine.context:get_option("dingdingFlg")
	local minttyFlg = env.engine.context:get_option("minttyFlg")
	local cmdFlg = env.engine.context:get_option("cmdFlg")
	local pycharmFlg = env.engine.context:get_option("pycharmFlg")
	local vscodeFlg = env.engine.context:get_option("vscodeFlg")
	local matchedTxt = ''
	local esType = ''
	local esTxt = ''
	
	local cands={}
	local thisTxt
	
	for cand in input:iter() do
		--提交默认选项
		if nil == cands[cand.text] then
			yield(cand)
			cands[cand.text]=true
		end
		if on then
			local candTxt = cand.text:gsub("%s","") or ""
			
			if candTxt ~= "" then
				--获取增强选项
				local phraseList = getPhraseList(candTxt)
				if #phraseList > 0 then
					local idx
					for idx=1,#phraseList do
						thisTxt=phraseList[idx]
						
						if nil == cands[thisTxt] then
							cands[thisTxt]=true
							
							esType,esTxt = string.match(thisTxt,"^es(.+)(%[.+%])$")
							if nil ~= esType then
								esType = string.lower(esType)

								--这是一个表情选项
								if feishuFlg and nil ~= string.find(esType,'fs') then
									--这是一个 feishu 表情，且当前在 feishu 中输入
									if nil ~= esTxt then
										yield(Candidate("word", cand.start, cand._end, esTxt, '😃'))
									end
								elseif wechatFlg and nil ~= string.find(esType,'wx') then
									--这是一个 wechat 表情，且当前在 wechat 中输入
									if nil ~= esTxt then
										yield(Candidate("word", cand.start, cand._end, esTxt, '😃'))
									end
								elseif qqFlg and nil ~= string.find(esType,'qq') then
									--这是一个 QQ 表情，且当前在 QQ 中输入
									if nil ~= esTxt then
										yield(Candidate("word", cand.start, cand._end, esTxt, '😃'))
									end
								elseif dingdingFlg and nil ~= string.find(esType,'dt') then
									--这是一个 dingtalk 表情，且当前在 钉钉 中输入
									if nil ~= esTxt then
										yield(Candidate("word", cand.start, cand._end, esTxt, '😃'))
									end
								end
							else
								--这不是一个表情选项
								if string.lower(string.sub(thisTxt, 1, 4)) == 'git-' then
									-- 这是一个以 git 开头的选项，这被认为是一个 git 命令
									if minttyFlg or cmdFlg then
										-- 修剪选项
										thisTxt = string.sub(thisTxt, 5)

										-- git 命令选项只在 cmd 窗口或者是 mitty 窗口才允许输出，以避免造成干扰
										yield(Candidate("word", cand.start, cand._end, thisTxt:gsub("&nbsp"," "), '💡'))
									end
								elseif string.lower(string.sub(thisTxt, 1, 3)) == 'py-' then
									-- 这是一个以 py- 开头的选项，这被认为是一个 python 关键字
									if pycharmFlg or vscodeFlg then
										-- 修剪选项
										thisTxt = string.sub(thisTxt, 4)
										-- python 关键字选项只在 pycharm 或者 vscode 中才允许输出， 以避免造成干扰
										yield(Candidate("word", cand.start, cand._end, thisTxt:gsub("&nbsp"," "), '💡'))
									end
								else
									yield(Candidate("word", cand.start, cand._end, thisTxt:gsub("&nbsp"," "), '💡'))
								end
							end
						end
					end
				end
			end
		end
	end
end

return phraseExt_Filter
