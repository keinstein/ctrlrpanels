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
            ["stringrep"] = function(data) return string.format("Korg M1, Id %d",data['devId']) end
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
	 return bit.band(midi:byte(current), 0xf0), current, data
      end,
      ["newstate"] = {
	 [0xf0] = "sys",
      }
   },
   ["end"] = {},
   ["byte"] = {
      ["fields"] = {
	 {1,"r","value"}
      },
   },
   ["sys"] = {
      ["fields"] = {
	 {1,"r","midi type"}
      },
      ["statefield"] = "midi type",
      ["newstate"] = {
	 [0xf0] = "sysex"
      },
      ["prev"] = "start"
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
	 -- console(string.format("vid = %x",vid))
	 data["vid"] = vid
	 data["vendor"] = (ManufacturerTable[vid] and ManufacturerTable[vid]["name"]) or string.format("%x",vid)
	 -- console(string.format("vendor = %s",data["vendor"]))
	 return vid, current, data
      end,
      ["construct"] = function (midi, current, data)
	 local newmidi = string.char(data["vid"]) .. midi .. string.char(0xf7)
	 return newmidi, current, data
      end,
      ["newstate"] = {
	 [0x42] = "Korg Sysex",
	 [0x43] = "YamahaSysex",
	 [0x7e] = "unrt sysex",
	 [0x7f] = "urt sysex",
      },
      ["addfields"] = {
	 ["midi type"] = 0xf0
      },
      ["prev"] = "sys"
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
      },
      ["addfields"] = {
	 vid = 0x7e,
      },
      ["prev"] = "sysex"
   },
   ["unrt device inquiry request"] = {
      ["addfields"] = {
	 subId = 0x0601
      },
      ["prev"] = "unrt sysex"
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
	 -- print_table(ManufacturerTable)
	 -- print(data["unrt vid"])
	 local fam = ManufacturerTable[data["unrt vid"]]["families"][data["family"]]
	 -- print_table(fam)
	 if not fam then return "end", current, data end
	 -- data["family name"] = fam["name"] or string.format("%04x",data["family"])
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
	    string.format("%s %s %s, Id:%d",
			  data["unrt vendor"],
			  data["family name"],
			  data["member"],
			  data["devId"])
	 -- print_table(data)
	 midiInquiryAnswerReceived(midi, data)
	 return "end",current,data
      end,
      ["newstate"] = {
	 [0x42] = "korg device inquiry data",
      }
   },
   ["urt sysex"] = {
   },
   ["Korg Sysex"] = {
      ["getstate"] = function (midi, current, data)
	 data["devId"] = midi:byte(current) % 0x10
	 data["format"] = floor(midi:byte(current) / 0x10)
	 return data["format"], current + 1, data
      end,
      ["construct"] = function (midi, current, data)
	 local newmidi = string.char(data["format"] + data["channel"]) .. midi
	 return newmidi, current, data
      end,
      newstate = {
	 [0x3] = "Korg format 3 sysex"
      },
      addfields = {
	 vid = 0x42
      },
      prev = "sysex"
   },
   ["Korg format 3 sysex"] = {
      fields = {
	 { 1, "b", "modelId" }
      },
      addfields = {
	 format = 0x30
      },
      statefield = "modelId",
      newstate = {
	 [0x19] = "Korg M1 Sysex"
      },
      prev = "Korg Sysex"
   },
   ["Korg M1 Sysex"] =  {
      fields = {
	 { 1, "b", "function" }
      },
      addfields = {
	 modelId = 0x19
      },
      statefield = "function",
      newstate = {
	 [0x0e] = "Korg M1 global data dump request",
	 [0x26] = "Korg M1 midi in data format error",
	 [0x51] = "Korg M1 global data dump"
      },
      prev = "Korg format 3 sysex"
   },
   ["Korg M1 global data dump request"] = {
      fields = {
	 { 1, "b", "bank" }
      },
      ["addfields"] = {
	 ["function"] = 0x0e
      },
      ["prev"] = "Korg M1 Sysex"
   },
   ["Korg M1 midi in data format error"] = {
      ["addfields"] = {
	 ["function"] = 0x26
      },
      getstate = function (midi, current, data)
	 utils.warnWindow("Data transfer error.",
			  string.format("The data transferred to Korg M1 with dev Id %d was not recognised.",data["devId"]))
	 return "end", current, data
      end,
      newstate = {},
      ["prev"] = "Korg M1 Sysex"
   },
   ["Korg M1 global data dump"] = {
      fields = {
	 { 1, "b", "bank" },
	 { 1, "b", "global 8th bits" },
	 { 1, "b", "master tune" },
	 { 1, "b", "key transpose" },
	 { 1, "b", "damper polarity" },
	 { 1, "b", "assignable pedal 1" },
	 { 1, "b", "assignable pedal 2" },
	 { 1, "b", "scale type" },
	 { 1, "b", "pure type key" },
      },
      substates = {
	 {
	    name = "byte",
	    counter = "user scale bit8",
	    first = 1,
	    last = 1,
	    variable = "user scale bit 8"
	 },
	 {
	    name = "byte",
	    counter = "user scale entry",
	    first = 1,
	    last = 7,
	    variable = "user scale"
	 },
	 {
	    name = "byte",
	    counter = "user scale bit8",
	    first = 2,
	    last = 2,
	    variable = "user scale bit 8"
	 },
	 {
	    name = "byte",
	    counter = "user scale entry",
	    first = 8,
	    last = 12,
	    variable = "user scale"
	 },
	 {
	    name = "byte",
	    counter = "ignored byte",
	    first = 1,
	    last = 2,
	    variable = "ignored values"
	 },
	 {
	    name = "Korg M1 drum kit",
	    counter = "drum kit",
	    first = 1,
	    last = 4,
	    variable = "drum kits"
	 }
      },
      mappings = {
	 ["damper polarity"] = {
	    [0] = "‾|_",
	    [1] = "_|‾"
	 },
	 ["assignable pedal 1"] = {
	    [0] = "+ Program/Combiniation",
	    [1] = "− Program/Combination",
	    [2] = "Sequencer Start/Stop",
	    [3] = "Effect Switch 1",
	    [4] = "Effect Switch 2",
	    [5] = "Volume",
	    [6] = "VDF Cutoff",
	    [7] = "Effect Control 1",
	    [8] = "Effect Control 2",
	    [9] = "Edit Slider"
	 },
	 ["assignable pedal 2"] = {
	    [0] = "+ Program/Combiniation",
	    [1] = "− Program/Combination",
	    [2] = "Sequencer Start/Stop",
	    [3] = "Effect Switch 1",
	    [4] = "Effect Switch 2",
	    [5] = "Volume",
	    [6] = "VDF Cutoff",
	    [7] = "Effect Control 1",
	    [8] = "Effect Control 2",
	    [9] = "Edit Slider"
	 },
	 ["scale type"] = {
	    [0] = "Equal",
	    [1] = "Random",
	    [2] = "Pure Major",
	    [3] = "Pure Minor",
	    [4] = "User Program"
	 },
	 ["pure type key"] = {
	    [0] = "C",
	    [1] = "C#/D♭",
	    [2] = "D"
	 }
      },
      getstate = function (midi, current, data)
	 local bits = data["global 8th bits"]
	 local bit = bits % 2
	 bits = floor(bits /2)
	 console(string.format("bits %x, bit %d", bits,bit))
	 if bit > 0 then
	    data["master tune"] = data["master tune"] - 0x80
	 end
	 bit = bits % 2
	 bits = floor(bits /2)
	 if bit > 0 then
	    data["key transpose"] = data["key transpose"] - 0x80
	 end
	 bit = bits % 2
	 bits = floor(bits /2)
	 if bit > 0 then
	    data["decay"] = data["decay"] - 0x80
	 end
	 local i,j,step = 0,0,0
	 console(tostring(step))
	 for i = 1,2
	 do
	    console(tostring(step))
	    bits = data['user scale bit 8'][i]['value']
	    for j = 1, 7
	    do
	       console(tostring(step))
	       step = step + 1
	       bit = bits % 2
	       bits = floor(bits / 2)
	       console(string.format("bits %x, bit %d", bits,bit))
	       if data['user scale'][step] ~= nil and
		  bit > 0
	       then
		  data['user scale'][step]['value'] = data['user scale'][step]['value'] - 0x80
	       end
	    end
	 end
	 M1globalDataReceived(midi, data)
	 return "end", current, data
      end,
      addfields = {
	 ["function"] = 0x51
      },
      prev = "Korg M1 Sysex"
   },
   ["Korg M1 drum kit"] = {
      substates = {
	 {
	    name = "Korg M1 drum instrument",
	    counter = "instrument",
	    first = 0,
	    last = 29,
	    variable = "instrument"
	 },
      },
   },
   ["Korg M1 drum instrument"] = {
      fields = {
	 { 1, "b", "bit 8" },
	 { 1, "b", "sound" },
	 { 1, "b", "key" },
	 { 1, "b", "pan" },
	 { 1, "b", "tune" },
	 { 1, "b", "level" },
	 { 1, "b", "decay" },
	 { 1, "b", "ignore" },
      },
      getstate = function (midi, current, data)
	 local bits = floor(data["bit 8"]/0x08)
	 local bit = bits % 2
	 bits = floor(bits /2)
	 if bit > 0 then
	    data["tune"] = data["tune"] - 0x80
	 end
	 bit = bits % 2
	 bits = floor(bits /2)
	 if bit > 0 then
	    data["level"] = data["level"] - 0x80
	 end
	 bit = bits % 2
	 bits = floor(bits /2)
	 if bit > 0 then
	    data["decay"] = data["decay"] - 0x80
	 end
	 return "end", current, data
      end
   },
   ["YamahaSysex"] = {
      ["getstate"] = function (midi, current, data)
	 data["devId"] = midi:byte(current) % 0x10
	 return midi:byte(floor(current)) / 0x10, current + 1, data
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
	    -- console("Yamaha SY55 dump message –– checksum failed")
	    return "end",current,data
	 else
	    -- console("Yamaha SY55 dump message –– checksum OK.")
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
      -- console("running b+-")
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
      -- console("running b")
      local retval = 0
      local i
      for i = 0, count-1 do
	 retval = retval * 0x80 + midi:byte(index+i)
      end
      -- console(string.format("result: %x",retval))
      return retval
   end,
   -- raw, 8 bit unsigned
   ["r"] = function (midi, index, count)
      -- console("running r")
      local retval = 0
      local i
      -- console(string.format("r (..., %d, %d)",index,count))
      for i = 0, count-1 do
	 retval = retval * 0x100 + midi:byte(index+i)
	 -- console(string.format("i = %d, count-1 = %d, result: %x", i, count-1,retval))
      end
      -- console(string.format("result: %x",retval))
      return retval
   end,
   -- string
   ["c"] = function (midi, index, count)
      -- console("running c")
      return midi:sub(index,index+count -1)
   end
}

