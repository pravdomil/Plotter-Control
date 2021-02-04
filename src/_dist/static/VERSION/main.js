addEventListener("DOMContentLoaded", main)

function main() {
  checkSerialPortSupport()

  const app = Elm.Main.init({
    node: element(document.body, "div"),
    flags: {},
  })

  app.ports.sendData.subscribe(function (a) {
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
  try {
    const Ready = 0,
      Connecting = 1,
      Idle = 2,
      Busy = 3,
      Error = 4

    callback({ _: Connecting })

    const port = await getPort()
    if (!port) {
      callback({ _: Ready })
      return
    }

    if (!port.writable) {
      await port.open({ baudRate: 57600 })
    }

    if (port.writable.locked) {
      callback({ _: Error, a: "Can't open serial port." })
      return
    }

    callback({ _: Busy })
    const writer = port.writable.getWriter()
    await writer.write(new TextEncoder().encode(a))
    await writer.close()
    callback({ _: Idle })
  } catch (e) {
    callback({ _: Error, a: "Something went wrong." })
    throw e
  }
}

async function getPort() {
  try {
    const ports = await navigator.serial.getPorts()
    if (ports[0]) return ports[0]
    const options = {
      filters: [{ usbVendorId: 0x0403, usbProductId: 0x6001 }],
    }
    return await navigator.serial.requestPort(options)
  } catch (e) {}
  return null
}
