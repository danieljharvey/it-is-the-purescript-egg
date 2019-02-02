module Test.Logic.TakeTurn where

import Egg.Logic.TakeTurn (doAction)

import Prelude (Unit, discard, (>>=))
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions
import Data.Maybe (fromMaybe)

import Matrix as Mat
import Data.Map as M

import Egg.Types.Action (Action(..))
import Egg.Types.GameState (GameState)
import Egg.Types.Board (Board, emptyBoard)
import Egg.Data.TileSet (tiles)

import Egg.Logic.InitialiseLevel (initialiseGameState)

addOneEggCup :: Board -> Board
addOneEggCup board
  = fromMaybe board (eggCup >>= newBoard)
  where
    eggCup
      = M.lookup 12 tiles

    newBoard
      = \ec -> Mat.set 0 0 ec board

testGameState :: GameState
testGameState = addOutcome (initialiseGameState (addOneEggCup (emptyBoard 10)))
  where
    addOutcome gs = gs { outcome = "test" }

tests :: Spec Unit
tests =
  describe "Take turn" do
    describe "doAction" do
      it "Does nothing when Paused" do
        doAction testGameState Paused 1000 `shouldEqual` testGameState
      it "Does nothing when interval is under 1" do
        doAction testGameState Playing 0 `shouldEqual` testGameState
      it "Increments turn count when Playing with interval over 0" do
        doAction testGameState Playing 1000 `shouldNotEqual` testGameState
      it "Wipes outcome on Playing" do
        let newGameState = doAction testGameState Playing 1000
        newGameState.outcome `shouldEqual` ""
