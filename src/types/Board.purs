module Egg.Types.Board (Board, BoardSize, JSONBoard) where

import Egg.Types.Tile (JSONTile, Tile)

import Matrix as M

type BoardSize =
  { width  :: Int
  , height :: Int
  }

type Board = M.Matrix Tile

type JSONBoard = Array (Array JSONTile)
