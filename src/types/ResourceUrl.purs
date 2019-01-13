module Egg.Types.ResourceUrl (
  Filename,
  ResourceUrl,
  ResourceType(..),
  createResourceUrl
  ) where

import Data.Show
import Data.Semigroup ((<>))

type Filename = String

data ResourceUrl = ResourceUrl ResourceType Filename

createResourceUrl :: ResourceType -> Filename -> ResourceUrl
createResourceUrl rt path = ResourceUrl rt path

instance showResourceUrl :: Show ResourceUrl where
  show (ResourceUrl Image path) = "/img/" <> path

data ResourceType = Image
