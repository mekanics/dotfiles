-- Window sizing — port of Alex's .slate config (jigish/slate). 1:1 behavior parity.
-- Sections are annotated with the slate aliases they replace (`-- ${alias}`),
-- so behavior can be diffed line-by-line against the original .slate.
-- Stock Hammerspoon APIs only. No spoons, no external deps.

-- slate: config defaultToCurrentScreen true
--   → every position helper defaults to the focused window's current screen.
hs.window.animationDuration = 0  -- slate moves are instant

--------------------------------------------------------------------------------
-- Monitor aliases (resolved lazily — screens hot-plug)
--------------------------------------------------------------------------------

-- ${mon-mbp} = internal 2880x1800. Key on name first ("Built-in"), resolution fallback.
-- (Scaled MBP resolutions may not report exactly 2880x1800, so name wins.)
local function monMbp()
  for _, s in ipairs(hs.screen.allScreens()) do
    local n = s:name() or ""
    if n:find("Built%-in") then return s end
  end
  return hs.screen.find('2880x1800')  -- resolution fallback, like slate's alias
end

-- ${mon-ext} = external 2560x1440. Resolution first (slate semantics),
-- fallback: the single non-internal screen when exactly 2 are attached.
local function monExt()
  local s = hs.screen.find('2560x1440')
  if s then return s end
  local all = hs.screen.allScreens()
  if #all == 2 then
    local mbp = monMbp()
    for _, scr in ipairs(all) do
      if mbp == nil or scr:id() ~= mbp:id() then return scr end
    end
  end
  return hs.screen.primaryScreen()
end

--------------------------------------------------------------------------------
-- Position helpers — slate aliases computed from a screen's frame.
-- cf is a unit-rect table {x, y, w, h} in fractions of the screen frame,
-- exactly the arithmetic from the .slate aliases.
--------------------------------------------------------------------------------

-- slate: alias centerMargin 0.06
local M = 0.06

local POS = {
  full        = {x = 0,       y = 0,       w = 1,     h = 1},      -- ${full}
  left        = {x = 0,       y = 0,       w = 1/2,   h = 1},      -- ${left}
  left13      = {x = 0,       y = 0,       w = 1/3,   h = 1},      -- ${left-1/3}
  left23      = {x = 0,       y = 0,       w = 2/3,   h = 1},      -- ${left-2/3}
  right       = {x = 1/2,     y = 0,       w = 1/2,   h = 1},      -- ${right}
  right13     = {x = 2/3,     y = 0,       w = 1/3,   h = 1},      -- ${right-1/3}
  right23     = {x = 1/3,     y = 0,       w = 2/3,   h = 1},      -- ${right-2/3}
  middle13    = {x = 1/3,     y = 0,       w = 1/3,   h = 1},      -- ${middle-1/3}
  middle23    = {x = 1/6,     y = 0,       w = 2/3,   h = 1},      -- ${middle-2/3}
  middle12    = {x = 1/4,     y = 0,       w = 1/2,   h = 1},      -- ${middle-1/2}
  top         = {x = 0,       y = 0,       w = 1,     h = 1/2},    -- ${top}
  bottom      = {x = 0,       y = 1/2,     w = 1,     h = 1/2},    -- ${bottom}
  center      = {x = M,       y = M,       w = 1-2*M, h = 1-2*M},  -- ${center}
  centerS     = {x = 3*M,     y = 3*M,     w = 1-6*M, h = 1-6*M},  -- ${center-s}
  centerXS    = {x = 4*M,     y = 4*M,     w = 1-8*M, h = 1-8*M},  -- ${center-xs}
}

-- slate: move x;y w;h [screen]  →  frame = screenFrame * unitRect
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
  scr = scr or win:screen()          -- defaultToCurrentScreen
  if not scr then
    print("[hammerspoon] move: no screen")
    return
  end
  win:setFrame(frameFor(unit, scr), 0)
end

