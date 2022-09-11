ctrlr_common = {
   ["Note names"] = {
      "C",
      "C#/Db",
      "D",
      "D#/Eb",
      "E",
      "F",
      "F#/Gb",
      "G",
      "G#/Ab",
      "A",
      "A#/Bb/B",
      "B/H"
   },
}
M1 = {
   ["Drum sounds"] = {
      "Kick 1",
      "Kick 2",
      "Kick 3",
      "Snare 1",
      "Snare 2",
      "Snare 3",
      "Snare 4",
      "Side Stick",
      "Tom 1",
      "Tom 2",
      "Closed HH1",
      "Open HH1",
      "Closed HH2",
      "OpenHH2",
      "Crash",
      "Conga 1",
      "Conga 2",
      "Timbales 1",
      "Timbales 2",
      "Cowbell",
      "Claps",
      "Tambourine",
      "E. Tom",
      "Ride",
      "Rap",
      "Whip",
      "Shaker",
      "Pole",
      "Block",
      "Finger Snap",
      "Drop",
      "Vibe Hit",
      "Hammer",
      "Metal Hit",
      "Pluck",
      "Flexa Tone",
      "Wind Bell",
      "Tubular 1",
      "Tubular 2",
      "Tubular 3",
      "Tubular 4",
      "Bell Ring",
      "Metronome 1",
      "Metronome 2",
      "Pro BD",
      "Tight BD",
      "Punch BD",
      "Synth BD",
      "Pro SD 1",
      "Pro SD 2",
      "Tight SD",
      "Ambient SD",
      "Synth SD",
      "Rim Shot",
      "Stick Hit",
      "Ambinent Tom",
      "Closed HH3",
      "Open HH3",
      "Pedal HH",
      "Clang Hit",
      "Bell Ride",
      "Ping Ride",
      "Bongo Low",
      "Bongo High",
      "Bongo Slap",
      "Claps 2",
      "Maracas 1",
      "Maracas 2",
      "Cabasa",
      "Block 2",
      "Bell Hit",
      "Techno Zap",
      "Marimba",
      "Gamelan 1",
      "Gamelan 2",
      "Potcover",
      "Cymbell",
      "Timpani",
      "Clicker 1",
      "Clicker 2",
      "Spectrum 4L",
      "Spectrum 4H",
      "Noise",
      "Perc. WaveL",
      "Perc. WaveH",
   },
   states = {}
}

function ctrlrClassOf(o)
   return tostring(o)
end

function CtrlrModulator:setVisible(show)
   print("CtrlrModulator:setVisible(show)")
   print(show)
   self:getComponent():setVisible(show)
end
function CtrlrModulator:setEnabled(show)
   print("CtrlrModulator:setEnabled(show)")
   print(show)
   self:getComponent():setEnabled(show)
end

-- is used to iterate over a hashmap of controlos to set visibility
-- This function copied to the hashmap value "setVisible"
function setVisibleHashmap(me --[[ hash map / array ]], show --[[ shall the controls be shown]] )
   print("setVisibleHashmap")
   print_table(me)
   print(show)
   for k,v in pairs(me)
   do
      print(k)
      print(v)
      if not (type(v) == "function") then
	 print (ctrlrClassOf(v))
	 if type(v) == "table" then
	    print_table(v)
	 end
	 print(k)
	 -- ctrlrCBreak()
	 if v["setVisible"] ~= nil then
	    v:setVisible(show)
	 end
      end
   end
   print("setVisibleHashmap end")
end

-- is used to iterate over a hashmap of controlos to set visibility
-- This function copied to the hashmap value "setVisible"
function setEnabledHashmap(me --[[ hash map / array ]], show --[[ shall the controls be shown]] )
   print("setEnabledHashmap")
   print_table(me)
   print(show)
   for k,v in pairs(me)
   do
      print(k)
      print(v)
      if not (type(v) == "function") then
	 print (ctrlrClassOf(v))
	 if type(v) == "table" then
	    print_table(v)
	 end
	 print(k)
	 -- ctrlrCBreak()
	 if v["setEnabled"] ~= nil then
	    v:setEnabled(show)
	 end
      end
   end
   print("setEnabledHashmap end")
end

globals = true
