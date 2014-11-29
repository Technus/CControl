--TableCommander courtesy of tec_SG  A.K.A.  Technus
--use as program or load as API
--execute "tabby help" in shell for help
--in program you can use f1
--for more info go to ComputerCraftForums and/or GitHub

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

local function readEX( _sReplaceChar, _tHistory ,data,lastCharPos,state--[[side of screen or state table]])
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
        end
    end
	if _tHistory and sLine~="" then
		local test=true
		for k,v in ipairs(_tHistory) do
			if v==sLine then test=false end
		end
		if test then
			table.insert(_tHistory,sLine)
		end
	end
    local cx, cy = term.getCursorPos()
    term.setCursorBlink( false )
    term.setCursorPos( w + 1, cy )
    --print()
    
    return sLine,event
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

--[[]]function invisibleCharWrap(str)
	if type(str)~="string" then return nil end
	str=str:gsub("\\","\\\\")
	str=str:gsub("\n","\\n" )
	str=str:gsub("\t","\\t" )
	str=str:gsub("\v","\\v" )
	str=str:gsub("\a","\\a" )
	str=str:gsub("\b","\\b" )
	str=str:gsub("\f","\\f" )
	str=str:gsub("\r","\\r" )
	str=str:gsub("\0","\\0" )
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

--[[]]function invisibleCharUnwrap(str)
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
			elseif temp[i+1]=="0"  then out=out.."\0" i=i+1
			elseif tonumber(temp[i+1]) and tonumber(temp[i+2]) and tonumber(temp[i+3]) then 
				i=i+3
				local b=temp[i+1]*100+temp[i+2]*10+temp[i+3]
				if b<256 then out=out..string.char(b) end
			end
		end
		i=i+1
	end
	return out
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

local function solveDepths(wrapped)
	--changes depth levels to correct ones
	local depthMeasured=1
	for k,v in ipairs(wrapped.kinds) do
		if wrapped.depths[k]>=0 then--make sure will not alter negatives and skip them in processing	
			if wrapped.types[k]=="t" then
				wrapped.depths[k]=depthMeasured
				depthMeasured=depthMeasured+1
			elseif wrapped.types[k]=="x" then
				depthMeasured=depthMeasured-1
				wrapped.depths[k]=depthMeasured
			else
				wrapped.depths[k]=depthMeasured
			end
		end
	end
end

--[[]]function wrappedSolveDepths(wrapped)
	if type(wrapped)~="table" or type(wrapped.values)~="table" or 
	   type(wrapped.kinds)~="table" or type(wrapped.depths)~="table" or 
	   type(wrapped.parsed)~="table" or type(wrapped.types)~="table" or
	   type(wrapped.protected)~="table" or type(wrapped.tables)~="table" or
	   type(wrapped.functions)~="table" or type(wrapped.threads)~="table" or
	   type(wrapped.functions.keys)~="table" or type(wrapped.functions.values)~="table" or
	   type(wrapped.threads.keys)~="table" or type(wrapped.threads.values)~="table" or
	   type(wrapped.tables.keys)~="table" or type(wrapped.tables.values)~="table" 
	then 
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
				for k1,v1 in ipairs(wrapped.functions.values) do
					if k==v1 then test=false end
				end
				if test then
					table.insert(wrapped.functions.keys,tostring(k))
					table.insert(wrapped.functions.values,k)
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
				for k1,v1 in ipairs(wrapped.functions.values) do
					if v==v1 then test=false end
				end
				if test then
					table.insert(wrapped.functions.keys,tostring(v))
					table.insert(wrapped.functions.values,v)
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
	
	if #wrapped.kinds==0 then
				table.insert(wrapped.kinds, "V")
				table.insert(wrapped.depths, 1 )
				table.insert(wrapped.values,tostring(nil))
				table.insert(wrapped.types, shortType(nil))
	end
end

