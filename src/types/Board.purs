module Egg.Types.Board (Board, BoardSize, JSONBoard, RenderMap, RenderItem, RenderArray, RenderMapItem, emptyBoard) where

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

type RenderItem
  = { x :: Int
    , y :: Int
    , value :: Tile
    }

type RenderMapItem
  = { x :: Int
    , y :: Int
    , value :: Boolean
    }

type JSONBoard = Array (Array JSONTile)

emptyBoard :: Int -> Board
emptyBoard size
  = M.repeat size size emptyTile
