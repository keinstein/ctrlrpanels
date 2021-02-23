function createYamahaBulkDumpRequest(channel, data_format, memory_type, memory_number)
  print("createYamahaBulkDumpRequest")  
  -- return MidiMessage:createSysExMessage('hallo')
  return createYamahaSysex(0x20, -- bulk dump request
                           channel,
                           0x7a, -- format number
                           data_format..string.char(0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                                                    memory_type,
                                                    memory_number)
                           )
end