local function parse(wrapped,val)
	if tonumber(val) then
		local k=math.floor(tonumber(val))
		local v=wrapped.values[k]
		if wrapped.depths[k]>0 then
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
				for k1,v1 in ipairs(wrapped.functions.keys) do
					if v1==v and type(wrapped.functions.values[k1])=="function" then temp=wrapped.functions.values[k1] break else temp=function()end end
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
	if type(wrapped)~="table" or type(wrapped.values)~="table" or 
	   type(wrapped.kinds)~="table" or type(wrapped.depths)~="table" or 
	   type(wrapped.parsed)~="table" or type(wrapped.types)~="table" or
	   type(wrapped.protected)~="table" or type(wrapped.tables)~="table" or
	   type(wrapped.functions)~="table" or type(wrapped.threads)~="table" or
	   type(wrapped.functions.keys)~="table" or type(wrapped.functions.values)~="table" or
	   type(wrapped.threads.keys)~="table" or type(wrapped.threads.values)~="table" or
	   type(wrapped.tables.keys)~="table" or type(wrapped.tables.values)~="table" 
	then 
		return nil,wrapped,false
	end
	wrap=tableDuplicate(wrapped)
	parse(wrapped,val)
	return wrap,wrapped,true
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
						if type(key)~=nil then
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
			str=str.."\n"..tostring(wrapp.kinds[k]).." "..tostring(wrapp.types[k]).." "..invisibleCharWrap(tostring(wrapp.values[k]))
		end
	end
	str=str.."\nFUNCTIONS:"
	for k,v in ipairs(wrapp.functions.keys) do
		str=str.."\n"..tostring(wrapp.functions.keys[k]).."\n"..invisibleCharWrap(string.dump(wrapp.functions.values[k]))
	end
	return str,{wrap,wrapp},true
end

--[[]]function tableToString(input)
	if type(input)~="table" then return nil,false end
	local tab=tableDuplicate(input)
	return wrappedToString(tableToWrapped(tab)),tab,true
end

--[[]]function stringToWrapped(str)
	local test=true
	local wrapped={["kinds"]={},["depths"]={},["values"]={},["types"]={},["parsed"]={},["protected"]={},
					["tables"]={["keys"]={},["values"]={},["selfValue"]={}},["functions"]={["keys"]={},["values"]={}},
					["threads"]={["keys"]={},["values"]={}}}
	if type(str)~="string" then 
		str=""
		test=false
	end
	local strLines=stringSplit(str,"\n")
	if strLines[1]=="TABBY TABLE FORMAT:" then
		table.remove(strLines,1)
		local functions=false
		for k,v in ipairs(strLines) do
			local line=invisibleCharWrap(v)
			if line=="FUNCTIONS:" then 
				functions=1 
			elseif #line>0 then--ignore empty lines
				if functions then
					if functions==1 then
						functions=2
						table.insert(wrapped.functions.keys,line)
					else
						functions=1
						local func=loadstring(invisibleCharUnwrap(line))
						table.insert(wrapped.functions.values,func)
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
		test=false
	end
	if #wrapped.kinds==0 then
		table.insert(wrapped.kinds, "V")
		table.insert(wrapped.depths, 1 )
		table.insert(wrapped.values,tostring(nil))
		table.insert(wrapped.types, shortType(nil))
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
	if type(path)~="string" then return false end
	
	local str=wrappedToString(wrapped)
	
	local test,file=pcall(fs.open,tostring(path),"w")
	if test then
		file.write(str)
		file.close()
	end
end

--[[]]function loadWrapped(path)--?
	local wrapped={["kinds"]={},["depths"]={},["values"]={},["types"]={},["parsed"]={},["protected"]={},
					["tables"]={["keys"]={},["values"]={},["selfValue"]={}},["functions"]={["keys"]={},["values"]={}},
					["threads"]={["keys"]={},["values"]={}}}
	if type(path)~="string" or not fs.exists(path) then return nil end
	local test,file=pcall(fs.open,tostring(path),"r")
	if test then
		wrapped=stringToWrapped(file.readAll())
		file.close()
		return wrapped,nil,true
	end
	return {},nil,false
