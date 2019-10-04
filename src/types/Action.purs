module Egg.Types.Action where

import Egg.Types.Clockwise
import Data.Eq (class Eq)
import Data.Ord (class Ord)
import Data.Semigroup
import Data.Show

data Action = Paused
            | Playing
            | Turning Clockwise Int
            | Resize Int Int Action
            | NextLevel

derive instance eqAction  :: Eq Action
derive instance ordAction :: Ord Action

instance showAction :: Show Action where
  show Playing        = "Playing"
  show Paused         = "Paused"
  show (Turning cl i) = "Turning (" <> show cl <> ") (" <> show i <> ")"
  show (Resize x y a) = "Resize (" <> show x <> "," <> show y <> "): " <> show a
  show NextLevel      = "NextLevel"
