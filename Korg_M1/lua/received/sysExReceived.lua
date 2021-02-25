--
-- Called when a panel receives a midi message (does not need to match any modulator mask)
-- @midi   CtrlrMidiMessage object
--

local midiManufacturerSwitch
sysExReceived = function(--[[ CtrlrMidiMessage --]] midi)
  print("sysExReceived.()")
  midiManufacturerSwitch = midiManufacturerSwitch or {
    [0x42] = korgSysExReceived,
    [0x7e] = universalNonRealtimeSysExReceived,
    [0x7f] = universalRealtimeSysExReceived
  }
  local f =  midiManufacturerSwitch[midi:getData():getByte(1)]
  -- type(t[v]) == "function" and t[v]() or t[v] or "blah"
  f2 = type(f) == "function" and f(midi) or ignoredMidiReceived(midi)
end