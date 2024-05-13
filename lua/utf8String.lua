--utf8String.lua
--这个模块主要用于处理一些utf8字符串相关的操作

-- 定义一个全局变量，用于记录一个随机数种子
randomseed = os.time()

local logEnable, log = pcall(require, 'runLog')

local M={}
local dbgFlg = false

--左侧标点，例如左侧括号，左侧引号等，以及单符号标点也被识为左侧标点，例如 | , 等
local punctuationsAtLeft = {['，'] = true,[','] = true,
							['。'] = true, ['.'] = true,
							[';'] = true,['；'] = true,
							['、'] = true,['\\'] = true,
							['？'] = true,['?'] = true,
							['！'] = true,['!'] = true,
							['＠'] = true,['@'] = true,
							['&'] = true,['＆'] = true,
							['/'] = true,
							['…'] = true,
							[' '] = true,
							['（'] = true,['('] = true,
							['‘'] = true,['“'] = true,
							['［'] = true,['['] = true,['【'] = true,
							['<'] = true,['《'] = true,['〈'] = true
							}

--右侧标点，例如右侧括号，右侧绰号等，以及单符号标点也被识别为右侧标点，例如 | , 等
local punctuationsAtRight = {['，'] = true,[','] = true,
							['。'] = true, ['.'] = true,
							[';'] = true,['；'] = true,
							['、'] = true,['\\'] = true,
							['？'] = true,['?'] = true,
							['！'] = true,['!'] = true,
							['＠'] = true,['@'] = true,
							['&'] = true,['＆'] = true,
							['/'] = true,
							['…'] = true,
							[' '] = true,
							['）'] = true,[')'] = true,
							['’'] = true,['”'] = true,
							['］'] = true,[']'] = true,['】'] = true,
							['>'] = true,['》'] = true,['〉'] = true
							}

local lettersForPwd = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
"0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
"~", "!", "@", "#", "$", "%", "^", "&", "*", "-", "=", "+"}

--设置 dbg 开关
local function setDbg(flg)
	dbgFlg = flg
	print('utf8String dbgFlg is '..tostring(dbgFlg))
end

--判断给定的一个字符头，实际占用的字节数
local function chsize(char)
	if not char then
		return 0
	elseif char > 240 then
		return 4
	elseif char > 225 then
		return 3
	elseif char > 192 then
		return 2
	else
		return 1
	end
end

--判断给定的一个字符串的实际字符长度
local function utf8Len(str)
	local len = 0
	local currentIndex = 1
	while currentIndex <= #str do
		local char = string.byte(str,currentIndex)
		currentIndex = currentIndex + chsize(char)
		len = len + 1
	end

	return len
end

--根据给定的字符串，和指定的起始位置和字符数，截取子串
local function utf8Sub(str,startChar,numChars)
	local startIndex = 1
	while startChar > 1 do
		local char = string.byte(str,startIndex)
		startIndex = startIndex + chsize(char)
		startChar = startChar - 1
	end

	local currentIndex = startIndex

	while numChars > 0 and currentIndex <= #str do
		local char = string.byte(str,currentIndex)
		currentIndex = currentIndex + chsize(char)
		numChars = numChars - 1
	end

	return str:sub(startIndex,currentIndex - 1)
end

--根据给定的字符串，去除其头尾的空白符
local function utf8Trim(str)
	str = str or ''
	local cnt = 0
	local subChar = utf8Sub(str,1,1)

	--去除其头部的 空白
	while subChar:match("%s") do
		str = utf8Sub(str,2,utf8Len(str)-1)
		subChar = utf8Sub(str,1,1)
		cnt = cnt + 1
	end

	--去除其尾部的 空白
	subChar = utf8Sub(str,utf8Len(str),1)
	while subChar:match("%s") do
		str = utf8Sub(str,1,utf8Len(str)-1)
		subChar = utf8Sub(str,utf8Len(str),1)
		cnt = cnt + 1
	end

	return str,cnt
end

