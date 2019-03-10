module Egg.Logic.Movement where

import Prelude
import Egg.Types.Player (Player)
import Egg.Types.Board (Board, BoardSize)
import Egg.Types.Coord (Coord(..), createCoord, createMoveCoord, invert)
import Egg.Types.CurrentFrame (dec, inc)

import Egg.Logic.Board (boardSizeFromBoard, getTileByCoord)

import Data.Int (floor, toNumber)

moveDivision :: Int
moveDivision = 64

speedConst :: Int
speedConst = 20

movePlayers :: Board -> Int -> Array Player -> Array Player
movePlayers board i = map (movePlayer board i)

movePlayer :: Board -> Int -> Player -> Player
movePlayer board timePassed player
  = doMove player
  where 
    doMove
      = (markPlayerIfMoved player)
      <<< (correctPlayerMapOverflow board)
      <<< incrementPlayerFrame
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
correctPlayerOverflow = mapCoords correctTileOverflow

correctPlayerMapOverflow :: Board -> Player -> Player
correctPlayerMapOverflow board =
  mapCoords $ correctMapOverflow (boardSizeFromBoard board)

mapCoords :: (Coord -> Coord) -> Player -> Player
mapCoords f player
  = player { coords = f player.coords }

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

correctMapOverflow :: BoardSize -> Coord -> Coord
correctMapOverflow size (Coord coord)
  = Coord $ coord { x = x, y = y }
  where
    x = coord.x `mod` size.width
    y = coord.y `mod` size.height

checkFloorBelowPlayer :: Board -> Player -> Player
checkFloorBelowPlayer board player
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
      = player.coords <> (createCoord 0 1) 

markPlayerIfMoved :: Player -> Player -> Player
markPlayerIfMoved old new
  = new { moved = playerHasMoved old new }

playerHasMoved :: Player -> Player -> Boolean
playerHasMoved old new
  = old.coords /= new.coords

checkPlayerDirection :: Board -> Player -> Player
checkPlayerDirection board player
  = player { direction = newDirection }
  where
    newDirection 
      = if nextTile.background || player.falling
           then player.direction
           else invert player.direction
    
    nextTile
      = getTileByCoord board coord
    
    coord
      = player.coords <> player.direction
