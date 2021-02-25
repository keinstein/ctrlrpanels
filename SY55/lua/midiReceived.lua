--
-- Called when a MIDI channel property for the panel changes
--
midiReceived = function(--[[ CtrlrMidiMessage --]] midi)
  console("midiReceived: ".. midi:getData():getByte(0))
  console("full text: ".. midi:getData():toString())
  local codeTbl = codeTbl or {
    [0x0] = ignoreMidi,
    [0x1] = ignoreMidi,
    [0x2] = ignoreMidi,
    [0x3] = ignoreMidi,
    [0x4] = ignoreMidi,
    [0x5] = ignoreMidi,
    [0x6] = ignoreMidi,
    [0x7] = ignoreMidi,
    [0x8] = ignoreMidi,
    [0x9] = ignoreMidi,
    [0xa] = ignoreMidi,
    [0xb] = ignoreMidi,
    [0xc] = ignoreMidi,
    [0xd] = ignoreMidi,
    [0xe] = ignoreMidi,
    [0xf] = sysReceived,
  }
  local data = memoryblockToString(midi:getData())
  console("result: (".. tostring(#data).. ") " .. data)
  local index = math.floor(data:byte(1)/(0x10))
  console("Table entry: ".. index)
  codeTbl[ index ](data,{})
end
