--
-- Called when a modulator value changes
-- @mod   http://ctrlr.org/api/class_ctrlr_modulator.html
-- @value    new numeric value of the modulator
--
pressGlobalInquiry = function(--[[ CtrlrModulator --]] mod, --[[ number --]] value, --[[ number --]] source)
   if (deviceSelection == nil)
   then
      assignDeviceSelection()
   end
   if ( M1 == nil or M1["GlobalSettings"] == nil) 
   then
      assignGlobalSettings()
   end

   print_table(_G)
   
   local channel = deviceSelection["devId"]:getProperty("uiLabelText")
   console(string.format("channel: „%s“", channel))
   local controls = M1["GlobalSettings"]
   console(string.format("bank: „%s“", tostring(controls["bank"])))
   data = {
      channel = tonumber(channel) - 1,
      bank = controls["bank"]:getSelectedRow(0)
   }
   midiSend("Korg M1 global data dump request", 0, data)
end
