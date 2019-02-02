module Egg.Dom.AnimationLoop where

import Prelude (Unit, bind, discard, pure, unit)
import Effect (Effect)
import Web.HTML.Window
import Web.HTML (window)
import Effect.Now as Now
import Effect.Ref as Ref
import Data.Time (Time, diff)
import Data.Time.Duration (Milliseconds(..), fromDuration)
import Data.Int as Int

import Egg.Types.GameState (GameState)

type Callback = (Int -> Effect Unit)

type GameLoop = (Int -> GameState -> GameState)

-- old, new
type Listener = (GameState -> GameState -> Effect Unit)

animationLoop :: GameState -> GameLoop -> Listener -> Effect Unit
animationLoop initial gameLoop listener = do
  w <- window
  time <- Now.nowTime
  ref <- Ref.new time
  gameStateRef <- Ref.new initial
  let callback = \c -> do
              gameState <- Ref.read gameStateRef
              newGameState <- Ref.modify (gameLoop c) gameStateRef
              _ <- requestAnimationFrame (duration ref callback) w
              listener gameState newGameState
              pure unit
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
