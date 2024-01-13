--lua语言中的注释用“--” 
function translator(input, seg)
	if (input == "help") then
		yield(Candidate("help", seg.start, seg._end, "三角函数-->sin|cos|tan|cot|sec|csc", " "))
		yield(Candidate("help", seg.start, seg._end, "反三角函数-->asin|acos|atan|acot", " "))
		yield(Candidate("help", seg.start, seg._end, "双曲函数-->sh|ch|th|cth|sech|csch", " "))
		yield(Candidate("help", seg.start, seg._end, "反双曲函数-->ash|ach|ath", " "))
		yield(Candidate("help", seg.start, seg._end, "微分-->d?d?_", " "))
		yield(Candidate("help", seg.start, seg._end, "积分-->intc|int", " "))
		yield(Candidate("help", seg.start, seg._end, "对数-->log|lg|ln", " "))
		yield(Candidate("help", seg.start, seg._end, "极限-->lim", " "))
		yield(Candidate("help", seg.start, seg._end, "开方-->sqr", " "))
		yield(Candidate("help", seg.start, seg._end, "上标-->?^", " "))
		yield(Candidate("help", seg.start, seg._end, "下标-->?_", " "))
		yield(Candidate("help", seg.start, seg._end, "线-->bar", " "))
		yield(Candidate("help", seg.start, seg._end, "点-->dot", " "))
		yield(Candidate("help", seg.start, seg._end, "临域-->mr", " "))
		yield(Candidate("help", seg.start, seg._end, "R-->?n?", " "))
		yield(Candidate("help", seg.start, seg._end, "颜色名称-->clr", " "))
		yield(Candidate("help", seg.start, seg._end, "颜色文本-->tc|box", " "))
		yield(Candidate("help", seg.start, seg._end, "特殊字符4-->alig|appr|arra|beca|canc|case|disp|doll|exis|fora|frac|grou|idxx|infi|line|matr|nexi|prod|suba|subs|sout|tria|ther", " "))
		yield(Candidate("help", seg.start, seg._end, "特殊字符3-->big|gox|cap|cup|idx|max|min|neq|not|set|sim|sum|tau", " "))
		yield(Candidate("help", seg.start, seg._end, "特殊字符2-->in|mp|ni|to|gt|ge|lt|le|", " "))
		yield(Candidate("help", seg.start, seg._end, "希腊字符-->alph|beta|其它名称", " "))
		--yield(Candidate("help", seg.start, seg._end, "-->", " "))
	end
end

return translator