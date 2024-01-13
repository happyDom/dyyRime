--lua语言中的注释用“--” 
--声明全局变量

local colorName={"apricot",
				"aquamarine",
				"bittersweet",
				"black",
				"blue",
				"bluegreen",
				"blueviolet",
				"brickred",
				"brown",
				"burntorange",
				"cadetblue",
				"carnationpink",
				"cerulean",
				"cornflowerblue",
				"cyan",
				"dandelion",
				"darkorchid",
				"emerald",
				"forestgreen",
				"fuchsia",
				"goldenrod",
				"gray",
				"green",
				"greenyellow",
				"junglegreen",
				"lavender",
				"limegreen",
				"magenta",
				"mahogany",
				"maroon",
				"melon",
				"midnightblue",
				"mulberry",
				"navyblue",
				"olivegreen",
				"orange",
				"orangered",
				"orchid",
				"peach",
				"periwinkle",
				"pinegreen",
				"plum",
				"processblue",
				"purple",
				"rawsienna",
				"red",
				"redorange",
				"redviolet",
				"rhodamine",
				"royalblue",
				"royalpurple",
				"rubinered",
				"salmon",
				"seagreen",
				"sepia",
				"skyblue",
				"springgreen",
				"tan",
				"tealblue",
				"thistle",
				"turquoise",
				"violet",
				"violetred",
				"white",
				"wildstrawberry",
				"yellow",
				"yellowgreen",
				"yelloworange"
				}

local  xlNamesArry={
					{"alph","alpha","Alpha"},
					{"beta","beta","Beta"},
					{"delt","delta","Delta","varDelta"},
					{"epsi","varepsilon ","epsilon ","Epsilon"},
					{"gamm","gamma","varGamma","Gamma","digamma"},
					{"kapp","kappa","varkappa","Kappa"},
					{"iota","iota","Iota"},
					{"lamb","lambda","Lambda","varLambda"},
					{"omeg","omega","Omega","varOmega"},
					{"omic","omicron","Omicron"},
					{"upsi","upsilon","Upsilon","varUpsilon"},
					{"sigm","sigma","Sigma","varSigma","varsigma"},
					{"thet","theta","vartheta","Theta","varTheta"},
					{"zeta","zeta","Zeta"},
					{"chi","chi","Chi"},
					{"eta","eta","Eta"},
					{"phi","varphi","phi","Phi","varPhi"},
					{"psi","psi","Psi","varPsi"},
					{"rho","rho","varrho","Rho"},
					{"tau","tau","Tau"},
					{"mu","mu","Mu"},
					{"nu","nu","Nu"},
					{"pi","pi","Pi","varPi","varpi"},
					{"xi","xi","Xi","varXi"}
					}

