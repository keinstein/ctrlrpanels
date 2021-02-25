--
-- Called when a panel receives a midi message (does not need to match any modulator mask)
-- @midi   CtrlrMidiMessage object
--

local midiReceivedSwitch
midiReceived = function(--[[ CtrlrMidiMessage --]] midi)
    print("midiReceived")
    midiReceivedSwitch = midiReceivedSwitch or {
      [0xf0] = sysExReceived,
    }
    local f =  midiReceivedSwitch[midi:getData():getByte(0)]
    -- type(t[v]) == "function" and t[v]() or t[v] or "blah"
    f2 = type(f) == "function" and f(midi) or ignoredMidiReceived(midi)
end