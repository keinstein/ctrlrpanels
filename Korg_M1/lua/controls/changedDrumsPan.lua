--
-- Called when a modulator value changes
-- @mod   http://ctrlr.org/api/class_ctrlr_modulator.html
-- @value    new numeric value of the modulator
--
changedDrumsPan = function(--[[ CtrlrModulator --]] mod, --[[ number --]] value, --[[ number --]] source)
   console("changedDrumsPan")
   M1["GlobalSettings"]["drums"]["outputpan"]:setValue(value+10, true)
end
