module PlotterControl.Model exposing (..)

import File
import Length
import PlotterControl.File
import PlotterControl.Settings
import SerialPort


type alias Model =
    { file : Result FileError PlotterControl.File.File
    , settings : PlotterControl.Settings.Settings
    , serialPort : Result SerialPortError SerialPort.Port
    }



--


type FileError
    = NotAsked
    | Loading



--


type SerialPortError
    = NotAsked_
    | Loading_



--


type Msg
    = OpenFile
    | GotFile File.File
    | GotFileContent File.File String
    | DragOver
    | ChangePreset PlotterControl.Settings.Preset
    | PlusCopies PlotterControl.Settings.Copies
    | PlusCopyDistance Length.Length
