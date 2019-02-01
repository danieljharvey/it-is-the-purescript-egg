module Egg.Types.GameState where

import Egg.Types.Board (Board)
import Egg.Types.Player

type GameState
  = { players     :: Array Player
    , board       :: Board
    , score       :: Int
    , rotations   :: Int
    , rotateAngle :: Int
    , outcome     :: String
    }

createGameState :: Board -> GameState
createGameState board
  = { players: []
    , board: board
    , score: 0
    , rotations: 0
    , rotateAngle: 0
    , outcome: ""
  }