end

--[[]]function saveTable(tab, path)
	return saveWrapped(tableToWrapped(tab),path)
end

--[[]]function loadTable(path)
	return wrappedToTable(loadWrapped(path))
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
				
				term.setBackgroundColor(colors.lightBlue)
				term.setCursorPos(state.xTextMin-4,state.yTextMin+i-1)
				term.write(tostring(wrapped.kinds[i+state.yShift]))
				term.setCursorPos(state.xTextMin-1,state.yTextMin+i-1)
				term.write(tostring(wrapped.types[i+state.yShift]))
				
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
				term.write(tostring(wrapped.types[i+state.yShift]))
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
				term.setTextColor(colors.black)
				term.setCursorPos(state.xTextMin-3,state.yTextMin+i-1)
				term.write("  ")
				
				term.setBackgroundColor(colors.lightBlue)
				term.setCursorPos(state.xTextMin-4,state.yTextMin+i-1)
				term.write(" ")
				term.setCursorPos(state.xTextMin-1,state.yTextMin+i-1)
				term.write(" ")
				
				term.setBackgroundColor(colors.black)
				term.setTextColor(colors.blue)
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
end

local function drawThreadAliasGUI(state,wrapped)

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
end

local function drawTableAliasGUI(state,wrapped)

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
end

local function drawFunctionAliasGUI(state,wrapped)

end

local function drawMenu(state)
	if state.colored then
		term.setBackgroundColor(colors.lightBlue)
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
		
		term.setBackgroundColor(colors.blue)
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
	local sideTextColors={
	 colors.white
	,colors.white
	,colors.blue
	,colors.blue
	,colors.blue
	,colors.blue
	,colors.blue
	,colors.blue
	,colors.blue
	,colors.blue
	,colors.blue
	,colors.blue
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
	,state.safety.noSave and [[ -- ]] or [[SAVE]]
	,state.safety.noLoad and [[ -- ]] or [[LOAD]] 
	,[[RTRN]]
	,state.safety.noExit and [[ -- ]] or [[EXIT]]
	}
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
		,state.safety.noSave and [[! option disabled    ]] or [[saves table to file  ]]
		,state.safety.noLoad and [[! option disabled    ]] or [[loads table from file]]
		,[[returns table        ]]
		,[[quits the program    ]]
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
		,[[Creates new table]]
		,state.safety.noSave and [[! Option is disabled    ]] or [[Saves Table to a file specified Path]]
		,state.safety.noLoad and [[! Option is disabled    ]] or [[Loads Table from a file on specified Path]]
		,[[Returns the table back to the calling program (equal to EXIT if tabby started as program from shell)]]
		,[[Exits the program (equal to CTRL+T) - returns nil to the calling program]]
		}
	end
	if state.colored then
		for i=state.yPos,state.yPos+state.ySize-1 do
			if tonumber(sideTextColors[i+state.menu.yShift]) then
				term.setTextColor(sideTextColors[i+state.menu.yShift])
			end
			term.setCursorPos(state.xPos,i)
			writeEX(side[i+state.menu.yShift],0,4)
			
			term.setTextColor(colors.blue)
			term.setCursorPos(state.xPos+4,i)
			writeEX(help[i+state.menu.yShift],state.menu.xShift,state.xSize-4)
		end
	else
		for i=state.yPos,state.yPos+state.ySize-1 do
			term.setCursorPos(state.xPos,i)
			writeEX(side[i+state.menu.yShift],0,4)
			term.setCursorPos(state.xPos+5,i)
			writeEX(help[i+state.menu.yShift],state.menu.xShift,state.xSize-5)
		end
	end
end

