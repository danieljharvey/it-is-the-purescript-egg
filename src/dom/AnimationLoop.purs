module Egg.Dom.AnimationLoop where

import Prelude (Unit, bind, discard, pure)
import Effect (Effect)
import Web.HTML.Window
import Web.HTML (window)
import Effect.Now as Now
import Effect.Ref as Ref
import Data.Time (Time, diff)
import Data.Time.Duration (Milliseconds(..), fromDuration)
import Data.Int as Int
import Data.Maybe (Maybe(..))

import Egg.Types.InputEvent (InputEvent)
import Egg.Types.GameState (GameState)

type Callback = (Int -> Effect Unit)

type GameLoop = (Int -> Maybe InputEvent -> GameState -> GameState)

-- old, new
type Listener = (GameState -> GameState -> Effect Unit)

type MutableState = { time       :: Ref.Ref Time 
                    , gameState  :: Ref.Ref GameState
                    , inputEvent :: Ref.Ref (Maybe InputEvent)
                    }

createBlankState :: GameState -> Effect MutableState
createBlankState initial = do
  time <- Now.nowTime
  ref <- Ref.new time             -- store current time for calculating frame changes
  gameStateRef <- Ref.new initial -- store current state of game
  inputEvent <- Ref.new Nothing   -- store last input event
  pure { time: ref
       , gameState: gameStateRef
       , inputEvent
       }

animationLoop :: MutableState -> GameLoop -> Listener -> Effect Unit
animationLoop refs gameLoop listener = do
  w <- window
  let callback = \c -> do
        newEvent     <- Ref.read refs.inputEvent
        gameState    <- Ref.read refs.gameState
        newGameState <- Ref.modify (gameLoop c newEvent) refs.gameState
        _            <- requestAnimationFrame (duration refs.time callback) w
        listener gameState newGameState
        Ref.write Nothing refs.inputEvent -- clear input events

  -- start things going...
  callback 0

duration :: Ref.Ref Time -> Callback -> Effect Unit
duration ref callback = do
  time <- Now.nowTime
  oldTime <- Ref.read ref
  Ref.write time ref
  let change = difference oldTime time
  callback change

millisecondsToInt :: Milliseconds -> Int
millisecondsToInt (Milliseconds i) = Int.floor i

difference :: Time -> Time -> Int
difference old new
  = millisecondsToInt (fromDuration myDiff)
  where
    myDiff :: Milliseconds
    myDiff = diff new old
