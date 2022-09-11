--
-- Called when the panel has finished loading
--
-- @type the type of instance beeing started, types available in the CtrlrPanel
-- class as enum
--
-- InstanceSingle
-- InstanceMulti
-- InstanceSingleRestriced
-- InstanceSingleEngine
-- InstanceMultiEngine
-- InstanceSingleRestrictedEngine
--
panelLoaded = function(--[[ CtrlrInstance --]] type)
   sDevices = panel:getProperty("panelMidiControllerDevice")
   panel:setPropertyString("panelMidiControllerDevice", "-- None")
   panel:setPropertyString("panelMidiControllerDevice", sDevices)
   assignPanelControls()
   -- panel specific part
   mainTabChanged(nil, panelControls['mainTabs']:getProperty("uiTabsCurrentTab"))
end
