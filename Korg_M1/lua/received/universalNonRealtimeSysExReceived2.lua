--
-- Called when a panel receives a midi message (does not need to match any modulator mask)
-- @midi   CtrlrMidiMessage object
--

local universalNonRealtimeSysExSwitch
universalNonRealtimeSysExReceived = function(--[[ CtrlrMidiMessage --]] midi)
    print("Universal NRT Message()")
  universalNonRealtimeSysExSwitch = universalNonRealtimeSysExSwitch or {
    [0x06] = midiInquiryMessageReceived,
  }
  local f =  universalNonRealtimeSysExSwitch[midi:getData():getByte(3)]
  -- type(t[v]) == "function" and t[v]() or t[v] or "blah"
  f2 = type(f) == "function" and f(midi) or ignoredMidiReceived(midi)
end