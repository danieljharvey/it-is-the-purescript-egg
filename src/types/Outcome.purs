module Egg.Types.Outcome where

import Data.Show
import Data.Eq (class Eq)

newtype Outcome = Outcome String

derive newtype instance showOutcome :: Show Outcome
derive newtype instance eqOutcome   :: Eq Outcome