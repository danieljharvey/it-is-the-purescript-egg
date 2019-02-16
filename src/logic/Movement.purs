module Egg.Logic.Movement where

import Prelude
import Egg.Types.Player (Player)
import Egg.Types.Board (Board)
import Egg.Types.Coord (Coord(..), createCoord, createMoveCoord, invert)
import Egg.Types.CurrentFrame (dec, inc)
import Egg.Types.Tile (Tile, emptyTile)

import Data.Maybe (fromMaybe)
import Matrix as Mat
import Data.Int (floor, toNumber)

moveDivision :: Int
moveDivision = 128

speedConst :: Int
speedConst = 10

movePlayers :: Board -> Int -> Array Player -> Array Player
movePlayers board i = map (movePlayer board i)

movePlayer :: Board -> Int -> Player -> Player
movePlayer board timePassed
  = incrementPlayerFrame
  <<< (checkFloorBelowPlayer board)
  <<< (checkPlayerDirection board)
  <<< correctPlayerOverflow 
  <<< (incrementPlayerDirection timePassed)

incrementPlayerFrame :: Player -> Player
incrementPlayerFrame = resetDirectionWhenStationary
                   <<< changeFrameIfMoving

changeFrameIfMoving :: Player -> Player
changeFrameIfMoving player@{ direction: Coord direction }
  | direction.x < 0 = player { currentFrame = dec player.currentFrame }
  | direction.x > 0 = player { currentFrame = inc player.currentFrame }
  | direction.y < 0 = player { currentFrame = dec player.currentFrame }
  | direction.y > 0 = player { currentFrame = inc player.currentFrame }
  | otherwise       = player


resetDirectionWhenStationary :: Player -> Player
resetDirectionWhenStationary player
  = if isStationary player.coords
    then player { oldDirection = createCoord 0 0 }
    else player

isStationary :: Coord -> Boolean
isStationary (Coord { x: 0, y: 0, offsetX: 0, offsetY: 0 }) = true
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
      = player.coords <> (createMoveCoord moveAmount newDirection)

    newDirection
      = if player.falling
           then createCoord 0 1
           else player.direction

correctPlayerOverflow :: Player -> Player
correctPlayerOverflow p
  = p { coords = correctTileOverflow p.coords }

correctTileOverflow :: Coord -> Coord
correctTileOverflow (Coord coord)
  | coord.offsetX >= moveDivision 
    = createCoord (coord.x + 1) coord.y
  | coord.offsetX <= (-1) * moveDivision
    = createCoord (coord.x - 1) coord.y
  | coord.offsetY >= moveDivision
    = correctTileOverflow (createCoord coord.x (coord.y + 1))
  | coord.offsetY <= (-1) * moveDivision
    = correctTileOverflow (createCoord coord.x (coord.y - 1))
  | otherwise                     
    = Coord coord

checkFloorBelowPlayer :: Board -> Player -> Player
checkFloorBelowPlayer board player@{ coords: Coord coords }
  = player { falling = canFall && (breakable || hollow) }
  where
    canFall
      = not $ player.playerType.flying

    breakable
      = belowTile.breakable && player.falling
    
    hollow
      = belowTile.background
    
    belowTile
      = getTileByCoord board coord
    
    coord
      = Coord $ coords { y = coords.y + 1 } 

    
getTileByCoord :: Board -> Coord -> Tile
getTileByCoord board (Coord coord)
  = fromMaybe emptyTile tile
    where
      tile = Mat.get x y board
      x = coord.x `mod` Mat.width board
      y = coord.y `mod` Mat.height board    

playerHasMoved :: Player -> Player -> Boolean
playerHasMoved old new
  = old.coords /= new.coords

checkPlayerDirection :: Board -> Player -> Player
checkPlayerDirection board player
  = player { direction = newDirection }
  where
    newDirection 
      = if nextTile.background
           then player.direction
            else invert player.direction
    
    nextTile
      = getTileByCoord board coord
    
    coord
      = player.coords <> player.direction
