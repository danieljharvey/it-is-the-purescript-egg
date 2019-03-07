module Egg.Types.Score where

import Data.Show
import Data.Eq (class Eq)

newtype Score = Score Int

derive newtype instance showScore :: Show Score
derive newtype instance eqScore   :: Eq Score