--
-- Called when a panel receives a midi message (does not need to match any modulator mask)
-- @midi   CtrlrMidiMessage object
--
--[[
   We parse the midi stream with a finite state machine.
   So we can keep the complete MIDI parser in one function.
   A state can have the following attributes:
   - fields is a list of fields that will be filled in data before getstate is called
   - statefield is the field that shall be used to determine the next state if not prestent getstate is evaluated.
   - getstate a function returning a selection for the new state, the next index and the collected data
   or the next state
   - newstate  a table that turns the result from getstate into a new state. If nil, the new state will not
   be translated.
   no new state silently stops the parsing.
   - increment if present represents the increment that is done in the function.
]]
ManufacturerTable = {
  [0x42] = {
    ["name"] = "Korg", 
    ["families"] = {
      [0x1900] = {
        ["name"] = "M1",
        ["members"] = {
          [0x0000] = {
            ["name"] = "<default>",
            ["major version"] = function(data) return "SOFT VER. " .. floor(data["major version"]/0x80) end,
            ["minor version"] = function(data) return "ROM No. " .. floor(data["minor version"]/0x80) end,
            ["stringrep"] = function(data) return string.format("Korg M1, Id=%d",data['devId']) end
         }
        }
      }
    }
  },
  [0x43] = {
    ["name"] = "Yamaha",
  },
  [0x7e] = {
    ["name"] = "Universal Non-Realtime System Exclusive",
  },
  [0x7f] = {
    ["name"] = "Universal Realtime System Exclusive",
  }
}
YamahaSY55Data = {
   ["memory type"] = {
      [0x00] = "internal",
      [0x02] = "preset",
      [0x7f] = "edit buffer"
   },
   ["devices"] = {}
}
midiReceivedStates = {
   ["start"] = {
      ["getstate"] = function(midi, current, data)
	 return bit32.band(midi:byte(current), 0xf0), current, data
      end,
      ["newstate"] = {
	 [0xf0] = "sys",
      }
   },
   ["end"] = {},
   ["sys"] = {
      ["fields"] = {
	 {1,"b","midi type"}
      },
      ["statefield"] = "midi type",
      ["newstate"] = {
	 [0xf0] = "sysex"
      }
   },
   ["sysex"] = {
      ["getstate"] = function (midi, current, data)
	 local vid = midi:byte(current)
	 if vid == 0x00
	 then
	    vid = 0x10000 + midi:byte(current+2) *0x100 + midi:byte(current+2)
	    current = current + 3
	 else
	    current = current + 1
	 end
	 console(string.format("vid = %x",vid))
	 data["vid"] = vid
	 data["vendor"] = (ManufacturerTable[vid] and ManufacturerTable[vid]["name"]) or string.format("%x",vid)
	 console(string.format("vendor = %s",data["vendor"]))
	 return vid, current, data
      end,
      ["newstate"] = {
	 [0x42] = "KorgSysex",
	 [0x43] = "YamahaSysex",
	 [0x7e] = "unrt sysex",
	 [0x7f] = "urt sysex",
      }
   },
   ["unrt sysex"] = {
      ["fields"] = {
	 {1,"b","devId"},
	 {2,"r","subId"}
      },
      ["statefield"] = "subId",
      ["newstate"] = {
	 [0x0601] = "unrt device inquiry request",
	 [0x0602] = "unrt device inquiry reply"
      }
   },
   ["unrt device inquiry request"] = {
   },
   ["unrt device inquiry reply"] = {
      ["getstate"] = function (midi, current, data)
	 local vid = midi:byte(current)
	 if vid == 0x00
	 then
	    vid = 0x10000 + midi:byte(current+2) *0x100 + midi:byte(current+2)
	    current = current + 3
	 else
	    current = current + 1
	 end
	 data["unrt vid"] = vid
	 data["unrt vendor"] = ManufacturerTable[vid]["name"] or tostring(vid)
	 return "unrt device inquiry reply data", current, data
      end
   },   
   ["unrt device inquiry reply data"] = {
      ["fields"] = {
	 { 2, "r", "family" },
	 { 2, "r", "member" },
	 { 2, "b", "minor version" },
	 { 2, "b", "major version" }
      },
      ["getstate"] = function (midi, current, data)
	 print("getstate current byte: ",midi:byte(current)," = ",0xf7)
	 if (midi:byte(current) ~= 0xf7) then return "end",current, data end
	 print_table(ManufacturerTable)
	 print(data["unrt vid"])
	 local fam = ManufacturerTable[data["unrt vid"]]["families"][data["family"]]
	 print_table(fam)
	 if not fam then return "end", current, data end
	 data["family name"] = fam["name"] or string.format("%04x",data["family"])
	 local member = fam["members"][data["member"]]
	 if not member then return "end", current, data end
	 data["minor version"] = type(member["minor version"]) == "function" and
	    member["minor version"](data) or
	    string.format("%04x",data["minor version"])
	 data["major version"] = type(member["major version"]) == "function" and
	    member["major version"](data) or data["major version"] or
	    string.format("%04x",data["major version"])
	 data["stringrep"] = type(member["stringrep"]) == "function" and
	    member["stringrep"](data) or data["stringrep"] or
	    string.format("%s %s %s, Id=%d",
			  data["unrt vendor"],
			  data["family name"],
			  data["member"],
			  data["devId"])
	 print_table(data)
	 midiInquiryAnswerReceived(midi, data)
	 return "end",current,data
      end,
      ["newstate"] = {
	 [0x42] = "korg device inquiry data",
      }
   },
   ["urt sysex"] = {
   },
   ["KorgSysex"] = {
   },
   ["YamahaSysex"] = {
      ["getstate"] = function (midi, current, data)
	 data["devId"] = midi:byte(current % 0x10)
	 return midi:byte(floor(current / 0x10)), current + 1, data
      end,
      ["newstate"] = {
	 [0x0] = "YamahaDump",
	 [0x1] = "YamahaParameterChange",
	 [0x2] = "YamahaDumpRequest"
      }
   },
   ["YamahaDump"]  = {
      ["fields"] = {
	 {1,"b","format"}
      },
      ["statefield"] = "format",
      ["newstate"] = {
	 [0x7a] = "YamahaSY55FormatBulkDump",
      }
   },
   ["YamahaSY55FormatBulkDump"]  = {
      ["getstate"] = function (midi, current, data)
	 local datasize = midi:byte(current)*0x100 + midi:byte(current+1)
	 if dataSize + 8 ~= #midi then
	    return "end",current, data
	 end
	 if (streamSum(midi:sub(current+2,current+dataSize+2)) % 0x80) ~= 0
	 then
	    console("Yamaha SY55 dump message –– checksum failed")
	    return "end",current,data
	 else
	    console("Yamaha SY55 dump message –– checksum OK.")
	 end
	 return "YamahaSY55FormatBulkDumpHeader", current + 2, data
      end
   },
   ["YamahaSY55FormatBulkDumpHeader"]  = {
      ["fields"] = {
	 { 10, "c", "decoder name" },
	 { 14, "c", "additional header" },
	 { 1, "b", "memory type" },
	 { 1, "b", "memory number" }
      },
      ["statefield"] = "decoder name",
      ["newstate"] = {
	 ["LM  8103SY"] = "YamahaSY55SystemBulkDump"
      }
   },
   ["YamahaSY55SystemBulkDump"] = {
      ["fields"] = {
	 {1, "b+-", "master note shift"},     -- 0-127:-64-+63
	 {1, "b+-", "master fine tuning"},    -- 0-127:-64-+63
	 {1, "b",   "velocity curve select"}, -- 0-7:1-8
	 {1, "b",   "transmit channel"},      -- 0-15:1-16
	 {1, "b",   "receive channel"},       -- 0-16:1-16:16=omni
	 {1, "b",   "local switch"},          -- 0=off:1=on
	 {1, "b",   "device number"},         -- 0=off:1-16:17=all
	 {1, "b",   "bulk protect"},          -- 0=off:1=on
	 {1, "b",   "program change mode"},   -- 0=off:1=normal:2=direct
	 {1, "b",   "effect on/off"},         -- 0=off:1=on
	 {1, "b",   "card bank select"},      -- 0=bank1:1=bank2,
	 {1, "b",   "note on/off"},           -- 0=all:1=odd:2=even
	 {4, "c",   "reserved"}
      },
      ["getstate"] = function(midi,current,data)
	 if #SY55Data["devices"] == 0
	 then
	    SY55restoreDeviceData(data)
	 end
	 SY55Data["devices"][#SY55Data["devices"]+1] = data
	 return "end"
      end
   },
   ["YamahaParameterChange"] = {
   },
   ["YamahaDumpRequest"] = {
   },
}
midiReceivedStatesCollector = {
   -- signed with zero in the middle
   ["b+-"] = function (midi, index, count)
      console("running b+-")
      local retval = 0
      local maxvalue = 1
      local i
      for i = 0, count-1 do
	 retval = retval * 0x80 + midi:byte(index+i)
	 maxvalue = maxvalue * 0x80
      end
      return retval - floor(maxvalue / 2)
   end,
   -- unsigned
   ["b"] = function (midi, index, count)
      console("running b")
      local retval = 0
      local i
      for i = 0, count-1 do
	 retval = retval * 0x80 + midi:byte(index+i)
      end
      console(string.format("result: %x",retval))
      return retval
   end,
   -- raw, 8 bit unsigned
   ["r"] = function (midi, index, count)
      console("running r")
      local retval = 0
      local i
      console(string.format("r (..., %d, %d)",index,count))
      for i = 0, count-1 do
	 retval = retval * 0x100 + midi:byte(index+i)
	 console(string.format("i = %d, count-1 = %d, result: %x", i, count-1,retval))
      end
      console(string.format("result: %x",retval))
      return retval
   end,
   -- string
   ["c"] = function (midi, index, count)
      console("running c")
      return midi:sub(index,index+count -1)
   end
}
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
   local strmidi = memoryblockToString(midi:getData())
   local state = "start"
   local index = 1
   local data = {}
   print_table(midiReceivedStates)
   while (state ~= "end")
   do
      console("state: " .. tostring(state))
      local s = midiReceivedStates[state]
      if (s == nil) then break end
      if s["fields"]
      then
	 console("s[fields]")
	 print_table(s["fields"])
	 print("before:")
	 print_table(data)
	 for i = 1, #s["fields"] do
	    value = s["fields"][i]
	    print("value:")
	    print_table(value)
	    console("setting " .. tostring(value[3]) .. " to (" .. tostring(value[1]) .. "," .. tostring(value[2]).. ")")
	    data[value[3]] = midiReceivedStatesCollector[value[2]](strmidi, index, value[1])
	    index = index + value[1]
	 end
	 print("after")
	 print_table(data)
      end
      if (s["getstate"]) then
	 if type(s["getstate"]) == "function"
	 then
	    console("state function")
	    func = s["getstate"]
	    state, index, data = func(strmidi, index, data)
	 else
	    console("state absolute name")
	    state =  s["getstate"]
	 end
      else
	 console("state field: ".. tostring(s["statefield"]))
	 print_table(data)
	 state = data[s["statefield"]]
      end
      console("state id : " .. tostring(state))
      state = (s["newstate"] and s["newstate"][state]) or state
      console("new state : " .. tostring(state))
   end
   console("state: " .. state)
end
