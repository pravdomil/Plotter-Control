addEventListener("DOMContentLoaded", main)

function main() {
  if (!("serial" in navigator)) {
    alert(
      [
        "No Support for Serial Port",
        "",
        'Make sure to use Chrome browser and allow "Experimental Web Platform features" in Chrome flags.',
      ].join("\n")
    )
    return
  }

  const app = Elm.Main.init({
    node: element(document.body, "div"),
    flags: {},
  })
}

function element(parent, type, className) {
  const el = document.createElement(type)
  if (parent) parent.appendChild(el)
  if (className) el.className = className
  return el
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
