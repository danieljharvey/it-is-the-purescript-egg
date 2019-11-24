module Egg.Types.Clockwise where

import Data.Eq
import Data.Ord
import Data.Show

data Clockwise 
  = Clockwise
  | AntiClockwise

derive instance eqClockwise :: Eq Clockwise
derive instance ordClockwise :: Ord Clockwise

instance showClockwise :: Show Clockwise where
  show Clockwise     = "Clockwise"
  show AntiClockwise = "AntiClockwise"
