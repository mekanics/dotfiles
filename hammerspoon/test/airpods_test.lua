-- Observable behaviour of the AirPods listening-mode toggle.
-- Run: lua hammerspoon/test/airpods_test.lua

local fails = 0

local function check(name, ok, detail)
  if ok then
    io.write("ok   ", name, "\n")
  else
    fails = fails + 1
    io.write("FAIL ", name, detail and (": " .. detail) or "", "\n")
  end
end

local function eq(name, actual, expected)
  check(name, actual == expected, "got " .. tostring(actual) .. ", expected " .. tostring(expected))
end

local test_dir = debug.getinfo(1, "S").source:sub(2):match("(.*/)")
local module_dir = test_dir .. "../hammerspoon.symlink/"
local adapter = module_dir .. "airpods-listening-mode.js"

package.path = module_dir .. "?.lua;" .. package.path

local BROKE = "AirPods control broke — see Hammerspoon console"
local GRANT = "Allow Hammerspoon in System Settings › Privacy & Security › Bluetooth"
local TIMEOUT = "AirPods didn't respond"

local function capture(cmd)
  local handle = io.popen(cmd .. " 2>&1")
  local out = handle:read("*a") or ""
  handle:close()
  return (out:gsub("%s+$", ""))
end

local function shell_quote(s)
  return "'" .. tostring(s):gsub("'", "'\\''") .. "'"
end

local function adapter_cmd(args)
  local quoted = { shell_quote("/usr/bin/osascript"), "-l", "JavaScript", shell_quote(adapter) }
  for i = 1, #args do
    quoted[#quoted + 1] = shell_quote(args[i])
  end
  return table.concat(quoted, " ")
end

local function json_field(stdout, field)
  return stdout:match('"' .. field .. '":"([^"]*)"')
end

-- Adapter: the toggle rule, with no Bluetooth involved.
local function next_mode(current)
  return capture(adapter_cmd({ "next", current, "noise-cancellation", "adaptive" }))
end

eq("noise cancellation toggles to adaptive", json_field(next_mode("noise-cancellation"), "mode"), "adaptive")
eq("adaptive toggles to noise cancellation", json_field(next_mode("adaptive"), "mode"), "noise-cancellation")
eq("transparency toggles to noise cancellation", json_field(next_mode("transparency"), "mode"), "noise-cancellation")
eq("off toggles to noise cancellation", json_field(next_mode("off"), "mode"), "noise-cancellation")

local bogus = capture(adapter_cmd({ "next", "bogus", "noise-cancellation", "adaptive" }))
eq("unknown mode is rejected", json_field(bogus, "error"), "bad-args")

local missing = capture(adapter_cmd({ "set" }))
eq("set without a mode is rejected", json_field(missing, "error"), "bad-args")

-- Module: presence and alert copy. Requiring it must not touch Hammerspoon.
check("tests run outside Hammerspoon", hs == nil, "hs is defined")

local ok_require, airpods = pcall(require, "airpods")
check("airpods module loads", ok_require, tostring(airpods))

if ok_require then
  local present = airpods.isAirPodsPresent

  eq("bluetooth airpods are present", present({
    { name = "Alex's AirPods Pro", transport = "Bluetooth" },
  }, "AirPods"), true)
  eq("other bluetooth audio is not airpods", present({
    { name = "LG ULTRAWIDE", transport = "Bluetooth" },
  }, "AirPods"), false)
  eq("built-in device named airpods is not connected airpods", present({
    { name = "AirPods", transport = "Built-in" },
  }, "AirPods"), false)
  eq("no output devices means not present", present({}, "AirPods"), false)
  eq("name match is case insensitive", present({
    { name = "alex airpods pro", transport = "Bluetooth" },
  }, "AirPods"), true)
  eq("custom name pattern", present({
    { name = "Beats Studio", transport = "Bluetooth" },
  }, "Beats"), true)
  eq("missing device name is not present", present({
    { transport = "Bluetooth" },
  }, "AirPods"), false)

  local describe = airpods.describeResult

  local function success(mode, extra)
    extra = extra or ""
    return describe({
      exitCode = 0,
      reason = "exit",
      stdout = '{"ok":true,"device":"Alex\'s AirPods Pro","before":"adaptive","mode":"' .. mode .. '"' .. extra .. '}',
      stderr = "",
    })
  end

  local nc = success("noise-cancellation")
  eq("noise cancellation alert is ok", nc.ok, true)
  eq("noise cancellation alert names the mode", nc.mode, "noise-cancellation")
  eq("noise cancellation alert text", nc.text, "Noise Cancellation")
  eq("adaptive alert", success("adaptive").text, "Adaptive")
  eq("transparency alert", success("transparency").text, "Transparency")
  eq("off alert", success("off").text, "Off")

  local two = success("noise-cancellation", ',"candidates":2')
  eq("names the device when more than one headset is connected", two.text, "Noise Cancellation · Alex's AirPods Pro")

  local function failure(error)
    return describe({
      exitCode = 0,
      reason = "exit",
      stdout = '{"ok":false,"error":"' .. error .. '","detail":""}',
      stderr = "",
    })
  end

  eq("no device alert", failure("no-device").text, "No AirPods connected")
  eq("no peer alert", failure("no-peer").text, "Couldn't reach your AirPods")
  eq("bluetooth not ready alert", failure("not-ready").text, "Bluetooth isn't ready — try again")
  eq("bad arguments alert", failure("bad-args").text, BROKE)

  local grant = describe({ exitCode = 6, reason = "interrupt", stdout = "", stderr = "" })
  eq("missing bluetooth permission alert", grant.text, GRANT)
  eq("missing bluetooth permission is not ok", grant.ok, false)

  local crashed = describe({ exitCode = 1, reason = "exit", stdout = "", stderr = "TypeError: undefined" })
  eq("adapter crash alert", crashed.text, BROKE)
  eq("adapter crash is not ok", crashed.ok, false)

  local garbage = describe({ exitCode = 0, reason = "exit", stdout = "not json", stderr = "" })
  eq("unparseable adapter output alert", garbage.text, BROKE)

  local timed = describe({ exitCode = nil, reason = "interrupt", stdout = "", stderr = "", timedOut = true })
  eq("timeout alert", timed.text, TIMEOUT)

  eq("a successful toggle shows no alert", airpods.alertText(nc), nil)
  eq("a failed toggle still shows an alert", airpods.alertText(failure("no-device")), "No AirPods connected")

  eq("agreement needs no correction", airpods.disagreement("adaptive", "adaptive"), nil)
  eq(
    "disagreement names the mode the airpods stayed on",
    airpods.disagreement("adaptive", "noise-cancellation"),
    "AirPods stayed on Noise Cancellation"
  )
end

if fails > 0 then
  io.write(fails, " failed\n")
  os.exit(1)
end
io.write("all passed\n")
