module Egg.Types.Tile (Tile, defaultTile) where

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
