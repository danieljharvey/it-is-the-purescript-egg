module Egg.Types.Player where

import Egg.Types.PlayerType
import Egg.Types.Coord (Coord, createCoord)
import Egg.Types.CurrentFrame (CurrentFrame, createCurrentFrame)

type Player
  = { coords       :: Coord
    , direction    :: Coord
    , oldDirection :: Coord
    , currentFrame :: CurrentFrame
    , id           :: Int
    , falling      :: Boolean
    , stop         :: Boolean
    , lastAction   :: String
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
    , lastAction: ""
    , moved: false
    , oldDirection: createCoord 0 0
    , stop: false
    , playerType: defaultPlayerType
  }
