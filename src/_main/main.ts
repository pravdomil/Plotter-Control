import {
  ConnectSerialPort,
  ElmMessage,
  GotError,
  JavaScriptMessage,
  JsRefSerialPort,
  SendToSerialPort,
  SerialPortUpdated,
} from "../Generated/Types/PlotterControl"
import { Maybe } from "../Generated/Basics/Basics"

main()

/**
 * To start our app.
 */
function main(): void {
  // Check for serial support
  if (typeof navigator.serial === "undefined") {
    alert(
      [
        "There is no support for serial port communication.",
        "",
        'Make sure to use Chrome browser and allow "Experimental Web Platform features" in Chrome flags.',
      ].join("\n")
    )
    return
  }

  // App init
  const app = (window as any).Elm.Main.init()
  const send = (a: JavaScriptMessage) => app.ports.javaScriptMessageSubscription_.send(a)

  // Outcoming messages
  addEventListener("error", (e) => send([GotError, String(e.error)]))
  addEventListener("unhandledrejection", (e) => send([GotError, String(e.reason)]))
  navigator.serial.addEventListener("disconnect", () => send([SerialPortUpdated, null]))

  // Incoming messages
  ;(app.ports.sendElmMessage_.subscribe as any)((a: ElmMessage) => {
    switch (a[0]) {
      case ConnectSerialPort:
        return connectSerialPort(a[1], a[2]).then((a) => send([SerialPortUpdated, a]))
      case SendToSerialPort:
        return sendToSerialPort(a[1][1], a[2])
    }
  })
}

/**
 * To connect to serial port.
 * */
async function connectSerialPort(filter: SerialPortFilter, options: SerialOptions): Promise<Maybe<JsRefSerialPort>> {
  const port = await getPort(filter)
  if (!port) {
    return null
  }
  await port.open(options)
  return [JsRefSerialPort, port]
}

/**
 * To get first serial port or ask user to select one.
 * */
async function getPort(filter: SerialPortFilter): Promise<Maybe<SerialPort>> {
  const ports = await navigator.serial.getPorts()
  const firstPort = arrayGet(0, ports)
  if (firstPort) {
    return firstPort
  }

  try {
    return await navigator.serial.requestPort({ filters: [filter] })
  } catch (e) {}
  return null
}

/**
 * To send string to serial port.
 * */
function sendToSerialPort(a: SerialPort, b: string): void {
  a.writable?.getWriter().write(new TextEncoder().encode(b))
}

/**
 * To get element from array.
 */
export function arrayGet<T>(i: number, a: Array<T>): Maybe<T> {
  return i >= 0 && i < a.length ? a[i] : null
}
