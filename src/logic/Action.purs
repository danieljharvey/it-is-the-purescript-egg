module Egg.Logic.Action where

-- collisions between player and items on the board

import Prelude

import Data.Foldable (foldr)
import Data.Maybe (Maybe(..))
import Egg.Logic.Board (getTileByCoord, replaceTile)
import Egg.Types.Board (Board)
import Egg.Types.Coord (Coord, isCentered)
import Egg.Types.GameState (GameState)
import Egg.Types.Outcome (Outcome(..))
import Egg.Types.Player (Player)
import Egg.Types.Score (Score(..))
import Egg.Types.Tile (Tile, emptyTile)
import Egg.Types.TileAction (SwitchColour(..), TileAction(..))

import Egg.Logic.Map as Map

checkAllPlayerTileActions :: GameState -> GameState
checkAllPlayerTileActions gameState
  = foldr checkPlayer gameState gameState.players
  where
    checkPlayer player gameState'
      = let tileReturn = checkPlayerTileAction player gameState'.board gameState'.score gameState'.outcome
        in gameState' { outcome = tileReturn.outcome
                      , board   = tileReturn.board
                      , score   = tileReturn.score
                      }

type TileReturn = { outcome :: Outcome
                  , board   :: Board
                  , score   :: Score
                  }

checkPlayerTileAction :: Player -> Board -> Score -> Outcome -> TileReturn
checkPlayerTileAction player board score outcome
  = case _.action <$> getPlayerTile player board of
      Just tileAction -> doTileAction tileAction player.coords { outcome, board, score }
      _               -> { outcome, board, score } 

playerIsOverTile :: Player -> Boolean
playerIsOverTile player
  = isCentered player.coords && player.moved

getPlayerTile :: Player -> Board -> Maybe Tile
getPlayerTile player board
  = if playerIsOverTile player 
    then Just (getTileByCoord board player.coords)
    else Nothing

doTileAction :: TileAction -> Coord -> TileReturn -> TileReturn
doTileAction action coords vals
  = case action of
      Collectable i -> collectItem (Score i) coords vals
      CompleteLevel -> returnOutcome (Outcome "completeLevel") vals
      Switch colour -> doSwitch colour vals
      _             -> vals

returnOutcome :: Outcome -> TileReturn -> TileReturn
returnOutcome newOutcome vals
  = vals { outcome = newOutcome }

collectItem :: Score -> Coord -> TileReturn -> TileReturn
collectItem addScore coords { outcome, board, score }
  = { outcome
    , board: newBoard
    , score: score + addScore 
    }
  where
    newBoard
      = replaceTile board coords emptyTile

doSwitch :: SwitchColour -> TileReturn -> TileReturn
doSwitch colour vals
  = case colour of
      Pink  -> vals { board = newBoard 15 16 }
      Green -> vals { board = newBoard 18 19 }
  where
    newBoard old new
      = Map.switchTiles old new vals.board



{-



export class Action {
  // go through each player, check it's effect on board, score and outcome, return new gameState obj
  public checkAllPlayerTileActions(gameState: GameState): GameState {
    return gameState.players.reduce(
      (currentGameState: GameState, player: Player) => {
        const updated = this.checkPlayerTileAction(
          player,
          currentGameState.board,
          currentGameState.score,
          currentGameState.outcome
        );

        const postCrateBoard = this.checkTileBelowPlayer(player, updated.board);

        return gameState.modify({
          board: postCrateBoard,
          outcome: updated.outcome,
          score: updated.score
        });
      },
      gameState
    );
  }

  protected checkPlayerTileAction(
    player: Player,
    board: Board,
    score: number,
    outcome: string
  ): { outcome: string; board: Board; score: number } {
    const currentCoords = player.coords;

    if (tile.action === "pink-switch") {
      return {
        board: Map.switchTiles(board, 15, 16),
        outcome,
        score
      };
    } else if (tile.action === "green-switch") {
      return {
        board: Map.switchTiles(board, 18, 19),
        outcome,
        score
      };
    }
    return {
      board,
      outcome,
      score
    };
  }

  // basically, do we need to smash the block below?
  protected checkTileBelowPlayer(player: Player, board: Board): Board {
    if (player.falling === false) {
      return board;
    }

    const coords = player.coords;

    const belowCoords = Map.correctForOverflow(
      board,
      coords.modify({ y: coords.y + 1 })
    );

    const tile = board.getTile(belowCoords.x, belowCoords.y);

    if (tile.get("breakable") === true) {
      // if tile below is breakable (and we are already falling and thus have momentum, smash it)
      const newTile = Map.cloneTile(1);
      const newTileWithCoords = newTile.modify({
        x: belowCoords.x,
        y: belowCoords.y
      });
      return board.modify(belowCoords.x, belowCoords.y, newTileWithCoords);
    }
    return board;
  }
}
-}
