module Egg.Data.PlayerTypes where

import Egg.Types.PlayerType

playerTypes :: Array PlayerType
playerTypes
 = [
    defaultPlayerType {
      frames= 18,
      img= "egg-sprite.png",
      multiplier= 1,
      title= "It is of course the egg",
      type_= "egg",
      value= 1
    },
    defaultPlayerType {
      frames= 18,
      img= "egg-sprite-red.png",
      multiplier= 2,
      title= "It is of course the red egg",
      type_= "red-egg",
      value= 2
    },
    defaultPlayerType {
      frames= 18,
      img= "egg-sprite-blue.png",
      multiplier= 5,
      title= "It is of course the blue egg",
      type_= "blue-egg",
      value= 3
    },
    defaultPlayerType {
      frames= 18,
      img= "egg-sprite-yellow.png",
      multiplier= 10,
      title= "It is of course the yellow egg",
      type_= "yellow-egg",
      value= 4
    },
    defaultPlayerType {
      frames= 18,
      img= "egg-rainbow.png",
      multiplier= 1,
      title= "It goes without saying that this is the rainbow egg",
      type_= "rainbow-egg",
      value= 1
    },
    defaultPlayerType {
      fallSpeed= 20,
      frames= 1,
      img= "silver-egg.png",
      moveSpeed= 0,
      multiplier= 10,
      title= "It is of course the silver egg",
      type_= "silver-egg",
      value= 0
    },
    defaultPlayerType {
      frames= 18,
      img= "blade-sprite.png",
      title= "It is the mean spirited blade",
      type_= "blade",
      value= 0,
      flying= true
    },
    defaultPlayerType {
      frames= 18,
      img= "find-blade-sprite.png",
      title= "It is the mean spirited blade",
      type_= "find-blade",
      value= 0,
      movePattern= "seek-egg",
      flying= true
    }
]