function translator(input, seg)
	--声名局部变量
	local debugFlg=false
	local returnFlg=false
	local matchFlg=false
	local patterns=""
	local pattern=""
	local subpattern=""
	local str=""
	local subStr_0=""
	local subStr_1=""
	local keyW=""
	local keyW_1=""
	local keyW_2=""
	local keyW_3=""
	local keyW_u=""
	local keyW_sub=""
	local varW=""
	local varW_1=""
	local varW_2=""
	local varW_3=""
	local pos=0
	
	--在候选词中使用 '\r' 或者 '\013' 可以输出换行效果
	--在候选词中使用 '\t' 或者 '\009' 可以输出水平制表符
	--如果候选词中出现 '\n' 或者 '\010' 输入法程序会卡死退出
	
	if input == "test" and debugFlg then
		--使用键值的方式，通过单引号表示这是一个字符，而不是 '\0' 转义
		yield(Candidate("latex", seg.start, seg._end,"第一行"..'\013'.."第二行"..'\013'.."第三行", " "))
		--使用字符的方式，以下两种均可
		yield(Candidate("latex", seg.start, seg._end,"第一行"..'\r'.."第二行"..'\r'.."第三行", " "))
		yield(Candidate("latex", seg.start, seg._end,"第一行\r第二行\r第三行", " "))
		
		matchFlg=true
		returnFlg=true
	elseif input == "help" then
		--help 作为特殊输入，不做latters翻译
		returnFlg=true
	end
	
	if returnFlg then
		return 0
	end
	
	--初始化标志位
	returnFlg=false
	matchFlg = false
	
	--匹配颜色名称
	patterns={"clr[a-z]+"}
	for idx,pattern in ipairs(patterns) do
		if string.match(input,pattern)~=nil then
			str=string.match(input,"("..pattern..")")
			keyW=string.sub(str,1,3)
			varW=string.sub(str,4,string.len(str))
			
			if debugFlg then
				yield(Candidate("latex", seg.start, seg._end,"latexLetters: ".. pattern..", "..str, " "))
			end
			
			matchFlg=false
			for cidx,cname in ipairs(colorName) do
				if varW==cname then
					--命名完全相符的
					if matchFlg==false then
						matchFlg=true
					end
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, pattern, cname, 1), " "))
				end
			end
			
			for cidx,cname in ipairs(colorName) do
				if varW==string.sub(cname,1,string.len(varW)) then
					--命名在起始位置的
					if matchFlg==false then
						matchFlg=true
					end
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, pattern, cname, 1), " "))
				end
			end
			
			for cidx,cname in ipairs(colorName) do
				if string.find(cname,varW,2)~=nil then
					--命名在中间位置的
					if matchFlg==false then
						matchFlg=true
					end
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, pattern, cname, 1), " "))
				end
			end
			
			if matchFlg then
				returnFlg=true
				break
			end
		end
	end
	if returnFlg then
		return 0
	end

	--匹配带颜色的字符片段
	patterns={"tc[a-z]+","box[a-z]+"} 
	for idx,pattern in ipairs(patterns) do
		if string.match(input,pattern)~=nil then
			str=string.match(input,"("..pattern..")")
			keyW=string.sub(str,1,2)
			if keyW=="tc" then
				varW=string.sub(str,3,string.len(str))
			else
				keyW=string.sub(str,1,3)
				varW=string.sub(str,4,string.len(str))
			end
			
			if debugFlg then
				yield(Candidate("latex", seg.start, seg._end,"latexLetters: ".. pattern..", "..str, " "))
			end
			
			matchFlg=false
			for cidx,cname in ipairs(colorName) do
				if varW==cname then
					--命名完全相符的
					if matchFlg==false then
						matchFlg=true
					end
					if keyW=="tc" then
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, pattern, "\\textcolor{"..cname.."}{}", 1), " "))
					elseif keyW=="box" then
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, pattern, "\\fcolorbox{"..cname.."}{white}{}", 1), " "))
					end
				end
			end
			
			for cidx,cname in ipairs(colorName) do
				if varW==string.sub(cname,1,string.len(varW)) then
					--命名在起始位置的
					if matchFlg==false then
						matchFlg=true
					end
					if keyW=="tc" then
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, pattern, "\\textcolor{"..cname.."}{}", 1), " "))
					elseif keyW=="box" then
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, pattern, "\\fcolorbox{"..cname.."}{white}{}", 1), " "))
					end
				end
			end
			
			for cidx,cname in ipairs(colorName) do
				if string.find(cname,varW,2)~=nil then
					--命名在中间位置的
					if matchFlg==false then
						matchFlg=true
					end
					if keyW=="tc" then
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, pattern, "\\textcolor{"..cname.."}{}", 1), " "))
					elseif keyW=="box" then
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, pattern, "\\fcolorbox{"..cname.."}{white}{}", 1), " "))
					end
				end
			end
			
			if matchFlg then
				returnFlg=true
				break
			end
		end
	end
	if returnFlg then
		return 0
	end

	--4字符关键字匹配 之 反三角函数匹配
	patterns={"asin","acos","acos","atan","acot"}
	for pidx,pattern in ipairs(patterns) do
		if(string.match(input,pattern)~=nil) then
			if debugFlg then
				yield(Candidate("latex", seg.start, seg._end,"latexLetters: 反三角函数匹配", " "))
			end
			
			if pattern=="acot" then
				keyW = "{\\rm arccot}"
			elseif pattern=="arccot" then
				keyW = "{\\rm arccot}"
			else
				keyW = "\\"..string.sub(pattern,1,1).."rc"..string.sub(pattern,2)
			end
			local thisPattern=""
			
			--匹配希腊字母参数
			for xlidx,xlNames in ipairs(xlNamesArry) do
				local nameKey=xlNames[1]
				--生成xl字符名称
				local names={}
				for k,v in ipairs(xlNames) do
					if k>1 then
						table.insert(names,v)
					end
				end
				
				if(string.match(input,pattern..".+_")~=nil) then
					--匹配希腊字母带下标
					thisPattern=pattern..nameKey.."_"
					if(string.match(input,thisPattern)~=nil) then
						--生成候选词
						for k,name in ipairs(names) do
							for i=1,8 do
								yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{\\"..name.."_{"..tostring(i).."}}",1), " "))
							end
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{\\"..name.."_{n}}",1), " "))
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{\\"..name.."_{0}}",1), " "))
						end
						--标记过程状态
						matchFlg=true
					end
				elseif(string.match(input,pattern..".+^")~=nil) then
					--匹配希腊字母本身带上标
					thisPattern=pattern..nameKey.."^"
					if(string.match(input,thisPattern)~=nil) then
						--生成候选词
						for k,name in ipairs(names) do
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{\\"..name.."}",1), " "))
							for i=2,9 do
								yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{\\"..name.."^{"..tostring(i).."}}",1), " "))
							end
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{\\"..name.."^{n}}",1), " "))
						end
						--标记过程状态
						matchFlg=true
					end
				else
					--匹配希腊字母本身
					thisPattern=pattern..nameKey
					if(string.match(input,thisPattern)~=nil) then
						--生成候选词
						for k,name in ipairs(names) do
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{\\"..name.."}",1), " "))
							for i=2,9 do
								yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."^{"..tostring(i).."}{\\"..name.."}",1), " "))
							end
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."^{n}{\\"..name.."}",1), " "))
						end
						--标记过程状态
						matchFlg=true
					end
				end
				if matchFlg then
					break
				end
			end
			if matchFlg then
				break
			end
			
			--匹配正常字母参数
			thisPattern=pattern.."[a-zA-Z][_^]?"
			if(string.match(input,thisPattern)~=nil) then
				str=string.match(input,"("..thisPattern..")")
				varW=string.sub(str,string.len(pattern)+1,string.len(pattern)+1)
				varW_1=string.sub(str,string.len(str))
				
				if varW_1=='_' then
					--匹配正常字母参数，带下标
					for i=1,8 do
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{"..varW.."_{"..tostring(i).."}}",1), " "))
					end
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{"..varW.."_{n}}",1), " "))
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{"..varW.."_{0}}",1), " "))
					
					--标记过程状态
					matchFlg=true
				elseif varW_1=='^' then
					--匹配正常字母参数,带上标
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{"..varW.."}",1), " "))
					for i=2,9 do
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{"..varW.."^{"..tostring(i).."}}",1), " "))
					end
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{"..varW.."^{n}}",1), " "))
					--标记过程状态
					matchFlg=true
				else
					--匹配正常字母参数，无上下标
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{"..varW.."}",1), " "))
					for i=2,9 do
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."^{"..tostring(i).."}{"..varW.."}",1), " "))
					end
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."^{n}{"..varW.."}",1), " "))
					--标记过程状态
					matchFlg=true
				end
			end
			if matchFlg then
				break
			end
			
			--匹配无参数
			thisPattern=pattern
			if(string.match(input,thisPattern)~=nil) then
				str=string.match(input,"("..thisPattern..")")
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."()",1), " "))
				for i=2,9 do
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."^{"..tostring(i).."}()",1), " "))
				end
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."^{n}()",1), " "))
				
				--标记过程状态
				matchFlg=true
			end
			if matchFlg then
				returnFlg=true
				break
			end
		end
	end
	if returnFlg then
		return 0
	end
	
	--3字符关键字匹配 之 反双曲函数匹配
	patterns={"ash","ach","ath"}
	for pidx,pattern in ipairs(patterns) do
		if(string.match(input,pattern)~=nil) then
			if debugFlg then
				yield(Candidate("latex", seg.start, seg._end,"latexLetters: 反双曲函数匹配", " "))
			end
			
			keyW = "{\\rm "..string.sub(pattern,1,1)..'r'..string.sub(pattern,2).."}"
			
			local thisPattern=""
			
			--匹配希腊字母参数
			for xlidx,xlNames in ipairs(xlNamesArry) do
				local nameKey=xlNames[1]
				--生成xl字符名称
				local names={}
				for k,v in ipairs(xlNames) do
					if k>1 then
						table.insert(names,v)
					end
				end
				
				if(string.match(input,pattern..".+_")~=nil) then
					--匹配希腊字母带下标
					thisPattern=pattern..nameKey.."_"
					if(string.match(input,thisPattern)~=nil) then
						--生成候选词
						for k,name in ipairs(names) do
							for i=1,8 do
								yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{\\"..name.."_{"..tostring(i).."}}",1), " "))
							end
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{\\"..name.."_{n}}",1), " "))
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{\\"..name.."_{0}}",1), " "))
						end
						--标记过程状态
						matchFlg=true
					end
				elseif(string.match(input,pattern..".+^")~=nil) then
					--匹配希腊字母本身带上标
					thisPattern=pattern..nameKey.."^"
					if(string.match(input,thisPattern)~=nil) then
						--生成候选词
						for k,name in ipairs(names) do
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{\\"..name.."}",1), " "))
							for i=2,9 do
								yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{\\"..name.."^{"..tostring(i).."}}",1), " "))
							end
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{\\"..name.."^{n}}",1), " "))
						end
						--标记过程状态
						matchFlg=true
					end
				else
					--匹配希腊字母本身
					thisPattern=pattern..nameKey
					if(string.match(input,thisPattern)~=nil) then
						--生成候选词
						for k,name in ipairs(names) do
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{\\"..name.."}",1), " "))
							for i=2,9 do
								yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."^{"..tostring(i).."}{\\"..name.."}",1), " "))
							end
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."^{n}{\\"..name.."}",1), " "))
						end
						--标记过程状态
						matchFlg=true
					end
				end
				if matchFlg then
					break
				end
			end
			if matchFlg then
				break
			end
			
			--匹配正常字母参数
			thisPattern=pattern.."[a-zA-Z][_^]?"
			if(string.match(input,thisPattern)~=nil) then
				str=string.match(input,"("..thisPattern..")")
				varW=string.sub(str,string.len(pattern)+1,string.len(pattern)+1)
				varW_1=string.sub(str,string.len(str))
				
				if varW_1=='_' then
					--匹配正常字母参数，带下标
					for i=1,8 do
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{"..varW.."_{"..tostring(i).."}}",1), " "))
					end
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{"..varW.."_{n}}",1), " "))
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{"..varW.."_{0}}",1), " "))
					
					--标记过程状态
					matchFlg=true
				elseif varW_1=='^' then
					--匹配正常字母参数，带上标
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{"..varW.."}",1), " "))
					for i=2,9 do
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{"..varW.."^{"..tostring(i).."}}",1), " "))
					end
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{"..varW.."^{n}}",1), " "))
					--标记过程状态
					matchFlg=true
				else
					--匹配正常字母参数，不带上下标
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{"..varW.."}",1), " "))
					for i=2,9 do
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."^{"..tostring(i).."}{"..varW.."}",1), " "))
					end
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."^{n}{"..varW.."}",1), " "))
					--标记过程状态
					matchFlg=true
				end
			end
			if matchFlg then
				break
			end
			
			--匹配无参数
			thisPattern=pattern
			if(string.match(input,thisPattern)~=nil) then
				str=string.match(input,"("..thisPattern..")")
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."()",1), " "))
				for i=2,9 do
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."^{"..tostring(i).."}()",1), " "))
				end
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."^{n}()",1), " "))
				
				--标记过程状态
				matchFlg=true
			end
			if matchFlg then
				returnFlg=true
				break
			end
		end
	end
	if returnFlg then
		return 0
	end
	
	--5字符关键字匹配 之 双曲函数匹配
	patterns={"sech","csch","sh","ch","th","cth"}
	for pidx,pattern in ipairs(patterns) do
		if(string.match(input,pattern)~=nil) then
			if debugFlg then
				yield(Candidate("latex", seg.start, seg._end,"latexLetters: 双曲三角函数匹配", " "))
			end
			
			if pattern=="sech" then
				keyW = "{\\rm sech}"
			elseif pattern=="csch" then
				keyW = "{\\rm csch}"
			elseif pattern=="sinh" then
				keyW = "\\sh"
			elseif pattern=="cosh" then
				keyW = "\\ch"
			elseif pattern=="tanh" then
				keyW = "\\th"
			elseif pattern=="coth" then
				keyW = "\\cth"
			else
				keyW = "\\"..pattern
			end
			local thisPattern=""
			
			--匹配希腊字母参数
			for xlidx,xlNames in ipairs(xlNamesArry) do
				local nameKey=xlNames[1]
				--生成xl字符名称
				local names={}
				for k,v in ipairs(xlNames) do
					if k>1 then
						table.insert(names,v)
					end
				end
				
				if(string.match(input,pattern..".+_")~=nil) then
					--匹配希腊字母带下标
					thisPattern=pattern..nameKey.."_"
					if(string.match(input,thisPattern)~=nil) then
						--生成候选词
						for k,name in ipairs(names) do
							for i=1,8 do
								yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{\\"..name.."_{"..tostring(i).."}}",1), " "))
							end
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{\\"..name.."_{n}}",1), " "))
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{\\"..name.."_{0}}",1), " "))
						end
						--标记过程状态
						matchFlg=true
					end
				elseif(string.match(input,pattern..".+^")~=nil) then
					--匹配希腊字母本身带上标
					thisPattern=pattern..nameKey.."^"
					if(string.match(input,thisPattern)~=nil) then
						--生成候选词
						for k,name in ipairs(names) do
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{\\"..name.."}",1), " "))
							for i=2,9 do
								yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{\\"..name.."^{"..tostring(i).."}}",1), " "))
							end
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{\\"..name.."^{n}}",1), " "))
						end
						--标记过程状态
						matchFlg=true
					end
				else
					--匹配希腊字母本身
					thisPattern=pattern..nameKey
					if(string.match(input,thisPattern)~=nil) then
						--生成候选词
						for k,name in ipairs(names) do
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{\\"..name.."}",1), " "))
							for i=2,9 do
								yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."^{"..tostring(i).."}{\\"..name.."}",1), " "))
							end
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."^{n}{\\"..name.."}",1), " "))
						end
						--标记过程状态
						matchFlg=true
					end
				end
				if matchFlg then
					break
				end
			end
			if matchFlg then
				break
			end
			
			--匹配正常字母参数
			thisPattern=pattern.."[a-zA-Z][_^]?"
			if(string.match(input,thisPattern)~=nil) then
				str=string.match(input,"("..thisPattern..")")
				varW=string.sub(str,string.len(pattern)+1,string.len(pattern)+1)
				varW_1=string.sub(str,string.len(str))
				
				if varW_1=='_' then
					--匹配正常字母参数，带下标
					for i=1,8 do
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{"..varW.."_{"..tostring(i).."}}",1), " "))
					end
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{"..varW.."_{n}}",1), " "))
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{"..varW.."_{0}}",1), " "))
					
					--标记过程状态
					matchFlg=true
				elseif varW_1=='^' then
					--匹配正常字母参数，带上标
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{"..varW.."}",1), " "))
					for i=2,9 do
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{"..varW.."^{"..tostring(i).."}}",1), " "))
					end
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{"..varW.."^{n}}",1), " "))
					--标记过程状态
					matchFlg=true
				else
					--匹配正常字母参数，不带上下标
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{"..varW.."}",1), " "))
					for i=2,9 do
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."^{"..tostring(i).."}{"..varW.."}",1), " "))
					end
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."^{n}{"..varW.."}",1), " "))
					--标记过程状态
					matchFlg=true
				end
			end
			if matchFlg then
				break
			end
			
			--匹配无参数
			thisPattern=pattern
			if(string.match(input,thisPattern)~=nil) then
				str=string.match(input,"("..thisPattern..")")
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."()",1), " "))
				for i=2,9 do
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."^{"..tostring(i).."}()",1), " "))
				end
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."^{n}()",1), " "))
				
				--标记过程状态
				matchFlg=true
			end
			if matchFlg then
				returnFlg=true
				break
			end
		end
	end
	if returnFlg then
		return 0
	end
	
	--4+字符关键字匹配 之 微商匹配
	patterns={"d[a-zA-Z]+d[a-zA-Z]+_?"}
	for pidx,pattern in ipairs(patterns) do
		if(string.match(input,pattern)~=nil) then
			if debugFlg then
				yield(Candidate("latex", seg.start, seg._end,"latexLetters: 微商匹配", " "))
			end
			
			local thisPattern=""
			
			--匹配希腊字母因变量
			for bidx,yNames in ipairs(xlNamesArry) do
				local yNameKey=yNames[1]
				if(string.match(input,"d"..yNameKey.."d[a-zA-Z]+_?")~=nil) then
					--生成xl字符名称
					local yNameNames={}
					for k,v in ipairs(yNames) do
						if k>1 then
							table.insert(yNameNames,v)
						end
					end
					
					--匹配希腊字母自变量
					for xidx,xNames in ipairs(xlNamesArry) do
						local xNameKey=xNames[1]
						--生成xl字符名称
						local xNameNames={}
						for k,v in ipairs(xNames) do
							if k>1 then
								table.insert(xNameNames,v)
							end
						end
						
						--带下标场景
						thisPattern="d"..yNameKey.."d"..xNameKey.."_"
						if(string.match(input,thisPattern)~=nil) then
							--dpsidphi_类的输入
							for fk,fn in ipairs(yNameNames) do
								for xk,xn in ipairs(xNameNames) do
									yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\left.\\cfrac{d\\"..fn.."}{d\\"..xn.."}\\right|_{\\"..xn.."=0}",1), " "))
									for i=2,9 do
										yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\left.\\cfrac{d^{"..tostring(i).."}\\"..fn.."}{d\\"..xn.."^{"..tostring(i).."}}\\right|_{\\"..xn.."=0}",1), " "))
									end
									yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\left.\\cfrac{d^{n}\\"..fn.."}{d\\"..xn.."^{n}}\\right|_{\\"..xn.."=0}",1), " "))
								end
							end
							--标记过程状态
							matchFlg=true
						end
						if matchFlg then
							break
						end
						
						--不带下标场景
						thisPattern="d"..yNameKey.."d"..xNameKey
						if(string.match(input,thisPattern)~=nil) then
							--dpsidphi_类的输入
							for fk,fn in ipairs(yNameNames) do
								for xk,xn in ipairs(xNameNames) do
									yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\frac{d\\"..fn.."}{d\\"..xn.."}",1), " "))
									for i=2,9 do
										yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\frac{d^{"..tostring(i).."}\\"..fn.."}{d\\"..xn.."^{"..tostring(i).."}}",1), " "))
									end
									yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\frac{d^{n}\\"..fn.."}{d\\"..xn.."^{n}}",1), " "))
								end
							end
							--标记过程状态
							matchFlg=true
						end
						if matchFlg then
							break
						end
					end
					if matchFlg then
						break
					end
					
					--匹配单字母自变量
					--带下标场景
					thisPattern="d"..yNameKey.."d[a-zA-Z]_"
					if(string.match(input,thisPattern)~=nil) then
						--dpsidx_类的输入
						str=string.match(input,"("..thisPattern..")")
						varW=string.sub(str,string.len(str)-1,string.len(str)-1)
						
						for fk,fn in ipairs(yNameNames) do
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\left.\\cfrac{d\\"..fn.."}{d"..varW.."}\\right|_{"..varW.."=0}",1), " "))
							for i=2,9 do
								yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\left.\\cfrac{d^{"..tostring(i).."}\\"..fn.."}{d"..varW.."^{"..tostring(i).."}}\\right|_{"..varW.."=0}",1), " "))
							end
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\left.\\cfrac{d^{n}\\"..fn.."}{d"..varW.."^{n}}\\right|_{"..varW.."=0}",1), " "))
						end
						--标记过程状态
						matchFlg=true
					end
					if matchFlg then
						break
					end
					
					--不带下标场景
					thisPattern="d"..yNameKey.."d[a-zA-Z]"
					if(string.match(input,thisPattern)~=nil) then
						--dpsidx_类的输入
						str=string.match(input,"("..thisPattern..")")
						varW=string.sub(str,string.len(str))
						
						for fk,fn in ipairs(yNameNames) do
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\cfrac{d\\"..fn.."}{d"..varW.."}",1), " "))
							for i=2,9 do
								yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\cfrac{d^{"..tostring(i).."}\\"..fn.."}{d"..varW.."^{"..tostring(i).."}}",1), " "))
							end
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\cfrac{d^{n}\\"..fn.."}{d"..varW.."^{n}}",1), " "))
						end
						--标记过程状态
						matchFlg=true
					end
					if matchFlg then
						break
					end
				end
			end
			if matchFlg then
				returnFlg=true
				break
			end
			
			--匹配单字母因变量，匹配希腊字母自变量
			for xidx,xNames in ipairs(xlNamesArry) do
				local xNameKey=xNames[1]
				--生成xl字符名称
				local xNameNames={}
				for k,v in ipairs(xNames) do
					if k>1 then
						table.insert(xNameNames,v)
					end
				end
				
				--带下标场景
				thisPattern="d[a-zA-Z]d"..xNameKey.."_"
				if(string.match(input,thisPattern)~=nil) then
					--dpsidx_类的输入
					str=string.match(input,"("..thisPattern..")")
					varW_1=string.sub(str,2,2)
					
					for xk,xn in ipairs(xNameNames) do
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\left.\\cfrac{d"..varW_1.."}{d\\"..xn.."}\\right|_{\\"..xn.."=0}",1), " "))
						for i=2,9 do
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\left.\\cfrac{d^{"..tostring(i).."}"..varW_1.."}{d\\"..xn.."^{"..tostring(i).."}}\\right|_{\\"..xn.."=0}",1), " "))
						end
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\left.\\cfrac{d^{n}"..varW_1.."}{d\\"..xn.."^{n}}\\right|_{\\"..xn.."=0}",1), " "))
					end
					--标记过程状态
					matchFlg=true
				end
				if matchFlg then
					break
				end
				
				--不带下标场景
				thisPattern="d[a-zA-Z]d"..xNameKey
				if(string.match(input,thisPattern)~=nil) then
					--dpsidx_类的输入
					str=string.match(input,"("..thisPattern..")")
					varW_1=string.sub(str,2,2)
					
					for xk,xn in ipairs(xNameNames) do
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\cfrac{d"..varW_1.."}{d\\"..xn.."}",1), " "))
						for i=2,9 do
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\cfrac{d^{"..tostring(i).."}"..varW_1.."}{d\\"..xn.."^{"..tostring(i).."}}",1), " "))
						end
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\cfrac{d^{n}"..varW_1.."}{d\\"..xn.."^{n}}",1), " "))
					end
					--标记过程状态
					matchFlg=true
				end
				if matchFlg then
					break
				end
			end
			if matchFlg then
				returnFlg=true
				break
			end
			
			--匹配单字母因变量，匹配单字母自变量，带下标场景
			thisPattern="d[a-zA-Z]d[a-zA-Z]_"
			if(string.match(input,thisPattern)~=nil) then
				--dydx_类的输入
				str=string.match(input,"("..thisPattern..")")
				varW_1=string.sub(str,2,2)
				varW_2=string.sub(str,4,4)
				
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\left.\\cfrac{d"..varW_1.."}{d"..varW_2.."}\\right|_{"..varW_2.."=0}",1), " "))
				for i=2,9 do
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\left.\\cfrac{d^{"..tostring(i).."}"..varW_1.."}{d"..varW_2.."^{"..tostring(i).."}}\\right|_{"..varW_2.."=0}",1), " "))
				end
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\left.\\cfrac{d^{n}"..varW_1.."}{d"..varW_2.."^{n}}\\right|_{"..varW_2.."=0}",1), " "))
				
				--标记过程状态
				matchFlg=true
			end
			if matchFlg then
				returnFlg=true
				break
			end
			
			--匹配单字母因变量，匹配单字母自变量，不带下标场景
			thisPattern="d[a-zA-Z]d[a-zA-Z]"
			if(string.match(input,thisPattern)~=nil) then
				--dydx类的输入
				str=string.match(input,"("..thisPattern..")")
				varW_1=string.sub(str,2,2)
				varW_2=string.sub(str,4,4)
				
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\cfrac{d"..varW_1.."}{d"..varW_2.."}",1), " "))
				for i=2,9 do
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\cfrac{d^{"..tostring(i).."}"..varW_1.."}{d"..varW_2.."^{"..tostring(i).."}}",1), " "))
				end
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\cfrac{d^{n}"..varW_1.."}{d"..varW_2.."^{n}}",1), " "))
				
				--标记过程状态
				matchFlg=true
			end
			if matchFlg then
				returnFlg=true
				break
			end
		end
	end
	if returnFlg then
		return 0
	end

	--4字符关键字，latex专用组合
	patterns={"[a-zA-Z][a-zA-Z][a-zA-Z][a-zA-Z]"}
	for pos=1,string.len(input) do
		matchFlg=false
		for idx,pattern in ipairs(patterns) do
			if string.match(input,pattern,pos)~=nil then
				str=string.match(input,"("..pattern..")",pos)
				if pos==1 then
					subStr_0=""
				else
					subStr_0=string.sub(input,1,pos-1)
				end
				subStr_1=string.sub(input,pos,string.len(input))
				
				if debugFlg then
					yield(Candidate("latex", seg.start, seg._end,"latexLetters: latex专用组合，4字符", " "))
				end
				
				if str=="alig" then
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\begin{aligned}\r  \\end{aligned}", 1), " "))
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\begin{equation}\\begin{aligned}\r    \\end{aligned}\\end{equation}", 1), " "))
					matchFlg=true
				elseif str=="appr" then
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\approx ", 1), " "))
					matchFlg=true
				elseif str=="arra" then
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\begin{array}{rl} ab & c \\\\ b & cd \\end{array}", 1), " "))
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\begin{array}{cc} ab & c \\\\ b & cd \\end{array}", 1), " "))
					matchFlg=true
				elseif str=="beca" then
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\because ", 1), " "))
					matchFlg=true
				elseif str=="canc" then
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\cancel{}", 1), " "))
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\xcancel{}", 1), " "))
					matchFlg=true
				elseif str=="case" then
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\begin{cases}\r ?&=? \\\\ \r\\end{cases}", 1), " "))
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "x=\\begin{cases}\r ?=? &\\text{if} ? \\\\ \r\\end{cases}", 1), " "))
					matchFlg=true
				elseif str=="disp" then
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\displaystyle", 1), " "))
					matchFlg=true
				elseif str=="exis" then
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\exist ", 1), " "))
					matchFlg=true
				elseif str=="fora" then
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\forall ", 1), " "))
					matchFlg=true
				elseif str=="frac" then
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\frac{}{}", 1), " "))
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\cfrac{}{}", 1), " "))
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\dfrac{}{}", 1), " "))
					matchFlg=true
				elseif str=="grou" then
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\overgroup{}", 1), " "))
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\undergroup{}", 1), " "))
					matchFlg=true
				elseif str=="idxx" then
					for i=1,10 do
						yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "式("..tostring(i)..")", 1), " "))
					end
					matchFlg=true
				elseif str=="infi" then
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\infin", 1), " "))
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "-\\infin", 1), " "))
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "+\\infin", 1), " "))
					matchFlg=true
				elseif str=="line" then
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\overline{}", 1), " "))
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\underline{}", 1), " "))
					matchFlg=true
				elseif str=="matr" then
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\begin{matrix}\r a & b \\\\\r c & d \r\\end{matrix}", 1), " "))
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\begin{bmatrix}\r a & b \\\\\r c & d \r\\end{bmatrix}", 1), " "))
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\begin{pmatrix}\r a & b \\\\\r c & d \r\\end{pmatrix}", 1), " "))
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\begin{vmatrix}\r a & b \\\\\r c & d \r\\end{vmatrix}", 1), " "))
					matchFlg=true
				elseif str=="nexi" then
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\nexists ", 1), " "))
					matchFlg=true
				elseif str=="prod" then
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\prod_{}^{n}{}", 1), " "))
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\displaystyle\\prod_{}^{n}{}", 1), " "))
					matchFlg=true
				elseif str=="suba" then
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\begin{subarray}{c} ab \\\\ c \\end{subarray}", 1), " "))
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\begin{subarray}{l} ab \\\\ c \\end{subarray}", 1), " "))
					matchFlg=true
				elseif str=="subs" then
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\substack{ab\\\\c}", 1), " "))
					matchFlg=true
				elseif str=="sout" then
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\sout{}", 1), " "))
					matchFlg=true
				elseif str=="tria" then
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\triangleq ", 1), " "))
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\vartriangle ", 1), " "))
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\vartriangleleft ", 1), " "))
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\vartriangleright ", 1), " "))
					matchFlg=true
				elseif str=="ther" then
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\therefore ", 1), " "))
					matchFlg=true
				end
			end
			if matchFlg then
				break
			end
		end
		if matchFlg then
			returnFlg=true
			break
		end
	end
	if returnFlg then
		return 0
	end

	--3+字符关键字匹配 之 log匹配
	patterns={"log[a-zA-Z]*_?"}
	for pidx,pattern in ipairs(patterns) do
		if(string.match(input,pattern)~=nil) then
			if debugFlg then
				yield(Candidate("latex", seg.start, seg._end,"latexLetters: log匹配", " "))
			end
			
			local thisPattern=""
			
			--匹配希腊字母底
			for bidx,bNames in ipairs(xlNamesArry) do
				local bNameKey=bNames[1]
				if(string.match(input,"log"..bNameKey.."[a-zA-Z]*_?")~=nil) then
					--生成xl字符名称
					local bNameNames={}
					for k,v in ipairs(bNames) do
						if k>1 then
							table.insert(bNameNames,v)
						end
					end
					
					--匹配希腊字母自变量
					for xidx,xNames in ipairs(xlNamesArry) do
						local xNameKey=xNames[1]
						--生成xl字符名称
						local xNameNames={}
						for k,v in ipairs(xNames) do
							if k>1 then
								table.insert(xNameNames,v)
							end
						end
						
						--带下标场景
						thisPattern="log"..bNameKey..xNameKey.."_"
						if(string.match(input,thisPattern)~=nil) then
							--logpsiphi_类的输入
							for bk,bn in ipairs(bNameNames) do
								for xk,xn in ipairs(xNameNames) do
									for i=1,8 do
										yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\log_{\\"..bn.."}\\"..xn.."_{"..tostring(i).."}",1), " "))
									end
									yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\log_{\\"..bn.."}\\"..xn.."_{n}",1), " "))
									yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\log_{\\"..bn.."}\\"..xn.."_{0}",1), " "))
								end
							end
							--标记过程状态
							matchFlg=true
						end
						if matchFlg then
							break
						end
						
						--带上标场景
						thisPattern="log"..bNameKey..xNameKey.."^"
						if(string.match(input,thisPattern)~=nil) then
							--logpsiphi^类的输入
							for bk,bn in ipairs(bNameNames) do
								for xk,xn in ipairs(xNameNames) do
									yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\log_{\\"..bn.."}\\"..xn.." ",1), " "))
									for i=2,9 do
										yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\log_{\\"..bn.."}\\"..xn.."^{"..tostring(i).."}",1), " "))
									end
									yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\log_{\\"..bn.."}\\"..xn.."^{n}",1), " "))
								end
							end
							--标记过程状态
							matchFlg=true
						end
						if matchFlg then
							break
						end
						
						--不带上下标场景
						thisPattern="log"..bNameKey..xNameKey
						if(string.match(input,thisPattern)~=nil) then
							--logpsiphi类的输入
							for bk,bn in ipairs(bNameNames) do
								for xk,xn in ipairs(xNameNames) do
									yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\log_{\\"..bn.."}\\"..xn.." ",1), " "))
									for i=2,9 do
										yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\log_{\\"..bn.."}^{"..tostring(i).."}\\"..xn.." ",1), " "))
									end
									yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\log_{\\"..bn.."}^{n}\\"..xn.." ",1), " "))
								end
							end
							--标记过程状态
							matchFlg=true
						end
						if matchFlg then
							break
						end
					end
					if matchFlg then
						break
					end
					
					--匹配单字母自变量，带下标场景
					thisPattern="log"..bNameKey.."[a-zA-Z]_"
					if(string.match(input,thisPattern)~=nil) then
						--logpsia_类的输入
						str=string.match(input,"("..thisPattern..")")
						varW=string.sub(str,string.len(str)-1,string.len(str)-1)
						
						for bk,bn in ipairs(bNameNames) do
							for i=1,8 do
								yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\log_{\\"..bn.."}"..varW.."_{"..tostring(i).."}",1), " "))
							end
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\log_{\\"..bn.."}"..varW.."_{n}",1), " "))
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\log_{\\"..bn.."}"..varW.."_{0}",1), " "))
						end
						--标记过程状态
						matchFlg=true
					end
					if matchFlg then
						break
					end
					
					--匹配单字母自变量，带上标场景
					thisPattern="log"..bNameKey.."[a-zA-Z]^"
					if(string.match(input,thisPattern)~=nil) then
						--logpsia^类的输入
						str=string.match(input,"("..thisPattern..")")
						varW=string.sub(str,string.len(str)-1,string.len(str)-1)
						
						for bk,bn in ipairs(bNameNames) do
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\log_{\\"..bn.."}"..varW.." ",1), " "))
							for i=2,9 do
								yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\log_{\\"..bn.."}"..varW.."^{"..tostring(i).."}",1), " "))
							end
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\log_{\\"..bn.."}"..varW.."^{n}",1), " "))
						end
						--标记过程状态
						matchFlg=true
					end
					if matchFlg then
						break
					end
					
					--匹配单字母自变量，不带上下标场景
					thisPattern="log"..bNameKey.."[a-zA-Z]"
					if(string.match(input,thisPattern)~=nil) then
						--logpsia类的输入
						str=string.match(input,"("..thisPattern..")")
						varW=string.sub(str,string.len(str),string.len(str))
						
						for bk,bn in ipairs(bNameNames) do
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\log_{\\"..bn.."}"..varW.." ",1), " "))
							for i=2,9 do
								yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\log_{\\"..bn.."}^{"..tostring(i).."}"..varW.." ",1), " "))
							end
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\log_{\\"..bn.."}^{n}"..varW.." ",1), " "))
						end
						--标记过程状态
						matchFlg=true
					end
					if matchFlg then
						break
					end
					
					--匹配单字母自变量，不带参数场景
					thisPattern="log"..bNameKey
					if(string.match(input,thisPattern)~=nil) then
						--logpsi类的输入
						for bk,bn in ipairs(bNameNames) do
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\log_{\\"..bn.."}()",1), " "))
							for i=2,9 do
								yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\log_{\\"..bn.."}^{"..tostring(i).."}()",1), " "))
							end
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\log_{\\"..bn.."}^{n}()",1), " "))
						end
						--标记过程状态
						matchFlg=true
					end
					if matchFlg then
						break
					end
				end
			end
			if matchFlg then
				returnFlg=true
				break
			end
			
			--匹配单字母底，匹配希腊字母自变量
			for xidx,xNames in ipairs(xlNamesArry) do
				local xNameKey=xNames[1]
				--生成xl字符名称
				local xNameNames={}
				for k,v in ipairs(xNames) do
					if k>1 then
						table.insert(xNameNames,v)
					end
				end
				
				--带下标场景
				thisPattern="log[a-zA-Z]"..xNameKey.."_"
				if(string.match(input,thisPattern)~=nil) then
					--logapsi_类的输入
					str=string.match(input,"("..thisPattern..")")
					varW_1=string.sub(str,4,4)
					
					for xk,xn in ipairs(xNameNames) do
						for i=1,8 do
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\log_{"..varW_1.."}\\"..xn.."_{"..tostring(i).."}",1), " "))
						end
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\log_{"..varW_1.."}\\"..xn.."_{n}",1), " "))
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\log_{"..varW_1.."}\\"..xn.."_{0}",1), " "))
					end
					
					--标记过程状态
					matchFlg=true
				end
				if matchFlg then
					break
				end
				
				--带上标场景
				thisPattern="log[a-zA-Z]"..xNameKey.."^"
				if(string.match(input,thisPattern)~=nil) then
					--logapsi^类的输入
					str=string.match(input,"("..thisPattern..")")
					varW_1=string.sub(str,4,4)
					
					for xk,xn in ipairs(xNameNames) do
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\log_{"..varW_1.."}\\"..xn.." ",1), " "))
						for i=2,9 do
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\log_{"..varW_1.."}\\"..xn.."^{"..tostring(i).."}",1), " "))
						end
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\log_{"..varW_1.."}\\"..xn.."^{n}",1), " "))
					end
					
					--标记过程状态
					matchFlg=true
				end
				if matchFlg then
					break
				end
				
				--不带上下标场景
				thisPattern="log[a-zA-Z]"..xNameKey
				if(string.match(input,thisPattern)~=nil) then
					--logapsi类的输入
					str=string.match(input,"("..thisPattern..")")
					varW_1=string.sub(str,4,4)
					
					for xk,xn in ipairs(xNameNames) do
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\log_{"..varW_1.."}\\"..xn.." ",1), " "))
						for i=2,9 do
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\log_{"..varW_1.."}^{"..tostring(i).."}\\"..xn.." ",1), " "))
						end
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\log_{"..varW_1.."}^{n}\\"..xn.." ",1), " "))
					end
					
					--标记过程状态
					matchFlg=true
				end
				if matchFlg then
					break
				end
			end
			if matchFlg then
				returnFlg=true
				break
			end
			
			--匹配单字底，匹配单字母自变量，带下标场景
			thisPattern="log[a-zA-Z][a-zA-Z]_"
			if(string.match(input,thisPattern)~=nil) then
				--logab_类的输入
				str=string.match(input,"("..thisPattern..")")
				varW_1=string.sub(str,4,4)
				varW_2=string.sub(str,5,5)
				
				for i=1,8 do
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\log_{"..varW_1.."}"..varW_2.."_{"..tostring(i).."}",1), " "))
				end
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\log_{"..varW_1.."}"..varW_2.."_{n}",1), " "))
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\log_{"..varW_1.."}"..varW_2.."_{0}",1), " "))
				
				--标记过程状态
				matchFlg=true
			end
			if matchFlg then
				returnFlg=true
				break
			end
			
			--匹配单字底，匹配单字母自变量，带上标场景
			thisPattern="log[a-zA-Z][a-zA-Z]^"
			if(string.match(input,thisPattern)~=nil) then
				--logab_类的输入
				str=string.match(input,"("..thisPattern..")")
				varW_1=string.sub(str,4,4)
				varW_2=string.sub(str,5,5)
				
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\log_{"..varW_1.."}"..varW_2.." ",1), " "))
				for i=2,9 do
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\log_{"..varW_1.."}"..varW_2.."^{"..tostring(i).."}",1), " "))
				end
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\log_{"..varW_1.."}"..varW_2.."^{n}",1), " "))
				
				--标记过程状态
				matchFlg=true
			end
			if matchFlg then
				returnFlg=true
				break
			end
			
			--匹配单字底，匹配单字母自变量，不带上下标场景
			thisPattern="log[a-zA-Z][a-zA-Z]"
			if(string.match(input,thisPattern)~=nil) then
				--logab_类的输入
				str=string.match(input,"("..thisPattern..")")
				varW_1=string.sub(str,4,4)
				varW_2=string.sub(str,5,5)
				
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\log_{"..varW_1.."}"..varW_2.." ",1), " "))
				for i=2,9 do
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\log_{"..varW_1.."}^{"..tostring(i).."}"..varW_2.." ",1), " "))
				end
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\log_{"..varW_1.."}^{n}"..varW_2.." ",1), " "))
				
				--标记过程状态
				matchFlg=true
			end
			if matchFlg then
				returnFlg=true
				break
			end
			
			--匹配单字母自变量，不带参数场景
			thisPattern="log[a-zA-Z]"
			if(string.match(input,thisPattern)~=nil) then
				--loga类的输入
				str=string.match(input,"("..thisPattern..")")
				varW_1=string.sub(str,4,4)
				
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\log_{"..varW_1.."}()",1), " "))
				for i=2,9 do
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\log_{"..varW_1.."}^{"..tostring(i).."}()",1), " "))
				end
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\log_{"..varW_1.."}^{n}()",1), " "))
				
				--标记过程状态
				matchFlg=true
			end
			if matchFlg then
				returnFlg=true
				break
			end
			
			--匹配无底无参数场景
			thisPattern="log"
			if(string.match(input,thisPattern)~=nil) then
				--log类的输入
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\log_{?}()",1), " "))
				for i=2,9 do
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\log_{?}^{"..tostring(i).."}()",1), " "))
				end
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\log_{?}^{n}()",1), " "))
				
				--标记过程状态
				matchFlg=true
			end
			
			returnFlg = matchFlg
			
			if returnFlg then
				break
			end
		end
	end
	if returnFlg then
		return 0
	end
	
	--3+字符关键字
	patterns={"lim[a-zA-Z]+"}
	for idx,pattern in ipairs(patterns) do
		if string.match(input,pattern)~=nil then
			str=string.match(input,"("..pattern..")")
			keyW=string.sub(str,1,3)
			varW=string.sub(str,4,4)
			
			if debugFlg then
				yield(Candidate("latex", seg.start, seg._end,"latexLetters: ".. pattern..", "..str, " "))
			end
			
			if keyW=="lim" then
				
				local thisPattern=""
				
				--匹配希腊字母参数
				for xlidx,xlNames in ipairs(xlNamesArry) do
					local nameKey=xlNames[1]
					--生成xl字符名称
					local names={}
					for k,v in ipairs(xlNames) do
						if k>1 then
							table.insert(names,v)
						end
					end
					
					if(string.match(input,pattern..".+_")~=nil) then
						--匹配希腊字母带下标
						thisPattern=keyW..nameKey.."_"
						if(string.match(input,thisPattern)~=nil) then
							--生成候选词
							for k,name in ipairs(names) do
								yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\displaystyle\\"..keyW.."_{\\"..name.."\\to0}{}", 1), " "))
								for i=2,9 do
									yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\displaystyle\\"..keyW.."_{\\"..name.."_{"..tostring(i).."}".."\\to0}{}", 1), " "))
								end
								yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\displaystyle\\"..keyW.."_{\\"..name.."_{n}\\to0}{}", 1), " "))
								
								yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\displaystyle\\"..keyW.."_{\\"..name.."\\to\\infin}{}", 1), " "))
								for i=2,9 do
									yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\displaystyle\\"..keyW.."_{\\"..name.."_{"..tostring(i).."}".."\\to\\infin}{}", 1), " "))
								end
								yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\displaystyle\\"..keyW.."_{\\"..name.."_{n}\\to\\infin}{}", 1), " "))
								
								yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\displaystyle\\"..keyW.."_{\\"..name.."\\to-\\infin}{}", 1), " "))
								for i=2,9 do
									yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\displaystyle\\"..keyW.."_{\\"..name.."_{"..tostring(i).."}".."\\to-\\infin}{}", 1), " "))
								end
								yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\displaystyle\\"..keyW.."_{\\"..name.."_{n}\\to-\\infin}{}", 1), " "))
							end
							--标记过程状态
							matchFlg=true
						end
					elseif(string.match(input,pattern..".+^")~=nil) then
						--匹配希腊字母本身带上标
						thisPattern=keyW..nameKey.."^"
						if(string.match(input,thisPattern)~=nil) then
							--生成候选词
							for k,name in ipairs(names) do
								yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\displaystyle\\"..keyW.."_{\\"..name.."\\to0}{}", 1), " "))
								for i=2,9 do
									yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\displaystyle\\"..keyW.."_{\\"..name.."^{"..tostring(i).."}".."\\to0}{}", 1), " "))
								end
								yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\displaystyle\\"..keyW.."_{\\"..name.."^{n}\\to0}{}", 1), " "))
								
								yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\displaystyle\\"..keyW.."_{\\"..name.."\\to\\infin}{}", 1), " "))
								for i=2,9 do
									yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\displaystyle\\"..keyW.."_{\\"..name.."^{"..tostring(i).."}".."\\to\\infin}{}", 1), " "))
								end
								yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\displaystyle\\"..keyW.."_{\\"..name.."^{n}\\to\\infin}{}", 1), " "))
								
								yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\displaystyle\\"..keyW.."_{\\"..name.."\\to-\\infin}{}", 1), " "))
								for i=2,9 do
									yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\displaystyle\\"..keyW.."_{\\"..name.."^{"..tostring(i).."}".."\\to-\\infin}{}", 1), " "))
								end
								yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\displaystyle\\"..keyW.."_{\\"..name.."^{n}\\to-\\infin}{}", 1), " "))
							end
							--标记过程状态
							matchFlg=true
						end
					else
						--匹配希腊字母本身
						thisPattern=keyW..nameKey
						if(string.match(input,thisPattern)~=nil) then
							--生成候选词
							for k,name in ipairs(names) do
								yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\displaystyle\\"..keyW.."_{\\"..name.."\\to0}{}", 1), " "))
								yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\displaystyle\\"..keyW.."_{\\"..name.."\\to\\infin}{}", 1), " "))
								yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\displaystyle\\"..keyW.."_{\\"..name.."\\to-\\infin}{}", 1), " "))
							end
							--标记过程状态
							matchFlg=true
						end
					end
					if matchFlg then
						break
					end
				end
				if matchFlg then
					break
				end
				
				--匹配正常字母参数
				thisPattern=keyW.."[a-zA-Z][_^]?"
				if(string.match(input,thisPattern)~=nil) then
					str=string.match(input,"("..thisPattern..")")
					varW=string.sub(str,string.len(keyW)+1,string.len(keyW)+1)
					varW_1=string.sub(str,string.len(str))
					
					if varW_1=='_' then
						--匹配正常字母参数，带下标
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\displaystyle\\"..keyW.."_{"..varW.."\\to0}{}", 1), " "))
						for i=2,9 do
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\displaystyle\\"..keyW.."_{"..varW.."_{"..tostring(i).."}".."\\to0}{}", 1), " "))
						end
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\displaystyle\\"..keyW.."_{"..varW.."_{n}\\to0}{}", 1), " "))
						
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\displaystyle\\"..keyW.."_{"..varW.."\\to\\infin}{}", 1), " "))
						for i=2,9 do
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\displaystyle\\"..keyW.."_{"..varW.."_{"..tostring(i).."}".."\\to\\infin}{}", 1), " "))
						end
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\displaystyle\\"..keyW.."_{"..varW.."_{n}\\to\\infin}{}", 1), " "))
						
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\displaystyle\\"..keyW.."_{"..varW.."\\to-\\infin}{}", 1), " "))
						for i=2,9 do
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\displaystyle\\"..keyW.."_{"..varW.."_{"..tostring(i).."}".."\\to-\\infin}{}", 1), " "))
						end
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\displaystyle\\"..keyW.."_{"..varW.."_{n}\\to-\\infin}{}", 1), " "))
						
						--标记过程状态
						matchFlg=true
					elseif varW_1=='^' then
						--匹配正常字母参数，带上标
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\displaystyle\\"..keyW.."_{"..varW.."\\to0}{}", 1), " "))
						for i=2,9 do
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\displaystyle\\"..keyW.."_{"..varW.."^{"..tostring(i).."}".."\\to0}{}", 1), " "))
						end
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\displaystyle\\"..keyW.."_{"..varW.."^{n}\\to0}{}", 1), " "))
						
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\displaystyle\\"..keyW.."_{"..varW.."\\to\\infin}{}", 1), " "))
						for i=2,9 do
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\displaystyle\\"..keyW.."_{"..varW.."^{"..tostring(i).."}".."\\to\\infin}{}", 1), " "))
						end
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\displaystyle\\"..keyW.."_{"..varW.."^{n}\\to\\infin}{}", 1), " "))
						
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\displaystyle\\"..keyW.."_{"..varW.."\\to-\\infin}{}", 1), " "))
						for i=2,9 do
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\displaystyle\\"..keyW.."_{"..varW.."^{"..tostring(i).."}".."\\to-\\infin}{}", 1), " "))
						end
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\displaystyle\\"..keyW.."_{"..varW.."^{n}\\to-\\infin}{}", 1), " "))
						
						--标记过程状态
						matchFlg=true
					else
						--匹配正常字母参数，不带上下标
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\displaystyle\\"..keyW.."_{"..varW.."\\to0}{}", 1), " "))
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\displaystyle\\"..keyW.."_{"..varW.."\\to\\infin}{}", 1), " "))
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\displaystyle\\"..keyW.."_{"..varW.."\\to-\\infin}{}", 1), " "))
						
						--标记过程状态
						matchFlg=true
					end
				end
				if matchFlg then
					break
				end
			end
			
			returnFlg=matchFlg
			
			if returnFlg then
				break
			end
		end
	end
	if returnFlg then
		return 0
	end

	--3+字符关键字，匹配点
	patterns={"dot[-\\_]?"}
	for idx,pattern in ipairs(patterns) do
		if string.match(input,pattern)~=nil then
			str=string.match(input,"("..pattern..")")
			if string.len(str)==4 then
				varW=string.sub(str,4,4)
			else
				varW=""
			end
			
			if debugFlg then
				yield(Candidate("latex", seg.start, seg._end,"latexLetters: ".. pattern..", "..str, " "))
			end
			
			matchFlg=false
			if varW=='-' then
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, pattern, "\\cdots ", 1), " "))
				matchFlg=true
			elseif varW=='_' then
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, pattern, "\\ldots ", 1), " "))
				matchFlg=true
			elseif varW=='|' then
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, pattern, "\\vdots ", 1), " "))
				matchFlg=true
			elseif varW=='\\' then
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, pattern, "\\ddots ", 1), " "))
				matchFlg=true
			else
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, pattern, "\\sdot ", 1), " "))
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, pattern, "\\dots ", 1), " "))
				matchFlg=true
			end
			
			if matchFlg then
				returnFlg=true
				break
			end
		end
	end
	if returnFlg then
		return 0
	end

	--3+字符关键字匹配 之 三角函数匹配
	patterns={"sin","cos","tan","cot","sec","csc"}
	for pidx,pattern in ipairs(patterns) do
		if(string.match(input,pattern)~=nil) then
			if debugFlg then
				yield(Candidate("latex", seg.start, seg._end,"latexLetters: 三角函数匹配", " "))
			end
			
			keyW="\\"..pattern
			local thisPattern=""
			
			--匹配希腊字母参数
			for xlidx,xlNames in ipairs(xlNamesArry) do
				local nameKey=xlNames[1]
				--生成xl字符名称
				local names={}
				for k,v in ipairs(xlNames) do
					if k>1 then
						table.insert(names,v)
					end
				end
				
				if(string.match(input,pattern..".+_")~=nil) then
					--匹配希腊字母带下标
					thisPattern=pattern..nameKey.."_"
					if(string.match(input,thisPattern)~=nil) then
						--生成候选词
						for k,name in ipairs(names) do
							for i=1,8 do
								yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{\\"..name.."_{"..tostring(i).."}}",1), " "))
							end
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{\\"..name.."_{n}}",1), " "))
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{\\"..name.."_{0}}",1), " "))
						end
						--标记过程状态
						matchFlg=true
					end
				elseif(string.match(input,pattern..".+^")~=nil) then
					--匹配希腊字母本身带上标
					thisPattern=pattern..nameKey.."^"
					if(string.match(input,thisPattern)~=nil) then
						--生成候选词
						for k,name in ipairs(names) do
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{\\"..name.."}",1), " "))
							for i=2,9 do
								yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{\\"..name.."^{"..tostring(i).."}}",1), " "))
							end
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{\\"..name.."^{n}}",1), " "))
						end
						--标记过程状态
						matchFlg=true
					end
				else
					--匹配希腊字母本身
					thisPattern=pattern..nameKey
					if(string.match(input,thisPattern)~=nil) then
						--生成候选词
						for k,name in ipairs(names) do
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{\\"..name.."}",1), " "))
							for i=2,9 do
								yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."^{"..tostring(i).."}{\\"..name.."}",1), " "))
							end
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."^{n}{\\"..name.."}",1), " "))
						end
						--标记过程状态
						matchFlg=true
					end
				end
				if matchFlg then
					break
				end
			end
			if matchFlg then
				break
			end
			
			--匹配正常字母参数
			thisPattern=pattern.."[a-zA-Z][_^]?"
			if(string.match(input,thisPattern)~=nil) then
				str=string.match(input,"("..thisPattern..")")
				varW=string.sub(str,string.len(pattern)+1,string.len(pattern)+1)
				varW_1=string.sub(str,string.len(str))
				
				if varW_1=='_' then
					--匹配正常字母参数，带下标
					for i=1,8 do
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{"..varW.."_{"..tostring(i).."}}",1), " "))
					end
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{"..varW.."_{n}}",1), " "))
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{"..varW.."_{0}}",1), " "))
					
					--标记过程状态
					matchFlg=true
				elseif varW_1=='^' then
					--匹配正常字母参数，带上标
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{"..varW.."}",1), " "))
					for i=2,9 do
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{"..varW.."^{"..tostring(i).."}}",1), " "))
					end
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{"..varW.."^{n}}",1), " "))
					--标记过程状态
					matchFlg=true
				else
					--匹配正常字母参数，不带上下标
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{"..varW.."}",1), " "))
					for i=2,9 do
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."^{"..tostring(i).."}{"..varW.."}",1), " "))
					end
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."^{n}{"..varW.."}",1), " "))
					--标记过程状态
					matchFlg=true
				end
			end
			if matchFlg then
				break
			end
			
			--匹配无参数
			thisPattern=pattern
			if(string.match(input,thisPattern)~=nil) then
				str=string.match(input,"("..thisPattern..")")
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."()",1), " "))
				for i=2,9 do
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."^{"..tostring(i).."}()",1), " "))
				end
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."^{n}()",1), " "))
				
				--标记过程状态
				matchFlg=true
			end
			if matchFlg then
				returnFlg=true
				break
			end
		end
	end
	if returnFlg then
		return 0
	end

	--3+字符关键字匹配 之 abs操作符匹配
	patterns={"abs"}
	for pidx,pattern in ipairs(patterns) do
		if(string.match(input,pattern)~=nil) then
			if debugFlg then
				yield(Candidate("latex", seg.start, seg._end,"latexLetters: abs 操作符匹配", " "))
			end
			
			keyW="\\left|"
			keyWEnd="\\right|"
			local thisPattern=""
			
			--匹配希腊字母参数
			for xlidx,xlNames in ipairs(xlNamesArry) do
				local nameKey=xlNames[1]
				--生成xl字符名称
				local names={}
				for k,v in ipairs(xlNames) do
					if k>1 then
						table.insert(names,v)
					end
				end
				
				if(string.match(input,pattern..".+_")~=nil) then
					--匹配希腊字母带下标
					thisPattern=pattern..nameKey.."_"
					if(string.match(input,thisPattern)~=nil) then
						--生成候选词
						for k,name in ipairs(names) do
							for i=1,8 do
								yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{\\"..name.."_{"..tostring(i).."}}"..keyWEnd,1), " "))
							end
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{\\"..name.."_{n}}"..keyWEnd,1), " "))
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{\\"..name.."_{0}}"..keyWEnd,1), " "))
						end
						--标记过程状态
						matchFlg=true
					end
				elseif(string.match(input,pattern..".+^")~=nil) then
					--匹配希腊字母本身带上标
					thisPattern=pattern..nameKey.."^"
					if(string.match(input,thisPattern)~=nil) then
						--生成候选词
						for k,name in ipairs(names) do
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{\\"..name.."}"..keyWEnd,1), " "))
							for i=2,9 do
								yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{\\"..name.."}"..keyWEnd.."^{"..tostring(i).."}",1), " "))
							end
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{\\"..name.."}"..keyWEnd.."^{n}",1), " "))
						end
						--标记过程状态
						matchFlg=true
					end
				else
					--匹配希腊字母本身
					thisPattern=pattern..nameKey
					if(string.match(input,thisPattern)~=nil) then
						--生成候选词
						for k,name in ipairs(names) do
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{\\"..name.."}"..keyWEnd,1), " "))
							for i=2,9 do
								yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{\\"..name.."}"..keyWEnd.."^{"..tostring(i).."}",1), " "))
							end
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{\\"..name.."}"..keyWEnd.."^{n}",1), " "))
						end
						--标记过程状态
						matchFlg=true
					end
				end
				if matchFlg then
					break
				end
			end
			if matchFlg then
				break
			end
			
			--匹配正常字母参数
			thisPattern=pattern.."[a-zA-Z][_^]?"
			if(string.match(input,thisPattern)~=nil) then
				str=string.match(input,"("..thisPattern..")")
				varW=string.sub(str,string.len(pattern)+1,string.len(pattern)+1)
				varW_1=string.sub(str,string.len(str))
				
				if varW_1=='_' then
					--匹配正常字母参数，带下标
					for i=1,8 do
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{"..varW.."_{"..tostring(i).."}}"..keyWEnd,1), " "))
					end
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{"..varW.."_{n}}"..keyWEnd,1), " "))
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{"..varW.."_{0}}"..keyWEnd,1), " "))
					
					--标记过程状态
					matchFlg=true
				elseif varW_1=='^' then
					--匹配正常字母参数，带上标
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{"..varW.."}"..keyWEnd,1), " "))
					for i=2,9 do
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{"..varW.."^{"..tostring(i).."}}"..keyWEnd,1), " "))
					end
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{"..varW.."^{n}}"..keyWEnd,1), " "))
					
					--标记过程状态
					matchFlg=true
				else
					--匹配正常字母参数，不带上下标
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{"..varW.."}"..keyWEnd,1), " "))
					for i=2,9 do
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{"..varW.."}"..keyWEnd.."^{"..tostring(i).."}",1), " "))
					end
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{"..varW.."}"..keyWEnd.."^{n}",1), " "))
					
					--标记过程状态
					matchFlg=true
				end
			end
			if matchFlg then
				break
			end
			
			--匹配无参数
			thisPattern=pattern
			if(string.match(input,thisPattern)~=nil) then
				str=string.match(input,"("..thisPattern..")")
				
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{?}"..keyWEnd,1), " "))
				for i=2,9 do
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{?}"..keyWEnd.."^{"..tostring(i).."}",1), " "))
				end
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{?}"..keyWEnd.."^{n}",1), " "))
				
				--标记过程状态
				matchFlg=true
			end
			if matchFlg then
				returnFlg=true
				break
			end
		end
	end
	if returnFlg then
		return 0
	end

	--3+字符关键字匹配 之 bar操作符匹配
	patterns={"bar"}
	for pidx,pattern in ipairs(patterns) do
		if(string.match(input,pattern)~=nil) then
			if debugFlg then
				yield(Candidate("latex", seg.start, seg._end,"latexLetters: bar 操作符匹配", " "))
			end
			
			keyW="\\"..pattern
			local thisPattern=""
			
			--匹配希腊字母参数
			for xlidx,xlNames in ipairs(xlNamesArry) do
				local nameKey=xlNames[1]
				--生成xl字符名称
				local names={}
				for k,v in ipairs(xlNames) do
					if k>1 then
						table.insert(names,v)
					end
				end
				
				if(string.match(input,pattern..".+_")~=nil) then
					--匹配希腊字母带下标
					thisPattern=pattern..nameKey.."_"
					if(string.match(input,thisPattern)~=nil) then
						--生成候选词
						for k,name in ipairs(names) do
							for i=1,8 do
								yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{\\"..name.."_{"..tostring(i).."}}",1), " "))
							end
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{\\"..name.."_{n}}",1), " "))
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{\\"..name.."_{0}}",1), " "))
						end
						--标记过程状态
						matchFlg=true
					end
				elseif(string.match(input,pattern..".+^")~=nil) then
					--匹配希腊字母本身带上标
					thisPattern=pattern..nameKey.."^"
					if(string.match(input,thisPattern)~=nil) then
						--生成候选词
						for k,name in ipairs(names) do
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{\\"..name.."}",1), " "))
							for i=2,9 do
								yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{\\"..name.."^{"..tostring(i).."}}",1), " "))
							end
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{\\"..name.."^{n}}",1), " "))
						end
						--标记过程状态
						matchFlg=true
					end
				else
					--匹配希腊字母本身
					thisPattern=pattern..nameKey
					if(string.match(input,thisPattern)~=nil) then
						--生成候选词
						for k,name in ipairs(names) do
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{\\"..name.."}",1), " "))
							for i=2,9 do
								yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{\\"..name.."}^{"..tostring(i).."}",1), " "))
							end
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{\\"..name.."}^{n}",1), " "))
						end
						--标记过程状态
						matchFlg=true
					end
				end
				if matchFlg then
					break
				end
			end
			if matchFlg then
				break
			end
			
			--匹配正常字母参数
			thisPattern=pattern.."[a-zA-Z][_^]?"
			if(string.match(input,thisPattern)~=nil) then
				str=string.match(input,"("..thisPattern..")")
				varW=string.sub(str,string.len(pattern)+1,string.len(pattern)+1)
				varW_1=string.sub(str,string.len(str))
				
				if varW_1=='_' then
					--匹配正常字母参数，带下标
					for i=1,8 do
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{"..varW.."_{"..tostring(i).."}}",1), " "))
					end
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{"..varW.."_{n}}",1), " "))
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{"..varW.."_{0}}",1), " "))
					
					--标记过程状态
					matchFlg=true
				elseif varW_1=='^' then
					--匹配正常字母参数，带上标
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{"..varW.."}",1), " "))
					for i=2,9 do
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{"..varW.."^{"..tostring(i).."}}",1), " "))
					end
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{"..varW.."^{n}}",1), " "))
					
					--标记过程状态
					matchFlg=true
				else
					--匹配正常字母参数，不带上下标
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{"..varW.."}",1), " "))
					for i=2,9 do
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{"..varW.."}^{"..tostring(i).."}",1), " "))
					end
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{"..varW.."}^{n}",1), " "))
					
					--标记过程状态
					matchFlg=true
				end
			end
			if matchFlg then
				break
			end
			
			--匹配无参数
			thisPattern=pattern
			if(string.match(input,thisPattern)~=nil) then
				str=string.match(input,"("..thisPattern..")")
				
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{?}",1), " "))
				for i=2,9 do
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{?}^{"..tostring(i).."}",1), " "))
				end
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{?}^{n}",1), " "))
				
				--标记过程状态
				matchFlg=true
			end
			if matchFlg then
				returnFlg=true
				break
			end
		end
	end
	if returnFlg then
		return 0
	end

	--3+字符关键字匹配 之 积分符号匹配
	patterns={"intc","int"}
	for pidx,pattern in ipairs(patterns) do
		if(string.match(input,pattern)~=nil) then
			if debugFlg then
				yield(Candidate("latex", seg.start, seg._end,"latexLetters: 积分符号匹配", " "))
			end
			
			if pattern=="int" then
				keyW="\\"..pattern.."_{a}^{b}"
			elseif pattern=="intc" then
				keyW="\\"..string.sub(pattern,1,string.len(pattern)-1).." "
			end
			local thisPattern=""
			
			--匹配希腊字母参数
			for xlidx,xlNames in ipairs(xlNamesArry) do
				local nameKey=xlNames[1]
				--生成xl字符名称
				local names={}
				for k,v in ipairs(xlNames) do
					if k>1 then
						table.insert(names,v)
					end
				end
				
				if(string.match(input,pattern..".+_")~=nil) then
					--匹配希腊字母带下标
					thisPattern=pattern..nameKey.."_"
					if(string.match(input,thisPattern)~=nil) then
						--生成候选词
						for k,name in ipairs(names) do
							for i=1,8 do
								yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."d\\"..name.."_{"..tostring(i).."}",1), " "))
							end
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."d\\"..name.."_{n}",1), " "))
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."d\\"..name.."_{0}",1), " "))
						end
						--标记过程状态
						matchFlg=true
					end
				else
					--匹配希腊字母本身
					thisPattern=pattern..nameKey
					if(string.match(input,thisPattern)~=nil) then
						--生成候选词
						for k,name in ipairs(names) do
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."d\\"..name.." ",1), " "))
							for i=2,9 do
								yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."d(\\"..name.."^{"..tostring(i).."})",1), " "))
							end
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."d(\\"..name.."^{n})",1), " "))
						end
						--标记过程状态
						matchFlg=true
					end
				end
				if matchFlg then
					break
				end
			end
			if matchFlg then
				break
			end
			
			--匹配正常字母参数
			thisPattern=pattern.."[a-zA-Z]_?"
			if(string.match(input,thisPattern)~=nil) then
				str=string.match(input,"("..thisPattern..")")
				varW=string.sub(str,string.len(pattern)+1,string.len(pattern)+1)
				varW_1=string.sub(str,string.len(str))
				
				if varW_1=='_' then
					--匹配正常字母参数，带下标
					for i=1,8 do
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."d"..varW.."_{"..tostring(i).."}",1), " "))
					end
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."d"..varW.."_{n}",1), " "))
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."d"..varW.."_{0}",1), " "))
					
					--标记过程状态
					matchFlg=true
				else
					--匹配正常字母参数，不带上下标
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."d"..varW.."",1), " "))
					for i=2,9 do
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."d("..varW.."^{"..tostring(i).."})",1), " "))
					end
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."d("..varW.."^{n})",1), " "))
					
					--标记过程状态
					matchFlg=true
				end
			end
			if matchFlg then
				break
			end
			
			--匹配无参数
			thisPattern=pattern
			if(string.match(input,thisPattern)~=nil) then
				str=string.match(input,"("..thisPattern..")")
				
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."d()",1), " "))
				for i=2,9 do
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."d(x^{"..tostring(i).."})",1), " "))
				end
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."d(x^{n})",1), " "))
				
				--标记过程状态
				matchFlg=true
			end
			if matchFlg then
				returnFlg=true
				break
			end
		end
	end
	if returnFlg then
		return 0
	end

	--3+字符关键字匹配 之 开方匹配
	patterns={"sqrt","sqr"}
	for pidx,pattern in ipairs(patterns) do
		if(string.match(input,pattern)~=nil) then
			if debugFlg then
				yield(Candidate("latex", seg.start, seg._end,"latexLetters: 开方匹配", " "))
			end
			
			if(pattern=="sqr") then
				keyW="\\"..pattern.."t"
			else
				keyW="\\"..pattern
			end
			local thisPattern=""
			
			--匹配希腊字母参数
			for xlidx,xlNames in ipairs(xlNamesArry) do
				local nameKey=xlNames[1]
				--生成xl字符名称
				local names={}
				for k,v in ipairs(xlNames) do
					if k>1 then
						table.insert(names,v)
					end
				end
				
				if(string.match(input,pattern..".+_")~=nil) then
					--匹配希腊字母带下标
					thisPattern=pattern..nameKey.."_"
					if(string.match(input,thisPattern)~=nil) then
						--生成候选词
						for k,name in ipairs(names) do
							for i=1,8 do
								yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{\\"..name.."_{"..tostring(i).."}}",1), " "))
							end
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{\\"..name.."_{n}}",1), " "))
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{\\"..name.."_{0}}",1), " "))
						end
						--标记过程状态
						matchFlg=true
					end
				else
					--匹配希腊字母本身
					thisPattern=pattern..nameKey
					if(string.match(input,thisPattern)~=nil) then
						--生成候选词
						for k,name in ipairs(names) do
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{\\"..name.." }",1), " "))
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{\\"..name.."}",1), " "))
							for i=3,9 do
								yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."["..tostring(i).."]{\\"..name.."}",1), " "))
							end
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."[n]{\\"..name.."}",1), " "))
						end
						--标记过程状态
						matchFlg=true
					end
				end
				if matchFlg then
					break
				end
			end
			if matchFlg then
				break
			end
			
			--匹配正常字母参数
			thisPattern=pattern.."[a-zA-Z]_?"
			if(string.match(input,thisPattern)~=nil) then
				str=string.match(input,"("..thisPattern..")")
				varW=string.sub(str,string.len(pattern)+1,string.len(pattern)+1)
				varW_1=string.sub(str,string.len(str))
				
				if varW_1=='_' then
					--匹配正常字母参数，带下标
					for i=1,8 do
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{"..varW.."_{"..tostring(i).."}}",1), " "))
					end
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{"..varW.."_{n}}",1), " "))
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{"..varW.."_{0}}",1), " "))
					
					--标记过程状态
					matchFlg=true
				else
					--匹配正常字母参数，不带上下标
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{"..varW.." }",1), " "))
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{"..varW.."}",1), " "))
					for i=3,9 do
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."["..tostring(i).."]{"..varW.."}",1), " "))
					end
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."[n]{"..varW.."}",1), " "))
					
					--标记过程状态
					matchFlg=true
				end
			end
			if matchFlg then
				break
			end
			
			--匹配无参数
			thisPattern=pattern
			if(string.match(input,thisPattern)~=nil) then
				str=string.match(input,"("..thisPattern..")")
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{ }",1), " "))
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{}",1), " "))
				for i=3,9 do
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."["..tostring(i).."]{}",1), " "))
				end
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."[n]{}",1), " "))
				
				--标记过程状态
				matchFlg=true
			end
			if matchFlg then
				returnFlg=true
				break
			end
		end
	end
	if returnFlg then
		return 0
	end

	--2+字符关键字
	patterns={"mr[a-zA-Z][a-zA-Z]"}
	for idx,pattern in ipairs(patterns) do
		if string.match(input,pattern)~=nil then
			str=string.match(input,"("..pattern..")")
			keyW=string.sub(str,3,3)
			varW=string.sub(str,4,4)
			
			if debugFlg then
				yield(Candidate("latex", seg.start, seg._end,"latexLetters: ".. pattern..", "..str, " "))
			end
			
			keyW_u=string.upper(keyW)
			
			yield(Candidate("latex", seg.start, seg._end, string.gsub (input, pattern, "\\mathring{"..keyW_u.."}("..varW..")", 1), " "))
			yield(Candidate("latex", seg.start, seg._end, string.gsub (input, pattern, "\\mathring{"..keyW_u.."}("..varW.."_0)", 1), " "))
			yield(Candidate("latex", seg.start, seg._end, string.gsub (input, pattern, "\\mathring{"..keyW_u.."}("..varW.."_0, \\delta)", 1), " "))
			
			returnFlg=true
			break
		end
	end
	if returnFlg then
		return 0
	end

	--2+字符关键字匹配 之 对数匹配
	patterns={"lg","ln"}
	for pidx,pattern in ipairs(patterns) do
		if(string.match(input,pattern)~=nil) then
			if debugFlg then
				yield(Candidate("latex", seg.start, seg._end,"latexLetters: 对数匹配", " "))
			end
			
			keyW="\\"..pattern
			local thisPattern=""
			
			--匹配希腊字母参数
			for xlidx,xlNames in ipairs(xlNamesArry) do
				local nameKey=xlNames[1]
				--生成xl字符名称
				local names={}
				for k,v in ipairs(xlNames) do
					if k>1 then
						table.insert(names,v)
					end
				end
				
				if(string.match(input,pattern..".+_")~=nil) then
					--匹配希腊字母带下标
					thisPattern=pattern..nameKey.."_"
					if(string.match(input,thisPattern)~=nil) then
						--生成候选词
						for k,name in ipairs(names) do
							for i=1,8 do
								yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{\\"..name.."_{"..tostring(i).."}}",1), " "))
							end
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{\\"..name.."_{n}}",1), " "))
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{\\"..name.."_{0}}",1), " "))
						end
						--标记过程状态
						matchFlg=true
					end
				elseif(string.match(input,pattern..".+^")~=nil) then
					--匹配希腊字母本身带上标
					thisPattern=pattern..nameKey.."^"
					if(string.match(input,thisPattern)~=nil) then
						--生成候选词
						for k,name in ipairs(names) do
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{\\"..name.."}",1), " "))
							for i=2,9 do
								yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{\\"..name.."^{"..tostring(i).."}}",1), " "))
							end
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{\\"..name.."^{n}}",1), " "))
						end
						--标记过程状态
						matchFlg=true
					end
				else
					--匹配希腊字母本身
					thisPattern=pattern..nameKey
					if(string.match(input,thisPattern)~=nil) then
						--生成候选词
						for k,name in ipairs(names) do
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{\\"..name.."}",1), " "))
							for i=2,9 do
								yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."^{"..tostring(i).."}{\\"..name.."}",1), " "))
							end
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."^{n}{\\"..name.."}",1), " "))
						end
						--标记过程状态
						matchFlg=true
					end
				end
				if matchFlg then
					break
				end
			end
			if matchFlg then
				break
			end
			
			--匹配正常字母参数
			thisPattern=pattern.."[a-zA-Z][_^]?"
			if(string.match(input,thisPattern)~=nil) then
				str=string.match(input,"("..thisPattern..")")
				varW=string.sub(str,string.len(pattern)+1,string.len(pattern)+1)
				varW_1=string.sub(str,string.len(str))
				
				if varW_1=='_' then
					--匹配正常字母参数，带下标
					for i=1,8 do
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{"..varW.."_{"..tostring(i).."}}",1), " "))
					end
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{"..varW.."_{n}}",1), " "))
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{"..varW.."_{0}}",1), " "))
					
					--标记过程状态
					matchFlg=true
				elseif varW_1=='^' then
					--匹配正常字母参数，带上标
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{"..varW.."}",1), " "))
					for i=2,9 do
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{"..varW.."^{"..tostring(i).."}}",1), " "))
					end
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{"..varW.."^{n}}",1), " "))
					--标记过程状态
					matchFlg=true
				else
					--匹配正常字母参数，不带上下标
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."{"..varW.."}",1), " "))
					for i=2,9 do
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."^{"..tostring(i).."}{"..varW.."}",1), " "))
					end
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."^{n}{"..varW.."}",1), " "))
					--标记过程状态
					matchFlg=true
				end
			end
			if matchFlg then
				break
			end
			
			--匹配无参数
			thisPattern=pattern
			if(string.match(input,thisPattern)~=nil) then
				str=string.match(input,"("..thisPattern..")")
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."()",1), " "))
				for i=2,9 do
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."^{"..tostring(i).."}()",1), " "))
				end
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."^{n}()",1), " "))
				
				--标记过程状态
				matchFlg=true
			end
			if matchFlg then
				returnFlg=true
				break
			end
		end
	end
	if returnFlg then
		return 0
	end

	--3字符关键字
	patterns={"[prPR]n[a-z]"}
	for idx,pattern in ipairs(patterns) do
		if string.match(input,pattern)~=nil then
			str=string.match(input,"("..pattern..")")
			keyW=string.sub(str,1,1)
			varW_1=string.sub(str,2,2)
			varW_2=string.sub(str,3,3)
			
			if debugFlg then
				yield(Candidate("latex", seg.start, seg._end,"latexLetters: ".. pattern..", "..str, " "))
			end
			
			yield(Candidate("latex", seg.start, seg._end, string.gsub (input, pattern, string.upper(keyW).."_"..varW_1.."("..varW_2..")", 1), " "))
			
			returnFlg=true
			break
		end
	end
	if returnFlg then
		return 0
	end

	--3字符关键字，latex专用组合
	patterns={"[a-zA-Z][a-zA-Z][a-zA-Z]"}
	for pos=1,string.len(input) do
		matchFlg=false
		for idx,pattern in ipairs(patterns) do
			if string.match(input,pattern,pos)~=nil then
				str=string.match(input,"("..pattern..")",pos)
				if pos==1 then
					subStr_0=""
				else
					subStr_0=string.sub(input,1,pos-1)
				end
				subStr_1=string.sub(input,pos,string.len(input))
				
				if debugFlg then
					yield(Candidate("latex", seg.start, seg._end,"latexLetters: latex专用组合,3字符", " "))
					yield(Candidate("latex", seg.start, seg._end,"latexLetters: subStr_0, "..subStr_0, " "))
					yield(Candidate("latex", seg.start, seg._end,"latexLetters: subStr_1, "..subStr_1, " "))
				end
				
				if str=="bar" then
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\bar{} ", 1), " "))
					matchFlg=true
				elseif str=="big" then
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\big ", 1), " "))
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\Big ", 1), " "))
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\bigg ", 1), " "))
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\Bigg ", 1), " "))
					matchFlg=true
				elseif str=="box" then
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\boxed{}", 1), " "))
					matchFlg=true
				elseif str=="cap" then
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\cap ", 1), " "))
					matchFlg=true
				elseif str=="cup" then
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\cup ", 1), " "))
					matchFlg=true
				elseif str=="idx" then
					for i=1,10 do
						yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\quad("..tostring(i)..")", 1), " "))
					end
					matchFlg=true
				elseif str=="max" then
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\max()", 1), " "))
					matchFlg=true
				elseif str=="min" then
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\min()", 1), " "))
					matchFlg=true
				elseif str=="neq" then
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\neq ", 1), " "))
					matchFlg=true
				elseif str=="not" then
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\not ", 1), " "))
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\not=", 1), " "))
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\notin ", 1), " "))
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\notni ", 1), " "))
					matchFlg=true
				elseif str=="set" then
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\subset ", 1), " "))
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\supset ", 1), " "))
					matchFlg=true
				elseif str=="sim" then
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\sim ", 1), " "))
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\thicksim ", 1), " "))
					matchFlg=true
				elseif str=="sum" then
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\sum_{k=1}^{n}{}", 1), " "))
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\displaystyle\\sum_{k=1}^{n}{}", 1), " "))
					matchFlg=true
				end
			end
			if matchFlg then
				break
			end
		end
		if matchFlg then
			returnFlg=true
			break
		end
	end
	if returnFlg then
		return 0
	end

	--2字符关键字，latex固定组合
	patterns={"[a-zA-Z][a-zA-Z]"}
	for pos=1,string.len(input) do
		matchFlg=false
		for idx,pattern in ipairs(patterns) do
			if string.match(input,pattern,pos)~=nil then
				str=string.match(input,"("..pattern..")",pos)
				if pos==1 then
					subStr_0=""
				else
					subStr_0=string.sub(input,1,pos-1)
				end
				subStr_1=string.sub(input,pos,string.len(input))
				keyW=string.sub(subStr_1,1,1)
				varW=string.sub(subStr_1,2,2)
				
				if debugFlg then
					yield(Candidate("latex", seg.start, seg._end,"latexLetters: latex固定组合，2字符", " "))
				end
				
				if str=='in' then
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\in ",1), " "))
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\in()",1), " "))
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, keyW.."_{"..varW.."}",1), " "))
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, keyW.."^{"..varW.."}",1), " "))
					matchFlg=true
				elseif str=='mp' or str=='pm' then
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\"..str.." ",1), " "))
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, keyW.."_{"..varW.."}",1), " "))
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, keyW.."^{"..varW.."}",1), " "))
					matchFlg=true
				elseif str=='ni' then
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\ni ",1), " "))
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, keyW.."_{"..varW.."}",1), " "))
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, keyW.."^{"..varW.."}",1), " "))
					matchFlg=true
				elseif str=='to' then
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\to ",1), " "))
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, keyW.."_{"..varW.."}",1), " "))
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, keyW.."^{"..varW.."}",1), " "))
					matchFlg=true
				elseif string.match(str,"[gl][et]")~=nil then
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\"..str.." ",1), " "))
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, keyW.."_{"..varW.."}",1), " "))
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, keyW.."^{"..varW.."}",1), " "))
					matchFlg=true
				elseif string.match(str,"l[gn]")~=nil then
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, "\\"..str.."()",1), " "))
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, keyW.."_{"..varW.."}",1), " "))
					yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, keyW.."^{"..varW.."}",1), " "))
					matchFlg=true
				elseif keyW=='y' then
					if varW=='n' then
						yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, keyW.."^{"..varW.."}",1), " "))
						yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, keyW.."^{("..varW..")}",1), " "))
						matchFlg=true
					elseif varW=='x' then
						yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, keyW.."'\\left|_{"..varW.."=0}\\right.=",1), " "))
						yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, keyW.."''\\left|_{"..varW.."=0}\\right.=",1), " "))
						yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, keyW.."'''\\left|_{"..varW.."=0}\\right.=",1), " "))
						yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, keyW.."''''\\left|_{"..varW.."=0}\\right.=",1), " "))
						for i=5,8 do
							yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, keyW.."^{("..tostring(i)..")}\\left|_{"..varW.."=0}\\right.=",1), " "))
						end
						yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, keyW.."^{(n)}\\left|_{"..varW.."=0}\\right.=",1), " "))
						yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, keyW.."\\left|_{"..varW.."=0}\\right.=",1), " "))
						
						matchFlg=true
					else
						if string.match(varW,"[a-zA-Z]")~=nil then
							yield(Candidate("latex", seg.start, seg._end, subStr_0..string.gsub (subStr_1, pattern, keyW.."^{"..varW.."}",1), " "))
							matchFlg=true
						end
					end
				end
			end
			if matchFlg then
				break
			end
		end
		if matchFlg then
			returnFlg=true
			break
		end
	end
	if returnFlg then
		return 0
	end

	--字符关键字匹配 之 函数式匹配
	patterns={"[a-zA-Z]+_?"}
	for pidx,pattern in ipairs(patterns) do
		if(string.match(input,pattern)~=nil) then
			if debugFlg then
				yield(Candidate("latex", seg.start, seg._end,"latexLetters: 函数式匹配", " "))
			end
			
			local thisPattern=""
			local functionLetters="[pPfFgGhHvVsS]"
			
			--匹配希腊字母函数名
			for yidx,yNames in ipairs(xlNamesArry) do
				local yNameKey=yNames[1]
				if(string.match(input,yNameKey.."[a-zA-Z]+_?")~=nil) then
					--生成xl字符名称
					local yNameNames={}
					for k,v in ipairs(yNames) do
						if k>1 then
							table.insert(yNameNames,v)
						end
					end
					
					--匹配希腊字母自变量
					for xidx,xNames in ipairs(xlNamesArry) do
						local xNameKey=xNames[1]
						--生成xl字符名称
						local xNameNames={}
						for k,v in ipairs(xNames) do
							if k>1 then
								table.insert(xNameNames,v)
							end
						end
						
						--带下标场景
						thisPattern=yNameKey..xNameKey.."_"
						if(string.match(input,thisPattern)~=nil) then
							--psiphi_类的输入
							for fk,fn in ipairs(yNameNames) do
								for xk,xn in ipairs(xNameNames) do
									for i=1,8 do
										yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\"..fn.."(\\"..xn.."_{"..tostring(i).."})",1), " "))
									end
									yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\"..fn.."(\\"..xn.."_{n})",1), " "))
									yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\"..fn.."(\\"..xn.."_{0})",1), " "))
								end
							end
							--标记过程状态
							matchFlg=true
						end
						if matchFlg then
							break
						end
						
						--不带下标场景
						thisPattern=yNameKey..xNameKey
						if(string.match(input,thisPattern)~=nil) then
							--psiphi 类的输入
							for fk,fn in ipairs(yNameNames) do
								for xk,xn in ipairs(xNameNames) do
									yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\"..fn.."'(\\"..xn..")",1), " "))
									yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\"..fn.."''(\\"..xn..")",1), " "))
									for i=3,9 do
										yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\"..fn.."^{("..tostring(i)..")}(\\"..xn..")",1), " "))
									end
									yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\"..fn.."(\\"..xn..")",1), " "))
								end
							end
							--标记过程状态
							matchFlg=true
						end
						if matchFlg then
							break
						end
					end
					if matchFlg then
						break
					end
					
					--匹配单字母自变量，带下标场景
					thisPattern=yNameKey.."[a-zA-Z]_"
					if(string.match(input,thisPattern)~=nil) then
						--psix_类的输入
						str=string.match(input,"("..thisPattern..")")
						varW=string.sub(str,string.len(str)-1,string.len(str)-1)
						
						for fk,fn in ipairs(yNameNames) do
							for i=1,8 do
								yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\"..fn.."("..varW.."_{"..tostring(i).."})",1), " "))
							end
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\"..fn.."("..varW.."_{n})",1), " "))
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\"..fn.."("..varW.."_{0})",1), " "))
						end
						--标记过程状态
						matchFlg=true
					end
					if matchFlg then
						break
					end
					
					--不带下标场景
					thisPattern=yNameKey.."[a-zA-Z]"
					if(string.match(input,thisPattern)~=nil) then
						--psix 类的输入
						str=string.match(input,"("..thisPattern..")")
						varW=string.sub(str,string.len(str))
						
						for fk,fn in ipairs(yNameNames) do
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\"..fn.."'("..varW..")",1), " "))
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\"..fn.."''("..varW..")",1), " "))
							for i=3,9 do
								yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\"..fn.."^{("..tostring(i)..")}("..varW..")",1), " "))
							end
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\"..fn.."("..varW..")",1), " "))
						end
						--标记过程状态
						matchFlg=true
					end
					if matchFlg then
						break
					end
				end
			end
			if matchFlg then
				returnFlg=true
				break
			end
			
			--匹配单字母函数名，匹配希腊字母自变量
			for xidx,xNames in ipairs(xlNamesArry) do
				local xNameKey=xNames[1]
				--生成xl字符名称
				local xNameNames={}
				for k,v in ipairs(xNames) do
					if k>1 then
						table.insert(xNameNames,v)
					end
				end
				
				--带下标场景
				thisPattern=functionLetters..xNameKey.."_"
				if(string.match(input,thisPattern)~=nil) then
					--fpsi_类的输入
					str=string.match(input,"("..thisPattern..")")
					keyW=string.sub(str,1,1)
					
					for xk,xn in ipairs(xNameNames) do
						for i=1,8 do
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."(\\"..xn.."_{"..tostring(i).."})",1), " "))
						end
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."(\\"..xn.."_{n})",1), " "))
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."(\\"..xn.."_{0})",1), " "))
					end
					
					--标记过程状态
					matchFlg=true
				end
				if matchFlg then
					break
				end
				
				--不带下标场景
				thisPattern=functionLetters..xNameKey
				if(string.match(input,thisPattern)~=nil) then
					--fpsi 类的输入
					str=string.match(input,"("..thisPattern..")")
					keyW=string.sub(str,1,1)
					
					for xk,xn in ipairs(xNameNames) do
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."'(\\"..xn..")",1), " "))
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."''(\\"..xn..")",1), " "))
						for i=3,9 do
							yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."^{("..tostring(i)..")}(\\"..xn..")",1), " "))
						end
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."(\\"..xn..")",1), " "))
					end
					
					--标记过程状态
					matchFlg=true
				end
				if matchFlg then
					break
				end
			end
			if matchFlg then
				returnFlg=true
				break
			end
			
			--匹配单字母函数名，匹配单字母自变量，带下标场景
			thisPattern=functionLetters.."[a-zA-Z]_"
			if(string.match(input,thisPattern)~=nil) then
				--fx_类的输入
				str=string.match(input,"("..thisPattern..")")
				keyW=string.sub(str,1,1)
				varW=string.sub(str,2,2)
				
				--目标字符串位置
				local strPos=string.find(input,thisPattern)
				
				--尝试查找出现的xl字母的位置
				local xlPos=0
				local xlNameKeyW=""
				for xlidx,xlNames in ipairs(xlNamesArry) do
					local xlNameKey=xlNames[1]
					xlPos = string.find(input,xlNameKey)
					if xlPos~=nil then
						xlNameKeyW=xlNameKey
						break
					end
				end
				if xlPos==nil then
					xlPos=0
				end
				
				--此处需要避免 xl 字母被拆分
				--functionLetters="[pPfFgGhHvVsS]"
				if strPos<xlPos or strPos>xlPos+string.len(xlNameKeyW) then
					for i=1,8 do
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."("..varW.."_{"..tostring(i).."})",1), " "))
					end
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."("..varW.."_{n})",1), " "))
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."("..varW.."_{0})",1), " "))
				
					--标记过程状态
					matchFlg=true
				end
			end
			if matchFlg then
				returnFlg=true
				break
			end
			
			--匹配单字母函数名，匹配单字母自变量，不带下标场景
			thisPattern=functionLetters.."[a-zA-Z]"
			if(string.match(input,thisPattern)~=nil) then
				--fx类的输入
				str=string.match(input,"("..thisPattern..")")
				keyW=string.sub(str,1,1)
				varW=string.sub(str,2,2)
				
				--目标字符串位置
				local strPos=string.find(input,thisPattern)
				
				--尝试查找出现的xl字母的位置
				local xlPos=0
				local xlNameKeyW=""
				for xlidx,xlNames in ipairs(xlNamesArry) do
					local xlNameKey=xlNames[1]
					xlPos = string.find(input,xlNameKey)
					if xlPos~=nil then
						xlNameKeyW=xlNameKey
						break
					end
				end
				if xlPos==nil then
					xlPos=0
				end
				
				--此处需要避免 xl 字母被拆分
				--functionLetters="[pPfFgGhHvVsS]"
				if strPos<xlPos or strPos>xlPos+string.len(xlNameKeyW) then
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."'("..varW..")",1), " "))
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."''("..varW..")",1), " "))
					for i=3,9 do
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."^{("..tostring(i)..")}("..varW..")",1), " "))
					end
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, keyW.."("..varW..")",1), " "))
					
					--标记过程状态
					matchFlg=true
				end
			end
			if matchFlg then
				returnFlg=true
				break
			end
		end
	end
	if returnFlg then
		return 0
	end

	--匹配希腊字母
	if debugFlg then
		yield(Candidate("latex", seg.start, seg._end,"latexLetters: 匹配希腊字母", " "))
	end
	for xlkey,xlNames in ipairs(xlNamesArry) do
		xlname=xlNames[1]
		
		--匹配下标
		thisPattern=xlname.."_"
		if string.match(input,thisPattern)~=nil then
			--生成xl字符名称
			local names={}
			for k,v in ipairs(xlNames) do
				if k>1 then
					table.insert(names,v)
				end
			end
			
			for k,name in ipairs(names) do
				for i=1,8 do
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\"..name.."_{"..tostring(i).."}", 1), " "))
				end
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\"..name.."_{n}", 1), " "))
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\"..name.."_{0}", 1), " "))
			end
			
			--标记过程状态
			matchFlg=true
		end
		if matchFlg then
			returnFlg=true
			break
		end
		
		--匹配上标
		thisPattern=xlname.."^"
		if string.match(input,thisPattern)~=nil then
			--生成xl字符名称
			local names={}
			for k,v in ipairs(xlNames) do
				if k>1 then
					table.insert(names,v)
				end
			end
			
			for k,name in ipairs(names) do
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\"..name.." ", 1), " "))
				for i=2,9 do
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\"..name.."^{"..tostring(i).."}", 1), " "))
				end
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\"..name.."^{n}", 1), " "))
			end
			
			--标记过程状态
			matchFlg=true
		end
		if matchFlg then
			returnFlg=true
			break
		end
		
		--匹配无下标
		thisPattern=xlname
		if string.match(input,thisPattern)~=nil then
			--生成xl字符名称
			local names={}
			for k,v in ipairs(xlNames) do
				if k>1 then
					table.insert(names,v)
				end
			end
			
			for k,name in ipairs(names) do
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, thisPattern, "\\"..name.." ", 1), " "))
			end
			
			--标记过程状态
			matchFlg=true
		end
		if matchFlg then
			returnFlg=true
			break
		end
	end
	if returnFlg then
		return 0
	end

	--2/3字符关键字，箭头组合
	patterns={"[-|/\\=<>^]+"}
	for idx,pattern in ipairs(patterns) do
		if string.match(input,pattern)~=nil then
			str=string.match(input,"("..pattern..")")
			
			if debugFlg then
				yield(Candidate("latex", seg.start, seg._end,"latexLetters: ".. pattern..", "..str, " "))
			end
			
			matchFlg=false
			if str=="->" then
				--识别水平右箭头
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, pattern, "\\rarr ", 1), " "))
				matchFlg=true
			elseif str=="=>" then
				--识别水平右箭头
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, pattern, "\\rArr ", 1), " "))
				matchFlg=true
			elseif str==">>" then
				--识别水平右箭头
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, pattern, "\\rightrightarrows ", 1), " "))
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, pattern, "\\twoheadrightarrow ", 1), " "))
				matchFlg=true
			elseif str=="<-" then
				--识别水平左箭头
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, pattern, "\\larr ", 1), " "))
				matchFlg=true
			elseif str=="<=" then
				--识别水平左箭头
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, pattern, "\\lArr ", 1), " "))
				matchFlg=true
			elseif str=="<<" then
				--识别水平右箭头
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, pattern, "\\leftleftarrows ", 1), " "))
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, pattern, "\\twoheadleftarrow ", 1), " "))
				matchFlg=true
			elseif str=="<>" then
				--识别水平左右箭头
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, pattern, "\\lrarr ", 1), " "))
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, pattern, "\\lrArr ", 1), " "))
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, pattern, "\\leftrightarrows ", 1), " "))
				matchFlg=true
			elseif str=="/>" then
				--识别右上箭头
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, pattern, "\\nearrow ", 1), " "))
				matchFlg=true
			elseif str=="</" then
				--识别左下箭头
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, pattern, "\\swarrow ", 1), " "))
				matchFlg=true
			elseif str=="<\\" then
				--识别左上箭头
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, pattern, "\\nwarrow ", 1), " "))
				matchFlg=true
			elseif str=="\\>" then
				--识别右下箭头
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, pattern, "\\searrow ", 1), " "))
				matchFlg=true
			elseif str=="|>" then
				--识别下箭头
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, pattern, "\\darr ", 1), " "))
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, pattern, "\\dArr ", 1), " "))
				matchFlg=true
			elseif str=="|^" then
				--识别上箭头
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, pattern, "\\uarr ", 1), " "))
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, pattern, "\\uArr ", 1), " "))
				matchFlg=true
			elseif str=="^^" then
				--识别上箭头
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, pattern, "\\upuparrows ", 1), " "))
				matchFlg=true
			elseif str=="==" then
				--识别恒等号
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, pattern, "\\equiv ", 1), " "))
				matchFlg=true
			elseif str=="|->" then
				--识别|->符号
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, pattern, "\\mapsto ", 1), " "))
				matchFlg=true
			elseif str=="\\\\" then
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, str, "\\\\", 1), " "))
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, str, "~\\\\", 1), " "))
			end
			
			if matchFlg then
				returnFlg=true
				break
			end
		end
	end
	if returnFlg then
		return 0
	end

	--2字符关键字
	patterns={"[a-zA-Z][_^]"}
	for idx,pattern in ipairs(patterns) do
		if string.match(input,pattern)~=nil then
			str=string.match(input,"("..pattern..")")
			keyW=string.sub(str,1,1)
			varW=string.sub(str,2,2)
			
			if debugFlg then
				yield(Candidate("latex", seg.start, seg._end,"latexLetters: ".. pattern..", "..str, " "))
			end
			
			matchFlg=false
			if varW=='^' then
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, pattern, keyW, 1), " "))
				for i=2,9 do
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, pattern, keyW.."^{"..tostring(i).."}", 1), " "))
				end
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, pattern, keyW.."^{n}", 1), " "))
			elseif varW=='_' then
				for i=1,8 do
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, pattern, keyW.."_{"..tostring(i).."}", 1), " "))
				end
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, pattern, keyW.."_{n}", 1), " "))
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, pattern, keyW.."_{"..tostring(0).."}", 1), " "))
			end
			matchFlg=true
			
			if matchFlg then
				returnFlg=true
				break
			end
		end
	end
	if returnFlg then
		return 0
	end

	--2字符关键字，通用
	patterns={"[a-zA-Z][a-zA-Z]"}
	for idx,pattern in ipairs(patterns) do
		if string.match(input,pattern,pos)~=nil then
			str=string.match(input,"("..pattern..")",pos)
			keyW=string.sub(str,1,1)
			varW=string.sub(str,2,2)
			
			if debugFlg then
				yield(Candidate("latex", seg.start, seg._end,"latexLetters: ".. pattern..", "..input, " "))
				yield(Candidate("latex", seg.start, seg._end,"latexLetters: keyW, "..keyW, " "))
				yield(Candidate("latex", seg.start, seg._end,"latexLetters: varW, "..varW, " "))
			end
			
			yield(Candidate("latex", seg.start, seg._end, string.gsub (input, pattern, keyW.."_{"..varW.."}",1), " "))
			yield(Candidate("latex", seg.start, seg._end, string.gsub (input, pattern, keyW.."^{"..varW.."}",1), " "))
			matchFlg=true
		end
		if matchFlg then
			returnFlg=true
			break
		end
	end
	if returnFlg then
		return 0
	end

	--1字符关键字
	patterns={"[a-zA-Z]"}
	for idx,pattern in ipairs(patterns) do
		if string.match(input,pattern)~=nil then
			str=string.match(input,"("..pattern..")")
			keyW=string.sub(str,1,1)
			
			if debugFlg then
				yield(Candidate("latex", seg.start, seg._end,"latexLetters: ".. pattern..", "..str, " "))
			end
			
			matchFlg=false
			
			if keyW=='y' then
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, pattern, keyW.."'",1), " "))
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, pattern, keyW.."''",1), " "))
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, pattern, keyW.."'''",1), " "))
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, pattern, keyW.."''''",1), " "))
				for i=5,9 do
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, pattern, keyW.."^{("..tostring(i)..")}",1), " "))
				end
				yield(Candidate("latex", seg.start, seg._end, string.gsub (input, pattern, keyW,1), " "))
			else
				if string.match(input,"[a-zA-Z][%+%-=]+$")~=nil then
					for i=1,9 do
						yield(Candidate("latex", seg.start, seg._end, input..tostring(i), " "))
					end
					yield(Candidate("latex", seg.start, seg._end, input..tostring(0), " "))
				else
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, pattern, keyW,1), " "))
					for i=2,9 do
						yield(Candidate("latex", seg.start, seg._end, string.gsub (input, pattern, keyW.."^{"..tostring(i).."}",1), " "))
					end
					yield(Candidate("latex", seg.start, seg._end, string.gsub (input, pattern, keyW.."^{n}",1), " "))
				end
			end
			matchFlg=true
			
			if matchFlg then
				returnFlg=true
				break
			end
		end
	end
	if returnFlg then
		return 0
	end

	--符号字符关键字，符号 ( ) . % + - * ?[ ] ^ $ 在lua正则表达式中识别为特殊符号，可以通过 % 转义为符号本身
	patterns={"^[|%^%+%-_=%*%?%(%)%[%]{}<!@#%$&~']"}
	for idx,pattern in ipairs(patterns) do
		if string.match(input,pattern)~=nil then
			str=input
			keyW=str
			
			if debugFlg then
				yield(Candidate("latex", seg.start, seg._end,"latexLetters: "..string.sub(pattern,1,10)..", "..str, " "))
			end
			
			matchFlg=false
			
			if string.len(keyW)==1 then
				if string.match(keyW,"[%^_]")~=nil then
					for i=2,9 do
						yield(Candidate("latex", seg.start, seg._end, keyW.."{"..tostring(i).."}", " "))
					end
					if keyW=='_' then
						yield(Candidate("latex", seg.start, seg._end, keyW.."{0}", " "))
					else
						yield(Candidate("latex", seg.start, seg._end, keyW.."{n}", " "))
					end
					matchFlg=true
				elseif keyW=='|' then
					yield(Candidate("latex", seg.start, seg._end, "\\begin{vmatrix}\r a & b \\\\\r c & d \r\\end{vmatrix}", " "))
					yield(Candidate("latex", seg.start, seg._end, "\\begin{Vmatrix}\r a & b \\\\\r c & d \r\\end{Vmatrix}", " "))
					matchFlg=true
				elseif keyW=='(' then
					for i=2,9 do
						yield(Candidate("latex", seg.start, seg._end, "\\left( \\right)^{"..tostring(i).."}", " "))
					end
					yield(Candidate("latex", seg.start, seg._end, "\\left( \\right)^{n}", " "))
					yield(Candidate("latex", seg.start, seg._end, "\\left( \\right)", " "))
					yield(Candidate("latex", seg.start, seg._end, "\\begin{pmatrix}\r a & b \\\\\r c & d \r\\end{pmatrix}", " "))
					matchFlg=true
				elseif keyW=='<' then
					for i=2,9 do
						yield(Candidate("latex", seg.start, seg._end, "\\left\\langle {} \\right\\rangle^{"..tostring(i).."}", " "))
					end
					yield(Candidate("latex", seg.start, seg._end, "\\left\\langle {} \\right\\rangle^{n}", " "))
					yield(Candidate("latex", seg.start, seg._end, "\\left\\langle {} \\right\\rangle", " "))
					matchFlg=true
				elseif keyW==')' then
					for i=2,9 do
						yield(Candidate("latex", seg.start, seg._end, ")^{"..tostring(i).."}", " "))
					end
					yield(Candidate("latex", seg.start, seg._end, ")^{n}", " "))
					matchFlg=true
				elseif keyW=='[' then
					for i=2,9 do
						yield(Candidate("latex", seg.start, seg._end, "\\left[ \\right]^{"..tostring(i).."}", " "))
					end
					yield(Candidate("latex", seg.start, seg._end, "\\left[ \\right]^{n}", " "))
					yield(Candidate("latex", seg.start, seg._end, "\\left[ \\right]", " "))
					yield(Candidate("latex", seg.start, seg._end, "\\begin{bmatrix}\r a & b \\\\\r c & d \r\\end{bmatrix}", " "))
					yield(Candidate("latex", seg.start, seg._end, "\\begin{Bmatrix}\r a & b \\\\\r c & d \r\\end{Bmatrix}", " "))
					matchFlg=true
				elseif keyW==']' then
					for i=2,9 do
						yield(Candidate("latex", seg.start, seg._end, "]^{"..tostring(i).."}", " "))
					end
					yield(Candidate("latex", seg.start, seg._end, "]^{n}", " "))
					matchFlg=true
				elseif keyW=='{' then
					for i=2,9 do
						yield(Candidate("latex", seg.start, seg._end, "\\left\\{ \\right\\}^{"..tostring(i).."}", " "))
					end
					
					yield(Candidate("latex", seg.start, seg._end, "\\left\\{ \\right\\}^{n}", " "))
					yield(Candidate("latex", seg.start, seg._end, "\\left\\{ \\right\\}", " "))
					yield(Candidate("latex", seg.start, seg._end, "\\begin{cases}\r?&=?\\\\\r?&=?\r\\end{cases}", " "))
					yield(Candidate("latex", seg.start, seg._end, "\\begin{equation}\\begin{cases}\r?&=?\\\\\r?&=?\r\\end{cases}\\end{equation}", " "))
					matchFlg=true
				elseif keyW=='}' then
					for i=2,9 do
						yield(Candidate("latex", seg.start, seg._end, "}^{"..tostring(i).."}", " "))
					end
					yield(Candidate("latex", seg.start, seg._end, "}^{n}", " "))
					matchFlg=true
				elseif keyW=='&' then
					for i=3,9 do
						yield(Candidate("latex", seg.start, seg._end, keyW..tostring(i), " "))
					end
					yield(Candidate("latex", seg.start, seg._end, keyW..tostring(0), " "))
					matchFlg=true
				else
					for i=2,9 do
						yield(Candidate("latex", seg.start, seg._end, keyW..tostring(i), " "))
					end
					yield(Candidate("latex", seg.start, seg._end, keyW..tostring(0), " "))
					matchFlg=true
				end
			end
			
			if matchFlg then
				returnFlg=true
				break
			end
		end
	end
	if returnFlg then
		return 0
	end

	if debugFlg then
		yield(Candidate("latex", seg.start, seg._end,"latexLetters: last", " "))
	end
	yield(Candidate("latex", seg.start, seg._end, input, " "))
	
end

return translator