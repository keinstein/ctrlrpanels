   
function assignGlobalSettings()
   console("assignGlobalSettings")
   if (deviceSelection == nil)
   then
      assignDeviceSelection()
   end
   if M1 == nil
   then M1 = {}
   end
   console("initialize M1")
   M1["GlobalSettings"] = {
      setVisible = setVisibleHashmap,
      setEnabled = setEnabledHashmap,
      ["inquiry button"] = panel:getButton("globalInquiryButton"),
      bank = panel:getListBox("globalBank"),
      pedal1 = panel:getListBox("global1Pedal"),
      pedal2 = panel:getListBox("global2Pedal"),
      damper = panel:getListBox("globalDamperPolarity"),
      scale = {
	 setVisible = setVisibleHashmap,
	 setEnabled = setEnabledHashmap,
	 type = panel:getListBox("globalScaleType"),
	 key = panel:getCombo("globalPureTypeKey"),
	 keyboard = panel:getModulator("globalKbdPureTypeKey"),
	 [0] = panel:getSlider("globalCUserScale"):getOwnedSlider(),
	 [1] = panel:getSlider("globalCisUserScale"):getOwnedSlider(),
	 [2] = panel:getSlider("globalDUserScale"):getOwnedSlider(),
	 [3] = panel:getSlider("globalDisUserScale"):getOwnedSlider(),
	 [4] = panel:getSlider("globalEUserScale"):getOwnedSlider(),
	 [5] = panel:getSlider("globalFUserScale"):getOwnedSlider(),
	 [6] = panel:getSlider("globalFisUserScale"):getOwnedSlider(),
	 [7] = panel:getSlider("globalGUserScale"):getOwnedSlider(),
	 [8] = panel:getSlider("globalGisUserScale"):getOwnedSlider(),
	 [9] = panel:getSlider("globalAUserScale"):getOwnedSlider(),
	 [10] = panel:getSlider("globalAisUserScale"):getOwnedSlider(),
	 [11] = panel:getSlider("globalHUserScale"):getOwnedSlider(),
      },
      drums = {
	 setVisible = setVisibleHashmap,
	 setEnabled = setEnabledHashmap,
	 kit = panel:getListBox("drumsKit"),
	 instrument = panel:getListBox("drumsInstrument"),
	 sound = panel:getCombo("drumsSound"),
	 outputpan = panel:getFixedSlider("drumsOutPan"),
	 panning = panel:getFixedSlider("drumsPan"),
	 output =  panel:getListBox("drumsOutput"),
	 key = panel:getFixedSlider("drumsKey"),
	 keyboard = panel:getModulator("drumsKbdKey"), -- uiMidiKeyboard getComponent ?
	 tune = panel:getSlider("drumsTune"),
	 level = panel:getSlider("drumsLevel"),
	 decay = panel:getSlider("drumsDecay"),
	 showonsound = {'key',--[[ 'keyboard', --]] 'outputpan', 'panning',
			 'output', 'level', 'decay', 'tune'}
      }
   }
   console("status")
   -- print(M1["GlobalSettings"]["scale"]["key"])
   -- print(""..M1["GlobalSettings"]["scale"]["key"]:getText())
   -- print(M1["GlobalSettings"]["scale"]["key"]:getValueMap())
   local tmpoutput = M1["GlobalSettings"]["drums"]["output"]
   print(tmpoutput)
   -- print_table(tmpoutput)
   
   local tmp = getmetatable( tmpoutput )
   print (tmp)
   print("Value:")
   print(tmpoutput:getValue())
   print("done")
   -- print_table(tmp)


   
   console("setting pure keys")
   panel:getModulatorByName("globalPureTypeKey")
      :getComponent()
      :setProperty("uiComboContent",
		   table.concat(ctrlr_common["Note names"],
				"\n"),
		   false)
   console("collecting drum keys")
   local collector,octave,key
   collector = {}
   for octave=-1,9 do
      console("octave " .. tostring(octave))
      for _,key in pairs(ctrlr_common["Note names"]) do
	 console("key " .. key)
	 console("#collector " .. tostring(#collector))
	 if #collector > 127 then break end
	 collector[#collector+1] = key .. " " .. tostring(octave)
      end
   end
   console("setting drum keys")
   M1['key names'] = collector
   panel:getModulatorByName("drumsKey")
      :getComponent()
      :setProperty("uiFixedSliderContent",
		   table.concat(collector,
				"\n"),
		   false)
   panel:getModulatorByName("drumsSound")
      :getComponent()
      :setProperty("uiComboContent",
		   "Off\n" .. table.concat(M1["Drum sounds"],
				"\n"),
		   false)
   -- panel:getModulatorByName():getComponent():setProperty("uiFixedSliderContent",table.concat(collector,"\n"))
   -- ctrlrCBreak()
   M1["GlobalSettings"]:setVisible(false)
   M1["GlobalSettings"]:setEnabled(false)
end

