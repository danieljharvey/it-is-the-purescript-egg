module Egg.Types.Outcome where

import Data.Show
import Data.Eq (class Eq)

data Outcome
  = KeepPlaying
  | BackAtTheEggCup

instance showOutcome :: Show Outcome where
  show KeepPlaying = "KeepPlaying"
  show BackAtTheEggCup = "BackAtTheEggCup"

derive instance eqOutcome :: Eq Outcome
