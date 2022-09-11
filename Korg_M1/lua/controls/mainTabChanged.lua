--
-- Called when the current tab in an uiTabs component is changed
--

mainTabChanged = function(--[[ CtrlrModulator --]] mod, --[[ number --]] tabIndex)
   local doInit = {
      [4] = function ()
	 if M1["GlobalSettings"] == nil then
	    assignGlobalSettings()
	 end
	 if not M1["globalData"] then
	 end
   end  
   }
   if (type(doInit[tabIndex]) == "function")
   then doInit[tabIndex]() end
end
