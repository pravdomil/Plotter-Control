module PlotterControl.Model exposing (..)

import File
import PlotterControl.File
import SerialPort


type alias Model =
    { file : Result FileError PlotterControl.File.File
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
    = GotFile File.File
    | GotFileContent File.File String
    | DragOver
