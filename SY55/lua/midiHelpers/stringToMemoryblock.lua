function stringToMemoryBlock(data)
	-- Your method code here
    datalen = data:len()
    dataTable = {}
    for i = 1,datalen do
       dataTable[i] = string.byte(data,i)
    end
    return MemoryBlock.fromLuaTable(dataTable)
end