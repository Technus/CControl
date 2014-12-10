--TableCommander courtesy of Technus A.K.A. tec_SG
--use as program or load as APIz
--execute "tabby help" in shell for help
--in program you can use f1
--for more info go to ComputerCraftForums and/or GitHub

--you can always use pack/unpack (table.pack/table.unpack) to use tabby on sets of variables :D

_G["pack"]=function (...) --works like {STUFF,STUFFMORE,STUFFMOAR,...}
	return {...}
end
table.pack=_G["pack"]
table.unpack=unpack

--[[]]function stringSplit(str, inSplitPattern, outResults )
  if type(str)~="string" or type(inSplitPattern)~="string" or (type(outResults)~="nil" and type(outResults)~="table") then 
    return {},false
  end
  if type(outResults)~="table" then
    outResults = { }
  end
  local theStart = 1
  local theSplitStart, theSplitEnd = string.find( str, inSplitPattern, theStart )
  while theSplitStart do
    table.insert( outResults, string.sub( str, theStart, theSplitStart-1 ) )
    theStart = theSplitEnd + 1
    theSplitStart, theSplitEnd = string.find( str, inSplitPattern, theStart )
  end
  table.insert( outResults, string.sub( str, theStart ) )
  return outResults,true
end

--[[]]function readEX( _sReplaceChar, _tHistory ,data,lastCharPos,state--[[side of screen or state table]])
	local side=type(state)=="table" and state.side or tostring(state)
	term.setCursorBlink( true )
	local init=true
    local sLine = tostring(data) or ""
    local nHistoryPos
    local nPos = 0
    if type(_sReplaceChar)=="string" then
        _sReplaceChar = string.sub( _sReplaceChar, 1, 1 )
    end
	
	if type(_tHistory)~="table" then _tHistory=nil end
    
    local w = lastCharPos or term.getSize()
    local sx = term.getCursorPos()
    
    local function redraw( _sCustomReplaceChar )
        local nScroll = 0
        if sx + nPos >= w then
            nScroll = (sx + nPos) - w
        end

        local cx,cy = term.getCursorPos()
        term.setCursorPos( sx, cy )
        local sReplace = _sCustomReplaceChar or _sReplaceChar
        if sReplace then
            term.write( string.rep( sReplace, math.max( string.len(sLine) - nScroll, 0 ) ) )
        else
            term.write( string.sub( sLine, nScroll + 1 ) )
        end
        term.setCursorPos( sx + nPos - nScroll, cy )
    end
	
	for i=sx,w do
		term.write(" ")
	end
    redraw(" ")
    nPos = string.len(sLine)
    redraw()
    
	while true do
        --local sEvent, param = os.pullEvent()
		
		local event={coroutine.yield()}
		local sEvent=event[1]
		local param=event[2]
		
        if sEvent == "char" then
            -- Typed key
            sLine = string.sub( sLine, 1, nPos ) .. param .. string.sub( sLine, nPos + 1 )
            nPos = nPos + 1
            redraw()

        elseif sEvent == "paste" then
            -- Pasted text
            sLine = string.sub( sLine, 1, nPos ) .. param .. string.sub( sLine, nPos + 1 )
            nPos = nPos + string.len( param )
            redraw()
		elseif sEvent == "mouse_click" then
			break
        elseif sEvent == "key" then
            if param == keys.enter then
                -- Enter
                break
                
            elseif param == keys.left then
                -- Left
                if nPos > 0 then
                    nPos = nPos - 1
                    redraw()
                end
                
            elseif param == keys.right then
                -- Right                
                if nPos < string.len(sLine) then
                    redraw(" ")
                    nPos = nPos + 1
                    redraw()
                end
            
            elseif param == keys.up or param == keys.down then
                -- Up or down
                if _tHistory then
                    redraw(" ")
                    if param == keys.up then
                        -- Up
                        if nHistoryPos == nil then
                            if #_tHistory > 0 then
                                nHistoryPos = #_tHistory
                            end
                        elseif nHistoryPos > 1 then
                            nHistoryPos = nHistoryPos - 1
                        end
                    else
                        -- Down
                        if nHistoryPos == #_tHistory then
                            nHistoryPos = nil
                        elseif nHistoryPos ~= nil then
                            nHistoryPos = nHistoryPos + 1
                        end                        
                    end
                    if nHistoryPos then
                        sLine = _tHistory[nHistoryPos]
                        nPos = string.len( sLine ) 
                    else
                        sLine = ""
                        nPos = 0
                    end
                    redraw()
                end
            elseif param == keys.backspace then
                -- Backspace
                if nPos > 0 then
                    redraw(" ")
                    sLine = string.sub( sLine, 1, nPos - 1 ) .. string.sub( sLine, nPos + 1 )
                    nPos = nPos - 1                    
                    redraw()
                end
            elseif param == keys.home then
                -- Home
                redraw(" ")
                nPos = 0
                redraw()        
            elseif param == keys.delete then
                -- Delete
                if nPos < string.len(sLine) then
                    redraw(" ")
                    sLine = string.sub( sLine, 1, nPos ) .. string.sub( sLine, nPos + 2 )                
                    redraw()
                end
            elseif param == keys["end"] then
                -- End
                redraw(" ")
                nPos = string.len(sLine)
                redraw()
            end

        elseif sEvent == "term_resize" or (event[1]=="monitor_resize" and event[2]==side)  then
			if type(state)=="table" then state.resized=true end
            -- Terminal resized
            w = lastCharPos or term.getSize()
            redraw()
			break
		elseif sEvent=="timer" then
			if type(state)=="table" and event[2]==state.autoSave and type(state.safety)=="table" and not state.safety.noFSsave then
				state.doAutoSave=true
			end
        end
    end
	if _tHistory and sLine~="" then
		local k=1
		while k<=#_tHistory do
			if sLine==_tHistory[k] then
				table.remove(_tHistory,k)
			else
				k=k+1
			end
		end
		table.insert(_tHistory,sLine)
	end
    local cx, cy = term.getCursorPos()
    term.setCursorBlink( false )
    term.setCursorPos( w + 1, cy )
    --print()
    
    return sLine,event
end

--[[]]function historyAdd(_tHistory,sLine)
	if type(_tHistory)~="table" then return nil end
	if sLine~="" then
		local k=1
		while k<=#_tHistory do
			if sLine==_tHistory[k] then
				table.remove(_tHistory,k)
			else
				k=k+1
			end
		end
		table.insert(_tHistory,sLine)
	end
end

--[[]]function writeEX(str,xShift,xSize)
	if type(str)~=string then str=tostring(str) end
	if not str then return nil end
	xShift=tonumber(xShift) or 0 --0 shift is start
	xShift=xShift+1
	xSize=tonumber(xSize)
	str=string.sub(str,xShift,xShift+xSize-1)
	if xSize then
		while #str<xSize do str=str.." " end
	end
	term.write(str)
end

--[[]]function invisibleCharWrap(str)--based on " \" "
	if type(str)~="string" then return nil end
	str=str:gsub("\\","\\\\")
	str=str:gsub("\n","\\n" )
	str=str:gsub("\t","\\t" )
	str=str:gsub("\v","\\v" )
	str=str:gsub("\a","\\a" )
	str=str:gsub("\b","\\b" )
	str=str:gsub("\f","\\f" )
	str=str:gsub("\r","\\r" )
	--str=str:gsub("\0","\\0" ) --escaped wit \000
	local i=1
	while #str:sub(i,i)==1 do
		local b=str:sub(i,i):byte()
		if b<32 or b>126 then
			b=tostring(b)
			while #b<3 do b="0"..b end
			str=str:gsub(str:sub(i,i),"\\"..b)
			i=i+4
		else
			i=i+1
		end
	end
	return str
end

--[[]]function invisibleCharWrapDoubleQuotes(str)--based on " \" "
	if type(str)~="string" then return nil end
	str=str:gsub("\\","\\\\")
	str=str:gsub("\n","\\n" )
	str=str:gsub("\t","\\t" )
	str=str:gsub("\v","\\v" )
	str=str:gsub("\a","\\a" )
	str=str:gsub("\b","\\b" )
	str=str:gsub("\f","\\f" )
	str=str:gsub("\r","\\r" )
	str=str:gsub("\"","\\\"" )
	--str=str:gsub("\0","\\0" ) --escaped wit \000
	local i=1
	while #str:sub(i,i)==1 do
		local b=str:sub(i,i):byte()
		if b<32 or b>126 then
			b=tostring(b)
			while #b<3 do b="0"..b end
			str=str:gsub(str:sub(i,i),"\\"..b)
			i=i+4
		else
			i=i+1
		end
	end
	return str
end

--[[]]function invisibleCharWrapSingleQuotes(str)--based on " \" "
	if type(str)~="string" then return nil end
	str=str:gsub("\\","\\\\")
	str=str:gsub("\n","\\n" )
	str=str:gsub("\t","\\t" )
	str=str:gsub("\v","\\v" )
	str=str:gsub("\a","\\a" )
	str=str:gsub("\b","\\b" )
	str=str:gsub("\f","\\f" )
	str=str:gsub("\r","\\r" )
	str=str:gsub("'","\\'" )
	--str=str:gsub("\0","\\0" ) --escaped wit \000
	local i=1
	while #str:sub(i,i)==1 do
		local b=str:sub(i,i):byte()
		if b<32 or b>126 then
			b=tostring(b)
			while #b<3 do b="0"..b end
			str=str:gsub(str:sub(i,i),"\\"..b)
			i=i+4
		else
			i=i+1
		end
	end
	return str
end

--[[]]function invisibleCharUnwrap(str)--compatible with invisibleCharWrap and some of lua parsing (excluding \0 for example) based on " \" "
	if type(str)~="string" then return nil end
	local temp={}
	local out=""
	for i=1,#str do
		table.insert(temp,str:sub(i,i))
	end
	local i=1
	while i<=#temp do
		if temp[i]~="\\" then 
			out=out..temp[i]
		else
			if     temp[i+1]=="\\" then out=out.."\\" i=i+1
			elseif temp[i+1]=="n"  then out=out.."\n" i=i+1
			elseif temp[i+1]=="t"  then out=out.."\t" i=i+1
			elseif temp[i+1]=="v"  then out=out.."\v" i=i+1
			elseif temp[i+1]=="a"  then out=out.."\a" i=i+1
			elseif temp[i+1]=="b"  then out=out.."\b" i=i+1
			elseif temp[i+1]=="f"  then out=out.."\f" i=i+1
			elseif temp[i+1]=="r"  then out=out.."\r" i=i+1
			elseif tonumber(temp[i+1]) and tonumber(temp[i+2]) and tonumber(temp[i+3]) then 
				local b=temp[i+1]*100+temp[i+2]*10+temp[i+3]
				if b<256 then out=out..string.char(b) end
				i=i+3
			--elseif temp[i+1]=="0"  then out=out.."\0" i=i+1
			end
		end
		i=i+1
	end
	return out
end

--[[]]function invisibleCharUnwrapDoubleQuotes(str)--compatible with invisibleCharWrap and some of lua parsing (excluding \0 for example) based on " \" "
	if type(str)~="string" then return nil end
	local temp={}
	local out=""
	for i=1,#str do
		table.insert(temp,str:sub(i,i))
	end
	local i=1
	while i<=#temp do
		if temp[i]~="\\" then 
			out=out..temp[i]
		else
			if     temp[i+1]=="\\" then out=out.."\\" i=i+1
			elseif temp[i+1]=="n"  then out=out.."\n" i=i+1
			elseif temp[i+1]=="t"  then out=out.."\t" i=i+1
			elseif temp[i+1]=="v"  then out=out.."\v" i=i+1
			elseif temp[i+1]=="a"  then out=out.."\a" i=i+1
			elseif temp[i+1]=="b"  then out=out.."\b" i=i+1
			elseif temp[i+1]=="f"  then out=out.."\f" i=i+1
			elseif temp[i+1]=="r"  then out=out.."\r" i=i+1
			elseif temp[i+1]=="\""  then out=out.."\"" i=i+1
			elseif tonumber(temp[i+1]) and tonumber(temp[i+2]) and tonumber(temp[i+3]) then 
				local b=temp[i+1]*100+temp[i+2]*10+temp[i+3]
				if b<256 then out=out..string.char(b) end
				i=i+3
			--elseif temp[i+1]=="0"  then out=out.."\0" i=i+1
			end
		end
		i=i+1
	end
	return out
end

--[[]]function invisibleCharUnwrapSingleQuotes(str)--compatible with invisibleCharWrap and some of lua parsing (excluding \0 for example) based on " \" "
	if type(str)~="string" then return nil end
	local temp={}
	local out=""
	for i=1,#str do
		table.insert(temp,str:sub(i,i))
	end
	local i=1
	while i<=#temp do
		if temp[i]~="\\" then 
			out=out..temp[i]
		else
			if     temp[i+1]=="\\" then out=out.."\\" i=i+1
			elseif temp[i+1]=="n"  then out=out.."\n" i=i+1
			elseif temp[i+1]=="t"  then out=out.."\t" i=i+1
			elseif temp[i+1]=="v"  then out=out.."\v" i=i+1
			elseif temp[i+1]=="a"  then out=out.."\a" i=i+1
			elseif temp[i+1]=="b"  then out=out.."\b" i=i+1
			elseif temp[i+1]=="f"  then out=out.."\f" i=i+1
			elseif temp[i+1]=="r"  then out=out.."\r" i=i+1
			elseif temp[i+1]=="'"  then out=out.."'" i=i+1
			elseif tonumber(temp[i+1]) and tonumber(temp[i+2]) and tonumber(temp[i+3]) then 
				local b=temp[i+1]*100+temp[i+2]*10+temp[i+3]
				if b<256 then out=out..string.char(b) end
				i=i+3
			--elseif temp[i+1]=="0"  then out=out.."\0" i=i+1
			end
		end
		i=i+1
	end
	return out
end

--[[]]function invisibleCharUnwrapLuaDoubleQuotes(str)--compatible with invisibleCharWrap -- since it does use " \" "
	return loadstring('return "'..(tostring(str) or '' )..'"')()
end

--[[]]function invisibleCharUnwrapLuaSingleQuotes(str)--incompatible with invisibleCharWrap -- since it does use ' \' '
	return loadstring("return '"..(tostring(str) or "" ).."'")()
end

--[[]]function sortedTableIndexList(tab)
	if type(tab)~="table" then return nil end
	local sortedOut={}
	local keys={}
	local numerals={}
	local booleans={}
	local functions={}
	local threads={}
	local tables={}
	for k,v in pairs(tab) do
		if     type(k)=="string"    then table.insert(keys,k)
		elseif type(k)=="number"    then table.insert(numerals,k)
		elseif type(k)=="boolean"   then table.insert(booleans,k) 
		elseif type(k)=="function"  then table.insert(functions,k) 
		elseif type(k)=="thread"    then table.insert(threads,k) 
		elseif type(k)=="table"     then table.insert(tables,k) 
		end
	end
	
	if #keys~=1 then 
		repeat
			local sorted=true
			for i=1,#keys-1 do
				if keys[i]>keys[i+1] then 
					keys[i],keys[i+1]=keys[i+1],keys[i] 
					sorted=false
				end
			end
		until sorted
	end
	
	if #numerals~=1 then
		repeat
			local sorted=true
			for i=1,#numerals-1 do
				if numerals[i]>numerals[i+1] then 
					numerals[i],numerals[i+1]=numerals[i+1],numerals[i] 
					sorted=false
				end
			end
		until sorted
	end
	
	if #booleans==2 and booleans[1]==true then
		booleans[1],booleans[2]=booleans[2],booleans[1]
	end
	
	for k,v in ipairs(numerals) do
		table.insert(sortedOut,v)
	end
	for k,v in ipairs(booleans) do
		table.insert(sortedOut,v)
	end
	for k,v in ipairs(keys) do
		table.insert(sortedOut,v)
	end
	for k,v in ipairs(tables) do
		table.insert(sortedOut,v)
	end
	for k,v in ipairs(functions) do
		table.insert(sortedOut,v)
	end
	for k,v in ipairs(threads) do
		table.insert(sortedOut,v)
	end
	
	return sortedOut
end

--[[]]function shortType(stuff)
	local shortcuts=
	{
		["table"]="t",
		["number"]="n",
		["function"]="f",
		["boolean"]="b",
		["string"]="s",
		--["userdata"]="u",
		["thread"]="c",--aka process
		["coroutine"]="c",
		["nil"]="-"
	}
	if shortcuts[type(stuff)] then return shortcuts[type(stuff)] else return " " end
end

--[[]]function numToType(number)
	local conversion=
	{
	[0]="-",
	[1]="b",
	[2]="n",
	[3]="s",
	[4]="f",
	[5]="t",
	[6]="x",
	[7]="c",
	}
	return conversion[number]
end

--[[]]function typeToNum(typeShortcut)
	local conversion=
	{
	["-"]=0,
	["b"]=1,
	["n"]=2,
	["s"]=3,
	["f"]=4,
	["t"]=5,
	["x"]=6,
	["c"]=7
	}
	return conversion[typeShortcut]
end

--[[]]function typeCheck(stuff)
	local shortcuts=
	{
		["table"]="t",
		["t"]="t",
		["number"]="n",
		["n"]="n",
		["function"]="f",
		["f"]="f",
		["boolean"]="b",
		["b"]="b",
		["string"]="s",
		["s"]="s",
		--["userdata"]="u",
		["thread"]="c",--aka process
		["coroutine"]="c",
		["c"]="c",
		["nil"]="-",
		["-"]="-",
		["duplicate"]="d",
		["d"]="d",
		["terminator"]="x",
		["x"]="x"
	}
	if shortcuts[stuff] then return shortcuts[stuff] else return nil end
end

--[[]]function isWrapped(wrapped)
	if type(wrapped)~="table" or type(wrapped.values)~="table" or 
	   type(wrapped.kinds)~="table" or type(wrapped.depths)~="table" or 
	   type(wrapped.parsed)~="table" or type(wrapped.types)~="table" or
	   type(wrapped.protected)~="table" or type(wrapped.tables)~="table" or
	   type(wrapped.functions)~="table" or type(wrapped.threads)~="table" or
	   type(wrapped.functions.keys)~="table" or type(wrapped.functions.values)~="table" or
	   type(wrapped.threads.keys)~="table" or type(wrapped.threads.values)~="table" or
	   type(wrapped.tables.keys)~="table" or type(wrapped.tables.values)~="table" or
	   type(wrapped.tables.selfValue)~="table"
	then 
	return false
	end
	return true
end

local function solveDepths(wrapped)
	--changes depth levels to correct ones
	local depthMeasured=1
	for k,v in ipairs(wrapped.kinds) do
		if wrapped.depths[k]>=0 then--make sure will not alter negatives and skip them in processing	
			if wrapped.types[k]=="t" and depthMeasured>0 then
				wrapped.depths[k]=depthMeasured
				depthMeasured=depthMeasured+1
			elseif wrapped.types[k]=="x" and depthMeasured>0 then
				depthMeasured=depthMeasured-1
				wrapped.depths[k]=depthMeasured
			else
				wrapped.depths[k]=depthMeasured
			end
		end
	end
end

--[[]]function wrappedSolveDepths(wrapped)
	if not isWrapped(wrapped) then 
		return nil,wrapped,false
	end
	wrap=tableDuplicate(wrapped)
	solveDepths(wrap)
	return wrap,wrapped,true
end

