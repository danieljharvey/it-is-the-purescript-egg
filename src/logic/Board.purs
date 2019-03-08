module Egg.Logic.Board where

import Egg.Types.Board
import Egg.Types.Coord
import Egg.Types.Tile

import Prelude
import Data.Maybe
import Graphics.Canvas
import Matrix as Mat
import Data.Int (toNumber)

createBoardSize :: Int -> BoardSize
createBoardSize i
  = { width: i
    , height: i
    }

invertTranslation :: TranslateTransform -> TranslateTransform
invertTranslation trans 
  = { translateX: -1.0 * trans.translateX 
    , translateY: -1.0 * trans.translateY
    }

createCenteredTranslation :: Int -> TranslateTransform
createCenteredTranslation i
  = { translateX: toNumber (i / 2) 
    , translateY: toNumber (i / 2)
    }

getTileByCoord :: Board -> Coord -> Tile
getTileByCoord board (Coord coord)
  = fromMaybe emptyTile tile
    where
      tile = Mat.get x y board
      x = coord.x `mod` Mat.width board
      y = coord.y `mod` Mat.height board    

replaceTile :: Board -> Coord -> Tile -> Board
replaceTile board (Coord coord) tile
  = fromMaybe board newBoard
    where
      newBoard 
        = Mat.set coord.x coord.y tile board