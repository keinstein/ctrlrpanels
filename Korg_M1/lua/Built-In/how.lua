-- @1.1
--
-- Print all available classes
--
function how()
	ret = "Available classes:\n"
	ret = ret .. "\n-----------------------------------------------------------------"
	for i,v in ipairs(class_names()) do
		ret = ret .. "\t".. v .. "\n"
	end
	ret = ret .. "\n-----------------------------------------------------------------"
	console (J(ret))
	return ret
end