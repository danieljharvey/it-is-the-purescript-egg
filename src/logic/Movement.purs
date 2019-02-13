module Egg.Logic.Movement where

import Prelude
import Egg.Types.Player (Player)
import Egg.Types.Board
import Egg.Types.Coord (Coord, createCoord)
import Egg.Types.CurrentFrame (dec, inc)
import Egg.Types.Tile

import Data.Maybe
import Matrix as Mat
import Data.Int (floor, toNumber)

moveDivision :: Int
moveDivision = 128

speedConst :: Int
speedConst = 10

movePlayers :: Int -> Array Player -> Array Player
movePlayers i = map (movePlayer i)

movePlayer :: Int -> Player -> Player
movePlayer timePassed
  = incrementPlayerFrame
  <<< correctPlayerOverflow 
  <<< (incrementPlayerDirection timePassed)

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

correctPlayerOverflow :: Player -> Player
correctPlayerOverflow p
  = p { coords = correctTileOverflow p.coords }

correctTileOverflow :: Coord -> Coord
correctTileOverflow coord
  | coord.offsetX >= moveDivision 
    = coord { x = coord.x + 1, offsetX = 0 }
  | coord.offsetX <= (-1) * moveDivision
    = coord { x = coord.x - 1, offsetX = 0 } 
  | coord.offsetY >= moveDivision
    = correctTileOverflow (coord { y = coord.y + 1, offsetY = 0})
  | coord.offsetY <= (-1) * moveDivision
    = correctTileOverflow (coord { y = coord.y - 1, offsetY = 0 })
  | otherwise                     = coord

checkFloorBelowPlayer :: Board -> Player -> Player
checkFloorBelowPlayer board player
  = player { falling = breakable || hollow }
  where
    breakable
      = belowTile.breakable && player.falling
    
    hollow
      = belowTile.background
    
    belowTile
      = getTileByCoord board coord

    coord
      = player.coords { y = player.coords.y + 1 } 

getTileByCoord :: Board -> Coord -> Tile
getTileByCoord board coord
  = fromMaybe emptyTile tile
    where
      tile = Mat.get x y board
      x = coord.x `mod` Mat.width board
      y = coord.y `mod` Mat.height board    

