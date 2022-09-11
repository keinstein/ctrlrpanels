--
-- Called when a modulator value changes
-- @mod   http://ctrlr.org/api/class_ctrlr_modulator.html
-- @value    new numeric value of the modulator
--
changedPanningCombo2 = function(--[[ CtrlrModulator --]] mod, --[[ number --]] value, --[[ number --]] source)
console("changedPanningCombo")
console(tostring(mod))
console(tostring(value))
console(tostring(source))
end