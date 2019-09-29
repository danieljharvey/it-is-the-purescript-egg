module Egg.Logic.CreatePlayers where

import Prelude

import Egg.Data.PlayerTypes (playerTypes)
import Egg.Types.Board (Board, RenderItem)
import Egg.Types.Player (Player)
import Egg.Types.PlayerType (PlayerKind, PlayerType)
import Egg.Types.Coord (Coord, createCoord)
import Egg.Types.CurrentFrame (createCurrentFrame)

import Data.Maybe (fromMaybe, Maybe(..))
import Data.Array as Arr
import Matrix as Mat
import Data.Map as M

getPlayersFromBoard :: Board -> Array Player
getPlayersFromBoard board
  = Arr.catMaybes (Arr.mapWithIndex createPlayerFromTile tiles)
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

changePlayerKind :: Player -> PlayerKind -> Player
changePlayerKind player playerKind
  = fromMaybe player newPlayer
  where
    newPlayer
      = (\playerType' -> player { playerType = playerType' })
      <$> getPlayerTypeByKind playerKind 

createPlayer :: Int -> Coord -> PlayerType -> Player
createPlayer i coord playerType
  = { playerType: playerType
    , coords: coord
    , direction: createCoord 1 0
    , oldDirection: createCoord 0 0
    , currentFrame: createCurrentFrame playerType.frames
    , id: i
    , falling: false
    , stop: false
    , lastAction: Nothing
    , moved: false
    }
