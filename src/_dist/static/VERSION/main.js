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

function element(parent, tag, className) {
  const el = document.createElement(tag)
  if (parent) parent.appendChild(el)
  if (className) el.className = className
  return el
}

function checkSerialPortSupport() {
  if (!("serial" in navigator)) {
    alert("Sorry you browser is not supported.")
    throw new Error()
  }
}

async function sendData(a, send) {
  const Ready = 0,
    Connecting = 1,
    Sending = 2,
    Error = 3
  let port, writer, lock

  send({ a: Connecting })

  try {
    port = await getPort()
  } catch (e) {
    send({ a: Ready })
    throw e
  }

  try {
    if (!port.writable) await port.open({ baudRate: 57600 })
  } catch (e) {
    send({ a: Error, b: { a: 0 } })
    throw e
  }

  try {
    writer = port.writable.getWriter()
  } catch (e) {
    send({ a: Error, b: { a: 1 } })
    throw e
  }

  send({ a: Sending })

  try {
    lock = await navigator.wakeLock.request()
    await writer.write(new TextEncoder().encode(a))
    await writer.close()
    await lock.release()
  } catch (e) {
    send({ a: Error, b: { a: 2 } })
    throw e
  }

  send({ a: Ready })
}

async function getPort() {
  const ports = await navigator.serial.getPorts()
  if (ports[0]) return ports[0]
  const options = {
    filters: [{ usbVendorId: 0x0403, usbProductId: 0x6001 }],
  }
  return await navigator.serial.requestPort(options)
}
