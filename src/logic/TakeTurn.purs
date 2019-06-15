module Egg.Logic.TakeTurn where

import Prelude

import Data.Maybe (Maybe(..))
import Egg.Logic.Action as Action
import Egg.Logic.Board as Board
import Egg.Logic.Map as Map
import Egg.Logic.Movement as Movement
import Egg.Logic.Collisions as Collisions
import Egg.Types.Action (Action(..))
import Egg.Types.Clockwise (Clockwise(..))
import Egg.Types.GameState (GameState)
import Egg.Types.InputEvent (InputEvent(..))
import Egg.Types.Outcome (Outcome(..))
import Egg.Types.Player (Player)
import Egg.Types.RenderAngle (RenderAngle(..))
import Egg.Types.ScreenSize (screenSize)

spinSpeed :: Int
spinSpeed = 3

go :: Int -> Maybe InputEvent -> GameState -> GameState
go i input gs 
  = doAction gameState nextAction i
    where
      gameState
        = setAction nextAction gs
      nextAction
        = calcNextAction gs.current input

-- take input and current game state and work out what we should be doing next
calcNextAction :: Action -> Maybe InputEvent -> Action
calcNextAction (Turning c a) _             = Turning c a
calcNextAction Playing (Just Pause)        = Paused
calcNextAction Paused (Just Pause)         = Playing
calcNextAction Playing (Just LeftArrow)    = Turning AntiClockwise 0
calcNextAction Playing (Just RightArrow)   = Turning Clockwise 0
calcNextAction a (Just (ResizeWindow x y)) = Resize x y a
calcNextAction a _                         = a

doAction :: GameState -> Action -> Int -> GameState
doAction old Paused _  
  = old
doAction old Playing i | i >= 1 
  = doGameMove i old
doAction old Playing _ 
  = old
doAction old (Turning clockwise angle) _ | angle >= 90 
  = doRotate old clockwise
doAction old (Turning clockwise angle) _
  = doTurn clockwise angle old
doAction old (Resize x y action) _
  = resizeBoard x y action old

resizeBoard :: Int -> Int -> Action -> GameState -> GameState
resizeBoard width height oldAction gs
  = gs { screenSize = screenSize width height
       , current    = oldAction
       }

incrementTurnCount :: GameState -> GameState
incrementTurnCount gameState
  = gameState { turns = next }
  where
    next = gameState.turns + 1

doGameMove :: Int -> GameState -> GameState
doGameMove i = Action.checkAllActions 
          <<< (doPlayerMove i) 
          <<< checkCollisions
          <<< incrementTurnCount 
          <<< resetOutcome

checkCollisions :: GameState -> GameState
checkCollisions old
  = old { players = Collisions.checkAllCollisions old.players }

setAction :: Action -> GameState -> GameState
setAction action old
  = old { current = action }

doTurn :: Clockwise -> Int -> GameState -> GameState
doTurn clockwise angle gs
  = case clockwise of 
      Clockwise 
        -> gs { renderAngle = RenderAngle angle
              , current     = next
              }
      AntiClockwise 
        -> gs { renderAngle = RenderAngle (-1 * angle)
              , current     = next
              }
  where
    next
      = Turning clockwise (angle + spinSpeed)
    
doPlayerMove :: Int -> GameState -> GameState
doPlayerMove i old = old { players = newPlayers }
  where
    newPlayers = Movement.movePlayers old.board i old.players

isRainbowEggTime :: GameState -> Array Player
isRainbowEggTime gameState = gameState.players

doRotate :: GameState -> Clockwise -> GameState
doRotate gameState clockwise
  = gameState { rotations   = gameState.rotations + 1
              , board       = Map.rotateBoard clockwise gameState.board
              , players     = Map.rotatePlayer boardSize clockwise <$> gameState.players
              , rotateAngle = Map.changeRenderAngle gameState.rotateAngle clockwise
              , renderAngle = RenderAngle 0
              , current     = Playing
              }
  where
    boardSize
      = Board.boardSizeFromBoard gameState.board

resetOutcome :: GameState -> GameState
resetOutcome gs = gs { outcome = Outcome "" }

{-

  // this is where we have to do a shitload of things
  protected doGameMove(gameState: GameState, timePassed: number): GameState {

    const newGameState = Movement.doCalcs(startGameState, timePassed);

    const action = new Action();
    const newerGameState = action.checkAllPlayerTileActions(newGameState);

    const collisions = new Collisions();
    const sortedPlayers = collisions.checkAllCollisions(newerGameState.players);

    const splitPlayers = BoardCollisions.checkBoardCollisions(
      newerGameState.board,
      sortedPlayers
    );

    const colouredPlayers = this.checkNearlyFinished(
      newerGameState.modify({
        players: splitPlayers
      })
    );

    return newerGameState.modify({
      players: colouredPlayers
    });
  }

  protected checkNearlyFinished = (
    gameState: GameState
  ): Player[] => {
    if (Utils.checkLevelIsCompleted(gameState)) {
      return gameState.players.map(player => {
        if (player.value > 0) {
          const maybeNewPlayer = Utils.getPlayerType("rainbow-egg");
          return maybeNewPlayer.map(newPlayer => {
            return player.modify({
              ...newPlayer
            });
          }).valueOr(player)
        }
        return player;
      });
    }
    return gameState.players;
  };

 
-}
