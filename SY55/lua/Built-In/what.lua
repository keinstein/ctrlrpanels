-- @1.1
--
-- Print methods for an object
--
function what(o)
	info = class_info(o)
	if info ~= nil then
		ret = "Object type [" .. info.name .. "]\n-----------------------------------------------------------------\n\n".."Members:\n"

		if info.name == "table" then
			table_dump(o)
		end

		for k, v in pairs(info.methods) do
			ret = ret .. string.format ("\t%30s:\t%5s\n", k, type(v))
		end
		ret = ret .. "\n\nAttributes:\n"
		for k, v in pairs(info.attributes) do
			ret = ret .. string.format ("\t%30s:\t%5s\n", k, type(v))
		end
		ret = ret .. "\n-----------------------------------------------------------------"
	end

	console (ret)
	return ret
end