local function wrapTable(input,wrapped)
	wrapped.values={}
	wrapped.depths={}
	wrapped.kinds={}
	wrapped.types={}
	if #wrapped.functions.values>0 then
		table.insert(wrapped.functions.keys,"")
		table.insert(wrapped.functions.values,"")
	end
	if #wrapped.threads.values>0 then
		table.insert(wrapped.threads.keys,"")
		table.insert(wrapped.threads.values,"")
	end
	if #wrapped.tables.values>0 then
		table.insert(wrapped.tables.keys,"")
		table.insert(wrapped.tables.values,"")
	end
	local selfKey=tostring(input)
	wrapped.tables.selfValue={}
	
	table.insert(wrapped.tables.keys,tostring(input))
	table.insert(wrapped.tables.values,input)
	
	local function itIsTable(tab,depth,wrapped) 
		depth=depth or 1
		local list=sortedTableIndexList(tab)
		for _,k in ipairs(list) do--ik right but it works like that
			local v=tab[k]
			local temp=v
			if type(k)=="table" then
				local test=true
				if tostring(k)==selfKey then
					table.insert(wrapped.kinds, "K")
					table.insert(wrapped.depths,depth)
					table.insert(wrapped.values,"table: self")
					table.insert(wrapped.types, "d")
				else
					for k1,v1 in ipairs(wrapped.tables.values) do
						if k==v1 then test=false end
					end
					if test then
						table.insert(wrapped.tables.keys,tostring(k))
						table.insert(wrapped.tables.values,k)
						
						table.insert(wrapped.kinds, "K")
						table.insert(wrapped.depths,depth)
						table.insert(wrapped.values,tostring(k))
						table.insert(wrapped.types, "t")
						
						itIsTable(k,depth+1,wrapped)
						
						table.insert(wrapped.kinds, "K")
						table.insert(wrapped.depths,depth)
						table.insert(wrapped.values,tostring(k))
						table.insert(wrapped.types, "x")
					else
						table.insert(wrapped.kinds, "K")
						table.insert(wrapped.depths,depth)
						table.insert(wrapped.values,tostring(k))
						table.insert(wrapped.types, "d")
					end
				end
			elseif type(k)=="function" then
				local test=true
				--
				local dumped=invisibleCharWrap(string.dump(k))
				for k1,v1 in ipairs(wrapped.functions.values) do
					--if k==v1 then test=false end
					if dumped==v1 then test=false end
				end
				if test then
					table.insert(wrapped.functions.keys,tostring(k))
					--table.insert(wrapped.functions.values,k)
					table.insert(wrapped.functions.values,dumped)
				end
				table.insert(wrapped.kinds, "K")
				table.insert(wrapped.depths,depth)
				table.insert(wrapped.values,tostring(k))
				table.insert(wrapped.types, shortType(k))
				
			elseif type(k)=="thread" then
				local test=true
				for k1,v1 in ipairs(wrapped.threads.values) do
					if k==v1 then test=false end
				end
				if test then
					table.insert(wrapped.threads.keys,tostring(k))
					table.insert(wrapped.threads.values,k)
				end
				table.insert(wrapped.kinds, "K")
				table.insert(wrapped.depths,depth)
				table.insert(wrapped.values,tostring(k))
				table.insert(wrapped.types, shortType(k))
			elseif type(k)=="string" then
				table.insert(wrapped.kinds, "K")
				table.insert(wrapped.depths,depth)
				table.insert(wrapped.values,invisibleCharWrap(tostring(k)))
				table.insert(wrapped.types, shortType(k))
			elseif type(k)=="number" then
				table.insert(wrapped.kinds, "K")
				table.insert(wrapped.depths,depth)
				if k==tonumber(tostring(k)) then
					table.insert(wrapped.values,tostring(k))
				else
					table.insert(wrapped.values,string.format("%.0f",k))
				end
				table.insert(wrapped.types, shortType(k))
			else
				table.insert(wrapped.kinds, "K")
				table.insert(wrapped.depths,depth)
				table.insert(wrapped.values,tostring(k))
				table.insert(wrapped.types, shortType(k))
			end
			
			if type(v)=="table" then
				if tostring(v)==selfKey then
					table.insert(wrapped.kinds, "V")
					table.insert(wrapped.depths,depth)
					table.insert(wrapped.values,"table: self")
					table.insert(wrapped.types, "d")
				else
					local test=true
					for k1,v1 in ipairs(wrapped.tables.values) do
						if v==v1 then test=false end
					end
					if test then
						table.insert(wrapped.tables.keys,tostring(v))
						table.insert(wrapped.tables.values,v)
						
						table.insert(wrapped.kinds, "V")
						table.insert(wrapped.depths,depth)
						table.insert(wrapped.values,tostring(v))
						table.insert(wrapped.types, "t")
						
						itIsTable(v,depth+1,wrapped)
						
						table.insert(wrapped.kinds, "V")
						table.insert(wrapped.depths,depth)
						table.insert(wrapped.values,tostring(v))
						table.insert(wrapped.types, "x")
					else					
						table.insert(wrapped.kinds, "V")
						table.insert(wrapped.depths,depth)
						table.insert(wrapped.values,tostring(v))
						table.insert(wrapped.types, "d")
					end
				end
			elseif type(v)=="function" then
				local test=true
				--
				local dumped=invisibleCharWrap(string.dump(v))
				for k1,v1 in ipairs(wrapped.functions.values) do
					--if v==v1 then test=false end
					if dumped==v1 then test=false end
				end
				if test then
					table.insert(wrapped.functions.keys,tostring(v))
					--table.insert(wrapped.functions.values,v)
					table.insert(wrapped.functions.values,dumped)
				end
				table.insert(wrapped.kinds, "V")
				table.insert(wrapped.depths,depth)
				table.insert(wrapped.values,tostring(v))
				table.insert(wrapped.types, shortType(v))
			elseif type(v)=="thread" then
				local test=true
				for k1,v1 in ipairs(wrapped.threads.values) do
					if v==v1 then test=false end
				end
				if test then
					table.insert(wrapped.threads.keys,tostring(v))
					table.insert(wrapped.threads.values,v)
				end
				table.insert(wrapped.kinds, "V")
				table.insert(wrapped.depths,depth)
				table.insert(wrapped.values,tostring(v))
				table.insert(wrapped.types, shortType(v))
			elseif type(v)=="string" then
				table.insert(wrapped.kinds, "V")
				table.insert(wrapped.depths,depth)
				table.insert(wrapped.values,invisibleCharWrap(tostring(v)))
				table.insert(wrapped.types, shortType(v))
			elseif type(v)=="number" then
				table.insert(wrapped.kinds, "V")
				table.insert(wrapped.depths,depth)
				if v==tonumber(tostring(v)) then
					table.insert(wrapped.values,tostring(v))
				else
					table.insert(wrapped.values,string.format("%.0f",v))
				end
				table.insert(wrapped.types, shortType(v))
			else				
				table.insert(wrapped.kinds, "V")
				table.insert(wrapped.depths,depth)
				table.insert(wrapped.values,tostring(v))
				table.insert(wrapped.types, shortType(v))
			end
		end
	end
	
	itIsTable(input,nil,wrapped)--evil i know :D
end

local function parse(wrapped,val)
	if tonumber(val) then
		local k=math.floor(tonumber(val))
		if wrapped.depths[k] and wrapped.depths[k]>0 then
			local v=wrapped.values[k]
			local temp=v
			if     wrapped.types[k]=="t" then
				if wrapped.values[k]~="table: self" then
					--checks if it is the first definition
					for k1,v1 in ipairs(wrapped.values) do
						if wrapped.depths[k1]>0 then
							if k1==k and v1==v and wrapped.types[k1]=="t" then
								for k2,v2 in ipairs(wrapped.values) do
									if wrapped.depths[k2]>0 then
										if v2==v1 and wrapped.types[k2]=="d" and type(wrapped.parsed[k2])=="table" then
											temp=wrapped.parsed[k2]
											for k3,v3 in ipairs(wrapped.tables.keys) do
												if v3==v2 then temp=nil break end
											end
											if type(temp)=="table" then	break end
										end
									end
								end
								if type(temp)~="table" then
									for k2,v2 in ipairs(wrapped.values) do
										if v2==v1 and wrapped.depths[k2]>0 and wrapped.types[k2]=="t" and type(wrapped.parsed[k2])=="table" then
											temp=wrapped.parsed[k2] 
											break
										end
									end
								end
								if type(temp)~="table" then temp={} end
								break
							elseif v1==v and wrapped.types[k1]=="t" then
								temp=nil
								break
							end
						end
					end
				else
					temp=nil
				end
			elseif wrapped.types[k]=="x" then
				temp=nil
			elseif wrapped.types[k]=="d" then
				if wrapped.values[k]~="table: self" then
					for k1,v1 in ipairs(wrapped.values) do
						if v1==v and wrapped.depths[k1]>0 and wrapped.types[k1]=="d" then 
							temp=wrapped.parsed[k1]
						end
						if type(temp)=="table" then break end
					end
					if type(temp)~="table" then
						for k1,v1 in ipairs(wrapped.values) do
							if v1==v and wrapped.depths[k1]>0 and wrapped.types[k1]=="t" then 
								temp=wrapped.parsed[k1]
								break 
							end
						end
						if type(temp)~="table" then
							for k1,v1 in ipairs(wrapped.tables.keys) do
								if v1==v and type(wrapped.tables.values[k1])=="table"  then temp=wrapped.tables.values[k1] break end
							end
							if type(temp)~="table" then
								temp={}
							end
						end
					end
				else
					temp=nil
				end
			elseif wrapped.types[k]=="s" then
				temp=invisibleCharUnwrap(temp)
			elseif wrapped.types[k]=="-" then
				temp=nil
			elseif wrapped.types[k]=="n" then
				temp=tonumber(temp)
				if not temp then temp=0 end
			elseif wrapped.types[k]=="b" then
				temp=string.lower(temp)
				if temp=="false" or temp=="nil" or temp=="" or temp=="f" then temp=false else temp=true end
			elseif wrapped.types[k]=="f" then
				temp=function()end 
				for k1,v1 in ipairs(wrapped.functions.keys) do
					--if v1==v and type(wrapped.functions.values[k1])=="function" then temp=wrapped.functions.values[k1] break else temp=function()end end
					if v1==v and type(wrapped.functions.values[k1])=="string" then temp=loadstring("return loadstring(\""..wrapped.functions.values[k1].."\")")() break end--? BREAKS HERE USUALLY
				end
			elseif wrapped.types[k]=="c" then
				for k1,v1 in ipairs(wrapped.threads.keys) do
					if v1==v and type(wrapped.threads.values[k1])=="thread"  then temp=wrapped.threads.values[k1] break else temp=coroutine.create(function()end) end
				end
			end
			wrapped.parsed[k]=temp
		end
	else
		wrapped.parsed={}
		for k,v in ipairs(wrapped.values) do
			parse(wrapped,k)
		end
	end
end	

--[[]]function wrappedParse(wrapped, val)
	if not isWrapped(wrapped) then 
		return nil,wrapped,false
	end
	wrap=tableDuplicate(wrapped)
	parse(wrapped,val)
	return wrap,wrapped,true
end

local function unwrapTable(wrapped)
	wrapped.tables.selfValue={}
	local function fill(wrapped,into,entry)
		local key=nil
		local keyTest=false
		while entry<=#wrapped.values do
			if wrapped.depths[entry]>0 then
				if wrapped.types[entry]=="x" then
					return entry
				end
				
				local self=false
				if wrapped.values[entry]=="table: self" and (wrapped.types[entry]=="t" or wrapped.types[entry]=="d") then
					self=true
				end
			
				if wrapped.kinds[entry]=="K" then
					if self then 
						key=wrapped.tables.selfValue
					else
						key=wrapped.parsed[entry]
					end
					keyTest=true
				else
					
					if keyTest then
						if type(key)~="nil" then
							if self then 
								into[key]=wrapped.tables.selfValue
							else	
								into[key]=wrapped.parsed[entry]
							end
						end
						keyTest=false
					else
						if self then
							table.insert(into,wrapped.tables.selfValue)
						else
							table.insert(into,wrapped.parsed[entry])
						end
					end
				end
				
				if wrapped.types[entry]=="t" then
					if self then
						entry=fill(wrapped.tables.selfValue,wrapped.parsed[entry],entry+1)
					else
						entry=fill(wrapped,wrapped.parsed[entry],entry+1)
					end
				end
			end
			entry=entry+1
		end
	end
	fill(wrapped,wrapped.tables.selfValue,1)
	return wrapped.tables.selfValue
end

--[[]]function tableDuplicate(tab)
	if type(tab)~="table" then tab={tab} end
	local outTable={}
	local duplicates={tab}
	local newDuplicates={outTable}
	local function itIsTable(tab,where,duplicates,newDuplicates)
		for k,v in pairs(tab) do
			if type(k)=="table" then
				local temp={}
				local test=false
				for k1,v1 in ipairs(duplicates) do
					if k==v1 then test=k1 end
				end
				if not test then
					temp={}
					table.insert(duplicates,k)
					table.insert(newDuplicates,temp)
					itIsTable(k,temp,duplicates,newDuplicates)
				else
					temp=newDuplicates[test]
				end
				
				if type(v)=="table" then
					local test=false
					for k1,v1 in ipairs(duplicates) do
						if v==v1 then test=k1 end
					end
					if not test then
						where[temp]={}
						table.insert(duplicates,v)
						table.insert(newDuplicates,where[temp])
						itIsTable(v,where[temp],duplicates,newDuplicates)
					else
						where[temp]=newDuplicates[test]
					end
				else
					where[temp]=v
				end
			else
				if type(v)=="table" then
					local test=false
					for k1,v1 in ipairs(duplicates) do
						if v==v1 then test=k1 end
					end
					if not test then
						where[k]={}
						table.insert(duplicates,v)
						table.insert(newDuplicates,where[k])
						itIsTable(v,where[k],duplicates,newDuplicates)
					else
						where[k]=newDuplicates[test]
					end
				else
					where[k]=v
				end
			end
		end
	end
	itIsTable(tab,outTable,duplicates,newDuplicates)
	return outTable
end

--[[]]function tableToWrapped(input)
	local test=true
	if type(input)~="table" then 
		tab={}
		test=false
	else 
		tab=tableDuplicate(input)
	end
	local wrapped={["kinds"]={},["depths"]={},["values"]={},["types"]={},["parsed"]={},["protected"]={},
					["tables"]={["keys"]={},["values"]={},["selfValue"]={}},["functions"]={["keys"]={},["values"]={}},
					["threads"]={["keys"]={},["values"]={}}}
	wrapTable(tab,wrapped)
	--solveDepths(wrapped)
	parse(wrapped)
	return wrapped,tab,test
end

--[[]]function wrappedToString(wrapped)
	if not isWrapped(wrapped) then 
		return "",tableDuplicate(wrapped),false
	end
	local wrap=tableDuplicate(wrapped)
	solveDepths(wrap)
	parse(wrap)
	local tab=unwrapTable(wrap)--WILL REWRAP TABLE TO REMOVE CONNECTIONS TO *.tables.* (old tables), needed only if serializing
	local wrapp={["kinds"]={},["depths"]={},["values"]={},["types"]={},["parsed"]={},["protected"]={},
					["tables"]={["keys"]={},["values"]={},["selfValue"]={}},["functions"]={["keys"]={},["values"]={}},
					["threads"]={["keys"]={},["values"]={}}}
	wrapTable(tab,wrapp)
	--solveDepths(wrapp)
	parse(wrapp)
					
	local str="TABBY TABLE FORMAT:"
	for k,v in ipairs(wrapp.values) do
		if wrapp.depths[k]>0 --[[and wrapp.parsed[k]~=nil]] then
			str=str.."\n"..tostring(wrapp.kinds[k]).." "..tostring(wrapp.types[k]).." "..--[[invisibleCharWrap]](tostring(wrapp.values[k]))
		end
	end
	str=str.."\nFUNCTIONS:"
	for k,v in ipairs(wrapp.functions.keys) do
		--str=str.."\n"..tostring(wrapp.functions.keys[k]).."\n"..invisibleCharWrap(string.dump(wrapp.functions.values[k]))
		str=str.."\n"..tostring(wrapp.functions.keys[k]).."\n"..tostring(wrapp.functions.values[k])
	end
	return str,{wrap,wrapp},true
end

--[[]]function tableToString(input)
	if type(input)~="table" then return nil,false end
	local tab=tableDuplicate(input)
	return wrappedToString(tableToWrapped(tab)),tab,true
end

--[[]]function stringToWrapped(str,wrapped)
	local test=true
	if isWrapped(wrapped) then
		wrapped.values={}
		wrapped.depths={}
		wrapped.kinds={}
		wrapped.types={}
		if #wrapped.functions.values>0 then
			table.insert(wrapped.functions.keys,"")
			table.insert(wrapped.functions.values,"")
		end
		if #wrapped.threads.values>0 then
			table.insert(wrapped.threads.keys,"")
			table.insert(wrapped.threads.values,"")
		end
		if #wrapped.tables.values>0 then
			table.insert(wrapped.tables.keys,"")
			table.insert(wrapped.tables.values,"")
		end
	else
		wrapped={["kinds"]={},["depths"]={},["values"]={},["types"]={},["parsed"]={},["protected"]={},
						["tables"]={["keys"]={},["values"]={},["selfValue"]={}},["functions"]={["keys"]={},["values"]={}},
						["threads"]={["keys"]={},["values"]={}}}
	end
	if type(str)~="string" then 
		str=""
		test=false
	end
	local strLines=stringSplit(str,"\n")
	if test then
		if strLines[1]=="TABBY TABLE FORMAT:" then
			table.remove(strLines,1)
			local functions=false
			for k,v in ipairs(strLines) do
				local line=--[[invisibleCharWrap]](v)
				if line=="FUNCTIONS:" then 
					functions=true 
				elseif #line>0 then--ignore empty lines
					if functions then
						if functions==true then
							functions=line
						else
							local test=true
							for k1,v1 in ipairs(wrapped.functions.values) do
								--if k==v1 then test=false end
								if line==v1 and functions==wrapped.functions.keys[k1] then test=false end
							end
							if test then
								table.insert(wrapped.functions.keys,functions)
								table.insert(wrapped.functions.values,line)
							end
							functions=true
						end
					else
						table.insert(wrapped.kinds, line:sub(1,1))
						table.insert(wrapped.depths,1)
						table.insert(wrapped.types, line:sub(3,3))
						table.insert(wrapped.values,line:sub(5))
					end
				end
			end
		else
			local check,tab=pcall(textutils.unserialize,str)
			if check then
				return tableToWrapped(tab)
			end
		end
	end
	solveDepths(wrapped)
	parse(wrapped)
	return wrapped,nil,test
end

--[[]]function wrappedToTable(wrapped)
	if not isWrapped(wrapped) then 
		return {},false
	end
	local wrap=tableDuplicate(wrapped)
	solveDepths(wrap)
	parse(wrap)
	return unwrapTable(wrap),wrap,true
end

--[[]]function stringToTable(str)
	if type(str)~="string" then return nil,false end
	return wrappedToTable(stringToWrapped(str)),nil,true
end

--[[]]function saveWrapped(wrapped, path)--?
	if not isWrapped(wrapped) then 
		return false
	end
	if type(path)~="string" or path=="" then return false end
	
	local str=wrappedToString(wrapped)
	
	local test,file=pcall(fs.open,tostring(path),"w")
	if test then
		file.write(str)
		file.close()
	end
	return true
end

--[[]]function loadWrapped(path,wrapped)--?
	if type(path)~="string" or path=="" or not fs.exists(path) then return (wrapped or {}),nil,false end
	local test,file=pcall(fs.open,tostring(path),"r")
	if test then
		wrapped=stringToWrapped(file.readAll(),wrapped)
		file.close()
		return wrapped,nil,true
	end
	return (wrapped or {}),nil,false
end

--[[]]function saveTable(tab, path)
	return saveWrapped(tableToWrapped(tab),path)
end

--[[]]function loadTable(path)
	return wrappedToTable(loadWrapped(path))
end

--[[]]function swapCells(tab,...)
	if type(tab)~="table" then return nil end
	local args={...}
	local k=2
	while k<=#args do
		tab[args[k]],tab[args[k-1]]=tab[args[k-1]],tab[args[k]]
		k=k+2
	end
end

