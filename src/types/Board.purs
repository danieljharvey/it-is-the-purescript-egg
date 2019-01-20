module Egg.Types.Board (Board, BoardSize, JSONBoard, RenderMap, RenderItem, RenderArray) where

import Egg.Types.Tile (JSONTile, Tile)

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

type JSONBoard = Array (Array JSONTile)
