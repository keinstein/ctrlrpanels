--
-- Called when a panel receives a midi message (does not need to match any modulator mask)
-- @midi   CtrlrMidiMessage object
--

M1received = 1

M1globalDataReceived = function(--[[ string --]] midi, --[[ table ]] data)
   if (M1 == nil or M1["GlobalSettings"] == nil) then
      assignGlobalSettings()
   end

   M1["globalData"] = data
   setM1GlobalData()
   
   return
--[[
   -- console(midi:toString())
   data["manufacturer"] = data["unrt vendor"]
   -- console("devsel: " .. tostring(deviceSelection))
   if (deviceSelection == nil)
   then
      assignDeviceSelection()
   end
   -- console("devsel: ")
   -- print_table(deviceSelection)
   local loaddata = false
   if #deviceSelection["devices"] == 0
   then
      loaddata = true
   end
   deviceSelection["devices"][#deviceSelection["devices"]+1] = data
   -- console("devsel: ")
   -- print_table(deviceSelection)
   if loaddata then
      deviceSelection["current"] = 1
   end
   setDeviceSelection(deviceSelection["current"])
--]]
end

