module Egg.Data.TileSet (tiles, tileResources) where

import Prelude ((<$>))
import Egg.Types.Tile (Tile, defaultTile, emptyTile)
import Data.List (List)
import Data.Map as M
import Data.Tuple (Tuple(..))
import Data.Maybe

import Egg.Types.PlayerType
import Egg.Types.ResourceUrl

tileResources :: List ResourceUrl
tileResources = (\tile -> TileResource tile.img) <$> M.values tiles

tiles :: M.Map Int Tile
tiles = M.fromFoldable [
    Tuple 1 emptyTile,

    Tuple 2 defaultTile {
      background = false,
      id         = 2,
      img        = "fabric",
      title      = "Fabric"
    },
    Tuple 3 defaultTile {
      background  = true,
      collectable = 1,
      frontLayer  = true,
      id          = 3,
      img         = "cacti",
      title       = "Cacti"
    },
    Tuple 4 defaultTile {
      background  = true,
      collectable = 10,
      frontLayer  = true,
      id          = 4,
      img         = "plant",
      title       = "Plant"
    },
    Tuple 5 defaultTile {
      background = false,
      breakable  = true,
      id         = 5,
      img        = "crate",
      title      = "Crate"
    },
    Tuple 8 defaultTile {
      background = false,
      id         = 8,
      img        = "work-surface-2",
      title      = "Work surface 2"
    },
    Tuple 9 defaultTile {
      background = false,
      id         = 9,
      img        = "work-surface-3",
      title      = "Work surface 3"
    },
    Tuple 10 defaultTile {
      background = false,
      id         = 10,
      img        = "work-surface-4",
      title      = "Work surface 4"
    },
    Tuple 11 defaultTile {
      background = false,
      id         = 11,
      img        = "tile",
      title      = "Tiles"
    },
    Tuple 12 defaultTile {
      action       = "completeLevel",
      background   = true,
      createPlayer = Just Egg,
      frontLayer   = true,
      id           = 12,
      img          = "egg-cup",
      title        = "Egg Cup"
    },
    Tuple 13 defaultTile {
      background  = true,
      collectable = 100,
      dontAdd     = true,
      frontLayer  = true,
      id          = 13,
      img         = "toast",
      title       = "Toast"
    },
    Tuple 14 defaultTile {
      action     = "teleport",
      background = true,
      frontLayer = true,
      id         = 14,
      img        = "door",
      title      = "Door"
    },
    Tuple 15 defaultTile {
      background = true,
      frontLayer = true,
      id         = 15,
      img        = "pink-door-open",
      title      = "Pink door open"
    },
    Tuple 16 defaultTile {
      background = false,
      id         = 16,
      img        = "pink-door",
      title      = "Pink door closed"
    },
    Tuple 17 defaultTile {
      action     = "pink-switch",
      background = true,
      frontLayer = true,
      id         = 17,
      img        = "pink-switch",
      title      = "Pink door switch"
    },
    Tuple 18 defaultTile {
      background = true,
      frontLayer = true,
      id         = 18,
      img        = "green-door-open",
      title      = "Green door open"
    },
    Tuple 19 defaultTile {
      background = false,
      id         = 19,
      img        = "green-door",
      title      = "Green door closed"
    },
    Tuple 20 defaultTile {
      action     = "green-switch",
      background = true,
      frontLayer = true,
      id         = 20,
      img        = "green-switch",
      title      = "Green door switch"
    },
    Tuple 21 defaultTile {
      background   = true,
      createPlayer = Just SilverEgg,
      frontLayer   = true,
      id           = 21,
      img          = "silver-egg-cup",
      title        = "Silver Egg Cup"
    },
    Tuple 22 defaultTile {
      background   = true,
      createPlayer = Just Blade,
      frontLayer   = true,
      id           = 22,
      img          = "blade-egg-cup",
      title        = "Blade egg cup"
    },
    Tuple 23 defaultTile {
      background   = true,
      createPlayer = Just FindBlade,
      frontLayer   = true,
      id           = 23,
      img          = "find-blade-egg-cup",
      title        = "Find-blade egg cup"
    },
    Tuple 24 defaultTile {
      background = true,
      id         = 24,
      action     = "split-eggs",
      frontLayer = true,
      img        = "egg-splitter",
      title      = "It is the egg splitter"
    }
  ]
