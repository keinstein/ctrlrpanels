YamahaFormatTable = {
  [0x7a] = YamahaSY55FormatMessageReceived
}
function YamahaDump(--[[ string ]] midi, --[[ table ]] decoded)
    console("Yamaha Dump")
	-- Your method code here
    decoded["devId"] = midi:byte(3) % 0x10
    decoded["format"] = midi:byte(4)
    local f = YamahaFormatTable[decoded["format"]]
    return (type(f) == "function" and f(midi, decoded) or f)
end