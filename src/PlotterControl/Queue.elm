module PlotterControl.Queue exposing (..)

import Dict.Any
import Id
import Task
import Time


type alias Queue =
    Dict.Any.Dict (Id.Id Item) Item



--


type alias Item =
    { name : ItemName
    , data : String

    --
    , created : Time.Posix
    }


createItem : ItemName -> String -> Task.Task x Item
createItem name data =
    Task.map
        (\x ->
            Item
                name
                data
                x
        )
        Time.now



--


type ItemName
    = ItemName String


stringToItemName : String -> ItemName
stringToItemName =
    ItemName


itemNameToString : ItemName -> String
itemNameToString (ItemName a) =
    a
