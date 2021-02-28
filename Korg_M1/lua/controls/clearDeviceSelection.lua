function clearDeviceSelection(--[[ integer ]] index)
   -- panel:getComponent("IntOrCard"):setProperty("uiLabelText",bank,false)
   -- panel:getModulator("BankSelector"):setModulatorValue(value,false,false,false)
   -- console("setDeviceSelection")
   local data
   if (deviceSelection == nil)
   then
      assignDeviceSelection()
   else
      deviceSelection["devices"] = {}
   end
   -- print_table(data)
   -- console("old manufacturer: " .. deviceSelection["manufacturer"]:getProperty("uiLabelText"))
   local key, name
   for key,name in ipairs({ "manufacturer", "family", "member", "major", "minor", "devId" })
   do
      deviceSelection[name]:setPropertyString("uiLabelText","")
   end
end
