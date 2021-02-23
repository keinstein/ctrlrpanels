--
-- Called when a panel receives a midi message (does not need to match any modulator mask)
-- @midi   CtrlrMidiMessage object
--

YamahaMessageReceived = function(--[[ CtrlrMidiMessage --]] midi)
  console("Yamaha message")
    local YamahaIdTbl = YamahaIdTbl or {
   [0x0] = YamahaDump,
   [0x1] = YamahaParameterChange,
   [0x2] = YamahaDumpRequest
  }
  local callFunction = YamahaIdTbl[floor(midi:getByte(2)/0x10)]
  return type(callFunction) == "function" and callFunction(midi) or ignoreMidi(midi)
end