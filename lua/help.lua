--lua语言中的注释用“--” 
function translator(input, seg)
	if (input == "/help") then
		yield(Candidate("help", seg.start, seg._end, "带圈汉字/数字/字母/注音-->/hzq/szq/zmq/zy", " "))
		yield(Candidate("help", seg.start, seg._end, "符号/记号/箭头/雪花/表情-->/fh/jh/jt/xh/bq", " "))
		yield(Candidate("help", seg.start, seg._end, "数学/数字名/音乐/分数/电脑-->/sx/szm/yy/fs/dn", " "))
		yield(Candidate("help", seg.start, seg._end, "方块/麻将/象棋/色子/扑克-->/fk/mj/xq/sz/pk", " "))
		yield(Candidate("help", seg.start, seg._end, "单位/货币/偏旁-->/dw/hb/pp", " "))
		yield(Candidate("help", seg.start, seg._end, "标点/下标/竖标点-->/bd/xb/bdz", " "))
		yield(Candidate("help", seg.start, seg._end, "希腊字符/大写-->/xl/xld", " "))
		yield(Candidate("help", seg.start, seg._end, "罗马数字/大写-->/lm/lmd", " "))
		yield(Candidate("help", seg.start, seg._end, "天干/地支/干支-->/tg/dz/gz", " "))
		yield(Candidate("help", seg.start, seg._end, "八卦-->/bg/bgm/txj", " "))
		yield(Candidate("help", seg.start, seg._end, "星座/名-->/xz/xzm/seg", " "))
		yield(Candidate("help", seg.start, seg._end, "节气/天气-->/jq/tq", " "))
		yield(Candidate("help", seg.start, seg._end, "数字/字母-->/123/abc...", " "))
		yield(Candidate("help", seg.start, seg._end, "状态/推荐/进度/对错-->/zt/tj/jd/dc", " "))
	elseif (input == "help") then
		yield(Candidate("help", seg.start, seg._end, "lua version: ".._VERSION, " "))
		yield(Candidate("help", seg.start, seg._end, "特殊符号-->/help", " "))
		yield(Candidate("help", seg.start, seg._end, "latexLetters-->uzalph", " "))
		--yield(Candidate("help", seg.start, seg._end, "", " "))
		--yield(Candidate("help", seg.start, seg._end, "", " "))
		--yield(Candidate("help", seg.start, seg._end, "", " "))
	end
end

return translator