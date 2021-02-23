createSysex = function(manufacturer, data)
	-- Your method code here
    return CtrlrMidiMessage(stringToMemoryBlock(string.char(0xf0,manufacturer)..data..string.char(0xf7)))
end