require "windows"
require "alacritty"

local homeNetwork = require "network"
homeNetwork.setEthernetInterface("USB 10/100/1000 LAN")
systemWatcher = hs.caffeinate.watcher.new(homeNetwork.handleWifi)
systemWatcher:start()
