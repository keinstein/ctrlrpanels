--
-- Called when a panel receives a midi message (does not need to match any modulator mask)
-- @midi   CtrlrMidiMessage object
--

ignoredMidiReceived = function(--[[ CtrlrMidiMessage --]] midi)
  print("ignoredMidiReceived")
end