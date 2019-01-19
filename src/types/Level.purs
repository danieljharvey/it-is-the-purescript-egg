module Egg.Types.Level (JSONLevel) where

import Prelude ((<<<))
import Simple.JSON (readJSON)
import Data.Maybe
import Data.Either (hush)

import Egg.Types.Board (JSONBoard, Board, BoardSize)

type JSONLevel =
  { board :: JSONBoard
  , boardSize :: BoardSize
  , levelID :: String
  }

type Level =
  { board     :: Board
  , boardSize :: BoardSize
  , levelId   :: Int
}
{-}
convert :: Array Tile -> JSONLevel -> Maybe Level
convert jl = do
-}

readLevel :: String -> Maybe JSONLevel
readLevel = hush <<< readJSON
