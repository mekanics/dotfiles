-- Toggle AirPods listening mode. Bluetooth lives in airpods-listening-mode.js.
-- Requiring this file does not touch Hammerspoon; call start() to bind the hotkey.

local M = {}

M.LABELS = {
  off = "Off",
  ["noise-cancellation"] = "Noise Cancellation",
  transparency = "Transparency",
  adaptive = "Adaptive",
}

local BROKE = "AirPods control broke — see Hammerspoon console"
local GRANT = "Allow Hammerspoon in System Settings › Privacy & Security › Bluetooth"
local TIMEOUT = "AirPods didn't respond"
local NOT_READY = "Bluetooth isn't ready — try again"

local ERROR_TEXT = {
  ["no-device"] = "No AirPods connected",
  ["no-peer"] = "Couldn't reach your AirPods",
  ["not-ready"] = NOT_READY,
}

local ADAPTER_TIMEOUT = 3
local CONFIRM_AFTER = 0.4

function M.isAirPodsPresent(devices, namePattern)
  local needle = (namePattern or "AirPods"):lower()
  for _, device in ipairs(devices or {}) do
    local name = device and device.name
    if device and device.transport == "Bluetooth" and type(name) == "string"
        and name:lower():find(needle, 1, true) then
      return true
    end
  end
  return false
end

