function midiSend(--[[ string ]] start,--[[ integer ]] index,  --[[ table ]] data)
   local midi, mydata, myindex
   midi, mydata, myindex = constructMidi (start, index, data)
   print (midi)
   local block = stringToMemoryBlock(midi)
   console(block:toHexString(1))
   local msg = CtrlrMidiMessage(block)
   panel:sendMidiMessageNow(msg)
end
