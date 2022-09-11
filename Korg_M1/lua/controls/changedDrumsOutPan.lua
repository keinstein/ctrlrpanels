--
-- Called when a modulator value changes
-- @mod   http://ctrlr.org/api/class_ctrlr_modulator.html
-- @value    new numeric value of the modulator
--
changedDrumsOutPan = function(--[[ CtrlrModulator --]] mod, --[[ number --]] value, --[[ number --]] source)
   console("changedDrumsOutPan")
   if M1["states"]["drumsOutPan"] ~= value
   then
      if (value < 11)
      then
	 M1["GlobalSettings"]["drums"]["panning"]:setEnabled(true);
	 M1["GlobalSettings"]["drums"]["panning"]:setValue(value, false);
	 M1["GlobalSettings"]["drums"]["output"]:setValue(0, false);
      else
	 M1["GlobalSettings"]["drums"]["panning"]:setEnabled(false);
	 M1["GlobalSettings"]["drums"]["output"]:setValue(value - 10, false);
      end
      console(tostring(mod))
      console(tostring(value))
      console(tostring(source))
   end
end
