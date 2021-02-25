--
-- Called when a panel receives a midi message (does not need to match any modulator mask)
-- @midi   string
--

YamahaMessageReceived = function(--[[ string --]] midi, --[[ string --]] decoded)
  console("Yamaha message")
  local YamahaIdTbl = YamahaIdTbl or {
   [0x0] = YamahaDump,
   [0x1] = YamahaParameterChange,
   [0x2] = YamahaDumpRequest
  }
  local callFunction = YamahaIdTbl[floor(midi:byte(3)/0x10)]
  decoded["vendor"] = "Yamaha"
  return type(callFunction) == "function" and callFunction(midi, decoded) or ignoreMidi(midi)
end