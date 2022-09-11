--
-- Called when a panel receives a midi message (does not need to match any modulator mask)
-- @midi   CtrlrMidiMessage object
--

_G.ManufacturerIds = {
  [0x42] = {
    ["name"] = "Korg", 
    ["families"] = {
      [0x1900] = {
        ["name"] = "M1",
        ["members"] = {
          [0x0000] = {
            ["name"] = "<default>",
            ["Major Version"] = function(hi, lo) return "SOFT VER " .. hi .. "." .. lo end,
            ["Minor Version"] = function(hi, lo) return "ROM No. " .. hi .. "." .. lo end
         }
        }
      }
    }
  },
  [0x43] = {
    ["name"] = "Yamaha",
  },
  [0x7e] = {
    ["name"] = "Universal Non-Realtime",
  },
  [0x7f] = {
    ["name"] = "Universal Realtime",
  }
}
midiInquiryAnswerReceived = function(--[[ CtrlrMidiMessage --]] midi)
  -- console(midi:toString())
  devId = midi:getData():getByte(2)
  manId = midi:getData():getByte(5)
  famId = midi:getData():getByte(6)* 0x100 + midi:getData():getByte(7)
  memberId = midi:getData():getByte(8)* 0x100 + midi:getData():getByte(9)
  manufacturer = _G.ManufacturerIds[manId]
  manufacturername = manufacturer and manufacturer["name"] or tostring(manId)
  family = (manufacturer and manufacturer["families"]) and manufacturer["families"][famId]
  familyname = family and family["name"] or tostring(famId)
  member = (family and family["members"]) and family["members"][memberId]
  membername = member and member["name"] or tostring(memberId)
  majorname = (type(member["Major Version"])== "function" and 
     member["Major Version"](midi:getData():getByte(12),midi:getData():getByte(13)) or 
     midi:getData():getByte(12).." "..midi:getData():getByte(13))
  minorname = (type(member["Minor Version"])== "function" and 
     member["Minor Version"](midi:getData():getByte(10),midi:getData():getByte(11)) or 
     midi:getData():getByte(10).." "..midi:getData():getByte(11))
  console("Manufacturer: ".. manufacturername)
  console("Family: " .. familyname)
  console("Member: " .. membername)
  console("Major Version: " .. majorname)
  console("Minor Version: " .. minorname)
  console("Device Id: " .. devId)
end