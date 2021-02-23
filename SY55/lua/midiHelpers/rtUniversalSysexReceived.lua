--
-- Called when a panel receives a midi message (does not need to match any modulator mask)
-- @midi   CtrlrMidiMessage object
--

rtUniversalSysexReceived = function(--[[ CtrlrMidiMessage --]] midi)
  console("Universal Real Time message")
end 
