module Egg.Logic.CreatePlayers where

import Prelude

import Egg.Types.Board (Board, RenderItem)
import Egg.Types.Player (Player)
import Egg.Types.PlayerType (PlayerType)
import Egg.Types.Coord (Coord, createCoord)

import Data.Maybe (Maybe(..))
import Data.Array as Arr
import Matrix as Mat

getPlayersFromBoard :: Board -> Array Player
getPlayersFromBoard board
  = Arr.catMaybes (createPlayerFromTile <$> tiles)
    where
      tiles
        = Mat.toIndexedArray board

createPlayerFromTile :: RenderItem -> Maybe Player
createPlayerFromTile renderItem
  = Nothing

createPlayer :: Int -> PlayerType -> Coord -> Player
createPlayer i playerType coord
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