-- Flat JSON object decoder for the adapter's one-line replies. Returns nil on garbage.
local function parseJSON(input)
  if type(input) ~= "string" then return nil end
  local s = input:match("^%s*(%b{})%s*$") or input:match("(%b{})")
  if not s then return nil end

  local i = 1
  local function skip()
    while s:sub(i, i):match("%s") do i = i + 1 end
  end

  local parseValue

  local function parseString()
    if s:sub(i, i) ~= '"' then return nil, true end
    i = i + 1
    local parts = {}
    while i <= #s do
      local c = s:sub(i, i)
      if c == '"' then
        i = i + 1
        return table.concat(parts)
      elseif c == "\\" then
        local n = s:sub(i + 1, i + 1)
        local simple = {
          ['"'] = '"', ["\\"] = "\\", ["/"] = "/",
          b = "\b", f = "\f", n = "\n", r = "\r", t = "\t",
        }
        if simple[n] then
          parts[#parts + 1] = simple[n]
          i = i + 2
        elseif n == "u" then
          local cp = tonumber(s:sub(i + 2, i + 5), 16)
          if not cp then return nil, true end
          parts[#parts + 1] = utf8.char(cp)
          i = i + 6
        else
          return nil, true
        end
      else
        parts[#parts + 1] = c
        i = i + 1
      end
    end
    return nil, true
  end

  function parseValue()
    skip()
    local c = s:sub(i, i)
    if c == '"' then return parseString() end
    if c == "{" then
      i = i + 1
      local obj = {}
      skip()
      if s:sub(i, i) == "}" then
        i = i + 1
        return obj
      end
      while true do
        skip()
        local key, badKey = parseString()
        if badKey or key == nil then return nil, true end
        skip()
        if s:sub(i, i) ~= ":" then return nil, true end
        i = i + 1
        local value, badValue = parseValue()
        if badValue then return nil, true end
        obj[key] = value
        skip()
        local sep = s:sub(i, i)
        if sep == "," then
          i = i + 1
        elseif sep == "}" then
          i = i + 1
          return obj
        else
          return nil, true
        end
      end
    end
    if s:sub(i, i + 3) == "true" then i = i + 4 return true end
    if s:sub(i, i + 4) == "false" then i = i + 5 return false end
    if s:sub(i, i + 3) == "null" then i = i + 4 return nil end
    local num = s:sub(i):match("^(%-?%d+%.?%d*)")
    if num then
      i = i + #num
      return tonumber(num)
    end
    return nil, true
  end

  local value, bad = parseValue()
  if bad then return nil end
  return value
end

function M.describeResult(result)
  result = result or {}
  if result.timedOut then
    return { ok = false, mode = nil, text = TIMEOUT }
  end
  if result.exitCode == 6 and result.reason == "interrupt" then
    return { ok = false, mode = nil, text = GRANT }
  end
  if result.exitCode ~= 0 then
    return { ok = false, mode = nil, text = BROKE }
  end

  local parsed = parseJSON(result.stdout)
  if type(parsed) ~= "table" or parsed.ok ~= true then
    local text = type(parsed) == "table" and ERROR_TEXT[parsed.error] or nil
    return { ok = false, mode = nil, text = text or BROKE }
  end

  local mode = parsed.mode
  local label = M.LABELS[mode] or tostring(mode)
  local text = label
  local candidates = tonumber(parsed.candidates)
  if candidates and candidates > 1 and type(parsed.device) == "string" and parsed.device ~= "" then
    text = label .. " · " .. parsed.device
  end
  return { ok = true, mode = mode, text = text }
end

-- nil when the AirPods landed on the mode we set; otherwise the correction alert.
-- nil when the toggle stuck, so a success draws no alert. Failures still return copy.
function M.alertText(described)
  if not described or described.ok then return nil end
  return described.text
end

function M.disagreement(requested, actual)
  if requested == actual then return nil end
  return "AirPods stayed on " .. (M.LABELS[actual] or tostring(actual))
end

--------------------------------------------------------------------------------
-- Hammerspoon wiring. Nothing above this line reads the hs global.
--------------------------------------------------------------------------------

local function adapterPath()
  local source = debug.getinfo(1, "S").source
  local dir = source:sub(1, 1) == "@" and source:sub(2):match("(.*[/\\])") or "./"
  return dir .. "airpods-listening-mode.js"
end

local function keycodeFor(key)
  if type(key) == "number" then return key end
  local mapped = hs.keycodes.map[tostring(key):lower()]
  if type(mapped) ~= "number" then mapped = hs.keycodes.map[key] end
  if type(mapped) ~= "number" then return nil end
  return mapped
end

local function outputDevices()
  local devices = {}
  for _, device in ipairs(hs.audiodevice.allOutputDevices()) do
    devices[#devices + 1] = { name = device:name(), transport = device:transportType() }
  end
  return devices
end

function M.refresh()
  if not M.hotkey then return end
  if M.isAirPodsPresent(outputDevices(), M.namePattern) then
    M.hotkey:enable()
  else
    M.hotkey:disable()
  end
end

local function finishTask(task, timedOut, exitCode, stdout, stderr, onDone)
  if M.timer then
    M.timer:stop()
    M.timer = nil
  end
  if M.inFlight == task then M.inFlight = nil end
  onDone({
    exitCode = exitCode,
    reason = task:terminationReason(),
    stdout = stdout or "",
    stderr = stderr or "",
    timedOut = timedOut,
  })
end

local function runAdapter(args, onDone)
  if M.inFlight then return false end
  local timedOut = false
  local argv = { "-l", "JavaScript", adapterPath() }
  for i = 1, #args do argv[#argv + 1] = tostring(args[i]) end

  local task
  task = hs.task.new("/usr/bin/osascript", function(exitCode, stdout, stderr)
    finishTask(task, timedOut, exitCode, stdout, stderr, onDone)
  end, argv)
  if not task then return false end

  M.inFlight = task
  M.timer = hs.timer.doAfter(ADAPTER_TIMEOUT, function()
    if M.inFlight ~= task then return end
    timedOut = true
    task:terminate()
  end)
  if not task:start() then
    M.inFlight = nil
    if M.timer then M.timer:stop() M.timer = nil end
    return false
  end
  return true
end

local function show(result)
  local described = M.describeResult(result)
  if not described.ok and result.stderr and result.stderr ~= "" then
    print("[hammerspoon] airpods: " .. result.stderr)
  end
  local text = M.alertText(described)
  if text then hs.alert.show(text) end
  return described
end

function M.toggle()
  if M.busy or M.inFlight then return end
  M.busy = true
  local started = runAdapter(
    { "toggle", M.modes[1], M.modes[2], M.namePattern },
    function(result)
      local described = show(result)
      if not described.ok or not described.mode then
        M.busy = false
        return
      end
      M.confirmTimer = hs.timer.doAfter(CONFIRM_AFTER, function()
        M.confirmTimer = nil
        local reading = runAdapter({ "get", M.namePattern }, function(confirm)
          local got = M.describeResult(confirm)
          if not got.ok then
            if confirm.stderr and confirm.stderr ~= "" then
              print("[hammerspoon] airpods: " .. confirm.stderr)
            end
            hs.alert.show(got.text)
          else
            local note = M.disagreement(described.mode, got.mode)
            if note then hs.alert.show(note) end
          end
          M.busy = false
        end)
        if not reading then M.busy = false end
      end)
    end
  )
  if not started then M.busy = false end
end

function M.stop()
  if M.timer then M.timer:stop() M.timer = nil end
  if M.confirmTimer then M.confirmTimer:stop() M.confirmTimer = nil end
  if M.inFlight then
    M.inFlight:terminate()
    M.inFlight = nil
  end
  M.busy = false
  if M.hotkey then
    M.hotkey:delete()
    M.hotkey = nil
  end
  -- hs.audiodevice.watcher is one callback for the whole config. This module owns it.
  if M.watcherOn then
    hs.audiodevice.watcher.stop()
    M.watcherOn = false
  end
end

function M.start(opts)
  opts = opts or {}
  M.stop()
  M.namePattern = opts.namePattern or "AirPods"
  M.modes = opts.modes or { "noise-cancellation", "adaptive" }

  local key = opts.key or "§"
  local code = keycodeFor(key)
  if code == nil then
    print("[hammerspoon] airpods: no keycode for " .. tostring(key) .. "; hotkey not bound")
    return
  end
  -- Keycode 50 is "`". cmd+` is macOS "Move focus to next window".
  if code == 50 then
    print("[hammerspoon] airpods: refusing keycode 50; hotkey not bound")
    return
  end

  local ok, hotkey = pcall(hs.hotkey.bind, opts.mods or { "cmd" }, code, function()
    M.toggle()
  end)
  if not ok or not hotkey then
    print("[hammerspoon] airpods: hotkey not bound: " .. tostring(hotkey))
    return
  end
  -- Kept on the module so a reload or GC cannot collect the hotkey or the watcher callback.
  M.hotkey = hotkey

  hs.audiodevice.watcher.setCallback(function(event)
    if event == "dev#" then M.refresh() end
  end)
  hs.audiodevice.watcher.start()
  M.watcherOn = true
  M.refresh()
end

return M
