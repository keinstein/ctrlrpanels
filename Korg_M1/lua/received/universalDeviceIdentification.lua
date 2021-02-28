function universalDeviceIdentification(data)
   console("universalDeviceIdentification")
   console("vendor: " .. data["unrt vendor"])
   console("family: " .. string.format("%04x",data["family"]))
   console("minor: " .. data["minor version"])
   console("major: " .. data["major version"])
end
