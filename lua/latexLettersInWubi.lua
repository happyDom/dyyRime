--lua语言中的注释用“--” 
--声名全局变量
local xlNamesArry={
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
	--局部变量声名
	local debugFlg=false
	local returnFlg=false
	local matchFlg=false
	local inputStr=""
	local patterns
	local str=""
	local prefix="uz"
	local keyW=""
	local varW=""
	local varW_1=""
	local varW_2=""
	local varW_3=""

	local preFix_output="$$"
	local posFix_output="$"

	if debugFlg then
		yield(Candidate("latex", seg.start, seg._end,"latexLettersInWubi: input is "..input, " "))
	end

	--非prefix开头的输入，不触发本lua脚本
	if prefix~=string.sub(input,1,string.len(prefix)) then
		return 0
	else
		inputStr=string.sub(input,string.len(prefix)+1,string.len(input))
	end

	if debugFlg then
		yield(Candidate("latex", seg.start, seg._end,"latexLettersInWubi: prefix is "..prefix, " "))
		yield(Candidate("latex", seg.start, seg._end,"latexLettersInWubi: inputStr is "..inputStr, " "))
	end

	--4字符关键字的希腊字母
	patterns={"[a-zA-Z]+"}
	if string.len(inputStr)>1 then
		for idx,pattern in ipairs(patterns) do
			if string.match(inputStr,pattern)~=nil then
				str=string.match(inputStr,"("..pattern..")")
				
				if debugFlg then
					yield(Candidate("latex", seg.start, seg._end,"latexLettersInWubi: ".. pattern..", "..str, " "))
				end
				
				matchFlg=false
				
				for xlkey,xlNames in ipairs(xlNamesArry) do
					xlname=xlNames[1]
					if str==xlname then
						--生成xl字符名称
						local names={}
						for k,v in ipairs(xlNames) do
							if k>1 then
								table.insert(names,v)
							end
						end
						for k,name in ipairs(names) do
							yield(Candidate("latex", seg.start, seg._end, preFix_output.."\\"..name..posFix_output, " "))
						end
						
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
	end

	--3字符关键字
	patterns={"[a-zA-Z]+"}
	if string.len(inputStr)==3 then
		for idx,pattern in ipairs(patterns) do
			if string.match(inputStr,pattern)~=nil then
				str=string.match(inputStr,"("..pattern..")")
				
				if debugFlg then
					yield(Candidate("latex", seg.start, seg._end,"latexLettersInWubi: ".. pattern..", "..str, " "))
				end
				
				matchFlg=false
				if str=="idx" then
					for i=1,10 do
						yield(Candidate("latex", seg.start, seg._end, "式("..tostring(i)..")", " "))
					end
					for i=1,10 do
						yield(Candidate("latex", seg.start, seg._end, "\\quad("..tostring(i)..")", " "))
					end
					matchFlg=true
				elseif str=="inf" then
					yield(Candidate("latex", seg.start, seg._end, preFix_output.."\\infin"..posFix_output, " "))
					yield(Candidate("latex", seg.start, seg._end, preFix_output.."-\\infin"..posFix_output, " "))
					yield(Candidate("latex", seg.start, seg._end, preFix_output.."+\\infin"..posFix_output, " "))
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
	end

	--3字符关键字
	patterns={"[a-zA-Z][a-zA-Z][_^]"}
	if string.len(inputStr)==3 then
		for idx,pattern in ipairs(patterns) do
			if string.match(inputStr,pattern)~=nil then
				str=string.match(inputStr,"("..pattern..")")
				keyW=string.sub(str,1,1)
				varW_1=string.sub(str,2,2)
				varW_2=string.sub(str,3,3)
				
				if debugFlg then
					yield(Candidate("latex", seg.start, seg._end,"latexLettersInWubi: ".. pattern..", "..str, " "))
				end
				
				matchFlg=false
				if varW_2=='^' then
					yield(Candidate("latex", seg.start, seg._end, preFix_output..keyW.."("..varW_1..")"..posFix_output, " "))
					for i=2,9 do
						yield(Candidate("latex", seg.start, seg._end, preFix_output..keyW.."("..varW_1.."^{"..tostring(i).."})"..posFix_output, " "))
					end
					yield(Candidate("latex", seg.start, seg._end, preFix_output..keyW.."("..varW_1.."^{n})"..posFix_output, " "))
					yield(Candidate("latex", seg.start, seg._end, preFix_output..keyW.."("..varW_1.."^{n-1})"..posFix_output, " "))
				elseif varW_2=='_' then
					for i=1,8 do
						yield(Candidate("latex", seg.start, seg._end, preFix_output..keyW.."("..varW_1.."_{"..tostring(i).."})"..posFix_output, " "))
					end
					yield(Candidate("latex", seg.start, seg._end, preFix_output..keyW.."("..varW_1.."_{n})"..posFix_output, " "))
					yield(Candidate("latex", seg.start, seg._end, preFix_output..keyW.."("..varW_1.."_{"..tostring(0).."})"..posFix_output, " "))
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
	end

	--2字符关键字
	patterns={"[a-zA-Z][a-zA-Z]"}
	if string.len(inputStr)==2 then
		for idx,pattern in ipairs(patterns) do
			if string.match(inputStr,pattern)~=nil then
				str=string.match(inputStr,"("..pattern..")")
				keyW=string.sub(str,1,1)
				varW=string.sub(str,2,2)
				
				if debugFlg then
					yield(Candidate("latex", seg.start, seg._end,"latexLettersInWubi: ".. pattern..", "..str, " "))
				end
				
				matchFlg=false
				if string.match(keyW,"[pfghPFGHvsVS]")~=nil then
					if string.match(varW,"[a-z]")~=nil then
						yield(Candidate("latex", seg.start, seg._end, preFix_output..keyW.."'("..varW..")"..posFix_output, " "))
						yield(Candidate("latex", seg.start, seg._end, preFix_output..keyW.."''("..varW..")"..posFix_output, " "))
						yield(Candidate("latex", seg.start, seg._end, preFix_output..keyW.."'''("..varW..")"..posFix_output, " "))
						yield(Candidate("latex", seg.start, seg._end, preFix_output..keyW.."''''("..varW..")"..posFix_output, " "))
						for i=5,9 do
							yield(Candidate("latex", seg.start, seg._end, preFix_output..keyW.."^{("..tostring(i)..")}("..varW..")"..posFix_output, " "))
						end
						yield(Candidate("latex", seg.start, seg._end, preFix_output..keyW.."("..varW..")"..posFix_output, " "))
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
	end

	--2字符关键字
	patterns={"[a-zA-Z][_^]"}
	if string.len(inputStr)==2 then
		for idx,pattern in ipairs(patterns) do
			if string.match(inputStr,pattern)~=nil then
				str=string.match(inputStr,"("..pattern..")")
				keyW=string.sub(str,1,1)
				varW=string.sub(str,2,2)
				
				if debugFlg then
					yield(Candidate("latex", seg.start, seg._end,"latexLettersInWubi: ".. pattern..", "..str, " "))
				end
				
				matchFlg=false
				if varW=='_' then
					for i=1,8 do
						yield(Candidate("latex", seg.start, seg._end, preFix_output..keyW.."_{"..tostring(i).."}"..posFix_output, " "))
					end
					yield(Candidate("latex", seg.start, seg._end, preFix_output..keyW.."_{n}"..posFix_output, " "))
					yield(Candidate("latex", seg.start, seg._end, preFix_output..keyW.."_{"..tostring(0).."}"..posFix_output, " "))
				elseif varW=='^' then
					yield(Candidate("latex", seg.start, seg._end, preFix_output..keyW..posFix_output, " "))
					for i=2,9 do
						yield(Candidate("latex", seg.start, seg._end, preFix_output..keyW.."^{"..tostring(i).."}"..posFix_output, " "))
					end
					yield(Candidate("latex", seg.start, seg._end, preFix_output..keyW.."^{n}"..posFix_output, " "))
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
	end

	--1字符关键字
	patterns={"[a-zA-Z]"}
	if string.len(inputStr)==1 then
		for idx,pattern in ipairs(patterns) do
			if string.match(inputStr,pattern)~=nil then
				str=string.match(inputStr,"("..pattern..")")
				keyW=string.sub(str,1,1)
				
				if debugFlg then
					yield(Candidate("latex", seg.start, seg._end,"latexLettersInWubi: ".. pattern..", "..str, " "))
				end
				
				matchFlg=false
				--暂没有针对一个字符需要处理的逻辑
				--matchFlg=true
				
				if matchFlg then
					returnFlg=true
					break
				end
			end
		end
		if returnFlg then
			return 0
		end
	end

	--yield(Candidate("latex", seg.start, seg._end, preFix_output..inputStr..posFix_output, " "))
	--yield(Candidate("latex", seg.start, seg._end, preFix_output..string.upper(inputStr)..posFix_output, " "))
	--
	
	patterns={"[a-zA-Z]+"}
	for idx,pattern in ipairs(patterns) do
		if string.match(inputStr,pattern)~=nil then
			str=string.match(inputStr,"("..pattern..")")
			local strLen = string.len(str)
			
			local lastFirstChar = ""
			local lastSecondChar = ""
			
			matchFlg=false
			if strLen == 1 then
				yield(Candidate("latex", seg.start, seg._end, preFix_output..str..posFix_output, " "))
				yield(Candidate("latex", seg.start, seg._end, preFix_output..string.upper(str)..posFix_output, " "))
				yield(Candidate("latex", seg.start, seg._end, preFix_output..str.."'"..posFix_output, " "))
				yield(Candidate("latex", seg.start, seg._end, preFix_output..string.upper(str).."'"..posFix_output, " "))
				matchFlg=true
			else
				lastFirstChar = string.sub(inputStr, strLen,strLen)
				lastSecondChar = string.sub(inputStr, strLen-1,strLen-1)
				if strLen == 2 then
					if lastFirstChar == lastSecondChar then
						--如果第一个字符与第二个字符一致， 则在第二个字符上加 ' 处理, 并提供一个大写的版本
						yield(Candidate("latex", seg.start, seg._end, preFix_output..lastFirstChar..lastSecondChar.."'"..posFix_output, " "))
						yield(Candidate("latex", seg.start, seg._end, preFix_output..string.upper(lastFirstChar..lastSecondChar).."'"..posFix_output, " "))
						matchFlg=true
					elseif string.upper(lastFirstChar) == string.upper(lastSecondChar) then
						--如果两个字符互为大小写，则只提供原版选项
						yield(Candidate("latex", seg.start, seg._end, preFix_output..str..posFix_output, " "))
						matchFlg=true
					else
						--正常提供小写版和大写版的选项
						yield(Candidate("latex", seg.start, seg._end, preFix_output..str..posFix_output, " "))
						yield(Candidate("latex", seg.start, seg._end, preFix_output..string.upper(str)..posFix_output, " "))
						matchFlg=true
					end
				else
					--大于2字符的输入项， 正常提供大小写版本
					yield(Candidate("latex", seg.start, seg._end, preFix_output..str..posFix_output, " "))
					yield(Candidate("latex", seg.start, seg._end, preFix_output..string.upper(str)..posFix_output, " "))
					matchFlg=true
				end
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

	--如果逻辑运行到这里还没有返回，则做如下处理
	if debugFlg then
		yield(Candidate("latex", seg.start, seg._end,"latexLettersInWubi: last", " "))
	end
	yield(Candidate("latex", seg.start, seg._end, "uz", " "))
	yield(Candidate("latex", seg.start, seg._end, preFix_output..str..posFix_output, " "))
end

return translator