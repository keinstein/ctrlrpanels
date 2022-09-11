function memoryBlockToString(data)
	-- Your method code here
    console("memoryBlockToString")
	-- Your method code here
    local datalen = data:getSize()
    local result = {}
    local i
    for i = 0,datalen-1 do
       result[#result+1] = string.char(data:getByte(i))
    end
   return table.concat(result)
end