midiReceivedStateMachine = function(--[[ string ]] state,
						   --[[ string ]] midi,
						   --[[ integer ]] index,
						   --[[ table ]] data)
   -- print_table(midiReceivedStates)
   local i,j,substate, subdata, key, value
   while (state ~= "end")
   do
      console("state: " .. tostring(state))
      local s = midiReceivedStates[state]
      if (s == nil) then break end
      if s["fields"]
      then
	 -- console("s[fields]")
	 -- print_table(s["fields"])
	 -- print("before:")
	 -- print_table(data)
	 for i = 1, #s["fields"] do
	    value = s["fields"][i]
	    -- print("value:")
	    -- print_table(value)
	    -- console("setting " .. tostring(value[3]) .. " to (" .. tostring(value[1]) .. "," .. tostring(value[2]).. ")")
	    data[value[3]] = midiReceivedStatesCollector[value[2]](midi, index, value[1])
	    index = index + value[1]
	 end
	 -- print("after")
	 -- print_table(data)
      end
      if s["substates"] then
	 for i = 1,#s["substates"]
	 do
	    substate = s["substates"][i]
	    if data[substate["variable"]] == nil
	    then
	       data[substate["variable"]] = {}
	    end
	    if substate["counter"]
	    then
	       for j = substate["first"],substate["last"]
	       do
		  subdata = {
		     [substate["counter"]] = j
		  }
		  index,subdata = midiReceivedStateMachine(substate["name"],midi,index,subdata)
		  data[substate["variable"]][j] = subdata
	       end
	    else
	       index,data = midiReceivedStateMachine(substate["name"],midi,index,data)
	    end
	 end
      end
      if (s["mappings"]) then
	 for key, value in ipairs(s["mappings"]) do
	    data[key] = value[data[key]] or data[key]
	 end
      end
      if (s["getstate"]) then
	 if type(s["getstate"]) == "function"
	 then
	    -- console("state function")
	    func = s["getstate"]
	    state, index, data = func(midi, index, data)
	    console("after getstate" .. tostring(state));
	    console(tostring(state));
	    console(tostring(data));
	 else
	    -- console("state absolute name")
	    state =  s["getstate"]
	 end
      else
	 -- console("state field: ".. tostring(s["statefield"]))
	 state = data[s["statefield"]]
      end
      -- console("state id : " .. tostring(state))
      state = (s["newstate"] and s["newstate"][state]) or state
      -- console("new state : " .. tostring(state))
   end
   -- print_table(data)
   console(string.format("processed %d from %d bytes",index,#midi))
   return index,data
end
midiReceived = function(--[[ CtrlrMidiMessage --]] midi)
   console("midiReceived: ".. midi:getData():getByte(0))
   -- console("full text: ".. midi:getData():toString())
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
   midiReceivedStateMachine("start",
			    memoryBlockToString(midi:getData()),
			    1,
			    {}
   )
end
