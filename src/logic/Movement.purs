module Egg.Logic.Movement where

import Prelude
import Egg.Types.Player (Player)
import Egg.Types.Coord (Coord, createCoord)
import Egg.Types.CurrentFrame (dec, inc)

import Data.Int (floor, toNumber)

moveDivision :: Int
moveDivision = 128

speedConst :: Int
speedConst = 10

movePlayers :: Array Player -> Array Player
movePlayers = map movePlayer

movePlayer :: Player -> Player
movePlayer = incrementPlayerFrame

incrementPlayerFrame :: Player -> Player
incrementPlayerFrame = resetDirectionWhenStationary
                   <<< changeFrameIfMoving

changeFrameIfMoving :: Player -> Player
changeFrameIfMoving player
  | player.direction.x < 0 = player { currentFrame = dec player.currentFrame }
  | player.direction.x > 0 = player { currentFrame = inc player.currentFrame }
  | player.direction.y < 0 = player { currentFrame = dec player.currentFrame }
  | player.direction.y > 0 = player { currentFrame = inc player.currentFrame }
  | otherwise              = player


resetDirectionWhenStationary :: Player -> Player
resetDirectionWhenStationary player
  = if isStationary player.coords
    then player { oldDirection = createCoord 0 0 }
    else player

isStationary :: Coord -> Boolean
isStationary { x: 0, y: 0, offsetX: 0, offsetY: 0 } = true
isStationary _ = false

calcMoveAmount :: Int -> Int -> Int
calcMoveAmount moveSpeed timePassed
  = floor (moveAmount * (toNumber timePassed))
  where
    moveAmount :: Number
    moveAmount
      = (1.0 / (toNumber moveDivision))
        * toNumber moveSpeed
        * toNumber speedConst

incrementPlayerDirection :: Int -> Player -> Player
incrementPlayerDirection timePassed player
  = player { coords = newCoords }
  where
    moveAmount
      = calcMoveAmount player.playerType.moveSpeed timePassed

    newCoords
      = player.coords
          { offsetX = player.coords.offsetX + (player.direction.x * moveAmount)
          , offsetY = player.coords.offsetY + (player.direction.y * moveAmount)
          }
