module Egg.Types.ResourceUrl (
  Filename,
  ResourceUrl,
  ResourceType(..),
  createResourceUrl
  ) where

import Data.Show
import Data.Eq (class Eq)
import Data.Ord (class Ord)
import Data.Semigroup ((<>))

-- alias for Filename
type Filename = String

-- type of resource, dictates source folder and file ext
data ResourceType = Image

derive instance eqResourceType :: Eq ResourceType
derive instance ordResourceType :: Ord ResourceType

-- resourceUrl - unique identifier of a resource
data ResourceUrl = ResourceUrl ResourceType Filename

createResourceUrl :: ResourceType -> Filename -> ResourceUrl
createResourceUrl rt path = ResourceUrl rt path

derive instance eqResourceUrl :: Eq ResourceUrl
derive instance ordResourceUrl :: Ord ResourceUrl

instance showResourceUrl :: Show ResourceUrl where
  show (ResourceUrl Image path) = "/img/" <> path <> ".png"