--------------------------------------------------------------------------------
-- Chains — slate `chain a | b | c` semantics.
-- On press: if the window's frame ≈ one of the chain's positions, advance to
-- the next; otherwise restart at position 1. Frame-tolerant compare because
-- macOS rounds/clamps setFrame requests.
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
    local scr = win:screen()         -- chains target the current screen
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
-- Hotkeys — all ⌥⌘⌃ (alt+cmd+ctrl), exact .slate binds
--------------------------------------------------------------------------------

local MODS = {"alt", "cmd", "ctrl"}

-- bind left:alt;cmd;ctrl  chain ${left} | ${left-1/3} | ${left-2/3}
hs.hotkey.bind(MODS, "left",  chain({POS.left, POS.left13, POS.left23}))
-- bind right:alt;cmd;ctrl chain ${right} | ${right-1/3} | ${right-2/3}
hs.hotkey.bind(MODS, "right", chain({POS.right, POS.right13, POS.right23}))
-- bind m:alt;cmd;ctrl     chain ${full} | ${middle-2/3} | ${middle-1/2} | ${middle-1/3}
hs.hotkey.bind(MODS, "m",     chain({POS.full, POS.middle23, POS.middle12, POS.middle13}))
-- bind n:alt;cmd;ctrl     chain ${center} | ${center-s} | ${center-xs}
hs.hotkey.bind(MODS, "n",     chain({POS.center, POS.centerS, POS.centerXS}))
-- bind up:alt;cmd;ctrl    ${top}
hs.hotkey.bind(MODS, "up",    function() move(POS.top) end)
-- bind down:alt;cmd;ctrl  ${bottom}
hs.hotkey.bind(MODS, "down",  function() move(POS.bottom) end)

--------------------------------------------------------------------------------
-- Layouts — slate `layout` + `default` (auto by monitor config), via hs.layout.
-- App matching is by exact app name (as slate did). Check real names with
--   hs.application:name()  (e.g. in the Hammerspoon console)
-- and adjust here if a name differs on this machine.
--------------------------------------------------------------------------------

local function unit(u)  -- hs.layout wants hs.geometry unit rects
  return hs.geometry.rect(u.x, u.y, u.w, u.h)
end

-- slate: layout 1monitor 'Mail' ${mbp-full}
--                       'Terminal' ${mbp-right}  /  'Screen Sharing' ${mbp-full}
local function layout1monitor()
  local mbp = monMbp()
  if not mbp then
    print("[hammerspoon] layout 1monitor: internal screen not found, skipping")
    return nil
  end
  return {
    {"Mail",           nil, mbp, unit(POS.full),  nil, nil},
    {"Terminal",       nil, mbp, unit(POS.right), nil, nil},
    {"Screen Sharing", nil, mbp, unit(POS.full),  nil, nil},
  }
end

-- slate: layout 2monitor 'Mail' ${mbp-full}
--                       'Terminal' ${ext-left}  /  'Screen Sharing' ${ext-full}
--                       'Reminders' ${ext-right}
local function layout2monitor()
  local mbp, ext = monMbp(), monExt()
  if not mbp or not ext then
    print("[hammerspoon] layout 2monitor: a screen is missing, skipping")
    return nil
  end
  return {
    {"Mail",           nil, mbp, unit(POS.full), nil, nil},
    {"Terminal",       nil, ext, unit(POS.left), nil, nil},
    {"Screen Sharing", nil, ext, unit(POS.full), nil, nil},
    {"Reminders",      nil, ext, unit(POS.right), nil, nil},
  }
end

-- slate: default 1monitor resolutions:${mon-mbp}
--        default 2monitor resolutions:${mon-mbp};${mon-ext}
local function applyLayout()
  local t
  if #hs.screen.allScreens() > 1 then
    t = layout2monitor()
  else
    t = layout1monitor()
  end
  if t then hs.layout.apply(t) end
end

-- Auto-apply on screen-configuration change, debounced (~1s; screens flap
-- on connect/disconnect). Like slate's `default`, layouts only touch apps
-- that are already running.
local layoutTimer = nil
screenWatcher = hs.screen.watcher.new(function()
  if layoutTimer then layoutTimer:stop() end
  layoutTimer = hs.timer.doAfter(1.0, applyLayout)
end)
screenWatcher:start()

applyLayout()  -- apply once at config load, like slate at launch
