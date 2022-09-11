function stringToMemoryBlock(data)
    console("stringToMemoryBlock")
	-- Your method code here
    local datalen = data:len()
    local dataTable = {}
    for i = 1,datalen do
       dataTable[i] = string.byte(data,i)
    end
   return MemoryBlock.fromLuaTable(dataTable)
end