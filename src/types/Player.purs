module Egg.Types.Player where

import Egg.Types.PlayerType
import Egg.Types.Coord (Coord, createCoord)

type Player
  = { coords       :: Coord
    , direction    :: Coord
    , oldDirection :: Coord
    , currentFrame :: Int
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
    , currentFrame: 0
    , direction: createCoord 1 0
    , falling: false
    , id: 0
    , lastAction: ""
    , moved: false
    , oldDirection: createCoord 0 0
    , stop: false
    , playerType: defaultPlayerType
  }
