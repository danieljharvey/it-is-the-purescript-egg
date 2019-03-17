module Egg.Types.Board where

import Egg.Types.Tile

import Matrix as M

type BoardSize =
  { width  :: Int
  , height :: Int
  }

type Board = M.Matrix Tile

type RenderMap = M.Matrix Boolean

type RenderArray
  = Array RenderItem

type GenericRenderItem a
  = { x :: Int
    , y :: Int
    , value :: a
    }

type RenderItem = GenericRenderItem Tile

type RenderMapItem = GenericRenderItem Boolean

type JSONBoard = Array (Array JSONTile)

emptyBoard :: Int -> Board
emptyBoard size
  = M.repeat size size emptyTile
