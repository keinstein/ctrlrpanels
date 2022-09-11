midiReceivedStatesConstructor = {
      -- signed with zero in the middle
   ["b+-"] = function (count, name, data)
      console("running b+-")
      local value = data[name]
      local i
      local subtract = 1
      for i = 1, count
      do
	 subtract = subtract * 80
      end
      value = value + floor(subtract/2)
      retval = {}
      for i = count,1,-1 do
	 retval[i] = string.char(value % 0x80)
	 value = floor(value / 0x80)
      end
      return string.concat(retval)
   end,
   -- unsigned
   ["b"] = function (count, name, data)
      console(string.format("running b( %d, %s, ...)",count,name))
      print_table(data)
      local value = data[name]
      local i
      retval = {}
      for i = count,1,-1 do
	 retval[i] = string.char(value % 0x80)
	 value = floor(value / 0x80)
      end
      return table.concat(retval,"")
   end,
   -- raw, 8 bit unsigned
   ["r"] = function (count, name, data)
      console(string.format("running r( %d, %s, ...)",count,name))
      print_table(data)
      local value = data[name]
      local i
      retval = {}
      for i = count,1,-1 do
	 retval[i] = string.char(value % 0x100)
	 value = floor(value / 0x100)
      end
      return table.concat(retval,"")
   end,
   -- string
   ["c"] = function (count, name, data)
      console("running c")
      local value = data["name"]:sub(1,count)
      if #value < count
      then
	 value = value .. string.rep(string.char(0),count - #value)
      end
      return value
   end
}
function constructMidi(--[[ string ]] start,
				      --[[ integer ]] index,
				      --[[ table ]] data)
   local midi = ""
   local mydata = data
   local state = start
   while (state ~= "start")
   do
      console(state)
      print_table(mydata)
      console("running function")
      local s = midiReceivedStates[state]
      if s["addfields"] ~= nil
      then
	 for key,value in pairs(s["addfields"])
	 do
	    mydata[key] = value
	 end
      end
      if type(s["construct"]) == "function"
      then
	 midi,index,mydata = s["construct"] (midi,index,mydata)
      end
      if s["fields"] ~= nil
      then
	 console("fields")
	 print_table(s["fields"])
	 bindata = {}
	 for i = 1,#s["fields"]
	 do
	    bindata[#bindata + 1] =
	    midiReceivedStatesConstructor[s["fields"][i][2]](s["fields"][i][1],
							     s["fields"][i][3],
							     mydata)
	 end
	 midi = table.concat(bindata,"") .. midi
      end
      state = s["prev"] or "start"
      print_table(mydata)
   end
   return midi, mydata
end
