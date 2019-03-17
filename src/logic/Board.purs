module Egg.Logic.Board where

import Egg.Types.Board (Board, BoardSize, RenderItem)
import Egg.Types.Coord (Coord(..), createCoord, totalX, totalY)
import Egg.Types.Tile (Tile, emptyTile, tileSize)

import Prelude
import Data.Maybe (fromMaybe)
import Graphics.Canvas (TranslateTransform)
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
  = { translateX: toNumber $ (i / 2)
    , translateY: toNumber $ (i / 2)
    }

createTileTranslation :: Coord -> TranslateTransform
createTileTranslation c
  = { translateX: toNumber $ (tileSize / 2) + (totalX c) 
    , translateY: toNumber $ (tileSize / 2) + (totalY c)
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

boardFromArray :: Array (Array Tile) -> Board
boardFromArray tiles
  = fromMaybe Mat.empty $ Mat.fromArray tiles 

renderItemToCoord :: RenderItem -> Coord
renderItemToCoord { x, y } = createCoord x y

boardSizeFromBoard :: forall a. Mat.Matrix a -> BoardSize
boardSizeFromBoard board =
  { width : Mat.width board
  , height: Mat.height board
  }