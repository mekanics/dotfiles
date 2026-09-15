local M = {}
local ethernetInterface

local function isEthernetConnected()
    ipv4 = hs.network.primaryInterfaces()
    activeInterfaceName = hs.network.interfaceName(ipv4)

    return activeInterfaceName == ethernetInterface
end

local function toggleWifi()
    desiredState = not isEthernetConnected() and true or false

    if hs.wifi.interfaceDetails()['power'] ~= desiredState then
        hs.wifi.setPower(desiredState)

        newState = desiredState and "on" or "off"
        -- hs.alert.show("Turning wifi " .. newState)
    else
        -- hs.alert.show("Wifi already in the desired state")
    end
end

function M.setEthernetInterface(ethernetInterfaceName)
    ethernetInterface = ethernetInterfaceName
end

function M.handleWifi(event)
    if event == hs.caffeinate.watcher.systemDidWake then
        toggleWifi()
    elseif event == hs.caffeinate.watcher.screensDidUnlock then
        toggleWifi()
    end
end

return M