module Egg.Types.Clockwise where

import Data.Eq
import Data.Ord

data Clockwise 
  = Clockwise
  | AntiClockwise

derive instance eqClockwise :: Eq Clockwise
derive instance ordClockwise :: Ord Clockwise