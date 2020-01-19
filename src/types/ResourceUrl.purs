module Egg.Types.ResourceUrl where

import Data.Show (class Show, show)
import Data.Eq (class Eq)
import Data.Ord (class Ord)
import Data.Semigroup ((<>))
import Egg.Types.GamePlayType

-- alias for Filename
type Filename = String

-- resourceUrl - unique identifier of a resource
data ResourceUrl = TileResource Filename
                 | SpriteResource Filename
                 | LevelResource Int
                 | RemoteLevelResource LevelUrl 

derive instance eqResourceUrl :: Eq ResourceUrl
derive instance ordResourceUrl :: Ord ResourceUrl

instance showResourceUrl :: Show ResourceUrl where
  show (TileResource path) = "/img/tiles/" <> path <> ".png"
  show (SpriteResource path) = "/img/sprites/" <> path <> ".png"
  show (LevelResource num) = "/levels/" <> (show num) <> ".json"
  show (RemoteLevelResource url) = show url
