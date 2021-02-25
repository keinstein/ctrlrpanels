--
-- Called when a panel receives a midi message (does not need to match any modulator mask)
-- @midi   CtrlrMidiMessage object
--

sysexReceived = function(--[[ string --]] midi, --[[ table ]] decoded)
  print("Checking device ID...")
  local sysexIdTbl = sysexIdTbl or {
    [0x43] = YamahaMessageReceived,
    [0x7e] = nrtUniversalSysexReceived,
    [0x7f] = rtUniversalSysexReceived,
  }
  local callFunction = sysexIdTbl[midi:byte(2)]
  decoded["type"] = "SysEx"
  return type(callFunction) == "function" and callFunction(midi, decoded) or ignoreMidi(midi)
end