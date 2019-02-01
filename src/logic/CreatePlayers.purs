module Egg.Logic.CreatePlayers where

import Prelude

import Egg.Data.PlayerTypes (playerTypes)
import Egg.Types.Board (Board, RenderItem)
import Egg.Types.Player (Player)
import Egg.Types.PlayerType (PlayerKind, PlayerType)
import Egg.Types.Coord (Coord, createCoord)

import Data.Maybe (Maybe)
import Data.Array as Arr
import Matrix as Mat
import Data.Map as M

getPlayersFromBoard :: Board -> Array Player
getPlayersFromBoard board
  = Arr.catMaybes (createPlayerFromTile 0 <$> tiles)
    where
      tiles
        = Mat.toIndexedArray board

getPlayerTypeByKind :: PlayerKind -> Maybe PlayerType
getPlayerTypeByKind playerKind
  = M.lookup playerKind playerTypes

createPlayerFromTile :: Int -> RenderItem -> Maybe Player
createPlayerFromTile i renderItem
  = createPlayer i coord <$> playerType 
  where
    playerType
      = renderItem.value.createPlayer >>= getPlayerTypeByKind
    
    coord 
      = createCoord renderItem.x renderItem.y

createPlayer :: Int -> Coord -> PlayerType -> Player
createPlayer i coord playerType
  = { playerType: playerType
    , coords: coord
    , direction: createCoord 0 0
    , oldDirection: createCoord 0 0
    , currentFrame: 0
    , id: i
    , falling: false
    , stop: false
    , lastAction: ""
    , moved: false
    }
