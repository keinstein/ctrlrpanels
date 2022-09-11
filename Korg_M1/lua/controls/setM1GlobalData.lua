function setM1GlobalData()
   -- panel:getComponent("IntOrCard"):setProperty("uiLabelText",bank,false)
   -- panel:getModulator("BankSelector"):setModulatorValue(value,false,false,false)
   -- console("setDeviceSelection")
   local data
   if (M1 == nil or M1["GlobalSettings"] == nil)
   then
      assignGlobalSettings()
   end
   controls = M1["GlobalSettings"]
   data = M1["globalData"]
   console("intializing global data")
   console("data dump")
   print_table(data)
   console("controls dump")
   print_table(controls)
   console("notification type: ".. NotificationType.sendNotificationSync)

   controls['bank']:selectRow(data['bank'], false, true)
   controls['pedal1']:selectRow(data['assignable pedal 1'], false, true)
   controls['pedal2']:selectRow(data['assignable pedal 2'], false, true)
   controls['damper']:selectRow(data['damper polarity'], false, true)
   
   scaleUI = controls['scale']

   --[[
   scaleUI['type']:setProperty("modulatorValue",
			       data['scale type'],
			       false)
   valueMap = scaleUI['key']:getValueMap()
   valueMap:setCurrentNonMappedValue
   valueMap:
   --]]
   -- scaleUI['key']:setSelectedId(data['pure type key'])
   scaleUI['type']:selectRow(data['scale type'], false, true)
   scaleUI['key']:setSelectedItemIndex(data['pure type key'],false)
   for k,v in pairs(data['user scale']) do
      scaleUI[v['user scale entry']-1]:setValue(v['value'],
						NotificationType.sendNotificationSync)
   end
   
   return
--[[
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
--]]
end
