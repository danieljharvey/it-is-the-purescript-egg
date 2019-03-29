module Test.Logic.Collisions where

import Test.Spec.Assertions

import Prelude (Unit, discard, negate)
import Test.Spec (Spec, describe, it)
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..))

import Egg.Logic.Collisions (checkAllCollisions, checkCollision, combinePlayers, removeCollided, uniquePairs)

import Egg.Types.Coord (Coord, createCoord, createFullCoord)
import Egg.Types.LastAction (LastAction(..))
import Egg.Types.Player (Player, defaultPlayer)
import Egg.Types.PlayerType (PlayerKind(..), defaultPlayerType)
import Egg.Data.PlayerTypes (getPlayerType)

createTestPlayer :: Int -> Coord -> PlayerKind -> Player
createTestPlayer i coord kind
  = defaultPlayer { id = i
                  , coords = coord
                  , playerType = getPlayerType kind
                  }

tests :: Spec Unit
tests =
  describe "Collisions" do
    describe "checkAllCollisions" do
      it "List of one players returns list" do
        checkAllCollisions [defaultPlayer] `shouldEqual` [defaultPlayer]
      it "Combines two players, leaves one" do
        let firstPlayer = createTestPlayer 1 (createCoord 1 1) Egg
        let secondPlayer = createTestPlayer 2 (createCoord 20 20) RedEgg
        let thirdPlayer = createTestPlayer 3 (createCoord 20 20) RedEgg
        let combined = secondPlayer { playerType = getPlayerType YellowEgg }
        checkAllCollisions [firstPlayer, secondPlayer, thirdPlayer]
          `shouldEqual` [firstPlayer, combined]
    
    describe "uniquePairs" do
      it "No pairs with one item" do
        uniquePairs [defaultPlayer] `shouldEqual` []
      it "One unique pair with two items" do
        let otherPlayer = defaultPlayer { id = 100 }
        uniquePairs [defaultPlayer, otherPlayer] `shouldEqual` [(Tuple defaultPlayer otherPlayer)]
      it "Three unique pairs with three items" do
        let otherPlayer = defaultPlayer { id = 100 }
        let anotherPlayer = defaultPlayer { id = 101 }
        uniquePairs [defaultPlayer, otherPlayer, anotherPlayer]
         `shouldEqual` [ (Tuple defaultPlayer otherPlayer)
                       , (Tuple defaultPlayer anotherPlayer)
                       , (Tuple otherPlayer anotherPlayer)
                       ]

    describe "checkCollision" do
      it "Ignores same player collision" do
        checkCollision defaultPlayer defaultPlayer `shouldEqual` false

      it "Identifies two players in the same tile" do
        let otherPlayer = defaultPlayer { id = 100 }
        checkCollision defaultPlayer otherPlayer `shouldEqual` true

      it "Identifies two players are too far apart" do
        let firstPlayer = createTestPlayer 1 (createFullCoord 5 5 1 0) Egg
        let secondPlayer = defaultPlayer { id = 2
                                         , coords = createFullCoord 6 5 (-30) 0
                                         }
        checkCollision firstPlayer secondPlayer `shouldEqual` false

      it "Close enough to collide on RHS" do
        let firstPlayer = defaultPlayer { id = 1  
                                        , coords = createFullCoord 5 5 20 0
                                        }
        let secondPlayer = defaultPlayer { id = 2
                                         , coords = createFullCoord 6 5 (-20) 0
                                         }
        checkCollision firstPlayer secondPlayer `shouldEqual` true

      it "Close enough to collide on LHS" do
        let firstPlayer = defaultPlayer { id = 1  
                                        , coords = createFullCoord 6 5 (-40) 0
                                        }
        let secondPlayer = defaultPlayer { id = 2
                                         , coords = createFullCoord 5 5 0 0
                                         }
        checkCollision firstPlayer secondPlayer `shouldEqual` true

      it "Ignores collision with Silver Egg" do
        let otherPlayer = defaultPlayer { playerType = defaultPlayerType { type_ = SilverEgg } }
        checkCollision defaultPlayer otherPlayer `shouldEqual` false
        
      it "Ignores collision with just split player" do
        let otherPlayer = defaultPlayer { lastAction = Just Split }
        checkCollision defaultPlayer otherPlayer `shouldEqual` false

    describe "removeCollided" do
      it "Removes none if no players" do
        removeCollided [] [] `shouldEqual` []
      it "Removes none if no collisions" do
        let firstPlayer = defaultPlayer { id = 1  
                                        , coords = createFullCoord 6 5 (-40) 0
                                        }
        let secondPlayer = defaultPlayer { id = 2
                                         , coords = createFullCoord 5 5 0 0
                                         }
        removeCollided [] [firstPlayer, secondPlayer] `shouldEqual` [firstPlayer, secondPlayer]
      it "Removes subjects of collision" do
        let firstPlayer = defaultPlayer { id = 1  
                                        , coords = createFullCoord 6 5 (-40) 0
                                        }
        let secondPlayer = defaultPlayer { id = 2
                                         , coords = createFullCoord 5 5 0 0
                                         }
        removeCollided [Tuple firstPlayer secondPlayer] [firstPlayer, secondPlayer] `shouldEqual` []
      
    describe "combinePlayers" do
      it "Creates a new player" do
        let firstPlayer = createTestPlayer 1 (createCoord 100 100) Egg
        let secondPlayer = createTestPlayer 2 (createCoord 6 6) Egg
        let expected = createTestPlayer 1 (createCoord 100 100) RedEgg
        combinePlayers (Tuple firstPlayer secondPlayer) `shouldEqual` [expected]
      it "Returns players as no new one found" do
        let firstPlayer = createTestPlayer 1 (createCoord 100 100) YellowEgg
        let secondPlayer = createTestPlayer 2 (createCoord 6 6) YellowEgg
        combinePlayers (Tuple firstPlayer secondPlayer) `shouldEqual` [firstPlayer, secondPlayer]
