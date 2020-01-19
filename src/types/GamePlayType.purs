module Egg.Types.GamePlayType where

import Prelude

newtype LevelUrl
  = LevelUrl String

derive newtype instance eqLevelUrl :: Eq LevelUrl
derive newtype instance ordLevelUrl :: Ord LevelUrl
instance showLevelUrl :: Show LevelUrl where
  show (LevelUrl a) = a

data GamePlayType
  = RegularGame
  | LevelTest LevelUrl


