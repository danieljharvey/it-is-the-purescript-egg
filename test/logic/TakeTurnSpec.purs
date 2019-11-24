module Test.Logic.TakeTurn where

import Prelude (Unit, discard, ($), (<<<), (>>=))
import Egg.Logic.TakeTurn (doAction, checkNearlyFinished)
import Data.Array (length)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions
import Partial.Unsafe (unsafePartial)
import Matrix as Mat
import Data.Map as M
import Data.Maybe (Maybe(..), fromJust, fromMaybe)
import Data.Array as Arr
import Egg.Types.Action (Action(..))
import Egg.Types.GameState (GameState)
import Egg.Types.Board (Board, emptyBoard)
import Egg.Types.PlayerType (PlayerKind(..))
import Egg.Data.TileSet (tiles)
import Egg.Types.Outcome (Outcome(..))
import Egg.Logic.InitialiseLevel (initialiseGameState)

addTile :: Int -> Int -> Board -> Board
addTile i x board = fromMaybe board (eggCup >>= newBoard)
  where
  eggCup = M.lookup i tiles

  newBoard = \ec -> Mat.set x x ec board

addOneEggCup :: Int -> Board -> Board
addOneEggCup = addTile 12

addCacti :: Int -> Board -> Board
addCacti = addTile 3

testGameState :: GameState
testGameState =
  addOutcome
    <<< initialiseGameState
    <<< addOneEggCup 1
    $ emptyBoard 10
  where
  addOutcome gs = gs { outcome = BackAtTheEggCup }

gameStateNotFinished :: GameState
gameStateNotFinished =
  initialiseGameState
    <<< addOneEggCup 2
    <<< addOneEggCup 3
    <<< addCacti 4
    $ emptyBoard 10

tests :: Spec Unit
tests =
  describe "Take turn" do
    describe "doAction" do
      it "Does nothing when Paused" do
        doAction testGameState Paused 1000 `shouldEqual` (Just testGameState)
      it "Does nothing when interval is under 1" do
        doAction testGameState Playing 0 `shouldEqual` (Just testGameState)
      it "Increments turn count when Playing with interval over 0" do
        doAction testGameState Playing 1000 `shouldNotEqual` (Just testGameState)
      it "Does not change into rainbow egg when there are points to get" do
        let
          newGameState = checkNearlyFinished gameStateNotFinished
        newGameState.players `shouldEqual` gameStateNotFinished.players
      it "Should change egg into rainbow egg when there are no points left" do
        let
          newGameState = checkNearlyFinished testGameState
        length newGameState.players `shouldEqual` 1
        let
          newPlayer = unsafePartial (fromJust (Arr.head newGameState.players))
        newPlayer.playerType.type_ `shouldEqual` RainbowEgg
