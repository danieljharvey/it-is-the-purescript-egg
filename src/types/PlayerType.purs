module Egg.Types.PlayerType (PlayerType, defaultPlayerType) where

type PlayerType =
  { frames      :: Int
  , img         :: String
  , multiplier  :: Int
  , title       :: String
  , type_       :: String
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
    , type_: "egg"
    , value: 1
    , fallSpeed: 1
    , moveSpeed: 1
    , flying: false
    , movePattern: "normal"
    }
