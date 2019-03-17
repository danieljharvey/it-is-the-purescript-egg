module Egg.Types.Action where

import Egg.Types.Clockwise
import Data.Eq (class Eq)
import Data.Ord (class Ord)
import Data.Show

data Action = Paused
            | Playing
            | Turning Clockwise Int

derive instance eqAction  :: Eq Action
derive instance ordAction :: Ord Action

instance showAction :: Show Action where
  show Playing = "Playing"
  show Paused  = "Paused"
  show _       = "I am lazy and have not fully implemented Show for Action"