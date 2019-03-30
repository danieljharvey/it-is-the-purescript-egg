module Egg.Types.Coord  where

import Prelude

-- increments between tiles, as such
subparts :: Int
subparts = 64

newtype Coord = Coord
    { x       :: Int
    , y       :: Int
    , offsetX :: Int
    , offsetY :: Int
    }

derive newtype instance eqCoord :: Eq Coord
derive newtype instance ordCoord :: Ord Coord

instance showCoord :: Show Coord where
  show (Coord c) = "(" <> show c.x <> "." <> show c.offsetX <> ", " <> show c.y <> "." <> show c.offsetY <> ")"

instance semigroupCoord :: Semigroup Coord where
  append (Coord fst) (Coord snd)
    = Coord { x: fst.x + snd.x
            , y: fst.y + snd.y
            , offsetX: fst.offsetX + snd.offsetX
            , offsetY: fst.offsetY + snd.offsetY
            }

invert :: Coord -> Coord
invert (Coord coord)
  = Coord { x: (-1) * coord.x
          , y: (-1) * coord.y
          , offsetX: (-1) * coord.offsetX
          , offsetY: (-1) * coord.offsetY
          }

createCoord :: Int -> Int -> Coord
createCoord x y = Coord { x, y, offsetX: 0, offsetY: 0 }

createFullCoord :: Int -> Int -> Int -> Int -> Coord
createFullCoord x y offsetX offsetY
  = Coord { x, y, offsetX, offsetY }

createMoveCoord :: Int -> Coord -> Coord
createMoveCoord speed (Coord coord)
  = createFullCoord 0 0 newX newY
    where
      newX
        = speed * coord.x
      newY
        = speed * coord.y

justOffset :: Coord -> Coord
justOffset (Coord c)
  = Coord $ c { x = 0, y = 0 }

totalX :: Coord -> Int
totalX (Coord c) = (c.x * subparts) + c.offsetX

totalY :: Coord -> Int
totalY (Coord c) = (c.y * subparts) + c.offsetY

difference :: Coord -> Coord -> Coord
difference a b
  = (a <> invert b)

isCentered :: Coord -> Boolean
isCentered (Coord c) = c.offsetX == 0 && c.offsetY == 0

center :: Coord -> Coord
center (Coord c) = Coord $ c { offsetX = 0, offsetY = 0 }

directionCoord :: Coord -> Coord -> Coord
directionCoord (Coord current) (Coord aim)
  = createCoord x y
  where
    x = compare aim.x current.x
    y = compare aim.y current.y

compare :: Int -> Int -> Int
compare aim current
  | aim < current = (-1)
  | aim > current = 1
  | otherwise = 0