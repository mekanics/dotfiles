local spaces = require("hs.spaces") -- https://github.com/asmagill/hs._asm.spaces

-- Switch alacritty
hs.hotkey.bind({'control'}, 'space', function () -- change your own hotkey combo here, available keys could be found here:https://www.hammerspoon.org/docs/hs.hotkey.html#bind
  local BUNDLE_ID = 'org.alacritty' -- more accurate to avoid mismatching on browser titles

  function getMainWindow(app)
    -- get main window from app
    local win = nil
    while win == nil do
      win = app:mainWindow()
    end
    return win
  end

  function moveWindow(alacritty, space, mainScreen)
    -- move to main space
    local win = getMainWindow(alacritty)
    
    winFrame = win:frame()
    scrFrame = mainScreen:fullFrame()
    -- winFrame.w = scrFrame.w
    -- winFrame.y = scrFrame.y
    -- winFrame.x = scrFrame.x
    -- win:setFrame(winFrame, 0)
    spaces.moveWindowToSpace(win, space)
    
    win:focus()
  end

  local alacritty = hs.application.get(BUNDLE_ID)
  if alacritty ~= nil and alacritty:isFrontmost() then
    alacritty:hide()
  else
    local space = spaces.activeSpaceOnScreen()
    local mainScreen = hs.screen.mainScreen()
    if alacritty == nil and hs.application.launchOrFocusByBundleID(BUNDLE_ID) then
      local appWatcher = nil
      appWatcher = hs.application.watcher.new(function(name, event, app)
        if event == hs.application.watcher.launched and app:bundleID() == BUNDLE_ID then
          -- getMainWindow(app):move(hs.geometry({x=0,y=0,w=1,h=1})) -- move alacritty window on top, you could set the window percentage here
          app:hide()
          moveWindow(app, space, mainScreen)
          appWatcher:stop()
        end
      end)
      appWatcher:start()
    end
    if alacritty ~= nil then
      moveWindow(alacritty, space, mainScreen)
    end
  end
end)