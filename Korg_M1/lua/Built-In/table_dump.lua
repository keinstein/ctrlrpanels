-- @1.1
--
-- Print table contents
--
function table_dump(table)
	for key,value in ipairs(table) do
		_DBG ("KEY= ["..key.."]")

		if (type(value) == "table") then
			table_dump(value)
		elseif (type(value) == "nil") then
			_DBG (" = NIL")
		else
			what (value)
		end
	end
end