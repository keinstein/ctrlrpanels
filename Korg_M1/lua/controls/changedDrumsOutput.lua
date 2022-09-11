--
-- Called when a modulator value changes
-- @mod   http://ctrlr.org/api/class_ctrlr_modulator.html
-- @value    new numeric value of the modulator
--
changedDrumsOutput = function(--[[ CtrlrModulator --]] mod, --[[ number --]] value, --[[ number --]] source)
   console("changedDrumsOutput")
   if (value > 0) then
      console(tostring(M1["GlobalSettings"]["drums"]["outputpan"]:getValue()))
      M1["GlobalSettings"]["drums"]["outputpan"]:setValue(value+10, true)
   else
      M1["GlobalSettings"]["drums"]["outputpan"]
	 :setValue(M1["GlobalSettings"]["drums"]["panning"]:getValue(),
		   true)
   end
end