--[[]]function swapWrappedCells(wrapped,...)
	if not isWrapped(wrapped) then return nil end
	local args={...}
	local k=2
	while k<=#args do
		if args[k]<0 then
			wrapped["values"][args[k]]		=wrapped["values"][args[k-1]]	 
			wrapped["kinds"][args[k]]    	=wrapped["kinds"][args[k-1]]    
			wrapped["types"][args[k]]    	=wrapped["types"][args[k-1]]    
			wrapped["depths"][args[k]]   	=wrapped["depths"][args[k-1]]   
			wrapped["protected"][args[k]]	=wrapped["protected"][args[k-1]]
			table.remove(wrapped["values"],args[k-1])
			table.remove(wrapped["kinds"],args[k-1])
			table.remove(wrapped["types"],args[k-1])
			table.remove(wrapped["depths"],args[k-1])
			table.remove(wrapped["protected"],args[k-1])
		end
		if args[k-1]<0 then
			table.insert(wrapped["values"],		args[k],wrapped["values"][args[k-1]])
			table.insert(wrapped["kinds"],		args[k],wrapped["kinds"][args[k-1]])
			table.insert(wrapped["types"],		args[k],wrapped["types"][args[k-1]])
			table.insert(wrapped["depths"],		args[k],wrapped["depths"][args[k-1]])
			table.insert(wrapped["protected"],	args[k],wrapped["protected"][args[k-1]])
			wrapped["values"][args[k-1]]	=nil
			wrapped["kinds"][args[k-1]]    	=nil
			wrapped["types"][args[k-1]]    	=nil
			wrapped["depths"][args[k-1]]   	=nil
			wrapped["protected"][args[k-1]]	=nil
		end
		if args[k]>=0 and args[k-1]>=0 then
			wrapped["values"][args[k]]	 ,wrapped["values"][args[k-1]]	 =wrapped["values"][args[k-1]]	 ,wrapped["values"][args[k]]
			wrapped["kinds"][args[k]]    ,wrapped["kinds"][args[k-1]]    =wrapped["kinds"][args[k-1]]    ,wrapped["kinds"][args[k]]
			wrapped["types"][args[k]]    ,wrapped["types"][args[k-1]]    =wrapped["types"][args[k-1]]    ,wrapped["types"][args[k]]
			wrapped["depths"][args[k]]   ,wrapped["depths"][args[k-1]]   =wrapped["depths"][args[k-1]]   ,wrapped["depths"][args[k]]
			wrapped["protected"][args[k]],wrapped["protected"][args[k-1]]=wrapped["protected"][args[k-1]],wrapped["protected"][args[k]]
		end
		k=k+2
	end
end

--[[]]function fill(tab,filling,...)
	local args={...}
	for k,v in ipairs(args) do
		tab[v]=filling
	end
end

--[[]]function populate(tab,filling,...)
	local args={...}
	for k,v in ipairs(args) do
		if type(tab[v])=="nil" then tab[v]=filling end
	end
end

--[[]]function numberList(start,stop,step)
	local tab={}
	--if not step then step=1 end
	if not tonumber(start) or not tonumber(stop) then return nil end
	if not tonumber(step) then step=1 end
	for i=start,stop,step do
		table.insert(tab,i)
	end
	return unpack(tab)
end

--NON API STUFF--
 
local function xCursorName(input)
	local returns={
		[1]="kinds",
		[2]="depths",
		[3]="types",
		[4]="values"
		}
	return returns[input]
end

local function drawMainElements(state)--main
	local temp=string.rep(" ",state.xSize)
	if state.colored then
		term.setBackgroundColor(colors.blue)
		term.setCursorPos(state.xPos,state.yPos)
		term.write(temp)
		
		term.setTextColor(colors.black)
		term.setCursorPos(state.xPos,state.yPos)
		term.write("X:")--xPos+5,yPos
		term.setCursorPos(state.xPos+8,state.yPos)
		term.write("Y:")--xPos+13,yPos
		term.setCursorPos(state.xPos+16,state.yPos)
		term.write("L:")--xPos+21,yPos
		term.setTextColor(colors.white)
		term.setCursorPos(state.xPos+state.xSize-1,state.yPos)
		term.write("M")--xPos+21,yPos
		
		--[[X:      Y:      L:]]
		for i=state.yTextMin,state.yTextMax do
			term.setCursorPos(state.xPos,i)
			term.write(temp)
		end
		
		term.setBackgroundColor(colors.white)
		for i=state.yTextMin,state.yTextMax do
			term.setCursorPos(state.xTextMin-3,i)
			term.write("  ")
		end
		term.setBackgroundColor(colors.lightBlue)
		for i=state.yTextMin,state.yTextMax do
			term.setCursorPos(state.xTextMin-4,i)
			term.write(" ")
			term.setCursorPos(state.xTextMin-1,i)
			term.write(" ")
		end
		
		
	else		
		for i=state.yPos,state.yPos+state.ySize-1 do
			term.setCursorPos(state.xPos,i)
			term.write(temp)
		end
		
		term.setCursorPos(state.xPos,state.yPos)
		term.write("X:")--xPos+5,yPos
		term.setCursorPos(state.xPos+8,state.yPos)
		term.write("Y:")--xPos+13,yPos
		term.setCursorPos(state.xPos+16,state.yPos)
		term.write("L:")--xPos+21,yPos
		
		for i=state.yTextMin,state.yTextMax do
			term.setCursorPos(state.xTextMin-1,i)
			term.write("|")
		end
	end
end

local function drawTable(state,wrapped)--main
	local temp="     "
	if state.colored then
		term.setBackgroundColor(colors.blue)
		term.setTextColor(colors.lightBlue)
	end
	term.setCursorPos(state.xMin+2,state.yMin)
	term.write(temp)
	term.setCursorPos(state.xMin+2,state.yMin)
	term.write(tostring(state.xShift%100000))
	term.setCursorPos(state.xMin+10,state.yMin)
	term.write(temp)
	term.setCursorPos(state.xMin+10,state.yMin)
	term.write(tostring(state.yShift%100000))
	term.setCursorPos(state.xMin+18,state.yMin)
	term.write(temp)
	term.setCursorPos(state.xMin+18,state.yMin)
	term.write(tostring((state.yCursor+state.yShift)%100000))
	
	for i=1,state.yTextSize do
		if wrapped.values[i+state.yShift] or wrapped.kinds[i+state.yShift] 
		or wrapped.types[i+state.yShift]  or wrapped.depths[i+state.yShift] then
			local spacer=string.rep(" ",state.indents*math.abs(wrapped.depths[i+state.yShift]))
			if state.colored then
				term.setBackgroundColor(colors.white)
				if wrapped.kinds[i+state.yShift]=="K" then
					term.setTextColor(colors.blue)
				else
					term.setTextColor(colors.black)
				end
				term.setCursorPos(state.xTextMin-3,state.yTextMin+i-1)
				local temp
				if wrapped.depths[i+state.yShift]>=0 then
					temp=tostring(wrapped.depths[i+state.yShift]%100)
					while #temp<2 do temp=" "..temp end
				else
					temp="--"
				end
				term.write(temp)
				
				if state.selection[i+state.yShift] then
					term.setBackgroundColor(colors.lime)
				else
					term.setBackgroundColor(colors.lightBlue)
				end
				term.setCursorPos(state.xTextMin-4,state.yTextMin+i-1)
				term.write(tostring(wrapped.kinds[i+state.yShift]))
				term.setCursorPos(state.xTextMin-1,state.yTextMin+i-1)
				temp=tostring(wrapped.types[i+state.yShift])
				if state.selection[i+state.yShift] then
					temp=string.upper(temp)
					if temp=="-" then temp="+" end
				end
				term.write(temp)
				
				term.setBackgroundColor(colors.black)
				if wrapped.kinds[i+state.yShift]=="K" then
					if wrapped.depths[i+state.yShift]>0 then
						if wrapped.types[i+state.yShift]=="t" then
							term.setTextColor(colors.lightBlue)
						elseif wrapped.types[i+state.yShift]=="x" then
							term.setTextColor(colors.lightBlue)
						elseif wrapped.types[i+state.yShift]=="d" then
							term.setTextColor(colors.cyan)
						elseif wrapped.types[i+state.yShift]=="f" then
							term.setTextColor(colors.cyan)
						elseif wrapped.types[i+state.yShift]=="c" then
							term.setTextColor(colors.cyan)
						else
							term.setTextColor(colors.blue)
						end
					elseif wrapped.depths[i+state.yShift]==0 then
						term.setBackgroundColor(colors.cyan)
						term.setTextColor(colors.black)
					else
						term.setTextColor(colors.gray)
					end
				else
					if wrapped.depths[i+state.yShift]>0 then
						if wrapped.types[i+state.yShift]=="t" then
							term.setTextColor(colors.lime)
						elseif wrapped.types[i+state.yShift]=="x" then
							term.setTextColor(colors.lime)
						elseif wrapped.types[i+state.yShift]=="d" then
							term.setTextColor(colors.green)
						elseif wrapped.types[i+state.yShift]=="f" then
							term.setTextColor(colors.green)
						elseif wrapped.types[i+state.yShift]=="c" then
							term.setTextColor(colors.green)
						else
							term.setTextColor(colors.white)
						end
					elseif wrapped.depths[i+state.yShift]==0 then
						term.setBackgroundColor(colors.green)
						term.setTextColor(colors.black)
					else
						term.setTextColor(colors.lightGray)
					end
				end
				term.setCursorPos(state.xTextMin,state.yTextMin+i-1)
				if wrapped.protected[i+state.yShift] then
					writeEX(spacer.."Protected =^.^=",state.xShift,state.xTextSize)
				else
					temp=tostring(wrapped.values[i+state.yShift])
					writeEX(spacer..temp,state.xShift,state.xTextSize)
				end
			else
				term.setCursorPos(state.xTextMin-5,state.yTextMin+i-1)
				term.write(tostring(wrapped.kinds[i+state.yShift]))
				term.setCursorPos(state.xTextMin-4,state.yTextMin+i-1)
				local temp
				if wrapped.depths[i+state.yShift]>=0 then
					temp=tostring(wrapped.depths[i+state.yShift]%100)
					while #temp<2 do temp=" "..temp end
				else
					temp="--"
				end
				term.write(temp)
				term.setCursorPos(state.xTextMin-2,state.yTextMin+i-1)
				temp=tostring(wrapped.types[i+state.yShift])
				if state.selection[i+state.yShift] then
					temp=string.upper(temp)
					if temp=="-" then temp="+" end
				end
				term.write(temp)
				term.setCursorPos(state.xTextMin,state.yTextMin+i-1)
				if wrapped.protected[i+state.yShift] then
					writeEX(spacer.."Protected =^.^=",state.xShift,state.xTextSize)
				else
					temp=tostring(wrapped.values[i+state.yShift])
					writeEX(spacer..temp,state.xShift,state.xTextSize)
				end
			end
		else
			if state.colored then
				term.setBackgroundColor(colors.white)
				term.setCursorPos(state.xTextMin-3,state.yTextMin+i-1)
				term.write("  ")
				
				term.setBackgroundColor(colors.lightBlue)
				term.setCursorPos(state.xTextMin-4,state.yTextMin+i-1)
				term.write(" ")
				term.setCursorPos(state.xTextMin-1,state.yTextMin+i-1)
				term.write(" ")
				
				term.setBackgroundColor(colors.black)
				term.setCursorPos(state.xTextMin,state.yTextMin+i-1)
				local temp=" "
				while #temp<state.xTextSize do temp=temp.." " end
				term.write(temp)
			else
				term.setCursorPos(state.xTextMin-5,state.yTextMin+i-1)
				term.write("    ")
				term.setCursorPos(state.xTextMin,state.yTextMin+i-1)
				local temp=" "
				while #temp<state.xTextSize do temp=temp.." " end
				term.write(temp)
			end
		end
	end
end

local function drawGUI(state,wrapped)--main
	--xCursor - points to column 1,2,3,4
	--yCursor - points to line
	drawTable(state,wrapped)
	term.setCursorBlink(true)
	if state.place=="main" then
		if state.colored then
			if state.blockClipboard[xCursorName(state.xCursor)] then
				term.setTextColor(colors.red)
				term.setBackgroundColor(colors.pink)
			else
				term.setTextColor(colors.blue)
				term.setBackgroundColor(colors.lime)
			end
			local doTable={
				[1]=function(state)
						term.setCursorPos(state.xTextMin-4,state.yCursor+state.yTextMin-1)
					end
				,[2]=function(state)
						term.setCursorPos(state.xTextMin-3,state.yCursor+state.yTextMin-1)
					end
				,[3]=function(state)
						term.setCursorPos(state.xTextMin-1,state.yCursor+state.yTextMin-1)
					end
				,[4]=function(state)
						term.setCursorPos(state.xTextMin,state.yCursor+state.yTextMin-1)
					end
				}
			if doTable[state.xCursor] then doTable[state.xCursor](state) end
		else
			if state.blockClipboard[xCursorName(state.xCursor)] then
				term.setCursorBlink(true)
			else
				term.setCursorBlink(state.timer)
			end
			local doTable={
				[1]=function(state)
						term.setCursorPos(state.xTextMin-5,state.yCursor+state.yTextMin-1)
					end
				,[2]=function(state)
						term.setCursorPos(state.xTextMin-4,state.yCursor+state.yTextMin-1)
					end
				,[3]=function(state)
						term.setCursorPos(state.xTextMin-2,state.yCursor+state.yTextMin-1)
					end
				,[4]=function(state)
						term.setCursorPos(state.xTextMin,state.yCursor+state.yTextMin-1)
					end
				}
			if doTable[state.xCursor] then doTable[state.xCursor](state) end
		end
	elseif state.place=="topBar" then
		drawTable(state,wrapped)
		term.setCursorBlink(true)
		if state.colored then
			term.setTextColor(colors.red)
			term.setBackgroundColor(colors.pink)
		end
		local doTable={
			 [1]=function(state)
					term.setCursorPos(state.xMin+2,state.yMin)
				end
			,[2]=function(state)
					term.setCursorPos(state.xMin+10,state.yMin)
				end
			,[3]=function(state)
					term.setCursorPos(state.xMin+18,state.yMin)
				end
			,[4]=function(state)
					term.setCursorPos(state.xMax,state.yMin)
				end
			}
		if doTable[state.xCursor] then doTable[state.xCursor](state) end
	end
end

local function drawThreadAlias(state)
	if state.colored then
		term.setBackgroundColor(colors.pink)
		local temp="    "
		for i=state.yPos,state.yPos+state.ySize-1 do
			term.setCursorPos(state.xPos,i)
			term.write(temp)
		end
		
		term.setBackgroundColor(colors.black)
		temp=""
		while #temp<state.xSize-4 do
			temp=temp.." "
		end
		for i=state.yPos,state.yPos+state.ySize-1 do
			term.setCursorPos(state.xPos+4,i)
			term.write(temp)
		end
		
		term.setBackgroundColor(colors.red)
		term.setCursorPos(state.xPos,state.yPos)
		temp=temp.."    "
		term.write(temp)
		
		term.setTextColor(colors.black)
	else
		local temp="    #"
		while #temp<state.xSize do
			temp=temp.." "
		end
		for i=state.yPos,state.yPos+state.ySize-1 do
			term.setCursorPos(state.xPos,i)
			term.write(temp)
		end
		term.setCursorPos(state.xPos,state.yPos)
		temp=temp.."    "
		term.write(temp)
	end
	term.setCursorPos(state.xPos,state.yPos)
	term.write("X:")--xPos+5,yPos
	term.setCursorPos(state.xPos+8,state.yPos)
	term.write("Y:")--xPos+13,yPos
	term.setCursorPos(state.xPos+16,state.yPos)
	term.write("L:")--xPos+21,yPos
	if state.colored then
		term.setTextColor(colors.white)
	end
	term.setCursorPos(state.xPos+state.xSize-1,state.yPos)
	term.write("M")--xPos+21,yPos
end

