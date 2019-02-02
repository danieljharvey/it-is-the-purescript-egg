module Egg.Types.Tile (Tile, TileMap, JSONTile, tileSize, emptyTile, defaultTile) where

import Data.Map as M
import Data.Maybe (Maybe(..))
import Egg.Types.PlayerType (PlayerKind)
import Egg.Types.ResourceUrl

-- tile of actual tile image
tileSize :: Int
tileSize = 64

type TileMap = M.Map Int Tile

type Tile =
  { id           :: Int
  , title        :: String
  , img          :: ResourceUrl
  , background   :: Boolean
  , frontLayer   :: Boolean
  , collectable  :: Int
  , breakable    :: Boolean
  , action       :: String
  , dontAdd      :: Boolean
  , createPlayer :: Maybe PlayerKind
  }

emptyTile :: Tile
emptyTile =
  defaultTile
    { background = true
    , id         = 1
    , img        = TileResource "sky"
    , title      = "Title"
    }

defaultTile :: Tile
defaultTile =
  { action: ""
  , background: false
  , breakable: false
  , collectable: 0
  , createPlayer: Nothing
  , dontAdd: false
  , frontLayer: false
  , id: 0
  , img: TileResource "sky"
  , title: "Title"
}

type JSONTile
  = { id :: Int }