local function drawHelp(state)
	if state.colored then
		term.setBackgroundColor(colors.lightBlue)
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
	end
	term.setCursorPos(state.xPos,state.yPos)
	term.write("X:")--xPos+5,yPos
	term.setCursorPos(state.xPos+8,state.yPos)
	term.write("Y:")--xPos+13,yPos
	term.setCursorPos(state.xPos+16,state.yPos)
	term.write("L:")--xPos+21,yPos
end

local function drawHelpGUI(state)
	local sideTextColors={
	--    --
	colors.black
	,colors.black
	,colors.blue
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
	,[[---------------------]]
	,[[How to use the prog. ]]
	}
	if state.colored then
		for i=state.yPos,state.yPos+state.ySize-1 do
			term.setBackgroundColor(colors.lightBlue)
			if tonumber(sideTextColors[i+state.help.yShift]) then
				term.setTextColor(sideTextColors[i+state.help.yShift])
			end
			term.setCursorPos(state.xPos,i)
			if side[i+state.help.yShift] then
				writeEX(side[i+state.help.yShift],0,4)
			end
			term.setBackgroundColor(colors.black)
			term.setTextColor(colors.white)
			term.setCursorPos(state.xPos+4,i)
			if help[i+state.help.yShift] then
				writeEX(help[i+state.help.yShift],state.help.xShift,state.xSize-4)
			end
		end
	else
		for i=state.yPos,state.yPos+state.ySize-1 do
			term.setCursorPos(state.xPos,i)
			if side[i+state.help.yShift] then
				writeEX(side[i+state.help.yShift],0,4)
			end
			term.setCursorPos(state.xPos+5,i)
			if help[i+state.help.yShift] then
				writeEX(help[i+state.help.yShift],state.help.xShift,state.xSize-5)
			end
		end
	end
end

local function drawSideMenu3(state)

end

local function drawSideMenu3GUI(state)

end



