module Egg.Types.GameState where

import Egg.Types.Action (Action(..))
import Egg.Types.Board (Board)
import Egg.Types.Player (Player)
import Egg.Types.Outcome (Outcome(..))
import Egg.Types.Score
import Egg.Types.RenderAngle (RenderAngle(..))

type GameState
  = { players     :: Array Player
    , board       :: Board
    , score       :: Score
    , rotations   :: Int
    , rotateAngle :: RenderAngle
    , renderAngle :: RenderAngle
    , outcome     :: Outcome
    , turns       :: Int
    , current     :: Action
    }

createGameState :: Board -> GameState
createGameState board
  = { players: []
    , board: board
    , score: Score 0
    , rotations: 0
    , rotateAngle: RenderAngle 0
    , renderAngle: RenderAngle 0
    , outcome: Outcome ""
    , turns: 0
    , current: Playing
  }