--根据给定的字符串，去除其头尾部的 符号 字符
local function utf8PunctuationsGo(str)
	str = str or ''
	local cnt = 0
	local subChar = utf8Sub(str,1,1)

	--去除其头部的 右侧 标点
	while punctuationsAtRight[subChar] do
		str = utf8Sub(str,2,utf8Len(str)-1)
		subChar = utf8Sub(str,1,1)
		cnt = cnt + 1
	end

	--去除其尾部的 左侧 标点
	subChar = utf8Sub(str,utf8Len(str),1)
	while punctuationsAtLeft[subChar] do
		str = utf8Sub(str,1,utf8Len(str)-1)
		subChar = utf8Sub(str,utf8Len(str),1)
		cnt = cnt + 1
	end

	return str,cnt
end

--根据给定的字符串，去除其头尾部的 符号 和 空白
local function utf8PunctuationsTrim(str)
	str = str or ''
	local cnt = 0
	local subChar = utf8Sub(str,1,1)

	--去除其头部的 右侧 标点
	while punctuationsAtRight[subChar] do
		str = utf8Sub(str,2,utf8Len(str)-1)
		subChar = utf8Sub(str,1,1)
		cnt = cnt + 1
	end

	--去除其尾部的 左侧 标点
	subChar = utf8Sub(str,utf8Len(str),1)
	while punctuationsAtLeft[subChar] do
		str = utf8Sub(str,1,utf8Len(str)-1)
		subChar = utf8Sub(str,utf8Len(str),1)
		cnt = cnt + 1
	end

	return str,cnt
end

--把给定的字符串，根据指定的字符进行分割，返回分割后的子串数组
local function utf8Split(str, sp, sp1)
	if dbgFlg then
		log.writeLog("utf8Split is called:")
		log.writeLog("str: "..(str or ""))
		log.writeLog("sp: "..(sp or ""))
		log.writeLog("sp1: "..(sp1 or ""))
	end
	
	sp = type(sp) == "string"  and sp or " "
	if #sp == 0 then
		--如果分割符是空的，则匹配每个字符，并将其捕获出来
		sp = "([%z\1-\127\194-\244][\128-\191]*)"
	elseif #sp == 1 then
		--如果指定了一个分割字符，则匹配并捕获不包含该分割符的子串，并将其捕获出来
		sp = "[^" ..  (sp=="%" and "%%" or sp) .. "]*"
	else
		--如果指定的分割符（sp）是一个字符串，则需要先将分割字符串替换成新的分割符（sp1），然后再分割
		sp1 = sp1 or "^"
		if #sp1 > 1 then
			--确保分割符 sp1 是一个字符，而不是多字符
			sp1 = sp1:sub(1,1)
		end
		
		str = str:gsub(sp,sp1)
		sp = "[^".. sp1 .. "]*"
	end
	
	local tab= {}
	for v in str:gmatch(sp) do
		table.insert(tab,v)
		if dbgFlg then log.writeLog("v: "..v) end
	end
	
	return tab
end

--生成一个指定长度的随机密码
function newPwd(len, easyRead)
    len = len or 8
	easyRead = easyRead or true

	local pwd = ''
	local tmpChar = ''
	local cntForOptions = #lettersForPwd

	-- 初始化随机数种子
	math.randomseed(randomseed)

	repeat
		-- 重置随机数种子
		randomseed = math.random(0, 100000000)
		
		--随机挑选一个字符
		tmpChar = lettersForPwd[math.random(cntForOptions)]
		if easyRead then
			--如果要求易读，则禁用 1,l,o,O,0 这些字符
			if not ({['1']=true, ['l']=true, ['o']=true, ['O']=true, ['0']=true})[tmpChar] then
				pwd = pwd .. tmpChar
			end
		else
			pwd = pwd .. tmpChar
		end
		
	until (#pwd >= len)

    return pwd
end


--这是用于测试的函数
local function test(printPrefix)
	if nil == printPrefix then
		printPrefix = ' '
	end

	if dbgFlg then
		print(printPrefix,'utf8StringModule test starting...')

		print(printPrefix,utf8Len("好好学习5天天向上"))
		print(printPrefix,utf8Sub("好好学习5天天向上",5,2))
	end
end

--Module
function M.init(...)
	M.utf8Sub = utf8Sub
	M.utf8Len = utf8Len
	M.utf8Trim = utf8Trim
	M.utf8PunctuationsGo = utf8PunctuationsGo
	M.utf8PunctuationsTrim = utf8PunctuationsTrim
	M.utf8Split = utf8Split
	M.newPwd = newPwd

	M.setDbg = setDbg
	M.test = test
end

M.init()

return M