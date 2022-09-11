--
-- Called when a panel receives a midi message (does not need to match any modulator mask)
-- @midi   CtrlrMidiMessage object
--

midiInquiryAnswerReceived = function(--[[ string --]] midi, --[[ table ]] data)
   -- console(midi:toString())
   data["manufacturer"] = data["unrt vendor"]
   if (deviceSelection == nil)
   then
      assignDeviceSelection()
   end
   local loaddata = false
   if #deviceSelection["devices"] == 0
   then
      loaddata = true
   end
   deviceSelection["devices"][#deviceSelection["devices"]+1] = data
   if loaddata then
      setDeviceSelection(1)
   end
end

