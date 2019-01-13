import { fromJS, List } from "immutable";

import { Coords } from "../objects/Coords";
import { Player } from "../objects/Player";

import { playerTypes } from "../data/PlayerTypes";
import { Utils } from "./Utils";

import * as _ from "ramda";

export class Collisions {

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
}
