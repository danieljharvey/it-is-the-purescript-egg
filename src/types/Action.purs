module Egg.Types.Action where

import Data.Eq (class Eq)
import Data.Ord

data Action = Paused
            | Playing
            | RotateAntiClockwise
            | RotateClockwise

derive instance eqAction  :: Eq Action
derive instance ordAction :: Ord Action
