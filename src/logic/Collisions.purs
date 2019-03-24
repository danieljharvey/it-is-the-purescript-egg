module Egg.Logic.Collisions where

import Control.MonadZero (guard)
import Data.Tuple (Tuple(..))
import Prelude

import Data.Array (filter, zipWith, range, length)
import Data.Maybe (Maybe(..))
import Egg.Types.Coord (Coord, difference, totalX, totalY)
import Egg.Types.LastAction (LastAction(..))
import Egg.Types.Player (Player)
import Egg.Types.PlayerType (PlayerKind(..))

collisionDistance :: Int
collisionDistance = 30

checkAllCollisions :: Array Player -> Array Player
checkAllCollisions players = players

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


{-

  public checkAllCollisions(players: Player[]): Player[] {
    const combinations = this.getAllPlayerCombinations(players);

    // only one egg, do nothing
    if (combinations.length === 0) {
      return players;
    }

    const collided = this.findCollisions(combinations, players);

    if (collided.length === 0) {
      return players;
    }

    const oldPlayers = this.removeCollidedPlayers(collided, players);

    const newPlayers = this.createNewPlayers(collided, players);

    const allPlayers = this.combinePlayerLists(oldPlayers, newPlayers);

    return allPlayers;
  }

  protected combinePlayerLists(
    oldPlayers: Player[],
    newPlayers: Player[]
  ): Player[] {
    const allPlayers = [];
    oldPlayers.map(player => {
      allPlayers.push(player);
    });
    newPlayers.map(player => {
      allPlayers.push(player);
    });
    return fromJS(allPlayers);
  }

  // send an array of pairs of player ids, returns all that collide
  protected findCollisions(
    combinations: number[][],
    players: Player[]
  ): number[][] {
    return combinations.filter(comb => {
      const player1 = this.fetchPlayerByID(players, comb[0]);
      const player2 = this.fetchPlayerByID(players, comb[1]);
      return this.checkCollision(player1, player2);
    });
  }

  // returns all non-collided players
  // collided is any number of pairs of IDs, ie [[1,3], [3,5]]
  protected removeCollidedPlayers(
    collided: number[][],
    players: Player[]
  ): Player[] {
    const collidedIDs = Utils.flattenArray(collided);
    const uniqueIDs = Utils.removeDuplicates(collidedIDs);

    return players.filter(player => {
      if (uniqueIDs.indexOf(player.id) === -1) {
        return true;
      }
      return false;
    });
  }

  // go through each collided pair and combine the players to create new ones
  protected createNewPlayers(collided, players: Player[]): Player[] {
    return collided.reduce((newPlayers, collidedIDs) => {
      const player1 = this.fetchPlayerByID(players, collidedIDs[0]);
      const player2 = this.fetchPlayerByID(players, collidedIDs[1]);
      if (player1 === null || player2 === null) {
        return newPlayers;
      }
      const newOnes = this.combinePlayers(player1, player2);
      return newPlayers.concat(newOnes);
    }, []);
  }

  protected fetchPlayerByID(players: Player[], id: number): Player {
    const matching = players.filter(player => {
      return player.id === id;
    });

    if (matching.length === 0) {
      return null;
    }

    // we've found one then

    return _.find(item => {
      return item !== undefined;
    }, matching);
  }

  protected getAllPlayerCombinations(players: Player[]): number[][] {
    return players.reduce((total, player) => {
      const otherPlayers = players.filter(otherPlayer => {
        return player.id < otherPlayer.id;
      });
      const combos = otherPlayers.map(otherPlayer => {
        return [player.id, otherPlayer.id];
      });
      return total.concat(this.cleanCombos(combos));
    }, []);
  }

  // un-immutables values for sanity's sake
  protected cleanCombos(combo: any): number[] {
    if (List.isList(combo)) {
      return combo.toJS();
    }
    return combo;
  }

  protected getAllPlayerIDs(players: Player[]) {
    return players.map(player => {
      return player.id;
    });
  }

  // only deal with horizontal collisions for now
  protected checkCollision(player1: Player, player2: Player) {
    if (!player1 || !player2) {
      return false;
    }

    if (player1.id === player2.id) {
      return false;
    }

    if (player1.value === 0 || player2.value === 0) {
      return false;
    }

    if (player1.lastAction === "split" || player2.lastAction === "split") {
      return false;
    }

    const coords1 = player1.coords;
    const coords2 = player2.coords;

    if (coords1.y !== coords2.y) {
      return false;
    }

    let distance =
      coords1.getActualPosition().fullX - coords2.getActualPosition().fullX;
    if (distance < 0) {
      distance = distance * -1;
    }

    if (distance <= 20) {
      return true;
    }

    // nothing changes
    return false;
  }

  protected chooseHigherLevelPlayer(player1: Player, player2: Player) {
    if (player1.value > player2.value) {
      return player1;
    }
    if (player2.value > player1.value) {
      return player2;
    }
    if (player1.value === player2.value) {
      return player1;
    }
  }

  protected combinePlayers(player1: Player, player2: Player): Player[] {
    const newValue = player1.value + player2.value;
    const higherPlayer = this.chooseHigherLevelPlayer(player1, player2);

    const maybePlayerType = Utils.getPlayerTypeByValue(newValue);
    return maybePlayerType.map(newPlayerType => {
      
      const newParams = {
        ...newPlayerType,
        coords: higherPlayer.coords,
        direction: higherPlayer.direction
      }

      return [player1.modify(newParams)];
    }).valueOr([player1, player2])

    
  }

-}