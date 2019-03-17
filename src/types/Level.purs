module Egg.Types.Level (Level, JSONLevel) where


import Egg.Types.Board (JSONBoard, Board, BoardSize)

type JSONLevel =
  { board :: JSONBoard
  , boardSize :: BoardSize
  , levelID :: Int
  }

type Level =
  { board     :: Board
  , boardSize :: BoardSize
  , levelId   :: Int
}

