--
-- Called when a modulator value changes
-- @mod   http://ctrlr.org/api/class_ctrlr_modulator.html
-- @value    new numeric value of the modulator
--


changeDrumsSound = function(--[[ CtrlrModulator --]] mod, --[[ number --]] value, --[[ number --]] source)
   local controls = M1['GlobalSettings']['drums']
   local show = (value > 0)
   -- crlrCBreak()
   for _,k in ipairs(controls['showonsound'])
   do
      controls[k]:setVisible(show)
   end
end
