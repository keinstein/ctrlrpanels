createYamahaSysex = function(status,channel,format_number,data)
	return createSysex(0x43,
        string.char(status + channel,format_number).. data)
end