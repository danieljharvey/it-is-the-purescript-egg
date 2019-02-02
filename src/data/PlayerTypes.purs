module Egg.Data.PlayerTypes where

import Egg.Types.PlayerType (PlayerKind(..), PlayerType, defaultPlayerType)
import Egg.Types.ResourceUrl (ResourceUrl(..))

import Prelude
import Data.List as List
import Data.Map as M
import Data.Tuple (Tuple(..))

spriteResources :: List.List ResourceUrl
spriteResources = List.fromFoldable sprites
  where
    sprites
      = _.img <$> playerTypes

playerTypes :: M.Map PlayerKind PlayerType
playerTypes
 = M.fromFoldable [
    Tuple Egg defaultPlayerType {
      frames= 18,
      img= SpriteResource "egg-sprite",
      multiplier= 1,
      title= "It is of course the egg",
      type_= Egg,
      value= 1
    },
    Tuple RedEgg defaultPlayerType {
      frames= 18,
      img= SpriteResource "egg-sprite-red",
      multiplier= 2,
      title= "It is of course the red egg",
      type_= RedEgg,
      value= 2
    },
    Tuple BlueEgg defaultPlayerType {
      frames= 18,
      img= SpriteResource "egg-sprite-blue",
      multiplier= 5,
      title= "It is of course the blue egg",
      type_= BlueEgg,
      value= 3
    },
    Tuple YellowEgg defaultPlayerType {
      frames= 18,
      img= SpriteResource "egg-sprite-yellow",
      multiplier= 10,
      title= "It is of course the yellow egg",
      type_= YellowEgg,
      value= 4
    },
    Tuple RainbowEgg defaultPlayerType {
      frames= 18,
      img= SpriteResource "egg-rainbow",
      multiplier= 1,
      title= "It goes without saying that this is the rainbow egg",
      type_= RainbowEgg,
      value= 1
    },
    Tuple SilverEgg defaultPlayerType {
      fallSpeed= 20,
      frames= 1,
      img= SpriteResource "silver-egg",
      moveSpeed= 0,
      multiplier= 10,
      title= "It is of course the silver egg",
      type_= SilverEgg,
      value= 0
    },
    Tuple Blade defaultPlayerType {
      frames= 18,
      img= SpriteResource "blade-sprite",
      title= "It is the mean spirited blade",
      type_= Blade,
      value= 0,
      flying= true
    },
    Tuple FindBlade defaultPlayerType {
      frames= 18,
      img= SpriteResource "find-blade-sprite",
      title= "It is the mean spirited blade",
      type_= FindBlade,
      value= 0,
      movePattern= "seek-egg",
      flying= true
    }
]
