module Egg.Logic.Movement where

import Prelude
import Egg.Types.Player (Player)
import Egg.Types.Coord (Coord, createCoord)

movePlayers :: Array Player -> Array Player
movePlayers = map movePlayer

movePlayer :: Player -> Player
movePlayer = incrementPlayerFrame

incrementPlayerFrame :: Player -> Player
incrementPlayerFrame player = resetDirectionWhenStationary player

resetDirectionWhenStationary :: Player -> Player
resetDirectionWhenStationary player
  = if isStationary player.coords
    then player { oldDirection = createCoord 0 0 }
    else player

isStationary :: Coord -> Boolean
isStationary { x: 0, y: 0, offsetX: 0, offsetY: 0 } = true
isStationary _ = false
