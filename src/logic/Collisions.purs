module Egg.Logic.Collisions where

import Prelude

import Control.MonadZero (guard)
import Data.Array (concatMap, filter, zipWith, range, length)
import Data.Foldable (foldr)
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..))
import Egg.Types.Coord (Coord, difference, totalX, totalY)
import Egg.Types.LastAction (LastAction(..))
import Egg.Types.Player (Player)
import Egg.Types.PlayerType (PlayerKind(..), playerValue, valueToPlayer)
import Egg.Data.PlayerTypes (getPlayerType)

collisionDistance :: Int
collisionDistance = 30

checkAllCollisions :: Array Player -> Array Player
checkAllCollisions players 
  = remaining <> newPlayers
  where
    remaining
      = removeCollided pairs players

    pairs
      = collidedPairs players

    newPlayers
      = concatMap combinePlayers pairs

collidedPairs :: Array Player -> Array (Tuple Player Player)
collidedPairs players
  = filter (\(Tuple a b) -> checkCollision a b) (uniquePairs players)

alwaysPositive :: Int -> Int
alwaysPositive i
  = if i < 0 
    then negate i
    else i

checkCollision :: Player -> Player -> Boolean
checkCollision player1 player2
  =  player1 /= player2 
  && (highestDistance player1.coords player2.coords) < collisionDistance
  && isCollidable player1
  && isCollidable player2
  && not (justSplit player1)
  && not (justSplit player2)

justSplit :: Player -> Boolean
justSplit player
  = case player.lastAction of
      Just Split -> true
      _          -> false

isCollidable :: Player -> Boolean
isCollidable player
  = case player.playerType.type_ of
      SilverEgg -> false
      _         -> true

highestDistance :: Coord -> Coord -> Int
highestDistance first second
  = max (alwaysPositive $ totalX distance) (alwaysPositive $ totalY distance)
  where
    distance 
      = difference first second

zipWithIndex :: forall a. Array a -> Array (Tuple Int a)
zipWithIndex as
  = zipWith Tuple (range 0 (length as - 1)) as

uniquePairs :: forall a. (Eq a) => Array a -> Array (Tuple a a)
uniquePairs items = do
  (Tuple idX x) <- zipWithIndex items
  (Tuple idY y) <- zipWithIndex items
  guard (idX < idY)
  pure (Tuple x y)

removeCollided :: Array (Tuple Player Player) -> Array Player -> Array Player
removeCollided pairs players
  = filter (not $ inPairs pairs) players

inPairs :: Array (Tuple Player Player) -> Player -> Boolean
inPairs pairs player 
  = foldr (||) false ((inPair player) <$> pairs)

inPair :: Player -> Tuple Player Player -> Boolean
inPair c (Tuple a b) 
  = (c == a || c == b)

combinePlayers :: Tuple Player Player -> Array Player
combinePlayers (Tuple p1 p2) 
  = case getNewKinds p1.playerType.type_ p2.playerType.type_ of
      Just k  -> [p1 { playerType = getPlayerType k }]
      Nothing -> [p1, p2]

getNewKinds :: PlayerKind -> PlayerKind -> Maybe PlayerKind
getNewKinds p1 p2
  = valueToPlayer (playerValue p1 + playerValue p2)
