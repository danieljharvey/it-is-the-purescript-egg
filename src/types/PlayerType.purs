module Egg.Types.PlayerType where

import Data.Eq (class Eq)

data PlayerKind
  = Egg
  | RedEgg
  | BlueEgg
  | YellowEgg
  | RainbowEgg
  | SilverEgg
  | Blade
  | FindBlade

derive instance eqPlayerKind :: Eq PlayerKind

type PlayerType =
  { frames      :: Int
  , img         :: String
  , multiplier  :: Int
  , title       :: String
  , type_       :: PlayerKind
  , value       :: Int
  , fallSpeed   :: Int
  , moveSpeed   :: Int
  , flying      :: Boolean
  , movePattern :: String
}

defaultPlayerType :: PlayerType
defaultPlayerType
  = { frames: 18
    , img: "egg-sprite.png"
    , multiplier: 1
    , title: "The Egg"
    , type_: Egg
    , value: 1
    , fallSpeed: 1
    , moveSpeed: 1
    , flying: false
    , movePattern: "normal"
    }
