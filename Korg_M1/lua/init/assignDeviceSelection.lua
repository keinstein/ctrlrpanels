function assignDeviceSelection()
   console("assignDeviceSelection")
   deviceSelection = {
      manufacturer = panel:getModulatorByName("globManufacturer"):getComponent(),
      family       = panel:getModulatorByName("globFamily"):getComponent(),
      member       = panel:getModulatorByName("globFamMember"):getComponent(),
      major        = panel:getModulatorByName("globMajVersion"):getComponent(),
      minor        = panel:getModulatorByName("globMinVersion"):getComponent(),
      devId        = panel:getModulatorByName("globDevId"):getComponent(),
      devId1        = panel:getModulatorByName("globDevId1"),
      devSelection = panel:getModulatorByName("globSelDevice"):getComponent(),
      devices      = {},
   }
end

