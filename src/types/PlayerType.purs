module Egg.Types.PlayerType where

import Data.Eq (class Eq)
import Data.Ord (class Ord)
import Data.Show (class Show)

import Egg.Types.ResourceUrl

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

derive instance ordPlayerKind :: Ord PlayerKind

instance showPlayerKind :: Show PlayerKind where
  show Egg = "Egg"
  show RedEgg = "Red Egg"
  show BlueEgg = "Blue Egg"
  show YellowEgg = "Yellow Egg"
  show RainbowEgg = "Rainbow Egg"
  show SilverEgg = "Silver Egg"
  show Blade = "Blade"
  show FindBlade = "Find Blade"

type PlayerType =
  { frames      :: Int
  , img         :: ResourceUrl
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
    , img: SpriteResource "egg-sprite"
    , multiplier: 1
    , title: "The Egg"
    , type_: Egg
    , value: 1
    , fallSpeed: 1
    , moveSpeed: 1
    , flying: false
    , movePattern: "normal"
    }
