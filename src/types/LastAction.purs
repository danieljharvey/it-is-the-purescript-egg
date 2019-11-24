module Egg.Types.LastAction where

import Data.Eq (class Eq)
import Data.Ord (class Ord)
import Data.Show

data LastAction
  = Split
  | Teleported

derive instance eqLastAction :: Eq LastAction

derive instance ordLastAction :: Ord LastAction

instance showLastAction :: Show LastAction where
  show Split = "Split"
  show Teleported = "Teleported"
