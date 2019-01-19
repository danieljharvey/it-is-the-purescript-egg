module Egg.Types.Coord (Coord, createCoord, totalX, totalY) where

import Prelude

-- increments between tiles, as such
subparts :: Int
subparts = 64

type Coord =
  { x       :: Int
  , y       :: Int
  , offsetX :: Int
  , offsetY :: Int
  }

createCoord :: Int -> Int -> Coord
createCoord x y = { x, y, offsetX: 0, offsetY: 0 }

totalX :: Coord -> Int
totalX c = (c.x * subparts) + c.offsetX

totalY :: Coord -> Int
totalY c = (c.y * subparts) + c.offsetY
