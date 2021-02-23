--
-- Called when a modulator value changes
-- @mod   http://ctrlr.org/api/class_ctrlr_modulator.html
-- @value    new numeric value of the modulator
--
midiInquiry = function(--[[ CtrlrModulator --]] mod, --[[ number --]] value, --[[ number --]] source)
  console("midiInquiry")
  for i=0,0x0f
  do
   panel:sendMidiMessageNow(createYamahaSystemBulkDumpRequest(i))
  end 
end