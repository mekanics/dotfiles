-- Window sizing. Stock Hammerspoon APIs only. No spoons, no external deps.

-- Every position helper defaults to the focused window's current screen.
hs.window.animationDuration = 0

--------------------------------------------------------------------------------
-- Position helpers — unit rects {x, y, w, h} as fractions of a screen frame.
--------------------------------------------------------------------------------

local M = 0.06  -- inset for the centered sizes

local POS = {
  full        = {x = 0,       y = 0,       w = 1,     h = 1},      -- whole screen
  left        = {x = 0,       y = 0,       w = 1/2,   h = 1},      -- left half
  left13      = {x = 0,       y = 0,       w = 1/3,   h = 1},      -- left third
  left23      = {x = 0,       y = 0,       w = 2/3,   h = 1},      -- left two-thirds
  right       = {x = 1/2,     y = 0,       w = 1/2,   h = 1},      -- right half
  right13     = {x = 2/3,     y = 0,       w = 1/3,   h = 1},      -- right third
  right23     = {x = 1/3,     y = 0,       w = 2/3,   h = 1},      -- right two-thirds
  middle13    = {x = 1/3,     y = 0,       w = 1/3,   h = 1},      -- middle third
  middle23    = {x = 1/6,     y = 0,       w = 2/3,   h = 1},      -- centered two-thirds
  middle12    = {x = 1/4,     y = 0,       w = 1/2,   h = 1},      -- centered half
  top         = {x = 0,       y = 0,       w = 1,     h = 1/2},    -- top half
  bottom      = {x = 0,       y = 1/2,     w = 1,     h = 1/2},    -- bottom half
  center      = {x = M,       y = M,       w = 1-2*M, h = 1-2*M},  -- centered, 6% margin
  centerS     = {x = 3*M,     y = 3*M,     w = 1-6*M, h = 1-6*M},  -- centered, 18% margin
  centerXS    = {x = 4*M,     y = 4*M,     w = 1-8*M, h = 1-8*M},  -- centered, 24% margin
}

local function frameFor(unit, scr)
  local f = scr:frame()
  return {
    x = f.x + f.w * unit.x,
    y = f.y + f.h * unit.y,
    w = f.w * unit.w,
    h = f.h * unit.h,
  }
end

-- Move the focused window to `unit` on `scr` (defaults to its current screen).
local function move(unit, scr)
  local win = hs.window.focusedWindow()
  if not win then
    print("[hammerspoon] move: no focused window")
    return
  end
  scr = scr or win:screen()
  if not scr then
    print("[hammerspoon] move: no screen")
    return
  end
  win:setFrame(frameFor(unit, scr), 0)
end

--------------------------------------------------------------------------------
-- Chains. On press: if the window's frame ≈ one of the chain's positions,
-- advance to the next; otherwise restart at position 1. Frame-tolerant
-- compare because macOS rounds/clamps setFrame requests.
--------------------------------------------------------------------------------

local CHAIN_TOLERANCE = 4  -- px; macOS may round frames on scaled displays

local function nearly(a, b)
  return math.abs(a - b) <= CHAIN_TOLERANCE
end

local function frameMatches(f1, f2)
  return nearly(f1.x, f2.x) and nearly(f1.y, f2.y)
     and nearly(f1.w, f2.w) and nearly(f1.h, f2.h)
end

local function chain(units)
  return function()
    local win = hs.window.focusedWindow()
    if not win then return end
    local scr = win:screen()
    if not scr then return end
    local cur = win:frame()
    local nextIdx = 1
    for i, unit in ipairs(units) do
      if frameMatches(cur, frameFor(unit, scr)) then
        nextIdx = (i % #units) + 1
        break
      end
    end
    win:setFrame(frameFor(units[nextIdx], scr), 0)
  end
end

--------------------------------------------------------------------------------
-- Hotkeys — all ⌥⌘⌃ (alt+cmd+ctrl)
--------------------------------------------------------------------------------

local MODS = {"alt", "cmd", "ctrl"}

hs.hotkey.bind(MODS, "left",  chain({POS.left, POS.left13, POS.left23}))
hs.hotkey.bind(MODS, "right", chain({POS.right, POS.right13, POS.right23}))
hs.hotkey.bind(MODS, "m",     chain({POS.full, POS.middle23, POS.middle12, POS.middle13}))
hs.hotkey.bind(MODS, "n",     chain({POS.center, POS.centerS, POS.centerXS}))
hs.hotkey.bind(MODS, "up",    function() move(POS.top) end)
hs.hotkey.bind(MODS, "down",  function() move(POS.bottom) end)
