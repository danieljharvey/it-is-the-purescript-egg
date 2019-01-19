module Egg.Types.ResourceUrl (
  Filename,
  ResourceUrl(..)
  ) where

import Data.Show
import Data.Eq (class Eq)
import Data.Ord (class Ord)
import Data.Semigroup ((<>))

-- alias for Filename
type Filename = String

-- resourceUrl - unique identifier of a resource
data ResourceUrl = ImageResource Filename
                 | LevelResource Int

derive instance eqResourceUrl :: Eq ResourceUrl
derive instance ordResourceUrl :: Ord ResourceUrl

instance showResourceUrl :: Show ResourceUrl where
  show (ImageResource path) = "/img/" <> path <> ".png"
  show (LevelResource num) = "/levels/" <> (show num) <> ".json"
