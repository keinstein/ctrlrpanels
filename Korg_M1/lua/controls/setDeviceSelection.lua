function setDeviceSelection(--[[ integer ]] index)
   -- panel:getComponent("IntOrCard"):setProperty("uiLabelText",bank,false)
   -- panel:getModulator("BankSelector"):setModulatorValue(value,false,false,false)
   -- console("setDeviceSelection")
   local data
   if (deviceSelection == nil)
   then
      assignDeviceSelection()
   end

   data = deviceSelection["devices"][index]
   -- print_table(data)
   -- console("old manufacturer: " .. deviceSelection["manufacturer"]:getProperty("uiLabelText"))
   deviceSelection["manufacturer"]:setPropertyString("uiLabelText",data["unrt vendor"])
   -- deviceSelection["manufacturer"]:setValue(data["unrt vendor"],true,true)
   deviceSelection["family"]:setProperty("uiLabelText",data["family name"],false)
   deviceSelection["member"]:setProperty("uiLabelText",data["member"],false)
   deviceSelection["major"]:setProperty("uiLabelText",data["major version"],false)
   deviceSelection["minor"]:setProperty("uiLabelText",data["minor version"],false)
   deviceSelection["devId"]:setProperty("uiLabelText",tostring(data["devId"]+1),false)
   -- deviceSelection["devId"]:setModulatorValue(data["devId"]+1,false,false,false)
end
