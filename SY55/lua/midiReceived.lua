--
-- Called when a MIDI channel property for the panel changes
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
midiVendorTable = {
   [0x42] = "Korg",
   [0x43] = "Yamaha"
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
	 ["midi type"] = 1
      },
      ["statefield"] = "midi type",
      ["newstate"] = {
	 ["0xf0"] = "sysex"
      }
   },
   ["sysex"] = {
      ["getstate"] = function (midi, current, data)
	 local vid = midi:byte(current)
	 if vid == 0x00
	 then
	    vid = 0x10000 + midi:byte(current+2) *0x100 + midi:byte(current+2)
	    current = current + 3
	 end
	 data["vid"] = vid
	 data["vendor"] = midiVendorTable[vid]
	 return vid, current, data
      end,
      ["newstate"] = {
	 [0x43] = "YamahaSysex"
      }
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
	 ["format"] = 1
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
	 ["decoder name"] = 10,
	 ["additional header"] = 14,
	 ["memory type"] = 1,
	 ["memory number"] = 1
      },
      ["statefield"] = "decoder name",
      ["newstate"] = {
	 ["LM  8103SY"] = "YamahaSY55SystemBulkDump"
      }
   },
   ["YamahaSY55SystemBulkDump"] = {
      ["fields"] = {
	 ["master note shift"]     = {1,"b+-"}, -- 0-127:-64-+63
	 ["master fine tuning"]    = {1,"b+-"}, -- 0-127:-64-+63
	 ["velocity curve select"] = {1,"b"},   -- 0-7:1-8
	 ["transmit channel"]      = {1,"b"},   -- 0-15:1-16
	 ["receive channel"]       = {1,"b"},   -- 0-16:1-16:16=omni
	 ["local switch"]          = {1,"l"},   -- 0=off:1=on
	 ["device number"]         = {1,"b"},   -- 0=off:1-16:17=all
	 ["bulk protect"]          = {1,"l"},   -- 0=off:1=on
	 ["program change mode"]   = {1,"b"},   -- 0=off:1=normal:2=direct
	 ["effect on/off"]         = {1,"l"},   -- 0=off:1=on
	 ["card bank select"]      = {1,"b"},   -- 0=bank1:1=bank2,
	 ["note on/off"]           = {1,"b"},   -- 0=all:1=odd:2=even
	 ["reserved"]              = {4,"c"}
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
   ["b+-"] = function (midi, index, count)
      local retval = 0
      local maxvalue = 1
      local i
      for i = 0, count-1 do
	 retval = retval * 0x80 + midi:byte(index+i)
	 maxvalue = maxvalue * 0x80
      end
      return retval - floor(maxvalue / 2)
   end,
   ["b"] = function (midi, index, count)
      local retval = 0
      local i
      for i = 0, count-1 do
	 retval = retval * 0x80 + midi:byte(index+i)
	 maxvalue = maxvalue * 0x80
      end
      return retval
   end,
   ["c"] = function (midi, index, count)
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
   while (state ~= "end")
   do
      local s = midiReceivedStates["state"]
      if (s["fields"])
      then
	 for key,value in ipairs(s["fields"]) do
	    data[key] = midiReceivedStatesCollector[value[2]](midi, index, value[1])
	 end
      end
      if (s["getstate"]) then
	 state = type(s["getstate"]) == "function" and s["getstate"](midi, index, data) or s["getstate"]
      else
	 state = data[s["statefield"]]
      end
      state = s["newstate"][s] or s
   end
end
