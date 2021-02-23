YamahaFormatTable = {
  [0x7a] = receiveSY55FormatMessage
}
function YamahaDump(midi)
	-- Your method code here
    channel = midi.getByte(2) % 0x10
    format = midi.getByte(3)
    f = YamahaFormatTable[format]
    return (type(f) == "function" and f(midi) or f)
end