module Egg.Types.Player where

import Data.Maybe (Maybe(..))

import Egg.Types.PlayerType
import Egg.Types.Coord (Coord, createCoord)
import Egg.Types.CurrentFrame (CurrentFrame, createCurrentFrame)
import Egg.Types.LastAction (LastAction)

type Player
  = { coords       :: Coord
    , direction    :: Coord
    , oldDirection :: Coord
    , currentFrame :: CurrentFrame
    , id           :: Int
    , falling      :: Boolean
    , stop         :: Boolean
    , lastAction   :: Maybe LastAction
    , moved        :: Boolean
    , playerType   :: PlayerType
}

defaultPlayer :: Player
defaultPlayer
  = { coords: createCoord 0 0
    , currentFrame: createCurrentFrame 1
    , direction: createCoord 1 0
    , falling: false
    , id: 0
    , lastAction: Nothing
    , moved: false
    , oldDirection: createCoord 0 0
    , stop: false
    , playerType: defaultPlayerType
  }
