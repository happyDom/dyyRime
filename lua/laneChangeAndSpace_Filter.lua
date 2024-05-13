-- laneChangeAndSpace_Filter.lua
-- Copyright (C) 2023 yaoyuan.dou <douyaoyuan@126.com>
-- 这个过滤器的作用有二：
-- 1、当候选项的候选词或者注释中出现 <br> 时，将其处理成 \r 以实现换行效果
-- 2、当候选项的候选词或者注释中出现 &nbsp 时，将其处理成空格，以实现空格效果
-- 3、当候选项的注释长度超过限定值时，对其进行截短并添加截断标记

local dbgFlg = true

--comment单行最长长度限制
local maxLenOfComment = 150

--引入 utf8String 处理字符串相关操作
local utf8StringEnable, utf8String = pcall(require, 'utf8String')

local logEnable, log = pcall(require, "runLog")
if logEnable then
	log.writeLog('')
	log.writeLog('log from laneChangeAndSpace_Filter.lua')
	log.writeLog('utf8StringEnable:'..tostring(utf8StringEnable))
end

local utf8Split = utf8String.utf8Split
local utf8Sub = utf8String.utf8Sub
local utf8Len = utf8String.utf8Len
local utf8PunctuationsTrim = utf8String.utf8PunctuationsTrim

--过滤器
local function laneChangeAndSpace_Filter(input, env)
	local candTxt
	local candComment
	local candTxtNewFlg
	local candComment_brExistFlg
	local candCommentNewFlg
	local bottomLineLen
	
	for cand in input:iter() do
		--读取选项候选词
		candTxt = cand.text or ""
		--读取选项注释内容
		candComment = cand.comment or ""
		
		candTxtNewFlg = false
		if nil ~= string.find(candTxt,"<br>") or nil ~= string.find(candTxt,"&nbsp") then
			-- candTxt 存在 <br> 或者 &nbsp
			candTxtNewFlg = true
			candTxt = candTxt: gsub("<br>","\r"):gsub("&nbsp"," ")
		end
		
		candComment_brExistFlg = false
		candCommentNewFlg = false
		if nil ~= string.find(candComment,"<br>") then
			-- candComment 存在 <br>
			candComment_brExistFlg = true
			
			candCommentNewFlg = true
			candComment = candComment: gsub("<br>","\r")
		end
		if candComment_brExistFlg or nil ~= string.find(candComment,"&nbsp") then
			-- candComment 存在 &nbsp
			candCommentNewFlg = true
			candComment = candComment: gsub("&nbsp"," ")
		end
		bottomLineLen = utf8Len(candComment)
		if bottomLineLen > maxLenOfComment then
			--如果注释长度超过了限定要求，这也需要一个新的注释
			candCommentNewFlg = true
		end
		
		if candCommentNewFlg and bottomLineLen > maxLenOfComment then
			--如果确认需要一个新的注释，并且注释长度超过了限定值，则需要对注释进行截断处理
			if not candComment_brExistFlg then
				--如果原注释中不存在 <br> 符号，则直接截短注释即可
				candComment = utf8Sub(candComment, 1, maxLenOfComment)
			else
				--如果原注释中存在 <br> 符号，则需要按行分别处理
				local subStrList = utf8Split(candComment,"\r")
				local subStrTrimedList = {}
				for idx=1,#subStrList do
					--更新 bottomLineLen，以使其始终保持为最后一行的字符长度值
					bottomLineLen = utf8Len(subStrList[idx])
					if bottomLineLen > maxLenOfComment then
						table.insert(subStrTrimedList,utf8Sub(subStrList[idx], 1, maxLenOfComment).."...")
					else
						table.insert(subStrTrimedList,subStrList[idx])
					end
				end
				
				--将拆分的各行内容使用 \r 连接起来
				candComment = table.concat(subStrTrimedList,"\r")
			end
		end
		
		if candCommentNewFlg then
			--去除首尾空格 和 符号
			candComment = utf8PunctuationsTrim(candComment)
			--找补 candComment 尾部的截断符号
			if bottomLineLen > maxLenOfComment then
				candComment = candComment.."..."
			end
		end
		
		if candTxtNewFlg or candCommentNewFlg then
			--如果存在新的候选项或者注释，则需要生成新的候选词
			yield(Candidate("word", cand.start, cand._end, candTxt, candComment))
		else
			--如果不存在新的候选项且不存在新注释，则抛出原候选项对象
			yield(cand)
		end
	end
end

return laneChangeAndSpace_Filter
