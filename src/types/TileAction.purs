module Egg.Types.TileAction where

import Data.Eq (class Eq)
import Data.Ord (class Ord)
import Data.Show
import Data.Semigroup ((<>))

data SwitchColour
  = Pink
  | Green

derive instance eqSwitchColour  :: Eq SwitchColour
derive instance ordSwitchColour :: Ord SwitchColour

data TileAction
 = NoOp
 | Collectable Int
 | CompleteLevel
 | Switch SwitchColour
 | Teleport
 | SplitEggs

derive instance eqTileAction  :: Eq TileAction
derive instance ordTileAction :: Ord TileAction

instance showTileAction :: Show TileAction where
  show NoOp            = "NoOp"
  show (Collectable i) = "Collectable " <> show i
  show CompleteLevel   = "CompleteLevel"
  show (Switch Pink)   = "Pink Switch"
  show (Switch Green)  = "Green Switch"
  show Teleport        = "Teleport"
  show SplitEggs       = "SplitEggs"