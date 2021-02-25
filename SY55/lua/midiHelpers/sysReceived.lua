--
-- Called when a panel receives a midi message (does not need to match any modulator mask)
-- @midi   string object
--

sysReceived = function(--[[ string --]] midi, --[[ table ]] decoded)
  print("sysReceived")
  local sysTbl = sysTbl or {
    [0x0] = sysexReceived,
    [0x1] = ignoreMidi,
    [0x2] = ignoreMidi,
    [0x3] = ignoreMidi,
    [0x4] = ignoreMidi,
    [0x5] = ignoreMidi,
    [0x6] = ignoreMidi,
    [0x7] = ignoreMidi,
    [0x8] = ignoreMidi,
    [0x8] = ignoreMidi,
    [0xa] = ignoreMidi,
    [0xb] = ignoreMidi,
    [0xc] = ignoreMidi,
    [0xd] = ignoreMidi,
    [0xe] = ignoreMidi,
    [0xf] = ignoreMidi
  }
  print("Entry: ", midi:byte(1) % 0x10)
  return sysTbl[ midi:byte(1) % 0x10 ] (midi, decoded) 
end