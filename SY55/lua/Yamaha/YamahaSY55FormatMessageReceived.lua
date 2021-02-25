YamahaSY55FormatMessageTable = {
["LM  8103SY"] = YamahaSY55SystemBulkDumpReceived
}
function YamahaSY55FormatMessageReceived(--[[ string ]] midi, --[[ table ]] decoded)
  console("YamahaSY55FormatMessageReceived")
  console(tostring(type(midi)))
  console(midi)
  console("length:" .. tostring(#midi))
  console("raw: ".. midi:sub(7,16))
  local dataSize = midi:byte(5) * 0x100 + midi:byte(6)
  console("dataSize =  " .. tostring(dataSize))
  if dataSize + 8 ~= #midi then return ignoreMidi(midi) end
  console("Checksum: " .. tostring(midi:byte(7+dataSize)))
  console("sum 6+datasize: " .. tostring(midi:sub(6+dataSize,7+dataSize)))
  console("length #midi - dataSize: " .. tostring(#midi - dataSize))
  -- the checksum is the byte after the data (byte 7+ dataSize)
  -- checksum is the 2s complement of the stream sum  (mod 2^7).
  -- so adding it should result in 0
  if (streamSum(midi:sub(7,7+dataSize)) % 0x80) ~= 0
  then
    console("Yamaha SY55 dump message –– checksum failed")
    return ignoreMidi(midi)
  else
    console("Yamaha SY55 dump message –– checksum OK.")
  end
  decoded = (decodeYamahaSY55FormatDumpHeader(midi:sub(7,32),decoded))
table_dump(decoded)
  local callFunction = YamahaSY55FormatMessageTable[decoded["classification name"] .. decoded["data format name"]]
  return type(callFunction) == "function" and callFunction(midi, decoded) or ignoreMidi(midi)
end