local function drawThreadAliasGUI(state,wrapped)
	--DRAW TOP BAR
	local temp="     "
	if state.colored then
		term.setBackgroundColor(colors.red)
		term.setTextColor(colors.pink)
	end
	term.setCursorPos(state.xMin+2,state.yMin)
	term.write(temp)
	term.setCursorPos(state.xMin+2,state.yMin)
	term.write(tostring(state.threadAlias.xShift%100000))
	term.setCursorPos(state.xMin+10,state.yMin)
	term.write(temp)
	term.setCursorPos(state.xMin+10,state.yMin)
	term.write(tostring(state.threadAlias.yShift%100000))
	term.setCursorPos(state.xMin+18,state.yMin)
	term.write(temp)
	term.setCursorPos(state.xMin+18,state.yMin)
	term.write(tostring((state.threadAlias.yCursor+state.threadAlias.yShift)%100000))
	--DRAW THREAD TABLE
	if state.colored then
		for i=1,state.yTextSize do
			if i+state.threadAlias.yShift <= (#wrapped.threads.keys)*2 then
				if (i+state.threadAlias.yShift)%2==1 then
					term.setTextColor(colors.red)
					term.setBackgroundColor(colors.pink)
					term.setCursorPos(state.xTextMin-4,state.yTextMin+i-1)
					term.write("K")
					
					term.setTextColor(colors.red)
					term.setBackgroundColor(colors.black)
					term.setCursorPos(state.xTextMin,state.yTextMin+i-1)
					writeEX(tostring(wrapped.threads.keys[(i+state.yShift+1)/2]),state.threadAlias.xShift,state.xTextSize)
				else
					term.setTextColor(colors.black)
					term.setBackgroundColor(colors.pink)
					term.setCursorPos(state.xTextMin-4,state.yTextMin+i-1)
					term.write("V")
					
					term.setTextColor(colors.white)
					term.setBackgroundColor(colors.black)
					term.setCursorPos(state.xTextMin,state.yTextMin+i-1)
					writeEX(tostring(wrapped.threads.values[(i+state.yShift)/2]),state.threadAlias.xShift,state.xTextSize)
				end
			else
				term.setBackgroundColor(colors.pink)
				term.setCursorPos(state.xTextMin-4,state.yTextMin+i-1)
				term.write("    ")
				
				term.setBackgroundColor(colors.black)
				term.setCursorPos(state.xTextMin,state.yTextMin+i-1)
				local temp=" "
				while #temp<state.xTextSize do temp=temp.." " end
				term.write(temp)
			end
		end
	else
		for i=1,state.yTextSize do
			if i+state.threadAlias.yShift <= (#wrapped.threads.keys)*2 then
				if (i+state.threadAlias.yShift)%2==1 then
					term.setCursorPos(state.xTextMin-5,state.yTextMin+i-1)
					term.write("K")
					
					term.setCursorPos(state.xTextMin,state.yTextMin+i-1)
					writeEX(tostring(wrapped.threads.keys[(i+state.yShift+1)/2]),state.threadAlias.xShift,state.xTextSize)
				else
					term.setCursorPos(state.xTextMin-5,state.yTextMin+i-1)
					term.write("V")
					
					term.setCursorPos(state.xTextMin,state.yTextMin+i-1)
					writeEX(tostring(wrapped.threads.values[(i+state.yShift)/2]),state.threadAlias.xShift,state.xTextSize)
				end
			else
				term.setCursorPos(state.xTextMin-5,state.yTextMin+i-1)
				term.write("    ")
				term.setCursorPos(state.xTextMin,state.yTextMin+i-1)
				local temp=" "
				while #temp<state.xTextSize do temp=temp.." " end
				term.write(temp)
			end
		end
	end
	--draw CURSOR
	if state.colored then
		term.setTextColor(colors.blue)
	end
	term.setCursorBlink(true)
	if state.place=="topBarThreadAlias" then
		if state.threadAlias.xCursor==1 then
			term.setCursorPos(state.xMin+2,state.yMin)
		elseif state.threadAlias.xCursor==2 then
			term.setCursorPos(state.xMin+10,state.yMin)
		elseif state.threadAlias.xCursor==3 then
			term.setCursorPos(state.xMin+18,state.yMin)
		else
			term.setCursorPos(state.xMax,state.yMin)
		end
	else
		term.setCursorPos(state.xMin+3,state.yTextMin+state.threadAlias.yCursor-1)
	end
end

local function drawTableAlias(state)
	if state.colored then
		term.setBackgroundColor(colors.lime)
		local temp="    "
		for i=state.yPos,state.yPos+state.ySize-1 do
			term.setCursorPos(state.xPos,i)
			term.write(temp)
		end
		
		term.setBackgroundColor(colors.black)
		temp=""
		while #temp<state.xSize-4 do
			temp=temp.." "
		end
		for i=state.yPos,state.yPos+state.ySize-1 do
			term.setCursorPos(state.xPos+4,i)
			term.write(temp)
		end
		
		term.setBackgroundColor(colors.green)
		term.setCursorPos(state.xPos,state.yPos)
		temp=temp.."    "
		term.write(temp)
		
		term.setTextColor(colors.black)
	else
		local temp="    \\"
		while #temp<state.xSize do
			temp=temp.." "
		end
		for i=state.yPos,state.yPos+state.ySize-1 do
			term.setCursorPos(state.xPos,i)
			term.write(temp)
		end
		term.setCursorPos(state.xPos,state.yPos)
		temp=temp.."    "
		term.write(temp)
	end
	term.setCursorPos(state.xPos,state.yPos)
	term.write("X:")--xPos+5,yPos
	term.setCursorPos(state.xPos+8,state.yPos)
	term.write("Y:")--xPos+13,yPos
	term.setCursorPos(state.xPos+16,state.yPos)
	term.write("L:")--xPos+21,yPos
	if state.colored then
		term.setTextColor(colors.white)
	end
	term.setCursorPos(state.xPos+state.xSize-1,state.yPos)
	term.write("M")--xPos+21,yPos
end

local function drawTableAliasGUI(state,wrapped)
	--DRAW TOP BAR
	local temp="     "
	if state.colored then
		term.setBackgroundColor(colors.green)
		term.setTextColor(colors.lime)
	end
	term.setCursorPos(state.xMin+2,state.yMin)
	term.write(temp)
	term.setCursorPos(state.xMin+2,state.yMin)
	term.write(tostring(state.tableAlias.xShift%100000))
	term.setCursorPos(state.xMin+10,state.yMin)
	term.write(temp)
	term.setCursorPos(state.xMin+10,state.yMin)
	term.write(tostring(state.tableAlias.yShift%100000))
	term.setCursorPos(state.xMin+18,state.yMin)
	term.write(temp)
	term.setCursorPos(state.xMin+18,state.yMin)
	term.write(tostring((state.tableAlias.yCursor+state.tableAlias.yShift)%100000))
	--DRAW THREAD TABLE
	if state.colored then
		for i=1,state.yTextSize do
			if i+state.tableAlias.yShift <= (#wrapped.tables.keys)*2 then
				if (i+state.tableAlias.yShift)%2==1 then
					term.setTextColor(colors.green)
					term.setBackgroundColor(colors.lime)
					term.setCursorPos(state.xTextMin-4,state.yTextMin+i-1)
					term.write("K")
					
					term.setTextColor(colors.green)
					term.setBackgroundColor(colors.black)
					term.setCursorPos(state.xTextMin,state.yTextMin+i-1)
					writeEX(tostring(wrapped.tables.keys[(i+state.yShift+1)/2]),state.tableAlias.xShift,state.xTextSize)
				else
					term.setTextColor(colors.black)
					term.setBackgroundColor(colors.lime)
					term.setCursorPos(state.xTextMin-4,state.yTextMin+i-1)
					term.write("V")
					
					term.setTextColor(colors.white)
					term.setBackgroundColor(colors.black)
					term.setCursorPos(state.xTextMin,state.yTextMin+i-1)
					writeEX(tostring(wrapped.tables.values[(i+state.yShift)/2]),state.tableAlias.xShift,state.xTextSize)
				end
			else
				term.setBackgroundColor(colors.lime)
				term.setCursorPos(state.xTextMin-4,state.yTextMin+i-1)
				term.write("    ")
				
				term.setBackgroundColor(colors.black)
				term.setCursorPos(state.xTextMin,state.yTextMin+i-1)
				local temp=" "
				while #temp<state.xTextSize do temp=temp.." " end
				term.write(temp)
			end
		end
	else
		for i=1,state.yTextSize do
			if i+state.tableAlias.yShift <= (#wrapped.tables.keys)*2 then
				if (i+state.tableAlias.yShift)%2==1 then
					term.setCursorPos(state.xTextMin-5,state.yTextMin+i-1)
					term.write("K")
					
					term.setCursorPos(state.xTextMin,state.yTextMin+i-1)
					writeEX(tostring(wrapped.tables.keys[(i+state.yShift+1)/2]),state.tableAlias.xShift,state.xTextSize)
				else
					term.setCursorPos(state.xTextMin-5,state.yTextMin+i-1)
					term.write("V")
					
					term.setCursorPos(state.xTextMin,state.yTextMin+i-1)
					writeEX(tostring(wrapped.tables.values[(i+state.yShift)/2]),state.tableAlias.xShift,state.xTextSize)
				end
			else
				term.setCursorPos(state.xTextMin-5,state.yTextMin+i-1)
				term.write("    ")
				term.setCursorPos(state.xTextMin,state.yTextMin+i-1)
				local temp=" "
				while #temp<state.xTextSize do temp=temp.." " end
				term.write(temp)
			end
		end
	end
	--draw CURSOR
	if state.colored then
		term.setTextColor(colors.blue)
	end
	term.setCursorBlink(true)
	if state.place=="topBarTableAlias" then
		if state.tableAlias.xCursor==1 then
			term.setCursorPos(state.xMin+2,state.yMin)
		elseif state.tableAlias.xCursor==2 then
			term.setCursorPos(state.xMin+10,state.yMin)
		elseif state.tableAlias.xCursor==3 then
			term.setCursorPos(state.xMin+18,state.yMin)
		else
			term.setCursorPos(state.xMax,state.yMin)
		end
	else
		term.setCursorPos(state.xMin+3,state.yTextMin+state.tableAlias.yCursor-1)
	end
end

local function drawFunctionAlias(state)
	if state.colored then
		term.setBackgroundColor(colors.yellow)
		local temp="    "
		for i=state.yPos,state.yPos+state.ySize-1 do
			term.setCursorPos(state.xPos,i)
			term.write(temp)
		end
		
		term.setBackgroundColor(colors.black)
		temp=""
		while #temp<state.xSize-4 do
			temp=temp.." "
		end
		for i=state.yPos,state.yPos+state.ySize-1 do
			term.setCursorPos(state.xPos+4,i)
			term.write(temp)
		end
		
		term.setBackgroundColor(colors.orange)
		term.setCursorPos(state.xPos,state.yPos)
		temp=temp.."    "
		term.write(temp)
		
		term.setTextColor(colors.black)
	else
		local temp="    /"
		while #temp<state.xSize do
			temp=temp.." "
		end
		for i=state.yPos,state.yPos+state.ySize-1 do
			term.setCursorPos(state.xPos,i)
			term.write(temp)
		end
		term.setCursorPos(state.xPos,state.yPos)
		temp=temp.."    "
		term.write(temp)
	end
	term.setCursorPos(state.xPos,state.yPos)
	term.write("X:")--xPos+5,yPos
	term.setCursorPos(state.xPos+8,state.yPos)
	term.write("Y:")--xPos+13,yPos
	term.setCursorPos(state.xPos+16,state.yPos)
	term.write("L:")--xPos+21,yPos
	if state.colored then
		term.setTextColor(colors.white)
	end
	term.setCursorPos(state.xPos+state.xSize-1,state.yPos)
	term.write("M")--xPos+21,yPos
end

local function drawFunctionAliasGUI(state,wrapped)
	--DRAW TOP BAR
	local temp="     "
	if state.colored then
		term.setBackgroundColor(colors.orange)
		term.setTextColor(colors.yellow)
	end
	term.setCursorPos(state.xMin+2,state.yMin)
	term.write(temp)
	term.setCursorPos(state.xMin+2,state.yMin)
	term.write(tostring(state.functionAlias.xShift%100000))
	term.setCursorPos(state.xMin+10,state.yMin)
	term.write(temp)
	term.setCursorPos(state.xMin+10,state.yMin)
	term.write(tostring(state.functionAlias.yShift%100000))
	term.setCursorPos(state.xMin+18,state.yMin)
	term.write(temp)
	term.setCursorPos(state.xMin+18,state.yMin)
	term.write(tostring((state.functionAlias.yCursor+state.functionAlias.yShift)%100000))
	--DRAW THREAD TABLE
	if state.colored then
		for i=1,state.yTextSize do
			if i+state.functionAlias.yShift <= (#wrapped.functions.keys)*2 then
				if (i+state.functionAlias.yShift)%2==1 then
					term.setTextColor(colors.orange)
					term.setBackgroundColor(colors.yellow)
					term.setCursorPos(state.xTextMin-4,state.yTextMin+i-1)
					term.write("K")
					
					term.setTextColor(colors.orange)
					term.setBackgroundColor(colors.black)
					term.setCursorPos(state.xTextMin,state.yTextMin+i-1)
					writeEX(tostring(wrapped.functions.keys[(i+state.yShift+1)/2]),state.functionAlias.xShift,state.xTextSize)
				else
					term.setTextColor(colors.black)
					term.setBackgroundColor(colors.yellow)
					term.setCursorPos(state.xTextMin-4,state.yTextMin+i-1)
					term.write("V")
					
					term.setTextColor(colors.white)
					term.setBackgroundColor(colors.black)
					term.setCursorPos(state.xTextMin,state.yTextMin+i-1)
					writeEX(tostring(wrapped.functions.values[(i+state.yShift)/2]),state.functionAlias.xShift,state.xTextSize)
				end
			else
				term.setBackgroundColor(colors.yellow)
				term.setCursorPos(state.xTextMin-4,state.yTextMin+i-1)
				term.write("    ")
				
				term.setBackgroundColor(colors.black)
				term.setCursorPos(state.xTextMin,state.yTextMin+i-1)
				local temp=" "
				while #temp<state.xTextSize do temp=temp.." " end
				term.write(temp)
			end
		end
	else
		for i=1,state.yTextSize do
			if i+state.functionAlias.yShift <= (#wrapped.functions.keys)*2 then
				if (i+state.functionAlias.yShift)%2==1 then
					term.setCursorPos(state.xTextMin-5,state.yTextMin+i-1)
					term.write("K")
					
					term.setCursorPos(state.xTextMin,state.yTextMin+i-1)
					writeEX(tostring(wrapped.functions.keys[(i+state.yShift+1)/2]),state.functionAlias.xShift,state.xTextSize)
				else
					term.setCursorPos(state.xTextMin-5,state.yTextMin+i-1)
					term.write("V")
					
					term.setCursorPos(state.xTextMin,state.yTextMin+i-1)
					writeEX(tostring(wrapped.functions.values[(i+state.yShift)/2]),state.functionAlias.xShift,state.xTextSize)
				end
			else
				term.setCursorPos(state.xTextMin-5,state.yTextMin+i-1)
				term.write("    ")
				term.setCursorPos(state.xTextMin,state.yTextMin+i-1)
				local temp=" "
				while #temp<state.xTextSize do temp=temp.." " end
				term.write(temp)
			end
		end
	end
	--draw CURSOR
	if state.colored then
		term.setTextColor(colors.blue)
	end
	term.setCursorBlink(true)
	if state.place=="topBarFunctionAlias" then
		if state.functionAlias.xCursor==1 then
			term.setCursorPos(state.xMin+2,state.yMin)
		elseif state.functionAlias.xCursor==2 then
			term.setCursorPos(state.xMin+10,state.yMin)
		elseif state.functionAlias.xCursor==3 then
			term.setCursorPos(state.xMin+18,state.yMin)
		else
			term.setCursorPos(state.xMax,state.yMin)
		end
	else
		term.setCursorPos(state.xMin+3,state.yTextMin+state.functionAlias.yCursor-1)
	end
end

local function drawMenu(state)
	if state.colored then
		term.setBackgroundColor(colors.black)
		local temp="    "
		for i=state.yPos,state.yPos+state.ySize-1 do
			term.setCursorPos(state.xPos,i)
			term.write(temp)
		end
		
		term.setBackgroundColor(colors.blue)
		temp=""
		while #temp<state.xSize-4 do
			temp=temp.." "
		end
		for i=state.yPos,state.yPos+state.ySize-1 do
			term.setCursorPos(state.xPos+4,i)
			term.write(temp)
		end
		
		term.setBackgroundColor(colors.lightBlue)
		term.setCursorPos(state.xPos,state.yPos)
		temp=temp.."    "
		term.write(temp)
		
		term.setTextColor(colors.black)
	else
		local temp="    >"
		while #temp<state.xSize do
			temp=temp.." "
		end
		for i=state.yPos,state.yPos+state.ySize-1 do
			term.setCursorPos(state.xPos,i)
			term.write(temp)
		end
		term.setCursorPos(state.xPos,state.yPos)
		temp=temp.."    "
		term.write(temp)
	end
	term.setCursorPos(state.xPos,state.yPos)
	term.write("X:")--xPos+5,yPos
	term.setCursorPos(state.xPos+8,state.yPos)
	term.write("Y:")--xPos+13,yPos
	term.setCursorPos(state.xPos+16,state.yPos)
	term.write("L:")--xPos+21,yPos
end

local function drawMenuGUI(state)
	--DRAW TOP BAR
	local temp="     "
	if state.colored then
		term.setBackgroundColor(colors.lightBlue)
		term.setTextColor(colors.blue)
	end
	term.setCursorPos(state.xMin+2,state.yMin)
	term.write(temp)
	term.setCursorPos(state.xMin+2,state.yMin)
	term.write(tostring(state.menu.xShift%100000))
	term.setCursorPos(state.xMin+10,state.yMin)
	term.write(temp)
	term.setCursorPos(state.xMin+10,state.yMin)
	term.write(tostring(state.menu.yShift%100000))
	term.setCursorPos(state.xMin+18,state.yMin)
	term.write(temp)
	term.setCursorPos(state.xMin+18,state.yMin)
	term.write(tostring((state.menu.yCursor+state.menu.yShift)%100000))
	
	local sideTextColors={
	 colors.lightBlue
	,colors.lightBlue
	}
	local side={
	--    --
	 [[MENU]]
	,[[----]]
	,[[MAIN]]
	,[[TAB ]]
	,[[FUNC]]
	,[[THRD]]
	,[[HELP]]
	,[[NEW ]]
	,[[CLR ]]
	,state.safety.noSave and [[ -- ]] or [[SAVE]]
	,state.safety.noLoad and [[ -- ]] or [[LOAD]] 
	,[[RTRN]]
	,state.safety.noExit and [[ -- ]] or [[EXIT]]
	}
	--
	state.menu.entrycount=#side
	--
	local help
	if state.xSize<=21 then
		help={
		--                     --
		 [[You are in Main Menu ]]
		,[[---------------------]]
		,[[main tab. edit screen]]
		,[[tableRef. edit screen]]
		,[[function  edit screen]]
		,[[threadRef.edit screen]]
		,[[shows help file      ]]
		,[[creates new table    ]]
		,[[clears all data      ]]
		,state.safety.noSave and [[! option disabled    ]] or [[saves table to file  ]]
		,state.safety.noLoad and [[! option disabled    ]] or [[loads table from file]]
		,[[returns table        ]]
		,state.safety.noExit and [[! option disabled    ]] or  [[quits the program    ]]
		}
	else
		help={
		--                     --
		 [[You are in Main Menu ]]
		,[[---------------------]]
		,[[Moves user to Table edit screen]]
		,[[Moves user to Table Reference edit screen]]
		,[[Moves user to Function edit screen]]
		,[[Moves user to Thread Reference edit screen]]
		,[[Shows help file]]
		,[[Creates new table (clears the table contents)]]
		,[[Clears all data from wrapped table and alias tables]]
		,state.safety.noSave and [[! Option is disabled    ]] or [[Saves Table to a file specified Path]]
		,state.safety.noLoad and [[! Option is disabled    ]] or [[Loads Table from a file on specified Path]]
		,[[Returns the table back to the calling program (equal to EXIT if tabby started as program from shell)]]
		,state.safety.noExit and [[! Option is disabled    ]] or  [[Exits the program (equal to CTRL+T) - returns nil to the calling program]]
		}
	end
	
	if state.colored then
		for i=1,state.yTextSize do
			term.setBackgroundColor(colors.black)
			if tonumber(sideTextColors[i+state.menu.yShift]) then
				term.setTextColor(sideTextColors[i+state.menu.yShift])
			else
				term.setTextColor(colors.blue)
			end
			term.setCursorPos(state.xPos,i+state.yTextMin-1)
			if side[i+state.menu.yShift] then
				writeEX(side[i+state.menu.yShift],0,4)
			else
				term.write("    ")
			end
			
			term.setBackgroundColor(colors.blue)
			term.setTextColor(colors.lightBlue)
			term.setCursorPos(state.xPos+4,i+state.yTextMin-1)
			if help[i+state.menu.yShift] then
				writeEX(help[i+state.menu.yShift],state.menu.xShift,state.xTextSize)
			else
				term.write(string.rep(" ",state.xTextSize))
			end
		end
	else
		for i=state.yPos,state.yPos+state.ySize-1 do
			term.setCursorPos(state.xPos,i+state.yTextMin-1)
			if side[i+state.menu.yShift] then
				writeEX(side[i+state.menu.yShift],0,4)
			else
				term.write("    ")
			end
			term.setCursorPos(state.xPos+5,i+state.yTextMin-1)
			if help[i+state.menu.yShift] then
				writeEX(help[i+state.menu.yShift],state.menu.xShift,state.xTextSize)
			else
				term.write(string.rep(" ",state.xTextSize))
			end
		end
	end
	--draw CURSOR
	if state.colored then
		term.setTextColor(colors.white)
	end
	term.setCursorBlink(true)
	if state.place=="topBarMenu" then
		if state.menu.xCursor==1 then
			term.setCursorPos(state.xMin+2,state.yMin)
		elseif state.menu.xCursor==2 then
			term.setCursorPos(state.xMin+10,state.yMin)
		else
			term.setCursorPos(state.xMin+18,state.yMin)
		end
	else
		term.setCursorPos(state.xMin,state.yTextMin+state.menu.yCursor-1)
	end
end

local function drawHelp(state)
	if state.colored then
		term.setBackgroundColor(colors.blue)
		local temp="    "
		for i=state.yPos,state.yPos+state.ySize-1 do
			term.setCursorPos(state.xPos,i)
			term.write(temp)
		end
		
		term.setBackgroundColor(colors.lightBlue)
		temp=""
		while #temp<state.xSize-4 do
			temp=temp.." "
		end
		for i=state.yPos,state.yPos+state.ySize-1 do
			term.setCursorPos(state.xPos+4,i)
			term.write(temp)
		end
		
		term.setBackgroundColor(colors.white)
		term.setCursorPos(state.xPos,state.yPos)
		temp=temp.."    "
		term.write(temp)
		
		term.setTextColor(colors.black)
	else
		local temp="    :"
		while #temp<state.xSize do
			temp=temp.." "
		end
		for i=state.yPos,state.yPos+state.ySize-1 do
			term.setCursorPos(state.xPos,i)
			term.write(temp)
		end
		term.setCursorPos(state.xPos,state.yPos)
		temp=temp.."    "
		term.write(temp)
	end
	term.setCursorPos(state.xPos,state.yPos)
	term.write("X:")--xPos+5,yPos
	term.setCursorPos(state.xPos+8,state.yPos)
	term.write("Y:")--xPos+13,yPos
	if state.colored then
		term.setTextColor(colors.blue)
	end
	term.setCursorPos(state.xPos+state.xSize-1,state.yPos)
	term.write("M")--xPos+21,yPos
end

local function drawHelpGUI(state)
	--DRAW TOP BAR
	local temp="     "
	if state.colored then
		term.setBackgroundColor(colors.white)
		term.setTextColor(colors.blue)
	end
	term.setCursorPos(state.xMin+2,state.yMin)
	term.write(temp)
	term.setCursorPos(state.xMin+2,state.yMin)
	term.write(tostring(state.help.xShift%100000))
	term.setCursorPos(state.xMin+10,state.yMin)
	term.write(temp)
	term.setCursorPos(state.xMin+10,state.yMin)
	term.write(tostring(state.help.yShift%100000))
	local sideTextColors={
	--    --
	colors.black
	,colors.black
	,colors.lightBlue
	}
	local side={
	--    --
	 [[HELP]]
	,[[----]]
	,[[HOW ]]
	}
	local help={
	--                     --
	 [[You are in help File ]]
	,false--[[---------------------]]
	,[[How to use the prog. ]]
	}
	--
	state.help.entrycount=#help
	--
	if state.colored then
		for i=1,state.yTextSize do
			term.setBackgroundColor(colors.blue)
			if tonumber(sideTextColors[i+state.help.yShift]) then
				term.setTextColor(sideTextColors[i+state.help.yShift])
			else
				term.setTextColor(colors.lightBlue)
			end
			term.setCursorPos(state.xPos,i+state.yTextMin-1)
			if side[i+state.help.yShift] then
				writeEX(side[i+state.help.yShift],0,4)
			else
				term.write("    ")
			end
			term.setBackgroundColor(colors.lightBlue)
			term.setTextColor(colors.white)
			term.setCursorPos(state.xPos+4,i+state.yTextMin-1)
			if type(help[i+state.help.yShift])=="string" then
				writeEX(help[i+state.help.yShift],state.help.xShift,state.xTextSize)
			elseif type(help[i+state.help.yShift])~="nil" then
				term.write(string.rep("-",state.xTextSize))
			else
				term.write(string.rep(" ",state.xTextSize))
			end
		end
	else
		for i=state.yPos,state.yPos+state.ySize-1 do
			term.setCursorPos(state.xPos,i+state.yTextMin-1)
			if side[i+state.help.yShift] then
				writeEX(side[i+state.help.yShift],0,4)
			else
				term.write("    ")
			end
			term.setCursorPos(state.xPos+5,i+state.yTextMin-1)
			if help[i+state.help.yShift] then
				writeEX(help[i+state.help.yShift],state.help.xShift,state.xTextSize)
			else
				term.write(string.rep(" ",state.xTextSize))
			end
		end
	end
	--draw CURSOR
	if state.colored then
		term.setTextColor(colors.blue)
	end
	term.setCursorBlink(true)
	if state.help.xCursor==1 then
		term.setCursorPos(state.xMin+2,state.yMin)
	elseif state.help.xCursor==2 then
		term.setCursorPos(state.xMin+10,state.yMin)
	else
		term.setCursorPos(state.xMax,state.yMin)
	end
end

local function drawSideMenu3(state)

end

local function drawSideMenu3GUI(state)

end

local function navHome(place)
	place.yCursor=place.yCursor and 1
	place.yShift=0
end

local function navEnd(place,state,entrycount)
	if state.yTextSize>entrycount then 
		place.yCursor=place.yCursor and entrycount
		place.yShift=0
	else
		place.yCursor=place.yCursor and state.yTextSize
		place.yShift=entrycount-state.yTextSize
	end
end

local function navPageUp(place,state,entrycount)
	if place.yShift>=state.yTextSize then
		place.yShift=place.yShift-state.yTextSize
	elseif place.yShift==0 and (place.yCursor==1 or not place.yCursor) then
		if state.yTextSize>entrycount then 
			place.yCursor=place.yCursor and entrycount
			place.yShift=0
		else
			place.yCursor=place.yCursor and state.yTextSize
			place.yShift=entrycount-state.yTextSize
		end
	elseif place.yShift>0 then
		place.yShift=0
		place.yCursor=place.yCursor and 1
	end
end

local function navPageDown(place,state,entrycount)
	if entrycount>=place.yShift+state.yTextSize+(place.yCursor or state.yTextSize) then
		if entrycount>=place.yShift+state.yTextSize*2 then
			place.yShift=place.yShift+state.yTextSize
		else
			if state.yTextSize>=entrycount then 
				place.yCursor=place.yCursor and entrycount
				place.yShift=0
			else
				place.yCursor=state.yTextSize
				place.yShift=entrycount-state.yTextSize
			end
		end
	elseif place.yShift+(place.yCursor or state.yTextSize)==entrycount or not place.yCursor then--?
		place.yShift=0
		place.yCursor=place.yCursor and 1
	else--if entrycount<place.yShift+state.yTextSize then
		if state.yTextSize>=entrycount then 
			place.yCursor=place.yCursor and entrycount
			place.yShift=0
		else
			place.yCursor=place.yCursor and state.yTextSize
			place.yShift=entrycount-state.yTextSize
		end
	end
end

local function navUp(place,state,entrycount)
	if (place.yCursor or 1)>=2 then 
		place.yCursor=place.yCursor and place.yCursor-1
	elseif (place.yCursor or 1)==1 and place.yShift>1 then
		place.yShift=place.yShift-1
	else
		if state.yTextSize>entrycount then 
			place.yCursor=place.yCursor and entrycount
			place.yShift=0
		else
			place.yCursor=place.yCursor and state.yTextSize
			place.yShift=entrycount-state.yTextSize
		end
	end
end

local function navDown(place,state,entrycount)
	if (place.yCursor or state.yTextSize)<=state.yTextSize-1   and place.yShift+(place.yCursor or state.yTextSize)<entrycount  then
		place.yCursor=place.yCursor and place.yCursor+1
	elseif (place.yCursor or state.yTextSize)==state.yTextSize and place.yShift+state.yTextSize<entrycount then
		place.yShift=place.yShift+1
	else
		place.yCursor=place.yCursor and 1
		place.yShift=0
	end
end				

local function navLeftCursor(place,maxVal)
	if place.xCursor>=2 then
		place.xCursor=place.xCursor and place.xCursor-1
	elseif place.xCursor==1 then
		place.xCursor=place.xCursor and maxVal
	end
end				

local function navRightCursor(place,maxVal)
	if place.xCursor<maxVal then
		place.xCursor=place.xCursor and place.xCursor+1
	elseif place.xCursor==maxVal then
		place.xCursor=place.xCursor and 1
	end
end

local function navShiftText(place,qtty)
	place.xShift=place.xShift+qtty
	if place.xShift<0 then place.xShift=0 end
end

local function navShiftLines(place,state,entrycount,qtty)
	place.yShift=place.yShift+qtty
	if place.yShift<0 or entrycount==0 then 
		place.yShift=0 
	elseif entrycount<place.yShift+state.yTextSize then
		if entrycount<=state.yTextSize then
			place.yShift=0
			if place.yCursor and place.yCursor>entrycount then
				place.yCursor=entrycount
			end
		else
			place.yShift=entrycount-state.yTextSize
		end
	end
end

local function sureDlg(state,msg,size)
	state.state="dialog"
	local cx,cy=term.getCursorPos()
	local caseSize
	local decision=false
	local change=false
	
	if state.colored then
		term.setCursorPos(state.xTextMin,cy)
		term.setTextColor(colors.blue)
		term.setBackgroundColor(colors.white)
		local temp=" "
		while #temp<size do temp=temp.." " end
		term.write(temp)
			
		if size>=#msg+6 then
			caseSize=3
			term.setCursorPos(state.xTextMin,cy)
			term.write(msg)
			term.setTextColor(colors.white)
			term.setBackgroundColor(colors.blue)
			term.write(">N<")
			term.setTextColor(colors.white)
			term.setBackgroundColor(colors.green)
			term.write(">Y<")
			term.setCursorPos(state.xTextMin+#msg+1,cy)
		elseif size>=#msg+2 then
			caseSize=2
			term.setCursorPos(state.xTextMin,cy)
			term.setTextColor(colors.blue)
			term.setBackgroundColor(colors.white)
			term.write(msg)
			term.setTextColor(colors.white)
			term.setBackgroundColor(colors.blue)
			term.write("N")
			term.setTextColor(colors.white)
			term.setBackgroundColor(colors.green)
			term.write("Y")
			term.setCursorPos(state.xTextMin+#msg,cy)
		else
			caseSize=1
			term.setCursorPos(state.xTextMin,cy)
			term.setTextColor(colors.white)
			term.setBackgroundColor(colors.blue)
			term.write("N")
			term.setTextColor(colors.white)
			term.setBackgroundColor(colors.green)
			term.write("Y")
			term.setCursorPos(state.xTextMin,cy)
			
		end
		term.setTextColor(colors.black)
	else
		term.setCursorPos(state.xTextMin,cy)
		local temp=" "
		while #temp<size do temp=temp.." " end
		term.write(temp)
		
		if size>=#msg+6 then
			caseSize=3
			term.setCursorPos(state.xTextMin,cy)
			term.write(msg..">N<>Y<")
			term.setCursorPos(state.xTextMin+#msg+2,cy)
		elseif size>=#msg+2 then
			caseSize=2
			term.setCursorPos(state.xTextMin,cy)
			term.write(msg.."NY")
			term.setCursorPos(state.xTextMin+#msg+1,cy)
		else
			caseSize=1
			term.setCursorPos(state.xTextMin,cy)
			term.write("NY")
			term.setCursorPos(state.xTextMin,cy)
			
		end
	end
	term.setCursorBlink(true)
	--EVENT HANDLING
	local event
	local eventOld={}
	while true do
		local tx,ty=term.getCursorPos()--GET ACTUAL CURSOR POS
		
		if type(event)=="table" and (event[1]=="mouse_click" or event[1]=="mouse_drag") then
				eventOld=tableDuplicate(event) or {}
		end
		--event=nil
		--while not event do
			event={coroutine.yield()}
			--if ((event[1]=="mouse_click" or event[1]=="mouse_drag" or event[1]=="mouse_scroll") and state.side==nil)
			--or (event[1]=="monitor_touch" and event[2]==state.side) then
			--	if     event[3]>state.xSize+state.xPos-1 or event[3]<state.xPos then event=nil
			--	elseif event[4]>state.ySize+state.yPos-1 or event[4]<state.yPos then event=nil end
			--end
		--end
		
		--EVENT EXECUTE
		if event[1]=="timer" and event[2]==state.autoSave and not state.safety.noFSsave then
			state.doAutoSave=true
		elseif event[1]=="term_resize" or (event[1]=="monitor_resize" and event[2]==state.side) then
			state.resized=true
			return false
		elseif event[1]=="terminate" then
			state.exec=false
			state.terminated=true
		elseif event[1]=="key" then
			if event[2]==keys["enter"] or event[2]==keys["spacebar"] then 
				break
			elseif event[2]==keys["left"] or event[2]==keys["comma"] or event[2]==keys["right"] or event[2]==keys["period"] then
				decision=not decision
			end
		elseif (event[1]=="mouse_click" and event[2]==1) or (event[1]=="monitor_touch" and event[2]==state.side) then
			if event[4]==ty then
				if caseSize==3 then
					if event[3]<=tx+1 and event[3]>=tx-1 then--click on same
						break
					elseif decision and event[3]<=tx-2 and event[3]>=tx-4 then
						decision=false
					elseif (not decision) and event[3]<=tx+4 and event[3]>=tx+3 then
						decision=true
					end
				else
					if event[3]==tx then--click on same
						break
					elseif decision and event[3]==tx-1 then
						decision=false
					elseif (not decision) and event[3]==tx+1 then
						decision=true
					end
				end
			end
		end
		--UPDATE CURSOR
		if decision~=change then
			change=decision
			if decision then
				if caseSize==3 then
					term.setCursorPos(tx+3,ty)
				else
					term.setCursorPos(tx+1,ty)
				end
			else
				if caseSize==3 then
					term.setCursorPos(tx-3,ty)
				else
					term.setCursorPos(tx-1,ty)
				end	
			end
		end
	end
	state.state="pointing"
	return decision
end

local function execMenu(state,wrapped,choice)
	local execList={
	[1]=function(state) state.place="main" end,
	[2]=function(state) state.place="tableAlias" end,
	[3]=function(state) state.place="functionAlias" end,
	[4]=function(state) state.place="threadAlias" end,
	[5]=function(state) state.place="help" end,
	[6]=function(state,wrapped)
			local cx,cy=term.getCursorPos()
			term.setCursorPos(state.xTextMin,cy)
			if sureDlg(state,"Really? ",state.xTextSize) then
				wrapTable({},wrapped)
				state.selection={}
				for k=1,#wrapped.values do
					state.selection[k]=false
				end
				state.selectionPresent=false
				state.place="main"
			end
		end,
	[7]=function(state,wrapped) 
			local cx,cy=term.getCursorPos()
			term.setCursorPos(state.xTextMin,cy)
			if sureDlg(state,"Really? ",state.xTextSize) then
				wrapped=state.template
				wrapTable({},wrapped)
				state.selection={}
				for k=1,#wrapped.values do
					state.selection[k]=false
				end
				state.selectionPresent=false
				state.place="main"
			end
		end,
	[8]=function(state,wrapped)
			if not state.safety.noSave then
				local cx,cy=term.getCursorPos()
				term.setCursorPos(state.xTextMin,cy)
				if state.colored then
					term.setBackgroundColor(colors.white)
					term.setTextColor(colors.blue)
				end
				local temp=readEX(nil,state.history.fileNames,"",state.xMax,state)
				if not state.safety.noOverwrite then
					if fs.exists(temp) then return end
				end
				saveWrapped(wrapped, temp)
			end
		end,
	[9]=function(state,wrapped) 
			if not state.safety.noLoad then
				local cx,cy=term.getCursorPos()
				term.setCursorPos(state.xTextMin,cy)
				if state.colored then
					term.setBackgroundColor(colors.white)
					term.setTextColor(colors.blue)
				end
				wrapped=loadWrapped(readEX(nil,state.history.fileNames,"",state.xMax,state),wrapped)
				state.selection={}
				for k=1,#wrapped.values do
					state.selection[k]=false
				end
				state.selectionPresent=false
				state.place="main"
			end
		end,
	[10]=function(state) state.exec=false end,
	[11]=function(state) if not state.safety.noExit then state.exec=false state.terminated=true end end	
	}
	
	return execList[choice] and execList[choice](state,wrapped)
end

local function execEvent(state,wrapped,event,eventOld)
	if event[1]=="timer" then
		if event[2]==state.timerInstance and not state.colored then
			state.timer=not state.timer
			state.timerInstance=os.startTimer(0.5)
		elseif event[2]==state.autoSave and not state.safety.noFSsave then
			state.doAutoSave=true
		end
	elseif event[1]=="terminate" then
		state.exec=false
		state.terminated=true
	elseif event[1]=="term_resize" or (event[1]=="monitor_resize" and event[2]==state.side) then
		state.resized=true
	elseif state.place=="main" then
		if event[1]=="key" then
			if event[2]==keys["tab"] then--tab
				state.place="topBar"--MOVE
				
			elseif event[2]==keys["f8"] or event[2]==keys["e"] then--f1
				state.place=state.placePrevious or "main"
				
			elseif event[2]==keys["f1"] or event[2]==keys["h"] then--f1
				state.place="help"
				
			elseif event[2]==keys["f3"] or event[2]==keys["t"] then--f3
				state.place="tableAlias"
				--table Alias
				--try to get pointed Tab
				--insert?
				
			elseif event[2]==keys["f5"] or event[2]==keys["r"] then--f5
				state.place="threadAlias"
				--function alias
				--try to get pointed fun
				--insert?
				
			elseif event[2]==keys["f4"] or event[2]==keys["f"] then--f4
				state.place="functionAlias"
				--function alias
				--try to get pointed fun
				--insert?
				
			elseif event[2]==keys["f12"] or event[2]==keys["m"] then--f1,mm
				state.place="menu"
				
			elseif event[2]==keys["apostrophe"] and #wrapped.values>0 then--'
				state.selection[state.yCursor+state.yShift]=not state.selection[state.yCursor+state.yShift]
				if state.selection[state.yCursor+state.yShift] then 
					state.selectionPresent=true 
				else
					state.selectionPresent=false
					for k,v in pairs(state.selection) do
						if v==true then state.selectionPresent=true break end
					end
				end
			elseif event[2]==keys["leftBracket"] and #wrapped.values>0  then--[
				if state.selectionPresent then
				--check start / move it to end
					if state.selection[1] then
						swapWrappedCells(wrapped,1,-1)
						swapWrappedCells(wrapped,-1,#wrapped.values+1)
						table.insert(state.selection,#state.selection+1,state.selection[1])
						table.remove(state.selection,1)
					else
				--move inside
						for k=1,#state.selection do
							if state.selection[k] then
								swapWrappedCells(wrapped,k,k-1)
								swapCells(state.selection,k,k-1)
							end
						end
					end
				else
					if wrapped["values"][state.yCursor+state.yShift] and wrapped["values"][state.yCursor+state.yShift-1] then
						swapWrappedCells(wrapped,state.yCursor+state.yShift-1,state.yCursor+state.yShift)
					else
						swapWrappedCells(wrapped,1,-1)
						swapWrappedCells(wrapped,-1,#wrapped.values+1)
					end
				end
				if state.yCursor>=2 then 
					state.yCursor=state.yCursor-1
				elseif state.yCursor==1 and state.yShift>1 then
					state.yShift=state.yShift-1
				else
					if state.yTextSize>#wrapped.kinds then 
						state.yCursor=#wrapped.kinds
						state.yShift=0
					else
						state.yCursor=state.yTextSize
						state.yShift=#wrapped.kinds-state.yTextSize
					end
				end
			elseif event[2]==keys["rightBracket"] and #wrapped.values>0  then--]
				if state.selectionPresent then
				--check start / move it to end
					if state.selection[#state.selection] then
						swapWrappedCells(wrapped,#wrapped.values,-1)
						swapWrappedCells(wrapped,-1,1)
						table.insert(state.selection,1,state.selection[#state.selection])
						table.remove(state.selection,#state.selection)
					else
				--move inside
						for k=#state.selection,1,-1 do
							if state.selection[k] then
								swapWrappedCells(wrapped,k,k+1)
								swapCells(state.selection,k,k+1)
							end
						end
					end
				else
					if wrapped["values"][state.yCursor+state.yShift] and wrapped["values"][state.yCursor+state.yShift+1] then
						swapWrappedCells(wrapped,state.yCursor+state.yShift+1,state.yCursor+state.yShift)
					else
						swapWrappedCells(wrapped,#wrapped.values,-1)
						swapWrappedCells(wrapped,-1,1)
					end
				end
				if state.yCursor<=state.yTextSize-1   and state.yShift+state.yCursor<#wrapped.kinds  then
					state.yCursor=state.yCursor+1
				elseif state.yCursor==state.yTextSize and state.yShift+state.yTextSize<#wrapped.kinds then
					state.yShift=state.yShift+1
				else
					state.yCursor=1
					state.yShift=0
				end
			elseif ( event[2]==keys["f7"] or (event[2]==keys["enter"] and ((eventOld[2]==keys["leftCtrl"] or eventOld[2]==157--[[does not have correct value-> keys["rightCtrl"] ]]) and eventOld[1]=="key")) ) and #wrapped.values>0  then--f7 or ctrl enter
				state.state="editing"
				local curTempX,curTempY=term.getCursorPos()
				term.setCursorPos(state.xTextMin,state.yPos+state.yCursor)
				if state.colored then
					term.setTextColor(colors.green)
					term.setBackgroundColor(colors.lime)
				end
				--protected input
				--add new protected
				--edit variable value
				local assignType=false
				if wrapped["values"][state.yCursor+state.yShift]=="" and wrapped["types"][state.yCursor+state.yShift]=="-" then
					assignType=true
				end
				if wrapped["values"][state.yCursor+state.yShift] then
					if not wrapped.protected[state.yCursor+state.yShift] then
						historyAdd(state.history["values"],wrapped["values"][state.yCursor+state.yShift])
					end
					wrapped.protected[state.yCursor+state.yShift]=true
					wrapped["values"][state.yCursor+state.yShift]=
					readEX("*",nil,tostring(wrapped["values"][state.yCursor+state.yShift]),state.xTextMax,state)
				end
				if assignType then
					if wrapped["values"][state.yCursor+state.yShift]=="true" or wrapped["values"][state.yCursor+state.yShift]=="false" then
						wrapped["types"][state.yCursor+state.yShift]="b"
					elseif tonumber(wrapped["values"][state.yCursor+state.yShift]) then
						wrapped["types"][state.yCursor+state.yShift]="n"
					elseif #wrapped["values"][state.yCursor+state.yShift]>0 then
						wrapped["types"][state.yCursor+state.yShift]="s"
					end
				end
				term.setCursorPos(curTempX,curTempY)
				state.state="pointing"

			elseif event[2]==keys["enter"] and #wrapped.values>0  then--enter
				state.state="editing"
				if state.colored then
					term.setTextColor(colors.red)
					term.setBackgroundColor(colors.pink)
				end
				-- INTO readEX
				if wrapped[xCursorName(state.xCursor)][state.yCursor+state.yShift] then
					local temp
					if wrapped.protected[state.yCursor+state.yShift] and state.xCursor==4 then
						wrapped.protected[state.yCursor+state.yShift]=false
						wrapped.values[state.yCursor+state.yShift]=""
					end
					if state.xCursor<4 then
						term.setCursorPos(state.xPos,state.yPos+state.yCursor)
						temp=readEX(nil,state.history[xCursorName(state.xCursor)],tostring(wrapped[xCursorName(state.xCursor)][state.yCursor+state.yShift]),state.xPos+3,state)
					else
						temp=readEX(nil,state.history[xCursorName(state.xCursor)],tostring(wrapped[xCursorName(state.xCursor)][state.yCursor+state.yShift]),state.xTextMax,state)
					end
					if state.xCursor==4 then
						local assignType=false
						if wrapped["values"][state.yCursor+state.yShift]=="" and wrapped["types"][state.yCursor+state.yShift]=="-" then
							assignType=true
						end
						wrapped["values"][state.yCursor+state.yShift]=temp
						if assignType then
							if wrapped["values"][state.yCursor+state.yShift]=="true" or wrapped["values"][state.yCursor+state.yShift]=="false" then
								wrapped["types"][state.yCursor+state.yShift]="b"
							elseif tonumber(wrapped["values"][state.yCursor+state.yShift]) then
								wrapped["types"][state.yCursor+state.yShift]="n"
							elseif #wrapped["values"][state.yCursor+state.yShift]>0 then
								wrapped["types"][state.yCursor+state.yShift]="s"
							end
						end
					else
						if state.xCursor==1 then 
							temp=string.upper(temp)
							if temp=="KEY" then temp="K" end
							temp=string.sub(temp,#temp,#temp)
							if temp~="K" then temp="V" end
							if temp==wrapped[xCursorName(state.xCursor)][state.yCursor+state.yShift] then
								if temp=="K" then temp="V" else temp="K" end
							end
						end
						
						if state.xCursor==2 then 
							temp=math.floor(tonumber(temp) or wrapped[xCursorName(state.xCursor)][state.yCursor+state.yShift])
							if temp==wrapped[xCursorName(state.xCursor)][state.yCursor+state.yShift] then
								temp=-wrapped[xCursorName(state.xCursor)][state.yCursor+state.yShift]
							end
						end
						if state.xCursor==3 then 
							temp=string.lower(temp)
							temp=typeCheck(temp) or typeCheck(string.sub(temp,#temp,#temp)) or wrapped[xCursorName(state.xCursor)][state.yCursor+state.yShift]
						end
						
						
						wrapped[xCursorName(state.xCursor)][state.yCursor+state.yShift]=temp
					end
				end
				state.state="pointing"
			elseif event[2]==keys["home"] and #wrapped.values>0  then--home
				navHome(state[state.place])
			elseif event[2]==keys["end"] and #wrapped.values>0  then--end
				navEnd(state,state,#wrapped.values)
			elseif event[2]==keys["pageUp"] and #wrapped.values>0  then--pgu
				navPageUp(state,state,#wrapped.values)
			elseif event[2]==keys["pageDown"] and #wrapped.values>0  then--pgd
				navPageDown(state,state,#wrapped.values)
			elseif event[2]==keys["up"] and #wrapped.values>0  then--u
				navUp(state,state,#wrapped.values)
			elseif event[2]==keys["down"] and #wrapped.values>0  then--d
				navDown(state,state,#wrapped.values)
			elseif event[2]==keys["left"] and #wrapped.values>0  then--l
				navLeftCursor(state,4)
			elseif event[2]==keys["right"] and #wrapped.values>0  then--r
				navRightCursor(state,4)
			elseif event[2]==keys["s"] then--s
				sleep(0)
				execMenu(state,wrapped,8)
			elseif event[2]==keys["l"] then--l
				sleep(0)
				execMenu(state,wrapped,9)
			elseif event[2]==keys["backslash"] then--\
				solveDepths(wrapped)
			elseif ( event[2]==keys["delete"] or event[2]==keys["backspace"] or event[2]==keys["d"] ) and #wrapped.values>0  then--delete or bks space
				--table.remove pair
				if wrapped.kinds[state.yCursor+state.yShift]=="K" and 
				wrapped.types[state.yCursor+state.yShift]~="t" and 
				wrapped.types[state.yCursor+state.yShift+1]~="t" and 
				wrapped.types[state.yCursor+state.yShift]~="x" and 
				wrapped.types[state.yCursor+state.yShift+1]~="x" and 
				wrapped.kinds[state.yCursor+state.yShift+1]=="V" then
					local temp=state.yCursor+state.yShift
					table.remove(wrapped.kinds, temp)
					table.remove(wrapped.kinds, temp)
					table.remove(wrapped.depths,temp)
					table.remove(wrapped.depths,temp)
					table.remove(wrapped.types, temp)
					table.remove(wrapped.types, temp)
					table.remove(wrapped.values,temp)
					table.remove(wrapped.values,temp)
					table.remove(state.selection,temp)
					table.remove(state.selection,temp)
					if #wrapped.kinds==0 then
						state.yCursor=1
						state.yShift=0
					elseif state.yCursor+state.yShift>#wrapped.kinds then
						if state.yTextSize>=#wrapped.kinds then 
							state.yShift=0
							state.yCursor=#wrapped.kinds
						elseif state.yShift+state.yTextSize>#wrapped.kinds then
							if state.yShift>=2 then 
								state.yShift=state.yShift-2
							elseif state.yShift==1 then
								state.yShift=0
								state.yCursor=state.yCursor-1
							else
								state.yCursor=state.yCursor-2
							end
						end
					end
				elseif wrapped.kinds[state.yCursor+state.yShift]=="V" and
				wrapped.types[state.yCursor+state.yShift]~="t" and 
				wrapped.types[state.yCursor+state.yShift-1]~="t" and 
				wrapped.types[state.yCursor+state.yShift]~="x" and 
				wrapped.types[state.yCursor+state.yShift-1]~="x" and 
				wrapped.kinds[state.yCursor+state.yShift-1]=="K" then
					local temp=state.yCursor+state.yShift-1
					table.remove(wrapped.kinds, temp)
					table.remove(wrapped.kinds, temp)
					table.remove(wrapped.depths,temp)
					table.remove(wrapped.depths,temp)
					table.remove(wrapped.types, temp)
					table.remove(wrapped.types, temp)
					table.remove(wrapped.values,temp)
					table.remove(wrapped.values,temp)
					table.remove(state.selection,temp)
					table.remove(state.selection,temp)
					if #wrapped.kinds==0 then
						state.yCursor=1
						state.yShift=0
					elseif state.yCursor+state.yShift>#wrapped.kinds then
						if state.yTextSize>=#wrapped.kinds then 
							state.yShift=0
							state.yCursor=#wrapped.kinds
						elseif state.yShift+state.yTextSize>#wrapped.kinds then
							if state.yShift>=1 then 
								state.yShift=state.yShift-1
							else
								state.yCursor=state.yCursor-1
							end
						end
					end
				end
			elseif event[2]==keys["insert"] or event[2]==keys["n"] then
				--table.insert pair
				local temp
				if #wrapped.kinds==0 then
					temp=1
				elseif wrapped.kinds[state.yCursor+state.yShift]=="K" and 
				   wrapped.kinds[state.yCursor+state.yShift+1]=="V" then
					temp=state.yCursor+state.yShift+2
				else
					temp=state.yCursor+state.yShift+1
				end
				table.insert(wrapped.kinds, temp,"V")--v
				table.insert(wrapped.kinds, temp,"K")--k
				table.insert(wrapped.depths,temp,wrapped.depths[state.yCursor+state.yShift] or 1)
				table.insert(wrapped.depths,temp,wrapped.depths[state.yCursor+state.yShift] or 1)
				table.insert(wrapped.types, temp,shortType(nil))
				table.insert(wrapped.types, temp,shortType(nil))
				table.insert(wrapped.values,temp,"")
				table.insert(wrapped.values,temp,"")
				table.insert(state.selection,temp,false)
				table.insert(state.selection,temp,false)
				
			elseif event[2]==keys["slash"] then--/ ?
				--get back to start
				state.xShift=0
				
			elseif event[2]==keys["grave"] or event[2]==keys["f10"] then--` f10
				--exit
				state.exec=false
			end
		
		elseif event[1]=="char" then
		
			if event[2]=="i" then
				state.indents=state.indents+1
				
			elseif event[2]=="I" then
				if state.indents>=1 then state.indents=state.indents-1 end
				
			elseif event[2]==";" and #wrapped.values>0 then--; --all/nothing
				if state.selectionPresent then
					for k=1,#state.selection do
						state.selection[k]=false
					end
				else
					for k=1,#state.selection do
						state.selection[k]=true
					end
				end
				state.selectionPresent=not state.selectionPresent
			elseif event[2]==":" and #wrapped.values>0 then--; --invert
				if state.selectionPresent then
					for k=1,#state.selection do
						state.selection[k]=not state.selection[k]
					end
					state.selectionPresent=false
					for k,v in pairs(state.selection) do
						if v then state.selectionPresent=true break end
					end
				else
					for k=1,#state.selection do
						state.selection[k]=true
					end
					state.selectionPresent=true
				end
				
			elseif event[2]=="x" and #wrapped.values>0 then
				--cut
				state.blockClipboard[xCursorName(state.xCursor)]=false
				state.clipboard[xCursorName(state.xCursor)]=
				wrapped[xCursorName(state.xCursor)][state.yCursor+state.yShift]
				if state.xCursor==4  or state.xCursor==3 then				
					wrapped[xCursorName(3)][state.yCursor+state.yShift]="-"
					wrapped[xCursorName(4)][state.yCursor+state.yShift]="nil"
				end
				
			elseif event[2]=="X" and #wrapped.values>0 then
				--cut row
				for i=1,4 do
					state.blockClipboard[xCursorName(i)]=false
					state.clipboard[xCursorName(i)]=
					wrapped[xCursorName(i)][state.yCursor+state.yShift]
				end
				wrapped[xCursorName(3)][state.yCursor+state.yShift]="-"
				wrapped[xCursorName(4)][state.yCursor+state.yShift]="nil"
				
			elseif event[2]=="c" and #wrapped.values>0 then
				--copy
				state.blockClipboard[xCursorName(state.xCursor)]=false
				state.clipboard[xCursorName(state.xCursor)]=
				wrapped[xCursorName(state.xCursor)][state.yCursor+state.yShift]
				
			elseif event[2]=="C" and #wrapped.values>0 then
				--copy row
				for i=1,4 do
					state.blockClipboard[xCursorName(i)]=false
					state.clipboard[xCursorName(i)]=
					wrapped[xCursorName(i)][state.yCursor+state.yShift]
				end
				
			elseif event[2]=="v" and #wrapped.values>0 then
				--paste
				if not state.blockClipboard[xCursorName(state.xCursor)] then
					wrapped[xCursorName(state.xCursor)][state.yCursor+state.yShift]=
					state.clipboard[xCursorName(state.xCursor)]
				end
				
			elseif event[2]=="V" and #wrapped.values>0 then
				--paste row
				for i=1,4 do
					if not state.blockClipboard[xCursorName(i)] then
						wrapped[xCursorName(i)][state.yCursor+state.yShift]=
						state.clipboard[xCursorName(i)]
					end
				end
				
			elseif event[2]=="b" then
				--paste
				state.blockClipboard[xCursorName(state.xCursor)]=true
				
			elseif event[2]=="B" then
				--paste row
				for i=1,4 do
					state.blockClipboard[xCursorName(i)]=true
				end
				
			elseif event[2]=="." then
				navShiftText(state,1)
			elseif event[2]==">" then
				navShiftText(state,10)
			elseif event[2]=="," then
				navShiftText(state,-1)
			elseif event[2]=="<" then
				navShiftText(state,-10)
			elseif ( event[2]=="-" or event[2]=="_" ) and #wrapped.values>0 then
				local temp=state.yCursor+state.yShift
				table.remove(wrapped.kinds, temp)--v
				table.remove(wrapped.depths,temp)
				table.remove(wrapped.types, temp)
				table.remove(wrapped.values,temp)
				table.remove(state.selection,temp)	
				if #wrapped.values==0 then
					state.yCursor=1
					state.yShift=0
				elseif state.yCursor+state.yShift>#wrapped.kinds then
					if state.yTextSize>=#wrapped.kinds then 
						state.yShift=0
						state.yCursor=#wrapped.kinds
					elseif state.yShift+state.yTextSize>#wrapped.kinds then
						if state.yShift>=1 then 
							state.yShift=state.yShift-1
						else
							state.yCursor=state.yCursor-1
						end
					end
				end
			elseif event[2]=="=" then
				local temp=#wrapped.values>0 and state.yCursor+state.yShift+1 or 1
				table.insert(wrapped.kinds, temp,"V")--v
				table.insert(wrapped.depths,temp,wrapped.depths[state.yCursor+state.yShift] or 1)
				table.insert(wrapped.types, temp,shortType(nil))
				table.insert(wrapped.values,temp,"")
				table.insert(state.selection,temp,false)	
			elseif event[2]=="+" then
				local temp=#wrapped.values>0 and state.yCursor+state.yShift+1 or 1
				table.insert(wrapped.kinds, temp,"K")--v
				table.insert(wrapped.depths,temp,wrapped.depths[state.yCursor+state.yShift] or 1)
				table.insert(wrapped.types, temp,shortType(nil))
				table.insert(wrapped.values,temp,"")
				table.insert(state.selection,temp,false)
			end	
		elseif event[1]=="mouse_scroll" then
			if event[4]==state.yPos then--top
				if event[3]>=state.xPos and event[3]<state.xPos+8 then--X
					navShiftText(state,event[2])
				elseif #wrapped.values>0 then--entries exist
					if event[3]>=state.xPos+8 and event[3]<state.xPos+16 then--Y
						if #wrapped.kinds>=state.yTextSize+state.yShift+event[2] then
							state.yShift=state.yShift+event[2]
						end
						if state.yShift<0 then state.yShift=0 end
					elseif event[3]>=state.xPos+16 and event[3]<state.xPos+24 then--L
						if #wrapped.kinds>=state.yCursor+state.yShift+event[2] then
							if (event[2]>0 and state.yCursor==state.yTextSize) or
							(event[2]<0 and state.yCursor==1) then
								state.yShift=state.yShift+event[2]
							else
								state.yCursor=state.yCursor+event[2]
							end
						end
						if state.yShift<0 then state.yShift=0 end
					end
				end
			elseif #wrapped.values>0 then--NOT TOP entries exist
				if event[3]==1 then--COLUMN 1
					if wrapped.kinds[event[4]-state.xPos]=="K" then 
						wrapped.kinds[event[4]-state.xPos]="V"
					else
						wrapped.kinds[event[4]-state.xPos]="K"
					end
				elseif event[3]<=3 then--COLUMN 2,3
					if wrapped.depths[event[4]-state.xPos] then 
						wrapped.depths[event[4]-state.xPos]=wrapped.depths[event[4]-state.xPos]+event[2]
					end
				elseif event[3]==4 then--COLUMN 4
					wrapped.types[event[4]-state.xPos]=numToType((event[2]+typeToNum(wrapped.types[event[4]-state.xPos]))%8)
				end
			end
		elseif event[1]=="mouse_click" and event[2]==1 then
			if event[4]==state.yPos then--TOP
				state.place="topBar"
			else
				if event[4]-state.yPos==state.yCursor and #wrapped.values>0 then--ON ACTUAL LINE
					if event[3]==state.xPos and state.xCursor==1 then
						state.state="editing"
						if wrapped[xCursorName(state.xCursor)][state.yCursor+state.yShift] then
							if state.colored then
								term.setTextColor(colors.red)
								term.setBackgroundColor(colors.pink)
							end
							term.setCursorPos(state.xPos,state.yPos+state.yCursor)
							local temp=readEX(nil,state.history[xCursorName(state.xCursor)],tostring(wrapped[xCursorName(state.xCursor)][state.yCursor+state.yShift]),state.xPos+3,state)
							temp=string.upper(temp)
							if temp=="KEY" then temp="K" end
							temp=string.sub(temp,#temp,#temp)
							if temp~="K" then temp="V" end
							if temp==wrapped[xCursorName(state.xCursor)][state.yCursor+state.yShift] then
								if temp=="K" then temp="V" else temp="K" end
							end
							wrapped[xCursorName(state.xCursor)][state.yCursor+state.yShift]=temp
						end
						state.state="pointing"
					elseif (event[3]==state.xPos+2 or event[3]==state.xPos+1) and state.xCursor==2 then
						state.state="editing"
							if state.colored then
								term.setTextColor(colors.red)
								term.setBackgroundColor(colors.pink)
							end
						if wrapped[xCursorName(state.xCursor)][state.yCursor+state.yShift] then
							term.setCursorPos(state.xPos,state.yPos+state.yCursor)
							local temp=readEX(nil,state.history[xCursorName(state.xCursor)],tostring(wrapped[xCursorName(state.xCursor)][state.yCursor+state.yShift]),state.xPos+3,state)
							temp=math.floor(tonumber(temp) or wrapped[xCursorName(state.xCursor)][state.yCursor+state.yShift])
							if temp==wrapped[xCursorName(state.xCursor)][state.yCursor+state.yShift] then
								temp=-wrapped[xCursorName(state.xCursor)][state.yCursor+state.yShift]
							end
							wrapped[xCursorName(state.xCursor)][state.yCursor+state.yShift]=temp
						end
						state.state="pointing"
					elseif event[3]==state.xPos+3 and state.xCursor==3 then
						state.state="editing"
						if wrapped[xCursorName(state.xCursor)][state.yCursor+state.yShift] then
							if state.colored then
								term.setTextColor(colors.red)
								term.setBackgroundColor(colors.pink)
							end
							term.setCursorPos(state.xPos,state.yPos+state.yCursor)
							local temp=readEX(nil,state.history[xCursorName(state.xCursor)],tostring(wrapped[xCursorName(state.xCursor)][state.yCursor+state.yShift]),state.xPos+3,state)
							temp=string.lower(temp)
							temp=string.lower(temp)
							temp=typeCheck(temp) or typeCheck(string.sub(temp,#temp,#temp)) or wrapped[xCursorName(state.xCursor)][state.yCursor+state.yShift]
							wrapped[xCursorName(state.xCursor)][state.yCursor+state.yShift]=temp
						end
						state.state="pointing"
					elseif event[3]>=state.xPos+4 and state.xCursor==4 then
						state.state="editing"
						if wrapped[xCursorName(state.xCursor)][state.yCursor+state.yShift] then
							if wrapped.protected[state.yCursor+state.yShift] then
								wrapped.protected[state.yCursor+state.yShift]=false
								wrapped.values[state.yCursor+state.yShift]=""
							end
							if state.colored then
								term.setTextColor(colors.red)
								term.setBackgroundColor(colors.pink)
							end
							local temp=readEX(nil,state.history[xCursorName(state.xCursor)],tostring(wrapped[xCursorName(state.xCursor)][state.yCursor+state.yShift]),state.xTextMax,state)
							if wrapped.protected[state.yCursor+state.yShift] then
								wrapped.protected[state.yCursor+state.yShift]=false
								wrapped.values[state.yCursor+state.yShift]=""
							end
							wrapped[xCursorName(state.xCursor)][state.yCursor+state.yShift]=temp
						end
						state.state="pointing"
					else--MOVE TO COLUMN
						if event[3]==state.xPos then
							state.xCursor=1
						elseif event[3]<=state.xPos+2 then
							state.xCursor=2
						elseif event[3]==state.xPos+3 then
							state.xCursor=3
						else 
							state.xCursor=4
						end
					end
				else--ON OTHER LINE
					if wrapped.kinds[event[4]-state.xPos+state.yShift] then--ON OTHER EXISTING LINE
						state.yCursor=event[4]-state.xPos--MOVE TO ROW
					end
					if event[3]==state.xPos then--MOVE TO COLUMN
						state.xCursor=1
					elseif event[3]<=state.xPos+2 then
						state.xCursor=2
					elseif event[3]==state.xPos+3 then
						state.xCursor=3
					else 
						state.xCursor=4
					end
				end
			end
		elseif event[1]=="mouse_click" and event[2]==2 then
			if event[4]==state.yPos then
				state.place="menu"
			elseif event[3]==state.xPos then
				if wrapped.kinds[event[4]-state.xPos+state.yShift] then --tests if value exist 
					state.xCursor=1
					state.yCursor=event[4]-state.yPos
					if wrapped.kinds[event[4]-state.xPos+state.yShift]=="K" then
						wrapped.kinds[event[4]-state.xPos+state.yShift]="V"
					else
						wrapped.kinds[event[4]-state.xPos+state.yShift]="K"
					end
				end
			elseif event[3]==state.xPos+3 then
				if wrapped.kinds[event[4]-state.xPos+state.yShift] then --tests if value exist 
					state.xCursor=3
					state.yCursor=event[4]-state.xPos
					state.place="sideMenu3"
				end
			end
		elseif event[1]=="mouse_drag" and event[2]==1 then
			if (eventOld[1]=="mouse_drag" or eventOld[1]=="mouse_click") and eventOld[2]==1 then
				local xDiv=eventOld[3]-event[3]
				local yDiv=eventOld[4]-event[4]
				navShiftText(state,xDiv)
				
				state.yShift=state.yShift+yDiv
				if state.yShift<0 or #wrapped.values==0 then 
					state.yShift=0 
				elseif #wrapped.values<state.yShift+state.yTextSize then
					if #wrapped.values<=state.yTextSize then
						state.yShift=0
						if state.yCursor>#wrapped.values then
							state.yCursor=#wrapped.values
						end
					else
						state.yShift=#wrapped.values-state.yTextSize
					end
				end
			end
		elseif event[1]=="monitor_touch" and event[2]==state.side then
			if event[4]==state.yPos then--QUIT on top bar click
				if state.colored then
					term.setBackgroundColor(colors.black)
					term.setTextColor(colors.white)
				end
				local temp=""
				while #temp<state.xSize do
					temp=temp.." "
				end
				for i=state.yPos,state.yPos+state.ySize-1 do
					term.setCursorPos(state.xPos,i)
					term.write(temp)
				end
				state.exec=false
			elseif event[3]<=state.xPos+3 and #wrapped.values>0 then--CLICK NAV
				local temp=math.floor(state.yPos+1+(state.yTextSize/2))--MID
				if event[4]<temp and state.yShift>0 then--TRYING TO DECREMENT YSHIFT
					if #wrapped.kinds>=state.yShift+state.yTextSize+state.yCursor then
						if #wrapped.kinds>=state.yShift+state.yTextSize*2 then
							state.yShift=state.yShift+state.yTextSize
						else
							if state.yTextSize>=#wrapped.kinds then 
								state.yCursor=#wrapped.kinds
								state.yShift=0
							else
								state.yCursor=state.yTextSize
								state.yShift=#wrapped.kinds-state.yTextSize
							end
						end
					elseif state.yShift+state.yCursor==#wrapped.kinds then
						state.yShift=0
						state.yCursor=1
					elseif #wrapped.kinds<state.yShift+state.yTextSize then
						if state.yTextSize>=#wrapped.kinds then 
							state.yCursor=#wrapped.kinds
							state.yShift=0
						else
							state.yCursor=state.yTextSize
							state.yShift=#wrapped.kinds-state.yTextSize
						end
					end
				else--TRYING TO INCREMENT YSHIFT
					if #wrapped.kinds>=state.yShift+state.yTextSize then
						state.yShift=state.yShift+state.yTextSize
					elseif state.yShift+state.yCursor==#wrapped.kinds then
						state.yShift=0
						state.yCursor=1
					elseif #wrapped.kinds<state.yShift+state.yTextSize then
						if state.yTextSize>#wrapped.kinds then 
							state.yCursor=#wrapped.kinds
							state.yShift=0
						else
							state.yCursor=state.yTextSize
							state.yShift=#wrapped.kinds-state.yTextSize
						end
					end
				end
			elseif event[3]>state.xPos+3 then
				local temp=math.floor(state.xPos+4+(state.xTextSize/2))
				local move=event[3]-temp+1
				if move<1 then move=move-1 end
				navShiftText(state,move)
			end
		end
	elseif state.place=="topBar" then
		if event[1]=="key" then
			if event[2]==keys["tab"] then--tab
				state.place="main"--MOVE
				
			elseif event[2]==keys["f8"] or event[2]==keys["e"] then--f8
				state.place="main"
				
			elseif event[2]==keys["f1"] or event[2]==keys["h"] then--f1
				state.place="help"
				
			elseif event[2]==keys["f3"] or event[2]==keys["t"] then--f3
				state.place="tableAlias"
				--table Alias
				--try to get pointed Tab
				--insert?
				
			elseif event[2]==keys["f5"] or event[2]==keys["r"] then--f5
				state.place="threadAlias"
				--function alias
				--try to get pointed fun
				--insert?
				
			elseif event[2]==keys["f4"] or event[2]==keys["f"] then--f4
				state.place="functionAlias"
				--function alias
				--try to get pointed fun
				--insert?
			elseif event[2]==keys["f12"] or event[2]==keys["m"] then--f1,mm
				state.place="menu"
			elseif event[2]==keys["home"] then--home
				navHome(state)
				
			elseif event[2]==keys["end"] and #wrapped.functions.values>0 then--end
				navEnd(state,state,#wrapped.functions.values*2)
				
			elseif event[2]==keys["pageUp"] and #wrapped.functions.values>0 then--pgu
				navPageUp(state,state,#wrapped.functions.values*2)
				
			elseif event[2]==keys["pageDown"] and #wrapped.functions.values>0 then--pgd
				navPageDown(state,state,#wrapped.functions.values*2)
				
			elseif event[2]==keys["up"] and #wrapped.functions.values>0 then--u
				navUp(state,state,#wrapped.functions.values*2)
				
			elseif event[2]==keys["down"] and #wrapped.functions.values>0 then--d
				navDown(state,state,#wrapped.functions.values*2)
				
			elseif event[2]==keys["left"] then--l
				navLeftCursor(state,4)
				
			elseif event[2]==keys["right"] then--r
				navRightCursor(state,4)
				
			elseif event[2]==keys["enter"] then
				state.state="editing"
				if state.colored then
					term.setTextColor(colors.red)
					term.setBackgroundColor(colors.pink)
				end
				-- INTO readEX
				
				state.state="pointing"
			end
		elseif event[1]=="char" then
		
		elseif event[1]=="mouse_scroll" then
			
		elseif event[1]=="mouse_click" then
			
		elseif event[1]=="monitor_touch" then
			
		end
	elseif state.place=="menu" then
		if event[1]=="key" then
			if event[2]==keys["f1"] or event[2]==keys["h"] then--f1
				state.place="help"
				
			elseif event[2]==keys["f8"] or event[2]==keys["e"] then--f8
				state.place="main"
				
			elseif event[2]==keys["f3"] or event[2]==keys["t"] then--f3
				state.place="tableAlias"
				--table Alias
				--try to get pointed Tab
				--insert?
				
			elseif event[2]==keys["f5"] or event[2]==keys["r"] then--f5
				state.place="threadAlias"
				--function alias
				--try to get pointed fun
				--insert?
				
			elseif event[2]==keys["f4"] or event[2]==keys["f"] then--f4
				state.place="functionAlias"
				--function alias
				--try to get pointed fun
				--insert?
			elseif event[2]==keys["f12"] or event[2]==keys["m"] then--f1,mm
				state.place="main"
				
			elseif event[2]==keys["home"] then--home
				navHome(state["menu"])
				
			elseif event[2]==keys["end"] then--end
				navEnd(state["menu"],state,state.menu.entrycount)
				
			elseif event[2]==keys["pageUp"] then--pgu
				navPageUp(state["menu"],state,state.menu.entrycount)
				
			elseif event[2]==keys["pageDown"] then--pgd
				navPageDown(state["menu"],state,state.menu.entrycount)
				
			elseif event[2]==keys["up"] then--u
				navUp(state["menu"],state,state.menu.entrycount)
				
			elseif event[2]==keys["down"] then--d
				navDown(state["menu"],state,state.menu.entrycount)
				
			elseif event[2]==keys["left"] then--l
				navShiftText(state["menu"],-1)
				
			elseif event[2]==keys["right"] then--r
				navShiftText(state["menu"],1)
				
			elseif event[2]==keys["enter"] then
				execMenu(state,wrapped,state.menu.yCursor+state.menu.yShift-2)
			end
		elseif event[1]=="char" then
			
		elseif event[1]=="mouse_scroll" then
			
		elseif event[1]=="mouse_click" then
		
		elseif event[1]=="mouse_drag" then
			
		elseif event[1]=="monitor_touch" then
			
		end
	elseif state.place=="help" then
		if event[1]=="key" then
			if event[2]==keys["f1"] or event[2]==keys["h"] then--f1
				state.place="main"
				
			elseif event[2]==keys["f8"] or event[2]==keys["e"] then--f8
				state.place="main"
				
			elseif event[2]==keys["f3"] or event[2]==keys["t"] then--f3
				state.place="tableAlias"
				--table Alias
				--try to get pointed Tab
				--insert?
				
			elseif event[2]==keys["f5"] or event[2]==keys["r"] then--f5
				state.place="threadAlias"
				--function alias
				--try to get pointed fun
				--insert?
				
			elseif event[2]==keys["f4"] or event[2]==keys["f"] then--f4
				state.place="functionAlias"
				--function alias
				--try to get pointed fun
				--insert?
			elseif event[2]==keys["f12"] or event[2]==keys["m"] then--f1,mm
				state.place="menu"
			elseif event[2]==keys["home"] then--home
				navHome(state["help"])
				
			elseif event[2]==keys["end"] then--end
				navEnd(state["help"],state,state.help.entrycount)
				
			elseif event[2]==keys["pageUp"] then--pgu
				navPageUp(state["help"],state,state.help.entrycount)
				
			elseif event[2]==keys["pageDown"] then--pgd
				navPageDown(state["help"],state,state.help.entrycount)
				
			elseif event[2]==keys["up"] then--u
				navShiftLines(state["help"],state,state.help.entrycount,-1)
				
			elseif event[2]==keys["down"] then--d
				navShiftLines(state["help"],state,state.help.entrycount,1)
				
			elseif event[2]==keys["left"] then--l
				navLeftCursor(state["help"],3)
				
			elseif event[2]==keys["right"] then--r
				navRightCursor(state["help"],3)
			end
		elseif event[1]=="char" then
			
		elseif event[1]=="mouse_scroll" then
			
		elseif event[1]=="mouse_click" then
		
		elseif event[1]=="mouse_drag" then
			
		elseif event[1]=="monitor_touch" then
			
		end
	elseif state.place=="tableAlias" then
		if event[1]=="key" then
			if event[2]==keys["tab"] then--tab
				state.place="topBarTableAlias"--MOVE
				
			elseif event[2]==keys["f8"] or event[2]==keys["e"] then--f8
				state.place="main"
				
			elseif event[2]==keys["f1"] or event[2]==keys["h"] then--f1
				state.place="help"
				
			elseif event[2]==keys["f3"] or event[2]==keys["t"] then--f3
				state.place="main"
				--table Alias
				--try to get pointed Tab
				--insert?
				
			elseif event[2]==keys["f5"] or event[2]==keys["r"] then--f5
				state.place="threadAlias"
				--function alias
				--try to get pointed fun
				--insert?
				
			elseif event[2]==keys["f4"] or event[2]==keys["f"] then--f4
				state.place="functionAlias"
				--function alias
				--try to get pointed fun
				--insert?
			elseif event[2]==keys["f12"] or event[2]==keys["m"] then--f1,mm
				state.place="menu"
			elseif event[2]==keys["home"] then--home
				navHome(state["tableAlias"])
				
			elseif event[2]==keys["end"] and #wrapped.tables.values>0 then--end
				navEnd(state["tableAlias"],state,#wrapped.tables.values*2)
				
			elseif event[2]==keys["pageUp"] and #wrapped.tables.values>0 then--pgu
				navPageUp(state["tableAlias"],state,#wrapped.tables.values*2)
				
			elseif event[2]==keys["pageDown"] and #wrapped.tables.values>0 then--pgd
				navPageDown(state["tableAlias"],state,#wrapped.tables.values*2)
				
			elseif event[2]==keys["up"] and #wrapped.tables.values>0 then--u
				navUp(state["tableAlias"],state,#wrapped.tables.values*2)
				
			elseif event[2]==keys["down"] and #wrapped.tables.values>0 then--d
				navDown(state["tableAlias"],state,#wrapped.tables.values*2)
				
			elseif event[2]==keys["left"] then--l
				navShiftText(state["tableAlias"],-1)
				
			elseif event[2]==keys["right"] then--r
				navShiftText(state["tableAlias"],1)
			end
		elseif event[1]=="char" then
			
		elseif event[1]=="mouse_scroll" then
			
		elseif event[1]=="mouse_click" then
		
		elseif event[1]=="mouse_drag" then
			
		elseif event[1]=="monitor_touch" then
			
		end
	elseif state.place=="topBarTableAlias" then
		if event[1]=="key" then
			if event[2]==keys["tab"] then--tab
				state.place="tableAlias"--MOVE
				
			elseif event[2]==keys["f8"] or event[2]==keys["e"] then--f8
				state.place="main"
				
			elseif event[2]==keys["f1"] or event[2]==keys["h"] then--f1
				state.place="help"
				
			elseif event[2]==keys["f3"] or event[2]==keys["t"] then--f3
				state.place="main"
				--table Alias
				--try to get pointed Tab
				--insert?
				
			elseif event[2]==keys["f5"] or event[2]==keys["r"] then--f5
				state.place="threadAlias"
				--function alias
				--try to get pointed fun
				--insert?
				
			elseif event[2]==keys["f4"] or event[2]==keys["f"] then--f4
				state.place="functionAlias"
				--function alias
				--try to get pointed fun
				--insert?
			elseif event[2]==keys["f12"] or event[2]==keys["m"] then--f1,mm
				state.place="menu"
			elseif event[2]==keys["home"] then--home
				navHome(state["tableAlias"])
				
			elseif event[2]==keys["end"] then--end
				navEnd(state["tableAlias"],state,state.menu.entrycount)
				
			elseif event[2]==keys["pageUp"] then--pgu
				navPageUp(state["tableAlias"],state,state.menu.entrycount)
				
			elseif event[2]==keys["pageDown"] then--pgd
				navPageDown(state["tableAlias"],state,state.menu.entrycount)
				
			elseif event[2]==keys["up"] then--u
				navUp(state["tableAlias"],state,state.menu.entrycount)
				
			elseif event[2]==keys["down"] then--d
				navDown(state["tableAlias"],state,state.menu.entrycount)
				
			elseif event[2]==keys["left"] then--l
				navLeftCursor(state["tableAlias"],4)
				
			elseif event[2]==keys["right"] then--r
				navRightCursor(state["tableAlias"],4)
			end
		elseif event[1]=="char" then
			
		elseif event[1]=="mouse_scroll" then
			
		elseif event[1]=="mouse_click" then
		
		elseif event[1]=="mouse_drag" then
			
		elseif event[1]=="monitor_touch" then
			
		end
	elseif state.place=="functionAlias" then
		if event[1]=="key" then
			if event[2]==keys["tab"] then--tab
				state.place="topBarFunctionAlias"--MOVE
				
			elseif event[2]==keys["f8"] or event[2]==keys["e"] then--f8
				state.place="main"
				
			elseif event[2]==keys["f1"] or event[2]==keys["h"] then--f1
				state.place="help"
				
			elseif event[2]==keys["f3"] or event[2]==keys["t"] then--f3
				state.place="tableAlias"
				--table Alias
				--try to get pointed Tab
				--insert?
				
			elseif event[2]==keys["f5"] or event[2]==keys["r"] then--f5
				state.place="threadAlias"
				--function alias
				--try to get pointed fun
				--insert?
				
			elseif event[2]==keys["f4"] or event[2]==keys["f"] then--f4
				state.place="main"
				--function alias
				--try to get pointed fun
				--insert?
			elseif event[2]==keys["f12"] or event[2]==keys["m"] then--f1,mm
				state.place="menu"
			elseif event[2]==keys["home"] then--home
				navHome(state["functionAlias"])
				
			elseif event[2]==keys["end"] and #wrapped.functions.values>0 then--end
				navEnd(state["functionAlias"],state,#wrapped.functions.values*2)
				
			elseif event[2]==keys["pageUp"] and #wrapped.functions.values>0 then--pgu
				navPageUp(state["functionAlias"],state,#wrapped.functions.values*2)
				
			elseif event[2]==keys["pageDown"] and #wrapped.functions.values>0 then--pgd
				navPageDown(state["functionAlias"],state,#wrapped.functions.values*2)
				
			elseif event[2]==keys["up"] and #wrapped.functions.values>0 then--u
				navUp(state["functionAlias"],state,#wrapped.functions.values*2)
				
			elseif event[2]==keys["down"] and #wrapped.functions.values>0 then--d
				navDown(state["functionAlias"],state,#wrapped.functions.values*2)
				
			elseif event[2]==keys["left"] then--l
				navShiftText(state["functionAlias"],-1)
				
			elseif event[2]==keys["right"] then--r
				navShiftText(state["functionAlias"],1)
			end
			
		elseif event[1]=="char" then
			
		elseif event[1]=="mouse_scroll" then
			
		elseif event[1]=="mouse_click" then
		
		elseif event[1]=="mouse_drag" then
			
		elseif event[1]=="monitor_touch" then
			
		end
	elseif state.place=="topBarFunctionAlias" then
		if event[1]=="key" then
			if event[2]==keys["tab"] then--tab
				state.place="functionAlias"--MOVE
				
			elseif event[2]==keys["f8"] or event[2]==keys["e"] then--f8
				state.place="main"
				
			elseif event[2]==keys["f1"] or event[2]==keys["h"] then--f1
				state.place="help"
				
			elseif event[2]==keys["f3"] or event[2]==keys["t"] then--f3
				state.place="tableAlias"
				--table Alias
				--try to get pointed Tab
				--insert?
				
			elseif event[2]==keys["f5"] or event[2]==keys["r"] then--f5
				state.place="threadAlias"
				--function alias
				--try to get pointed fun
				--insert?
				
			elseif event[2]==keys["f4"] or event[2]==keys["f"] then--f4
				state.place="main"
				--function alias
				--try to get pointed fun
				--insert?
			elseif event[2]==keys["f12"] or event[2]==keys["m"] then--f1,mm
				state.place="menu"
			elseif event[2]==keys["home"] then--home
				navHome(state["functionAlias"])
				
			elseif event[2]==keys["end"] and #wrapped.functions.values>0 then--end
				navEnd(state["functionAlias"],state,#wrapped.functions.values*2)
				
			elseif event[2]==keys["pageUp"] and #wrapped.functions.values>0 then--pgu
				navPageUp(state["functionAlias"],state,#wrapped.functions.values*2)
				
			elseif event[2]==keys["pageDown"] and #wrapped.functions.values>0 then--pgd
				navPageDown(state["functionAlias"],state,#wrapped.functions.values*2)
				
			elseif event[2]==keys["up"] and #wrapped.functions.values>0 then--u
				navUp(state["functionAlias"],state,#wrapped.functions.values*2)
				
			elseif event[2]==keys["down"] and #wrapped.functions.values>0 then--d
				navDown(state["functionAlias"],state,#wrapped.functions.values*2)
				
			elseif event[2]==keys["left"] then--l
				navLeftCursor(state["functionAlias"],4)
				
			elseif event[2]==keys["right"] then--r
				navRightCursor(state["functionAlias"],4)
			end
			
		elseif event[1]=="char" then
			
		elseif event[1]=="mouse_scroll" then
			
		elseif event[1]=="mouse_click" then
		
		elseif event[1]=="mouse_drag" then
			
		elseif event[1]=="monitor_touch" then
			
		end
	elseif state.place=="threadAlias" then
		if event[1]=="key" then
			if event[2]==keys["tab"] then--tab
				state.place="topBarThreadAlias"--MOVE
				
			elseif event[2]==keys["f8"] or event[2]==keys["e"] then--f8
				state.place="main"
				
			elseif event[2]==keys["f1"] or event[2]==keys["h"] then--f1
				state.place="help"
				
			elseif event[2]==keys["f3"] or event[2]==keys["t"] then--f3
				state.place="tableAlias"
				--table Alias
				--try to get pointed Tab
				--insert?
				
			elseif event[2]==keys["f5"] or event[2]==keys["r"] then--f5
				state.place="main"
				--function alias
				--try to get pointed fun
				--insert?
				
			elseif event[2]==keys["f4"] or event[2]==keys["f"] then--f4
				state.place="functionAlias"
				--function alias
				--try to get pointed fun
				--insert?
			elseif event[2]==keys["f12"] or event[2]==keys["m"] then--f1,mm
				state.place="menu"
			elseif event[2]==keys["home"] then--home
				navHome(state["threadAlias"])
				
			elseif event[2]==keys["end"] and #wrapped.threads.values>0 then--end
				navEnd(state["threadAlias"],state,#wrapped.threads.values*2)
				
			elseif event[2]==keys["pageUp"] and #wrapped.threads.values>0 then--pgu
				navPageUp(state["threadAlias"],state,#wrapped.threads.values*2)
				
			elseif event[2]==keys["pageDown"] and #wrapped.threads.values>0 then--pgd
				navPageDown(state["threadAlias"],state,#wrapped.threads.values*2)
				
			elseif event[2]==keys["up"] and #wrapped.threads.values>0 then--u
				navUp(state["threadAlias"],state,#wrapped.threads.values*2)
				
			elseif event[2]==keys["down"] and #wrapped.threads.values>0 then--d
				navDown(state["threadAlias"],state,#wrapped.threads.values*2)
				
			elseif event[2]==keys["left"] then--l
				navShiftText(state["threadAlias"],-1)
				
			elseif event[2]==keys["right"] then--r
				navShiftText(state["threadAlias"],1)
			end
			
		elseif event[1]=="char" then
			
		elseif event[1]=="mouse_scroll" then
			
		elseif event[1]=="mouse_click" then
		
		elseif event[1]=="mouse_drag" then
			
		elseif event[1]=="monitor_touch" then
			
		end
	elseif state.place=="topBarThreadAlias" then
		if event[1]=="key" then
			if event[2]==keys["tab"] then--tab
				state.place="threadAlias"--MOVE
				
			elseif event[2]==keys["f8"] or event[2]==keys["e"] then--f8
				state.place="main"
				
			elseif event[2]==keys["f1"] or event[2]==keys["h"] then--f1
				state.place="help"
				
			elseif event[2]==keys["f3"] or event[2]==keys["t"] then--f3
				state.place="tableAlias"
				--table Alias
				--try to get pointed Tab
				--insert?
				
			elseif event[2]==keys["f5"] or event[2]==keys["r"] then--f5
				state.place="main"
				--function alias
				--try to get pointed fun
				--insert?
				
			elseif event[2]==keys["f4"] or event[2]==keys["f"] then--f4
				state.place="functionAlias"
				--function alias
				--try to get pointed fun
				--insert?
			elseif event[2]==keys["f12"] or event[2]==keys["m"] then--f1,mm
				state.place="menu"
			elseif event[2]==keys["home"] then--home
				navHome(state["threadAlias"])
				
			elseif event[2]==keys["end"] and #wrapped.threads.values>0 then--end
				navEnd(state["threadAlias"],state,#wrapped.threads.values*2)
				
			elseif event[2]==keys["pageUp"] and #wrapped.threads.values>0 then--pgu
				navPageUp(state["threadAlias"],state,#wrapped.threads.values*2)
				
			elseif event[2]==keys["pageDown"] and #wrapped.threads.values>0 then--pgd
				navPageDown(state["threadAlias"],state,#wrapped.threads.values*2)
				
			elseif event[2]==keys["up"] and #wrapped.threads.values>0 then--u
				navUp(state["threadAlias"],state,#wrapped.threads.values*2)
				
			elseif event[2]==keys["down"] and #wrapped.threads.values>0 then--d
				navDown(state["threadAlias"],state,#wrapped.threads.values*2)
				
			elseif event[2]==keys["left"] then--l
				navLeftCursor(state["threadAlias"],4)
				
			elseif event[2]==keys["right"] then--r
				navRightCursor(state["threadAlias"],4)
			end
			
		elseif event[1]=="char" then
			
		elseif event[1]=="mouse_scroll" then
			
		elseif event[1]=="mouse_click" then
		
		elseif event[1]=="mouse_drag" then
			
		elseif event[1]=="monitor_touch" then
			
		end
	elseif state.place=="sideMenu3" then
		if event[1]=="key" then
			
		elseif event[1]=="char" then
			
		elseif event[1]=="mouse_scroll" then
			
		elseif event[1]=="mouse_click" then
		
		elseif event[1]=="mouse_drag" then
			
		elseif event[1]=="monitor_touch" then
			
		end
	end
end
				--[[ 1     2     3     4    5    6       7    8       9        10            11       12     13      14   ]]
--[[]]function start(input,xSize,ySize,xPos,yPos,colored,side,wrapped,noFSsave,noFSOverwrite,noFSload,noExit,noFedit,state)
	if type(input)~="table" then input={input} end
	
	state=state or {}
	
	state.safety			=state.safety or {}
	state.safety.noSave		=state.safety.noSave or noFSsave
	state.safety.noOverwrite=state.safety.noOverwrite or noFSOverwrite
	state.safety.noLoad		=state.safety.noLoad or noFSload
	state.safety.noExit		=state.safety.noExit or noExit
	state.safety.noFedit	=state.safety.noFedit or noFedit
	
	--state.macro={}
	state.side=tostring(side)
	state.xMax,state.yMax=term.getSize()
	state.xMin,state.yMin=1,1
	
	state.xSize=math.floor(tonumber(xSize) or state.xMax-state.xMin+1)
	state.ySize=math.floor(tonumber(ySize) or state.yMax-state.yMin+1)
	if state.xSize>state.xMax or state.xSize<state.xMin or 
	   state.ySize>state.yMax or state.ySize<state.yMin then 
		return nil
	end
	state.xPos=math.floor(tonumber(xPos) or state.xMin)
	state.yPos=math.floor(tonumber(yPos) or state.yMin)
	if state.xPos>state.xMax or state.xPos<state.xMin or
	   state.yPos>state.yMax or state.yPos<state.yMin then 
		return nil
	end
	
	if (colored==true or colored==nil) and term.isColor() then 
		state.colored=true
	else 
		state.colored=false 
	end
	if not state.colored and (state.xSize<25 or state.ySize<4) then return nil
	elseif state.colored and (state.xSize<25 or state.ySize<3) then return nil end
	
	if state.colored then
		state.xTextSize=state.xSize-4
		state.xTextMin=state.xPos+4
		state.xTextMax=state.xPos+state.xTextSize+state.xTextMin-2
		state.yTextSize=state.ySize-1
		state.yTextMin=state.yPos+1
		state.yTextMax=state.yPos+state.yTextSize+state.yTextMin-1
	else
		state.xTextSize=state.xSize-6
		state.xTextMin=state.xPos+5
		state.xTextMax=state.xPos+state.xTextSize+state.xTextMin-2
		state.yTextSize=state.ySize-1
		state.yTextMin=state.yPos+1
		state.yTextMax=state.yPos+state.yTextSize+state.yTextMin-1
	end
	
	state.help=state.help or {["xShift"]=0,["yShift"]=0,["xCursor"]=1}--defacto it is only topBar
	state.menu=state.menu or {["xShift"]=0,["yShift"]=0,["yCursor"]=3,["xCursor"]=1}
	state.functionAlias	=state.functionAlias or {["xShift"]=0,["yShift"]=0,["yCursor"]=1,["xCursor"]=1,["selection"]={},["clipboard"]={}}
	state.tableAlias	=state.tableAlias or {["xShift"]=0,["yShift"]=0,["yCursor"]=1,["xCursor"]=1,["selection"]={},["clipboard"]={}}
	state.threadAlias	=state.threadAlias or {["xShift"]=0,["yShift"]=0,["yCursor"]=1,["xCursor"]=1,["selection"]={},["clipboard"]={}} 
	
	state.template={["kinds"]={},["depths"]={},["values"]={},["types"]={},["protected"]={},["parsed"]={},
					["tables"]={["keys"]={},["values"]={}},["functions"]={["keys"]={},["values"]={}},
					["threads"]={["keys"]={},["values"]={}}}
	state.history=state.history or {["kinds"]={},["depths"]={},["values"]={},["types"]={},
					["tables"]={["keys"]={},["values"]={}},["functions"]={["keys"]={},["values"]={}},
					["threads"]={["keys"]={},["values"]={}},["fileNames"]={}}
	state.clipboard=state.clipboard or {}
	state.selection=state.selection or {}
	state.selectionPresent=state.selectionPresent or false
	state.blockClipboard=state.blockClipboard or {["kinds"]=true,["depths"]=true,["values"]=true,["types"]=true}
	state.xShift=state.xShift or 0
	state.yShift=state.yShift or 0
	state.xCursor=state.xCursor or 1
	state.yCursor=state.yCursor or 1
	state.indents=state.indents or 0
	state.state=state.state or "pointing"
	state.place=state.place or "main"
	state.placeChange=nil
	state.placePrevious=nil
	state.resized=false
	state.exec=true
	state.terminated=false
	
	
	if state.xSize>30 then state.indents=2 end
	
	state.timer=false
	if not state.colored then
	state.timerInstance=os.startTimer(0.5)
	end
	
	state.autoSaveDelay=300
	state.doAutoSave=false
	if not state.safety.noSave then
		state.doAutoSave=true
	end
	
	state.input=state.input or tableDuplicate(input)--stores a copy of inputted table
	if not isWrapped(wrapped) then
		wrapped =tableDuplicate(state.template)
		wrapTable(state.input,wrapped)
	end
	
	for k=1,#wrapped.values do
		state.selection[k]=state.selection[k] or false
	end
	
	local eventOld={}
	local event
	
		--drawMainElements(state)---
	while state.exec do
			--do once
		if state.place~=state.placeChange then
			state.placePrevious=state.placeChange
			state.placeChange=state.place
			if state.place=="main" or state.place=="topBar" then 
				drawMainElements(state) 
			elseif state.place=="help" then
				drawHelp(state)
			elseif state.place=="tableAlias" or state.place=="topBarTableAlias" then
				drawTableAlias(state)
			elseif state.place=="functionAlias" or state.place=="topBarFunctionAlias" then
				drawFunctionAlias(state)
			elseif state.place=="threadAlias" or state.place=="topBarThreadAlias" then
				drawThreadAlias(state)
			elseif state.place=="sideMenu3" then
				drawSideMenu3(state)
			elseif state.place=="menu" then
				drawMenu(state)
			end
			
		end
			--repeat
		if state.place=="main" or state.place=="topBar" then
			drawGUI(state,wrapped)
		elseif state.place=="help" then
			drawHelpGUI(state)
		elseif state.place=="tableAlias" or state.place=="topBarTableAlias" then
			drawTableAliasGUI(state,wrapped)
		elseif state.place=="functionAlias" or state.place=="topBarFunctionAlias" then
			drawFunctionAliasGUI(state,wrapped)
		elseif state.place=="threadAlias" or state.place=="topBarThreadAlias" then
			drawThreadAliasGUI(state,wrapped)
		elseif state.place=="sideMenu3" then
			drawSideMenu3GUI(state)
		elseif state.place=="menu" then
			drawMenuGUI(state)
		end
		
		if type(event)=="table" and (event[1]=="mouse_click" or event[1]=="mouse_drag" or event[1]=="key" or event[1]=="char") then
			eventOld=tableDuplicate(event) or {}
		end
		event=nil
		
		while not event do
			event={coroutine.yield()}
			if ((event[1]=="mouse_click" or event[1]=="mouse_drag" or event[1]=="mouse_scroll") and state.side==nil)
			or (event[1]=="monitor_touch" and event[2]==state.side) then
				if     event[3]>state.xSize+state.xPos-1 or event[3]<state.xPos then event=nil
				elseif event[4]>state.ySize+state.yPos-1 or event[4]<state.yPos then event=nil end
			end
		end
		term.setCursorBlink(false)
		execEvent(state,wrapped,event,eventOld)
		
		if state.doAutoSave and not state.safety.noFSsave then
			saveWrapped(wrapped,"Tabby_AutoSave")
			saveTable(state,"Tabby_TempState")
			state.doAutoSave=false
			state.autoSave=os.startTimer(state.autoSaveDelay)
		end
		
		if state.resized then
			state.resized=false
			state.xMax,state.yMax=term.getSize()
			
			state.xSize=math.floor(tonumber(xSize) or state.xMax-state.xMin+1)
			state.ySize=math.floor(tonumber(ySize) or state.yMax-state.yMin+1)
			if state.xSize>state.xMax or state.xSize<state.xMin or 
			state.ySize>state.yMax or state.ySize<state.yMin then 
				return nil
			end
			state.xPos=math.floor(tonumber(xPos) or state.xMin)
			state.yPos=math.floor(tonumber(yPos) or state.yMin)
			if state.xPos>state.xMax or state.xPos<state.xMin or
			state.yPos>state.yMax or state.yPos<state.yMin then 
				return nil
			end
			
			if not state.colored and (state.xSize<25 or state.ySize<4) then return nil
			elseif state.colored and (state.xSize<25 or state.ySize<3) then return nil end
			
			if state.colored then
				state.xTextSize=state.xSize-4
				state.xTextMin=state.xPos+4
				state.xTextMax=state.xPos+state.xTextSize+state.xTextMin-2
				state.yTextSize=state.ySize-1
				state.yTextMin=state.yPos+1
				state.yTextMax=state.yPos+state.yTextSize+state.yTextMin-1
			else
				state.xTextSize=state.xSize-5
				state.xTextMin=state.xPos+5
				state.xTextMax=state.xPos+state.xTextSize+state.xTextMin-2
				state.yTextSize=state.ySize-1
				state.yTextMin=state.yPos+1
				state.yTextMax=state.yPos+state.yTextSize+state.yTextMin-1
			end
			if state.place=="main" or state.place=="topBar" then 
				drawMainElements(state) 
			elseif state.place=="help" then
				drawHelp(state)
			elseif state.place=="tableAlias" or state.place=="topBarTableAlias" then
				drawTableAlias(state)
			elseif state.place=="functionAlias" or state.place=="topBarFunctionAlias" then
				drawFunctionAlias(state)
			elseif state.place=="threadAlias" or state.place=="topBarThreadAlias" then
				drawThreadAlias(state)
			elseif state.place=="sideMenu3" then
				drawSideMenu3(state)
			elseif state.place=="menu" then
				drawMenu(state)
			end
			state.yCursor=1
			state.menu.yCursor=1
			state.threadAlias.yCursor=1
			state.functionAlias.yCursor=1
			state.tableAlias.yCursor=1
			state.yShift=0
			state.help.yShift=0
			state.menu.yShift=0
			state.threadAlias.yShift=0
			state.functionAlias.yShift=0
			state.tableAlias.yShift=0
		end
	end
	if event[1]=="terminate" or state.terminated then
		saveWrapped(wrapped,"Tabby_AutoSave")
		saveTable(state,"Tabby_TempState")
		return nil,"passing nil, program terminated"
	end
	sleep(0)
	solveDepths(wrapped)
	parse(wrapped)
	fs.delete("Tabby_TempState")
	--fs.delete("Tabby_AutoSave")
	return unwrapTable(wrapped)
end

local function startProgram(args)
	if type(args[1])=="string" then args[1]=string.lower(args[1]) end
	if args[1]=="new" then
		if args[6]=="-" then args[6]=nil end
		if args[7]=="-" then args[7]=nil end
		start({},tonumber(args[2]),tonumber(args[3]),tonumber(args[4]),tonumber(args[5]),args[6],args[7])
	elseif args[1]=="edit" or args[1]=="load" and fs.exists(args[2]) and not fs.isDir(args[2]) then
		local tabIn
		if type(args[2])=="string" then
			local test,file=pcall(fs.open,args[2],"r")
			if test then
				tabIn=stringToWrapped(file.readAll())
				file.close()
			end
		end
		if type(tabIn)~="table" then tabIn={} end
		if args[7]=="-" then args[7]=nil end
		if args[8]=="-" then args[8]=nil end
		start(nil,tonumber(args[3]),tonumber(args[4]),tonumber(args[5]),tonumber(args[6]),args[7],args[8],tabIn)
	elseif args[1]=="resume" then
		local tabIn
		local test,file=pcall(fs.open,"Tabby_AutoSave","r")
		if test then
			tabIn=stringToWrapped(file.readAll())
			file.close()
		end
		if type(tabIn)~="table" then tabIn={} end
		
		local stateIn=loadTable("Tabby_TempState")
		if type(stateIn)~="table" then stateIn={} end
		
		if args[7]=="-" then args[7]=nil end
		if args[8]=="-" then args[8]=nil end
		start(nil,tonumber(args[2]),tonumber(args[3]),tonumber(args[4]),tonumber(args[5]),args[6],args[7],tabIn,nil,nil,nil,nil,nil,stateIn)
	end
	if term.isColor() then term.setTextColor(colors.white) term.setBackgroundColor(colors.black) end
	term.setCursorPos(1,1)
	term.clear()
end

args={...}

if args[1]=="new" or args[1]=="edit" or args[1]=="load" or args[1]=="resume" then
	--draw the logo
	if term.isColor() then
		term.setBackgroundColor(colors.blue)
		term.setTextColor(colors.lightBlue)
	end
	term.clear()
	term.setCursorPos(1,1)
	textutils.pagedPrint(
[[
 \`*-.  TABby - table     
  )  _`-.       editor    
 .  : `. .      for CC    
 : _   '  \     by Tec    
 ; *` _.   `*-._          
 `-.-'          `-.       
   ;       `       `.     
   :.       .        \    
   . \  .   :   .-'   .   
   '  `+.;  ;  '      :   
   :  '  |    ;       ;-. 
   ; '   : :`-:     _.`* ;
.*' /  .*' ; .*`- +'  `*' 
`*-*   `*-*  `*-*'        ]]
	)
	
	local timer=os.startTimer(2.5)
	local event={coroutine.yield()}
	while true do
		if (event[1]=="timer" and event[2]==timer) or event[1]=="key" or event[1]=="terminate" then break end
	end
	startProgram(args)
elseif args[1]=="help" then 
	if term.isColor() then
		term.setBackgroundColor(colors.blue)
	end
	textutils.pagedPrint([[
TABby - TableCommander by Tec_SG
Program which allows easy table editing

How to use:
0.  To get help inside the program press F1

1.  Load it as API and then
use the internal "start" function
tabby.start(table[,xSize,ySize,xPos,yPos,colored,side])

where:
xSize,ySize
    is the size of the window
    defaults to terminal size

xPos,yPos 
    position of the window relative to
    1st "pixel" in terminal
    defaults to 1,1 (corner)
					
colored
    boolean allowing to set coloring
    defaults to true
side
	just used to tell the program
	to which side the term was redirected
					
2.  Use as a program, just run
tabby new [xSize ySize xPos yPos colored side]
tabby edit {PATH} [xSize ySize xPos yPos colored side]

if you want to skip an argument "-" should work
(so it will revert to default value) just write
some kind of "not number" instead

this allows creation of a table and possibility to edit one
(tables are stored in serialized files)

Optional arguments are in square brackets]]
	)
end
