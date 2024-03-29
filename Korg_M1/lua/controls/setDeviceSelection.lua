function setDeviceSelection(--[[ integer ]] index)
   -- panel:getComponent("IntOrCard"):setProperty("uiLabelText",bank,false)
   -- panel:getModulator("BankSelector"):setModulatorValue(value,false,false,false)
   console("setDeviceSelection")
   local data
   if (deviceSelection == nil)
   then
      assignDeviceSelection()
   end

   local i
   local namelist = {}
   for i = 1, #deviceSelection["devices"]
   do
      namelist[i] = deviceSelection["devices"][i]["stringrep"]
   end

   deviceSelection["devSelection"]
      :setProperty("uiComboContent",
		   table.concat(namelist,"\n"),
		   false)
   deviceSelection["devSelection"]
      :setProperty("uiComboSelectedIndex",
		   index-1,
		   false)
   --deviceSelection["devSelection"]:setModulatorValue(index,false,false,false)
   
   data = deviceSelection["devices"][index]
   -- print_table(data)
   -- console("old manufacturer: " .. deviceSelection["manufacturer"]:getProperty("uiLabelText"))
   deviceSelection["manufacturer"]
      :setPropertyString("uiLabelText",
			 data["unrt vendor"])
   -- deviceSelection["manufacturer"]:setValue(data["unrt vendor"],true,true)
   deviceSelection["family"]:
      setProperty("uiLabelText",
		  data["family name"],false)
   deviceSelection["member"]:
      setProperty("uiLabelText",
		  data["member"],false)
   deviceSelection["major"]:
      setProperty("uiLabelText",
		  data["major version"],false)
   deviceSelection["minor"]:
      setProperty("uiLabelText",
		  data["minor version"],false)
   deviceSelection["devId"]:
      setProperty("uiLabelText",
		  tostring(data["devId"]+1),false)
   -- deviceSelection["devId"]:setModulatorValue(data["devId"]+1,false,false,false)

   if (data["family name"] == "Korg" and data["member"] == "M1") then
      if M1 == nil or M1["GlobalSettings"] == nil
      then
	 assignGlobalSettings()
      end
      M1["GlobalSettings"]:setVisible(true)
      M1["GlobalSettings"]:setEnabled(false)
      M1["GlobalSettings"]["inquiry button"]:setEnabled(true) 
      M1["GlobalSettings"]["bank"]:setEnabled(true) 
   end
end