local function execEvent(state,wrapped,event,eventOld)
	if event[1]=="timer" and event[2]==state.timerInstance and not state.colored then
		state.timer=not state.timer
		state.timerInstance=os.startTimer(0.5)
	elseif event[1]=="terminate" then
		state.exec=false
	elseif event[1]=="term_resize" or (event[1]=="monitor_resize" and event[2]==state.side) then
		state.resized=true
	elseif state.place=="main" then
		if event[1]=="key" then
		
			if event[2]==15 then--tab
				state.place="topBar"
				
			elseif event[2]==65 or (event[2]==28 and ((eventOld[2]==29 or eventOld[2]==157) and eventOld[1]=="key")) then--f7
				state.state="editing"
				local temp=state.xCursor
				state.xCursor=4
				local curTempX,curTempY=term.getCursorPos()
				term.setCursorPos(state.xTextMin,state.yPos+state.yCursor)
				if state.colored then
					term.setTextColor(colors.green)
					term.setBackgroundColor(colors.lime)
				end
				--protected input
				--add new protected
				--edit variable value
				if wrapped[xCursorName(state.xCursor)][state.yCursor+state.yShift] then
					wrapped.protected[state.yCursor+state.yShift]=true
					wrapped[xCursorName(state.xCursor)][state.yCursor+state.yShift]=
					readEX("*",nil,tostring(wrapped[xCursorName(state.xCursor)][state.yCursor+state.yShift]),state.xTextMax,state)
				end
				term.setCursorPos(curTempX,curTempY)
				state.xCursor=temp
				state.state="pointing"

			elseif event[2]==28 then--enter
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
						wrapped[xCursorName(state.xCursor)][state.yCursor+state.yShift]=temp
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
			elseif event[2]==199 then--home
				state.yCursor=1
				state.yShift=0
			elseif event[2]==207 then--end
				if state.yTextSize>#wrapped.kinds then 
					state.yCursor=#wrapped.kinds
					state.yShift=0
				else
					state.yCursor=state.yTextSize
					state.yShift=#wrapped.kinds-state.yTextSize
				end
			elseif event[2]==201 then--pgu
				if state.yShift>=state.yTextSize then
					state.yShift=state.yShift-state.yTextSize
				elseif state.yShift==0 and state.yCursor==1 then
					if state.yTextSize>#wrapped.kinds then 
						state.yCursor=#wrapped.kinds
						state.yShift=0
					else
						state.yCursor=state.yTextSize
						state.yShift=#wrapped.kinds-state.yTextSize
					end
				elseif state.yShift>0 then
					state.yShift=0
				elseif state.yShift==0 then
					state.yCursor=1
				end
			elseif event[2]==209 then--pgd
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
			elseif event[2]==200 then--u
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
			elseif event[2]==208 then--d
				if state.yCursor<=state.yTextSize-1   and state.yShift+state.yCursor<#wrapped.kinds  then
					state.yCursor=state.yCursor+1
				elseif state.yCursor==state.yTextSize and state.yShift+state.yTextSize<#wrapped.kinds then
					state.yShift=state.yShift+1
				else
					state.yCursor=1
					state.yShift=0
				end
			elseif event[2]==203 then--l
				if state.xCursor>=2 then
					state.xCursor=state.xCursor-1
				elseif state.xCursor==1 then
					state.xCursor=4
				end
			elseif event[2]==205 then--r
				if state.xCursor<=3 then
					state.xCursor=state.xCursor+1
				elseif state.xCursor==4 then
					state.xCursor=1
				end
			elseif event[2]==31 then--s
				--state.save=true
				do end
			elseif event[2]==38 then--l
				--state.load=true
				do end
			elseif event[2]==43 then--\
				solveDepths(wrapped)
			elseif event[2]==59 or event[2]==35 then--f1
				state.place="help"
			elseif event[2]==211 or event[2]==14 or event[2]==32 then--delete or bks space
				--table.remove pair
				if #wrapped.kinds>2 then
					if wrapped.kinds[state.yCursor+state.yShift]=="K" and 
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
						if state.yCursor+state.yShift>#wrapped.kinds then
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
						if state.yCursor+state.yShift>#wrapped.kinds then
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
				end
			elseif event[2]==210 or event[2]==49 then
				--table.insert pair
				if wrapped.kinds[state.yCursor+state.yShift]=="K" and 
				   wrapped.kinds[state.yCursor+state.yShift+1]=="V" then
					local temp=state.yCursor+state.yShift+2
					table.insert(wrapped.kinds, temp,"V")--v
					table.insert(wrapped.kinds, temp,"K")--k
					table.insert(wrapped.depths,temp,wrapped.depths[state.yCursor+state.yShift])
					table.insert(wrapped.depths,temp,wrapped.depths[state.yCursor+state.yShift])
					table.insert(wrapped.types, temp,shortType(nil))
					table.insert(wrapped.types, temp,shortType(nil))
					table.insert(wrapped.values,temp,tostring(nil))
					table.insert(wrapped.values,temp,tostring(nil))
				elseif wrapped.kinds[state.yCursor+state.yShift]=="V" then
					local temp=state.yCursor+state.yShift+1
					table.insert(wrapped.kinds, temp,"V")--v
					table.insert(wrapped.kinds, temp,"K")--k
					table.insert(wrapped.depths,temp,wrapped.depths[state.yCursor+state.yShift])
					table.insert(wrapped.depths,temp,wrapped.depths[state.yCursor+state.yShift])
					table.insert(wrapped.types, temp,shortType(nil))
					table.insert(wrapped.types, temp,shortType(nil))
					table.insert(wrapped.values,temp,tostring(nil))
					table.insert(wrapped.values,temp,tostring(nil))
				end
				
			elseif event[2]==61 or event[2]==20 then--f3
				state.place="tableAlias"
				--table Alias
				--try to get pointed Tab
				--insert?
				
			elseif event[2]==63 or event[2]==19 then--f5
				state.place="threadAlias"
				--function alias
				--try to get pointed fun
				--insert?
				
			elseif event[2]==62 or event[2]==33 then--f4
				state.place="functionAlias"
				--function alias
				--try to get pointed fun
				--insert?
				
			elseif event[2]==88 or event[2]==50 then--f1,mm
				state.place="menu"
				
			elseif event[2]==53 then--/ ?
				--get back to start
				state.xShift=0
				
			elseif event[2]==41 or event[2]==68 then--` f10
				--exit
				state.exec=false
			end
		
		elseif event[1]=="char" then
		
			if event[2]=="i" then
				state.indents=state.indents+1
				
			elseif event[2]=="I" then
				if state.indents>=1 then state.indents=state.indents-1 end
				
			elseif event[2]=="x" then
				--cut
				state.blockClipboard[xCursorName(state.xCursor)]=false
				state.clipboard[xCursorName(state.xCursor)]=
				wrapped[xCursorName(state.xCursor)][state.yCursor+state.yShift]
				if state.xCursor==4  or state.xCursor==3 then				
					wrapped[xCursorName(3)][state.yCursor+state.yShift]="-"
					wrapped[xCursorName(4)][state.yCursor+state.yShift]="nil"
				end
				
			elseif event[2]=="X" then
				--cut row
				for i=1,4 do
					state.blockClipboard[xCursorName(i)]=false
					state.clipboard[xCursorName(i)]=
					wrapped[xCursorName(i)][state.yCursor+state.yShift]
				end
				wrapped[xCursorName(3)][state.yCursor+state.yShift]="-"
				wrapped[xCursorName(4)][state.yCursor+state.yShift]="nil"
				
			elseif event[2]=="c" then
				--copy
				state.blockClipboard[xCursorName(state.xCursor)]=false
				state.clipboard[xCursorName(state.xCursor)]=
				wrapped[xCursorName(state.xCursor)][state.yCursor+state.yShift]
				
			elseif event[2]=="C" then
				--copy row
				for i=1,4 do
					state.blockClipboard[xCursorName(i)]=false
					state.clipboard[xCursorName(i)]=
					wrapped[xCursorName(i)][state.yCursor+state.yShift]
				end
				
			elseif event[2]=="v" then
				--paste
				if not state.blockClipboard[xCursorName(state.xCursor)] then
					wrapped[xCursorName(state.xCursor)][state.yCursor+state.yShift]=
					state.clipboard[xCursorName(state.xCursor)]
				end
				
			elseif event[2]=="V" then
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
				state.xShift=state.xShift+1
			elseif event[2]==">" then
				state.xShift=state.xShift+10
			elseif event[2]=="," then
				if state.xShift>=1 then state.xShift=state.xShift-1 end
			elseif event[2]=="<" then
				if state.xShift>=10 then
					state.xShift=state.xShift-10
				else
					state.xShift=0
				end				
			elseif event[2]=="-" or event[2]=="_" then
				if #wrapped.kinds>1 then
					local temp=state.yCursor+state.yShift
					table.remove(wrapped.kinds, temp)--v
					table.remove(wrapped.depths,temp)
					table.remove(wrapped.types, temp)
					table.remove(wrapped.values,temp)	
					if state.yCursor+state.yShift>#wrapped.kinds then
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
			elseif event[2]=="=" then
				local temp=state.yCursor+state.yShift
				table.insert(wrapped.kinds, temp,"V")--v
				table.insert(wrapped.depths,temp,wrapped.depths[state.yCursor+state.yShift])
				table.insert(wrapped.types, temp,shortType(nil))
				table.insert(wrapped.values,temp,tostring(nil))
			elseif event[2]=="+" then
				local temp=state.yCursor+state.yShift
				table.insert(wrapped.kinds, temp,"K")--v
				table.insert(wrapped.depths,temp,wrapped.depths[state.yCursor+state.yShift])
				table.insert(wrapped.types, temp,shortType(nil))
				table.insert(wrapped.values,temp,tostring(nil))
			end	
		elseif event[1]=="mouse_scroll" then
			if event[4]==state.yPos then
				if event[3]>=state.xPos and event[3]<state.xPos+8 then
					state.xShift=state.xShift+event[2]
					if state.xShift<0 then state.xShift=0 end
				elseif event[3]>=state.xPos+8 and event[3]<state.xPos+16 then
					if #wrapped.kinds>=state.yTextSize+state.yShift+event[2] then
						state.yShift=state.yShift+event[2]
					end
					if state.yShift<0 then state.yShift=0 end
				elseif event[3]>=state.xPos+16 and event[3]<state.xPos+24 then
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
			elseif event[3]==1 then
				if wrapped.kinds[event[4]-state.xPos]=="K" then 
					wrapped.kinds[event[4]-state.xPos]="V"
				else
					wrapped.kinds[event[4]-state.xPos]="K"
				end
			elseif event[3]<=3 then
				if wrapped.depths[event[4]-state.xPos] then 
					wrapped.depths[event[4]-state.xPos]=wrapped.depths[event[4]-state.xPos]+event[2]
				end
			end			
		elseif event[1]=="mouse_click" and event[2]==1 then
			if event[4]==state.yPos then
				state.place="topBar"
			else
				if event[4]-state.yPos==state.yCursor then
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
					else
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
				elseif wrapped.kinds[event[4]-state.xPos+state.yShift] then 
					state.yCursor=event[4]-state.xPos
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
			end
		elseif event[1]=="mouse_click" and event[2]==2 then
			if event[4]==state.yPos then
				state.place="menu"
			elseif event[3]==state.xPos then
				if wrapped.kinds[event[4]-state.xPos+state.yShift] then 
					state.xCursor=1
					state.yCursor=event[4]-state.yPos
					if wrapped.kinds[event[4]-state.xPos+state.yShift]=="K" then
						wrapped.kinds[event[4]-state.xPos+state.yShift]="V"
					else
						wrapped.kinds[event[4]-state.xPos+state.yShift]="K"
					end
				end
			elseif event[3]==state.xPos+3 then
				if wrapped.kinds[event[4]-state.xPos+state.yShift] then 
					state.xCursor=3
					state.yCursor=event[4]-state.xPos
					state.place="sideMenu3"
				end
			end
		elseif event[1]=="mouse_drag" and event[2]==1 then
			if (eventOld[1]=="mouse_drag" or eventOld[1]=="mouse_click") and eventOld[2]==1 then
				local xDiv=eventOld[3]-event[3]
				local yDiv=eventOld[4]-event[4]
				if xDiv<0 and state.xShift<(-xDiv) then 
					state.xShift=0
				else
					state.xShift=state.xShift+xDiv
				end
				
				if yDiv<0 and state.yShift<(-yDiv) then 
					state.yShift=0
				elseif #wrapped.kinds>=yDiv+state.yShift+state.yTextSize then
					state.yShift=state.yShift+yDiv
				end
			end
		elseif event[1]=="monitor_touch" and event[2]==state.side then
			if event[4]==state.yPos then
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
			elseif event[3]<=state.xPos+3 then
				local temp=math.floor(state.yPos+1+(state.yTextSize/2))
				if event[4]<temp and state.yShift>0 then 
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
				else
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
			else
				local temp=math.floor(state.xPos+4+(state.xTextSize/2))
				local move=event[3]-temp+1
				if move<1 then move=move-1 end
				state.xShift=state.xShift+move
				if state.xShift<0 then state.xShift=0 end
			end
		end
	elseif state.place=="topBar" then
		if event[1]=="key" then
			--if event[2]==
		elseif event[1]=="char" then
			
		elseif event[1]=="mouse_scroll" then
			
		elseif event[1]=="mouse_click" then
			
		elseif event[1]=="monitor_touch" then
			
		end
	elseif state.place=="help" then
		if event[1]=="key" then
			
		elseif event[1]=="char" then
			
		elseif event[1]=="mouse_scroll" then
			
		elseif event[1]=="mouse_click" then
		
		elseif event[1]=="mouse_drag" then
			
		elseif event[1]=="monitor_touch" then
			
		end
	elseif state.place=="tableAlias" then
		if event[1]=="key" then
			
		elseif event[1]=="char" then
			
		elseif event[1]=="mouse_scroll" then
			
		elseif event[1]=="mouse_click" then
		
		elseif event[1]=="mouse_drag" then
			
		elseif event[1]=="monitor_touch" then
			
		end
	elseif state.place=="functionAlias" then
		if event[1]=="key" then
			
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

--[[]]function start(input,xSize,ySize,xPos,yPos,colored,side,noFSsave,noFSOverwrite,noFSload,noExit,noFedit)
	if type(input)~="table" then input={input} end
	
	local state={}
	
	state.safety={}
	state.safety.noSave=noFSsave
	state.safety.noOverwrite=noFSOverwrite
	state.safety.noLoad=noFSload
	state.safety.noExit=noExit
	state.safety.noFedit=noFedit
	
	state.macro={}
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
	
	state.help={["xShift"]=0,["yShift"]=0}
	state.menu={["xShift"]=0,["yShift"]=0,["yCursor"]=1}
	state.functionAlias	={["xShift"]=0,["yShift"]=0,["yCursor"]=1,["xCursor"]=1}
	state.tableAlias	={["xShift"]=0,["yShift"]=0,["yCursor"]=1,["xCursor"]=1}
	state.threadAlias	={["xShift"]=0,["yShift"]=0,["yCursor"]=1,["xCursor"]=1} 
	
	state.template={["kinds"]={},["depths"]={},["values"]={},["types"]={},["protected"]={},["parsed"]={},
					["tables"]={["keys"]={},["values"]={}},["functions"]={["keys"]={},["values"]={}},
					["threads"]={["keys"]={},["values"]={}}}
	state.history={["kinds"]={},["depths"]={},["values"]={},["types"]={},
					["tables"]={["keys"]={},["values"]={}},["functions"]={["keys"]={},["values"]={}},
					["threads"]={["keys"]={},["values"]={}}}
	state.clipboard={}
	state.blockClipboard={["kinds"]=true,["depths"]=true,["values"]=true,["types"]=true}
	state.xShift,state.yShift=0,0
	state.xCursor,state.yCursor=1,1
	state.indents=0
	if state.xSize>30 then state.indents=2 end
	
	state.timer=false
	--state.timerInstance=os.startTimer(0.5)
	
	state.input=tableDuplicate(input)
	local wrapped =tableDuplicate(state.template)
	wrapTable(state.input,wrapped)
	
	state.state="pointing"
	state.place="main"
	state.resize=false
	state.placeOld=nil
	local eventOld={}
	local event
	
	state.exec=true
		--drawMainElements(state)---
	while state.exec do
			--do once
		if state.place~=state.placeOld then
			state.placeOld=state.place
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
		
		if not state.colored then
		state.timerInstance=os.startTimer(0.5)
		end
		
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
		end
	end
	if event[1]=="terminate" then
		return nil,"passing nil, program terminated"
	end
	sleep(0)
	solveDepths(wrapped)
	parse(wrapped)
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
				tabIn=stringToTable(file.readAll())
				file.close()
			end
		end
		if type(tabIn)~="table" then tabIn={} end
		if args[7]=="-" then args[7]=nil end
		if args[8]=="-" then args[8]=nil end
		start(tabIn,tonumber(args[3]),tonumber(args[4]),tonumber(args[5]),tonumber(args[6]),args[7],args[8])
	end
	if term.isColor() then term.setTextColor(colors.white) term.setBackgroundColor(colors.black) end
	term.setCursorPos(1,1)
	term.clear()
end

args={...}

if args[1]=="new" or args[1]=="edit" or args[1]=="load" then
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
	textutils.pagedPrint(
[[
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
