module Egg.Types.Score where

import Data.Show
import Data.Eq (class Eq)
import Data.Ord (class Ord)
import Data.Semiring (class Semiring)

newtype Score = Score Int

derive newtype instance showScore     :: Show Score
derive newtype instance eqScore       :: Eq Score
derive newtype instance ordScore      :: Ord Score
derive newtype instance semiringScore :: Semiring Score