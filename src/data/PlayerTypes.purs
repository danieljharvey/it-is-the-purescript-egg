module Egg.Data.PlayerTypes where

import Egg.Types.PlayerType
import Egg.Types.ResourceUrl

import Prelude
import Data.List (List, fromFoldable)
import Data.Array hiding (fromFoldable)
import Data.Map as M

spriteResources :: List ResourceUrl
spriteResources = fromFoldable sprites
  where
    sprites
      = (\playerType -> SpriteResource playerType.img) <$> playerTypes

playerTypes :: Array PlayerType
playerTypes
 = [
    defaultPlayerType {
      frames= 18,
      img= "egg-sprite",
      multiplier= 1,
      title= "It is of course the egg",
      type_= Egg,
      value= 1
    },
    defaultPlayerType {
      frames= 18,
      img= "egg-sprite-red",
      multiplier= 2,
      title= "It is of course the red egg",
      type_= RedEgg,
      value= 2
    },
    defaultPlayerType {
      frames= 18,
      img= "egg-sprite-blue",
      multiplier= 5,
      title= "It is of course the blue egg",
      type_= BlueEgg,
      value= 3
    },
    defaultPlayerType {
      frames= 18,
      img= "egg-sprite-yellow",
      multiplier= 10,
      title= "It is of course the yellow egg",
      type_= YellowEgg,
      value= 4
    },
    defaultPlayerType {
      frames= 18,
      img= "egg-rainbow",
      multiplier= 1,
      title= "It goes without saying that this is the rainbow egg",
      type_= RainbowEgg,
      value= 1
    },
    defaultPlayerType {
      fallSpeed= 20,
      frames= 1,
      img= "silver-egg",
      moveSpeed= 0,
      multiplier= 10,
      title= "It is of course the silver egg",
      type_= SilverEgg,
      value= 0
    },
    defaultPlayerType {
      frames= 18,
      img= "blade-sprite",
      title= "It is the mean spirited blade",
      type_= Blade,
      value= 0,
      flying= true
    },
    defaultPlayerType {
      frames= 18,
      img= "find-blade-sprite",
      title= "It is the mean spirited blade",
      type_= FindBlade,
      value= 0,
      movePattern= "seek-egg",
      flying= true
    }
]
