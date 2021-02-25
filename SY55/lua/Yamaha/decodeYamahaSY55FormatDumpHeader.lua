decodeYamahaSY55FormatDumpHeaderMemoryTypes = {
    [0x00] = "internal",
    [0x02] = "preset",
    [0x7f] = "edit buffer"
}
function decodeYamahaSY55FormatDumpHeader(--[[ string ]] midi, --[[ table ]] decoded)
	-- Your method code here
    decoded["classification name"] = midi:sub(1,4)
    decoded["data format name"] = midi:sub(5,10) 
    decoded["additional header"] = midi:sub(11,24)
    decoded["memory type"] = decodeYamahaSY55FormatDumpHeaderMemoryTypes[midi:byte(25)] or midi:byte(25)
    decoded["memory number"] = midi:byte(26)
    return decoded
end