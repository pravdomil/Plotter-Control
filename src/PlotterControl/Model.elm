module PlotterControl.Model exposing (..)

import File
import Length
import PlotterControl.File
import PlotterControl.SerialPort
import PlotterControl.Settings


type alias Model =
    { file : Result FileError PlotterControl.File.File
    , settings : PlotterControl.Settings.Settings
    , serialPort : Result SerialPortError ()
    }



--


type FileError
    = NotAsked
    | Loading



--


type SerialPortError
    = Ready
    | Sending
    | SerialPortError PlotterControl.SerialPort.Error



--


type Msg
    = OpenFile
    | GotFile File.File
    | GotFileContent File.File String
    | DragOver
      --
    | ChangePreset PlotterControl.Settings.Preset
    | PlusCopies PlotterControl.Settings.Copies
    | PlusCopyDistance Length.Length
    | ChangeMarkerLoading PlotterControl.Settings.MarkerLoading
      --
    | SendFile
    | FileSent (Result PlotterControl.SerialPort.Error ())
