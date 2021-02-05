addEventListener("DOMContentLoaded", main)

function main() {
  checkSerialPortSupport()

  const app = Elm.Main.init({
    node: element(document.body, "div"),
    flags: {},
  })

  app.ports.sendDataPort.subscribe(function (a) {
    sendData(a, app.ports.statusSubscriptionPort.send)
  })
}

function element(parent, type, className) {
  const el = document.createElement(type)
  if (parent) parent.appendChild(el)
  if (className) el.className = className
  return el
}

function checkSerialPortSupport() {
  if (!("serial" in navigator)) {
    alert(
      [
        "No Support for Serial Port",
        "",
        'Make sure to use Chrome browser and allow "Experimental Web Platform features" in Chrome flags.',
      ].join("\n")
    )
    throw new Error()
  }
}

async function sendData(a, callback) {
  const Ready = 0,
    Connecting = 1,
    Idle = 2,
    Busy = 3,
    Error = 4
  let port, writer

  callback({ _: Connecting })

  try {
    port = await getPort()
  } catch (e) {
    callback({ _: Ready })
    throw e
  }

  try {
    if (!port.writable) await port.open({ baudRate: 57600 })
  } catch (e) {
    callback({ _: Error, a: "Can't open serial port." })
    throw e
  }

  try {
    writer = port.writable.getWriter()
  } catch (e) {
    callback({ _: Error, a: "Serial port is busy." })
    throw e
  }

  callback({ _: Busy })

  try {
    await writer.write(new TextEncoder().encode(a))
    await writer.close()
  } catch (e) {
    callback({ _: Error, a: "Can't write data to serial port." })
    throw e
  }

  callback({ _: Idle })
}

async function getPort() {
  const ports = await navigator.serial.getPorts()
  if (ports[0]) return ports[0]
  const options = {
    filters: [{ usbVendorId: 0x0403, usbProductId: 0x6001 }],
  }
  return await navigator.serial.requestPort(options)
}
