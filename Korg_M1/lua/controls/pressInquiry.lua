--
-- Called when a modulator value changes
-- @mod   http://ctrlr.org/api/class_ctrlr_modulator.html
-- @value    new numeric value of the modulator
--
pressInquiry = function(--[[ CtrlrModulator --]] mod, --[[ number --]] value, --[[ number --]] source)
   clearDeviceSelection()
   local data = {
      devId = 0x7f -- all devices
   }
   console("pressInquiry")
   print_table(data)
   -- f0 7e 7f 06 01 f7
   midiSend("unrt device inquiry request", 0, data)
end
