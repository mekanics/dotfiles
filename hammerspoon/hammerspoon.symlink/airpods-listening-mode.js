// Listening-mode adapter for AirPods. The only code that touches private Bluetooth APIs.
//
//   osascript -l JavaScript airpods-listening-mode.js get [name]
//   osascript -l JavaScript airpods-listening-mode.js set <mode> [name]
//   osascript -l JavaScript airpods-listening-mode.js toggle <a> <b> [name]
//   osascript -l JavaScript airpods-listening-mode.js next <current> <a> <b>
//
// mode: off | noise-cancellation | transparency | adaptive
// stdout is one JSON object. Handled failures exit 0 with ok:false.
// An exception (a macOS update breaking the private API) exits non-zero.

const CODE = {
  off: 1,
  "noise-cancellation": 2,
  transparency: 3,
  adaptive: 4,
};

const NAME = {
  1: "off",
  2: "noise-cancellation",
  3: "transparency",
  4: "adaptive",
};

function isMode(value) {
  return Object.prototype.hasOwnProperty.call(CODE, value);
}

function fail(error, detail) {
  return JSON.stringify({ ok: false, error: error, detail: detail || "" });
}

function modeName(value) {
  const code = Number(value);
  return Object.prototype.hasOwnProperty.call(NAME, code) ? NAME[code] : String(value);
}

function textOf(value) {
  if (value == null) return "";
  if (typeof value === "string") return value;
  // ObjC methods report typeof "function" but throw when called. Unwrap the value.
  try {
    const unwrapped = ObjC.unwrap(value);
    if (unwrapped == null) return "";
    return String(unwrapped);
  } catch (e) {
    return "";
  }
}

function run(argv) {
  const command = argv[0];

  if (command === "next") {
    const current = argv[1];
    const first = argv[2];
    const second = argv[3];
    if (!isMode(current) || !isMode(first) || !isMode(second)) {
      return fail("bad-args", "next needs three modes");
    }
    return JSON.stringify({ ok: true, before: current, mode: current === first ? second : first });
  }

  if (command !== "get" && command !== "set" && command !== "toggle") {
    return fail("bad-args", "unknown command");
  }
  if (command === "set" && !isMode(argv[1])) return fail("bad-args", "set needs a mode");
  if (command === "toggle" && (!isMode(argv[1]) || !isMode(argv[2]))) {
    return fail("bad-args", "toggle needs two modes");
  }

  const pattern = command === "get" ? argv[1] : command === "set" ? argv[2] : argv[3];

  ObjC.import("IOBluetooth");
  const spin = (seconds) =>
    $.NSRunLoop.currentRunLoop.runUntilDate($.NSDate.dateWithTimeIntervalSinceNow(seconds));

  const paired = $.IOBluetoothDevice.pairedDevices;
  const found = [];
  for (let i = 0; i < paired.count; i++) {
    const device = paired.objectAtIndex(i);
    if (device.isConnected && device.isANCSupported) found.push(device);
  }
  if (found.length === 0) return fail("no-device");

  let device = found[0];
  if (pattern) {
    const needle = String(pattern).toLowerCase();
    for (let i = 0; i < found.length; i++) {
      if (textOf(found[i].name).toLowerCase().indexOf(needle) !== -1) {
        device = found[i];
        break;
      }
    }
  }

  // peerForAddressString: only resolves the uppercase colon form. addressString is lowercase dashes.
  const address = textOf(device.addressString).toUpperCase().replace(/-/g, ":");
  const coordinator = $.IOBluetoothCoreBluetoothCoordinator.sharedInstance;
  const peer = coordinator.peerForAddressString(address);
  if (!peer || (peer.isNil && peer.isNil())) return fail("no-peer", address);

  // setListeningMode: is dropped until the classic manager reports powered on (state 5).
  const manager = coordinator.classicManager;
  const state = () => Number(ObjC.unwrap(manager.state));
  const started = Date.now();
  while (state() !== 5 && Date.now() - started < 2000) spin(0.01);
  if (state() !== 5) return fail("not-ready", "classic manager state " + state());
  // Commands sent in the first instant after state 5 are often ignored.
  spin(0.5);

  const before = modeName(peer.listeningMode);
  let mode = null;
  if (command === "set") mode = argv[1];
  if (command === "toggle") mode = before === argv[1] ? argv[2] : argv[1];
  if (mode) {
    peer.setListeningMode(CODE[mode]);
    // The daemon rolls the change back if this process exits too soon.
    spin(1.5);
  } else {
    mode = before;
  }

  return JSON.stringify({
    ok: true,
    device: textOf(peer.name) || textOf(device.name),
    before: before,
    mode: mode,
    candidates: found.length,
  });
}
