module Egg.Types.Tile (Tile, TileMap, JSONTile, tileSize, emptyTile, defaultTile) where

import Data.Map as M

-- tile of actual tile image
tileSize :: Int
tileSize = 64

type TileMap = M.Map Int Tile

type Tile =
  { id           :: Int
  , title        :: String
  , img      :: String
  , background   :: Boolean
  , frontLayer   :: Boolean
  , collectable  :: Int
  , breakable    :: Boolean
  , action       :: String
  , dontAdd      :: Boolean
  , createPlayer :: String
  , x            :: Int
  , y            :: Int
  }

emptyTile :: Tile
emptyTile =
  defaultTile
    { background = true
    , id         = 1
    , img        = "sky"
    , title      = "Title"
    }

defaultTile :: Tile
defaultTile =
  { action: ""
  , background: false
  , breakable: false
  , collectable: 0
  , createPlayer: ""
  , dontAdd: false
  , frontLayer: false
  , id: 0
  , img: ""
  , title: "Title"
  , x: 0
  , y: 0
}

type JSONTile
  = { id :: Int }
