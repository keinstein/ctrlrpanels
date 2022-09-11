
local midiInquirySwitch
function midiInquiryMessageReceived(midi)
	-- Your method code here
  print("MidiInquiryMessageReceived()")
   midiInquirySwitch = midiInquirySwitch or {
       -- [0x01] = midiInquiryRequest,
    [0x02] = midiInquiryAnswerReceived
  }
  local f =  midiInquirySwitch[midi:getData():getByte(4)]
  -- type(t[v]) == "function" and t[v]() or t[v] or "blah"
  f2 = type(f) == "function" and f(midi) or ignoredMidiReceived(midi)
 
end