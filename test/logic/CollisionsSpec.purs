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

{-

test("Find collisions", () => {
  const players = [
    new Player({ id: 1, coords: new Coords({ x: 1, y: 1 }) }),
    new Player({ id: 2, coords: new Coords({ x: 1, y: 1 }) }),
    new Player({ id: 3, coords: new Coords({ x: 10, y: 10 }) })
  ];

  const combinations = [[1, 2], [1, 3], [2, 3]];

  const expected = [[1, 2]];

  const collisions = new Collisions(playerTypes);

  const actual = collisions.findCollisions(combinations, players);

  expect(actual).toEqual(expected);
});

test("Fetch player by ID", () => {
  const players = [
    new Player({ id: 1 }),
    new Player({ id: 2 }),
    new Player({ id: 3 })
  ];

  const expected = new Player({ id: 2 });

  const collisions = new Collisions(playerTypes);

  const actual = collisions.fetchPlayerByID(players, 2);

  expect(actual).toEqual(expected);
});

test("Fetch player by ID Immutable", () => {
  const players = fromJS([
    new Player({ id: 1 }),
    new Player({ id: 2 }),
    new Player({ id: 3 })
  ]);

  const expected = new Player({ id: 2 });

  const collisions = new Collisions(playerTypes);

  const actual = collisions.fetchPlayerByID(players, 2);

  expect(actual).toEqual(expected);
});


test("Create new players actually works", () => {
  const player1 = new Player({
    id: 1,
    value: 1,
    coords: new Coords({
      x: 100,
      y: 100
    })
  });

  const player2 = new Player({
    id: 2,
    value: 1,
    coords: new Coords({
      x: 6,
      y: 6
    })
  });

  const player3 = new Player({
    id: 3,
    value: 2,
    coords: new Coords({
      x: 100,
      y: 100
    })
  });

  const expected = [
    new Player({
      id: 1,
      img: "egg-sprite-red.png",
      multiplier: 2,
      title: "It is of course the red egg",
      type: "red-egg",
      value: 2,
      frames: 18,
      coords: new Coords({
        x: 100,
        y: 100
      })
    })
  ];

  const players = [player1, player2, player3];

  const collided = [[1, 2], [4, 6]];

  const collisions = new Collisions();

  const actual = collisions.createNewPlayers(collided, players);

  expect(actual).toEqual(expected);
});

test("Combine player lists", () => {
  const player1 = new Player({
    id: 1,
    value: 10,
    coords: new Coords({
      x: 100,
      y: 100
    })
  });

  const player2 = new Player({
    id: 2,
    value: 5,
    coords: new Coords({
      x: 6,
      y: 6
    })
  });

  const player3 = new Player({
    id: 3,
    value: 5,
    coords: new Coords({
      x: 100,
      y: 100
    })
  });

  const list1 = [player1, player2];

  const list2 = fromJS([player3]);

  const expected = fromJS([player1, player2, player3]);

  const collisions = new Collisions();

  const actual = collisions.combinePlayerLists(list1, list2);

  expect(actual).toEqual(expected);
});


-}