--
-- Called when a panel receives a midi message (does not need to match any modulator mask)
-- @midi   CtrlrMidiMessage object
--

sysexReceived = function(--[[ CtrlrMidiMessage --]] midi)
  print("Checking device ID...")
  local sysexIdTbl = sysexIdTbl or {
    [0x43] = YamahaMessageReceived,
    [0x7e] = nrtUniversalSysexReceived,
    [0x7f] = rtUniversalSysexReceived,
  }
  local callFunction = sysexIdTbl[midi:getByte(1)]
  return type(callFunction) == "function" and callFunction(midi) or ignoreMidi(midi)
end