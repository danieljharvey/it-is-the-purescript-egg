module Egg.Types.ResourceUrl where

import Data.Show
import Data.Eq (class Eq)
import Data.Ord (class Ord)
import Data.Semigroup ((<>))

-- alias for Filename
type Filename = String

-- resourceUrl - unique identifier of a resource
data ResourceUrl = TileResource Filename
                 | SpriteResource Filename
                 | LevelResource Int

derive instance eqResourceUrl :: Eq ResourceUrl
derive instance ordResourceUrl :: Ord ResourceUrl

instance showResourceUrl :: Show ResourceUrl where
  show (TileResource path) = "/img/tiles/" <> path <> ".png"
  show (SpriteResource path) = "/img/sprites/" <> path <> ".png"
  show (LevelResource num) = "/levels/" <> (show num) <> ".json"
