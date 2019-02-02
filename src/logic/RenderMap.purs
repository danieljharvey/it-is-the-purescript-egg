module Egg.Logic.RenderMap where

import Prelude
import Data.Maybe (fromMaybe)
import Matrix as Mat
import Data.Array (filter)

import Egg.Types.Board (Board, BoardSize, RenderMap, RenderArray, RenderItem)
import Egg.Types.Coord (Coord, createCoord)

createRenderMap :: Board -> Board -> RenderMap
createRenderMap before after
  = fromMaybe blankMap renderMap
  where
    blankMap
      = blankRenderMap before

    renderMap
      = Mat.zipWith compare before after

    compare a b
      = a == b

boardSizeFromBoard :: Board -> BoardSize
boardSizeFromBoard board =
  { width : Mat.width board
  , height: Mat.height board
  }

blankRenderMap :: Board -> RenderMap
blankRenderMap board = Mat.repeat (Mat.width board) (Mat.height board) true

shouldDrawItem :: RenderMap -> RenderItem -> Boolean
shouldDrawItem map item
  = shouldDraw map (createCoord item.x item.y)

shouldDraw :: RenderMap -> Coord -> Boolean
shouldDraw map coord = fromMaybe false draw
  where
    draw = Mat.get coord.x coord.y map

buildRenderArray :: RenderMap -> Board -> RenderArray
buildRenderArray map board = filter filterFunc array
  where
    filterFunc item
      = shouldDraw map (createCoord item.x item.y)

    array = Mat.toIndexedArray board
