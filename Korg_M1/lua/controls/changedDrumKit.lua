--
-- Called when a modulator value changes
-- @mod   http://ctrlr.org/api/class_ctrlr_modulator.html
-- @value    new numeric value of the modulator
--
changedDrumKit = function(--[[ CtrlrModulator --]] mod, --[[ number --]] value, --[[ number --]] source)
   console('mod ' .. tostring(mod) .. ', value ' .. tostring(value) .. ', source ' .. tostring(source))
   if not M1['globalData'] or not M1['globalData']['drum kits'] then return end
   -- print_table(M1)
   local drum_kit = M1['globalData']['drum kits'][value+1];
   local controls = M1['GlobalSettings']['drums']
   local soundNames = M1['Drum sounds']
   local keys = M1['key names']
   

   print("drum_kit\n")
   print_table(drum_kit)

   print("keys\n")
   print_table(keys)
   
   instrumentList = {}
   local k, v, s
   for k = 0,29 do
      v = drum_kit['instrument'][k]
      print('v')
      print_table(v)
      print('k = ' .. tostring(k))
      instrumentList[ #instrumentList+1] = tostring(k) .. '  ' .. ((v['key'] and keys[v['key']]) or '???') .. ' ' ..
	 ((v['sound'] and soundNames[v['sound']]) or '<empty>')
   end
   -- controls['instrument'] -- CtrlrListBox
   print_table(instrumentList)
   controls['instrument']:setProperty("uiListBoxContent",
				      table.concat(instrumentList,"\n"),
				      false)
end
