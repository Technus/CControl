--TableCommander courtesy of tec_SG
local function drawMainElements(state)
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

local function sortron(tab)
	local sortedOut={}
	local keys={}
	local numerals={}
	local booleans={}
	for k,v in pairs(tab) do
		if type(k)=="string" then table.insert(keys,k)
		elseif type(k)=="number" then table.insert(numerals,k)
		elseif type(k)=="boolean" then table.insert(booleans,k) 
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
		sortedOut[v]=tab[v]
	end
	for k,v in ipairs(booleans) do
		sortedOut[v]=tab[v]
	end
	for k,v in ipairs(keys) do
		sortedOut[v]=tab[v]
	end
	
	return sortedOut
end

local function shortType(stuff)
	local shortcuts=
	{
		["table"]="t",
		["number"]="n",
		["function"]="f",
		["boolean"]="b",
		["string"]="s",
		["nil"]="0"
	}
	if shortcuts[type(stuff)] then return shortcuts[type(stuff)] else return " " end
end	

local function wrapTable(input,wrapped)

	wrapped.tables={[2]=input}
					table.insert(wrapped.kinds, "K")
					table.insert(wrapped.depths, 0 )
					table.insert(wrapped.values,"nil")
					table.insert(wrapped.types, shortType(nil))
					
					table.insert(wrapped.kinds, "V")
					table.insert(wrapped.depths, 0 )
					table.insert(wrapped.values,input)
					table.insert(wrapped.types, "t")
	local function itIsTable(tab,depth,wrapped,duplicates) 
		depth=depth or 1
		tab=sortron(tab)
		for k,v in pairs(tab) do
			if type(v)=="table" then
				local test=true
				for k1,v1 in pairs(wrapped.tables) do
					if v==v1 then test=false end
				end
				if test then
					wrapped.tables[#wrapped.types]=v
					table.insert(wrapped.kinds, "K")
					table.insert(wrapped.depths,depth)
					table.insert(wrapped.values,k)
					table.insert(wrapped.types, shortType(k))
					
					table.insert(wrapped.kinds, "V")
					table.insert(wrapped.depths,depth)
					table.insert(wrapped.values,v)
					table.insert(wrapped.types, "t")
					
					itIsTable(tab[k],depth+1,wrapped)
					
					table.insert(wrapped.kinds, "K")
					table.insert(wrapped.depths,depth)
					table.insert(wrapped.values,k)
					table.insert(wrapped.types, shortType(k))
					
					table.insert(wrapped.kinds, "V")
					table.insert(wrapped.depths,depth)
					table.insert(wrapped.values,v)
					table.insert(wrapped.types, "x")
				else
					table.insert(wrapped.kinds, "K")
					table.insert(wrapped.depths,depth)
					table.insert(wrapped.values,k)
					table.insert(wrapped.types, shortType(k))
					
					table.insert(wrapped.kinds, "V")
					table.insert(wrapped.depths,depth)
					table.insert(wrapped.values,v)
					table.insert(wrapped.types, "d")
				end
			else
				table.insert(wrapped.kinds, "K")
				table.insert(wrapped.depths,depth)
				table.insert(wrapped.values,k)
				table.insert(wrapped.types, shortType(k))
				
				table.insert(wrapped.kinds, "V")
				table.insert(wrapped.depths,depth)
				table.insert(wrapped.values,v)
				table.insert(wrapped.types, shortType(v))
			end
		end
	end
	itIsTable(input,nil,wrapped)--evil i know :D					
					table.insert(wrapped.kinds, "K")
					table.insert(wrapped.depths, 0 )
					table.insert(wrapped.values, "nil")
					table.insert(wrapped.types, shortType(nil))
					
					table.insert(wrapped.kinds, "V")
					table.insert(wrapped.depths, 0 )
					table.insert(wrapped.values,input)
					table.insert(wrapped.types, "x")
end

local function tableDuplicate(tab)
	local outTable={}
	local duplicates={tab}
	local newDuplicates={outTable}
	local function itIsTable(tab,where,duplicates,newDuplicates)
		for k,v in pairs(tab) do
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
	itIsTable(tab,outTable,duplicates,newDuplicates)
	return outTable
end

local function drawTable(state,wrapped)
	for i=1,state.yTextSize do
		if wrapped.kinds[i+state.yShift] then
			if state.colored then
				term.setBackgroundColor(colors.white)
				if wrapped.kinds[i+state.yShift]=="K" then
					term.setTextColor(colors.blue)
				else
					term.setTextColor(colors.black)
				end
				term.setCursorPos(state.xTextMin-3,state.yTextMin+i-1)
				local temp=tostring(wrapped.depths[i+state.yShift])
				while #temp<2 do temp=" "..temp end
				term.write(temp)
				
				term.setBackgroundColor(colors.lightBlue)
				term.setCursorPos(state.xTextMin-4,state.yTextMin+i-1)
				term.write(tostring(wrapped.kinds[i+state.yShift]))
				term.setCursorPos(state.xTextMin-1,state.yTextMin+i-1)
				term.write(tostring(wrapped.types[i+state.yShift]))
				
				term.setBackgroundColor(colors.black)
				if wrapped.kinds[i+state.yShift]=="K" then
					term.setTextColor(colors.blue)
				elseif wrapped.types[i+state.yShift]=="t" then
					term.setTextColor(colors.lime)
				elseif wrapped.types[i+state.yShift]=="x" then
					term.setTextColor(colors.green)
				elseif wrapped.types[i+state.yShift]=="f" then
					term.setTextColor(colors.yellow)
				else
					term.setTextColor(colors.white)
				end
				term.setCursorPos(state.xTextMin,state.yTextMin+i-1)
				temp=tostring(wrapped.values[i+state.yShift])
				while #temp<state.xTextSize do temp=temp.." " end
				term.write(temp)
			else
				term.setCursorPos(state.xTextMin-5,state.yTextMin+i-1)
				term.write(tostring(wrapped.kinds[i+state.yShift]))
				term.setCursorPos(state.xTextMin-4,state.yTextMin+i-1)
				local temp=tostring(wrapped.depths[i+state.yShift])
				while #temp<2 do temp=" "..temp end
				term.write(temp)
				term.setCursorPos(state.xTextMin-2,state.yTextMin+i-1)
				term.write(tostring(wrapped.types[i+state.yShift]))
				term.setCursorPos(state.xTextMin,state.yTextMin+i-1)
				temp=tostring(wrapped.values[i+state.yShift])
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
				temp=tostring(wrapped.values[i+state.yShift])
				local temp=" "
				while #temp<state.xTextSize do temp=temp.." " end
				term.write(temp)
			else
				--term.setCursorPos(
				--term.write(
				--term.setCursorPos(
				--term.write(
				--term.setCursorPos(
				--term.write(
				--term.setCursorPos(
				--term.write(
			end
		end
	end
end

local function drawGUI(state)

end


function start(input,xSize,ySize,xPos,yPos,colored)
	if type(input)~="table" then input={input} end
	
	local state={}
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
	
	input=tableDuplicate(input)
	
	local wrapped={["kinds"]={},["depths"]={},["values"]={},["types"]={},["tables"]={}}
	wrapTable(input,wrapped)
	
	drawMainElements(state)
	
	state.xShift,state.yShift=0,0
	state.xCursor,state.yCursor=0,0
	state.exec=true
	while state.exec do
		drawTable(state,wrapped)
		--drawGUI(state,wrapped)
		--execEvent(state)
	end
	return unwrapTable(input)
end