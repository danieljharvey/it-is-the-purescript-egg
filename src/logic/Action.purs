module Egg.Logic.Action where

-- collisions between player and items on the board
import Prelude
import Data.Foldable (foldr)
import Data.Maybe (Maybe(..))
import Egg.Logic.Board (getTileByCoord, replaceTile)
import Egg.Types.Board (Board)
import Egg.Types.Coord (Coord, createCoord, isCentered)
import Egg.Types.GameState (GameState)
import Egg.Types.Outcome (Outcome(..))
import Egg.Types.Player (Player)
import Egg.Types.Score (Score(..))
import Egg.Types.Tile (Tile, emptyTile)
import Egg.Types.TileAction (SwitchColour(..), TileAction(..))
import Egg.Logic.Map as Map

checkAllActions :: GameState -> GameState
checkAllActions =
  checkAllPlayerTileActions
    <<< checkAllTilesBelowPlayer

checkAllPlayerTileActions :: GameState -> GameState
checkAllPlayerTileActions gameState = foldr checkPlayer gameState gameState.players
  where
  checkPlayer player gameState' =
    let
      tileReturn = checkPlayerTileAction player gameState'.board gameState'.score gameState'.outcome
    in
      gameState'
        { outcome = tileReturn.outcome
        , board = tileReturn.board
        , score = tileReturn.score
        }

type TileReturn
  = { outcome :: Outcome
    , board :: Board
    , score :: Score
    }

checkPlayerTileAction :: Player -> Board -> Score -> Outcome -> TileReturn
checkPlayerTileAction player board score outcome = case _.action <$> getPlayerTile player board of
  Just tileAction -> doTileAction tileAction player.coords { outcome, board, score }
  _ -> { outcome, board, score }

playerIsOverTile :: Player -> Boolean
playerIsOverTile player = isCentered player.coords && player.moved

getPlayerTile :: Player -> Board -> Maybe Tile
getPlayerTile player board =
  if playerIsOverTile player then
    Just (getTileByCoord board player.coords)
  else
    Nothing

doTileAction :: TileAction -> Coord -> TileReturn -> TileReturn
doTileAction action coords vals = case action of
  Collectable i -> collectItem (Score i) coords vals
  CompleteLevel -> returnOutcome (BackAtTheEggCup) vals
  Switch colour -> doSwitch colour vals
  _ -> vals

returnOutcome :: Outcome -> TileReturn -> TileReturn
returnOutcome newOutcome vals = vals { outcome = newOutcome }

collectItem :: Score -> Coord -> TileReturn -> TileReturn
collectItem addScore coords { outcome, board, score } =
  { outcome
  , board: newBoard
  , score: score + addScore
  }
  where
  newBoard = replaceTile board coords emptyTile

doSwitch :: SwitchColour -> TileReturn -> TileReturn
doSwitch colour vals = case colour of
  Pink -> vals { board = newBoard 15 16 }
  Green -> vals { board = newBoard 18 19 }
  where
  newBoard old new = Map.switchTiles old new vals.board

checkAllTilesBelowPlayer :: GameState -> GameState
checkAllTilesBelowPlayer gameState =
  let
    combine = \player' -> \board' -> checkTileBelowPlayer board' player'

    newBoard = foldr combine gameState.board gameState.players
  in
    gameState { board = newBoard }

checkTileBelowPlayer :: Board -> Player -> Board
checkTileBelowPlayer board player =
  let
    belowCoords = player.coords <> createCoord 0 1

    belowTile = getTileByCoord board belowCoords
  in
    if belowTile.breakable && player.falling then
      replaceTile board belowCoords emptyTile
    else
      board
