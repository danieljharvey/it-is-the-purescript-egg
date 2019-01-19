module Egg.Data.TileSet (tiles, tileResources) where

import Prelude ((<$>))
import Egg.Types.Tile (Tile, defaultTile)

import Egg.Types.ResourceUrl (ResourceUrl(ImageResource))

tileResources :: Array ResourceUrl
tileResources = (\tile -> ImageResource tile.img) <$> tiles

tiles :: Array Tile
tiles = [
    defaultTile {
      background = true,
      id         = 1,
      img        = "sky",
      title      = "Sky"
    },
    defaultTile {
      background = false,
      id         = 2,
      img        = "fabric",
      title      = "Fabric"
    },
    defaultTile {
      background  = true,
      collectable = 1,
      frontLayer  = true,
      id          = 3,
      img         = "cacti",
      title       = "Cacti"
    },
    defaultTile {
      background  = true,
      collectable = 10,
      frontLayer  = true,
      id          = 4,
      img         = "plant",
      title       = "Plant"
    },
    defaultTile {
      background = false,
      breakable  = true,
      id         = 5,
      img        = "crate",
      title      = "Crate"
    },
    defaultTile {
      background = false,
      id         = 8,
      img        = "work-surface-2",
      title      = "Work surface 2"
    },
    defaultTile {
      background = false,
      id         = 9,
      img        = "work-surface-3",
      title      = "Work surface 3"
    },
    defaultTile {
      background = false,
      id         = 10,
      img        = "work-surface-4",
      title      = "Work surface 4"
    },
    defaultTile {
      background = false,
      id         = 11,
      img        = "tile",
      title      = "Tiles"
    },
    defaultTile {
      action       = "completeLevel",
      background   = true,
      createPlayer = "egg",
      frontLayer   = true,
      id           = 12,
      img          = "egg-cup",
      title        = "Egg Cup"
    },
    defaultTile {
      background  = true,
      collectable = 100,
      dontAdd     = true,
      frontLayer  = true,
      id          = 13,
      img         = "toast",
      title       = "Toast"
  },
  defaultTile {
    action     = "teleport",
    background = true,
    frontLayer = true,
    id         = 14,
    img        = "door",
    title      = "Door"
  },
  defaultTile {
    background = true,
    frontLayer = true,
    id         = 15,
    img        = "pink-door-open",
    title      = "Pink door open"
  },
  defaultTile {
    background = false,
    id         = 16,
    img        = "pink-door",
    title      = "Pink door closed"
  },
  defaultTile {
    action     = "pink-switch",
    background = true,
    frontLayer = true,
    id         = 17,
    img        = "pink-switch",
    title      = "Pink door switch"
  },
  defaultTile {
    background = true,
    frontLayer = true,
    id         = 18,
    img        = "green-door-open",
    title      = "Green door open"
  },
  defaultTile {
    background = false,
    id         = 19,
    img        = "green-door",
    title      = "Green door closed"
  },
  defaultTile {
    action     = "green-switch",
    background = true,
    frontLayer = true,
    id         = 20,
    img        = "green-switch",
    title      = "Green door switch"
  },
  defaultTile {
    background   = true,
    createPlayer = "silver-egg",
    frontLayer   = true,
    id           = 21,
    img          = "silver-egg-cup",
    title        = "Silver Egg Cup"
  },
  defaultTile {
    background   = true,
    createPlayer = "blade",
    frontLayer   = true,
    id           = 22,
    img          = "blade-egg-cup",
    title        = "Blade egg cup"
  },
  defaultTile {
    background   = true,
    createPlayer = "find-blade",
    frontLayer   = true,
    id           = 23,
    img          = "find-blade-egg-cup",
    title        = "Find-blade egg cup"
  },
  defaultTile {
    background = true,
    id         = 24,
    action     = "split-eggs",
    frontLayer = true,
    img        = "egg-splitter",
    title      = "It is the egg splitter"
  }
]
