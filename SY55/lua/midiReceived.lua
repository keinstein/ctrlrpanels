--
-- Called when a MIDI channel property for the panel changes
--
midiReceived = function(--[[ CtrlrMidiMessage --]] midi)
  print("midiReceived: ", midi:getData():getByte(0))
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
  print(codeTbl)
  print("Table entry: ", math.floor((midi:getData():getByte(0))/(0x10)))
  codeTbl[ math.floor((midi:getData():getByte(0))/(0x10)) ](midi:getData())
end
