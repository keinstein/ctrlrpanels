--
-- Called when a modulator value changes
-- @mod   http://ctrlr.org/api/class_ctrlr_modulator.html
-- @value    new numeric value of the modulator
--
changedDrumsIstrument = function(--[[ CtrlrModulator --]] mod, --[[ number --]] value, --[[ number --]] source)
   if not M1['globalData'] or not M1['globalData']['drum kits'] then return end
   local controls = M1['GlobalSettings']['drums']
   local kit = controls['kit']:getSelectedRow(0)+1
   local drum_kits = M1['globalData']['drum kits']
   if not drum_kits
   then
      changedDrumKit(nil, kit-1, nil)
      drum_kits = M1['globalData']['drum kits']
   end
   local drum_kit = drum_kits[kit]
   print_table(drum_kit)
   local instrument = drum_kit['instrument'][value]
   print_table(instrument)
   print_table(controls)

   controls['sound']:setSelectedItemIndex(instrument['sound'], false)
   controls['key']:setValue(instrument['key'],
			    true)
   controls['outputpan']:setValue(instrument['pan'],
				  true)

   controls['level']:setValue(instrument['level'],
			      true)
   controls['decay']:setValue(instrument['decay'],
			      true)
   controls['tune']:setValue(instrument['tune'],
			     true)
   changeDrumsSound(nil, instrument['sound'], nil)
end
