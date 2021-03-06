module Egg.Dom.Events where

-- listeners for window size, keyboard presses, clicks etc
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Ref as Ref
import Effect.Uncurried (runEffectFn3)
import Egg.Dom.TouchEvents (setupSwipes)
import Egg.Types.InputEvent (InputEvent(..))
import Prelude (Unit, bind, discard, pure, unit, (<$>))
import Web.Event.Event (Event, EventType(..))
import Web.Event.EventTarget (EventTarget, addEventListener, eventListener)
import Web.HTML (window)
import Web.HTML.Window (innerHeight, innerWidth, toEventTarget)
import Web.UIEvent.KeyboardEvent (code, fromEvent)

type Updater
  = (InputEvent -> Effect Unit)

-- does the actual updating, pre-filled with the right ref
updateInputEventRef :: Ref.Ref (Maybe InputEvent) -> InputEvent -> Effect Unit
updateInputEventRef ref event = do
  Ref.write (Just event) ref

setupEvents :: Ref.Ref (Maybe InputEvent) -> Effect Unit
setupEvents ref = do
  let
    updater = updateInputEventRef ref
  readResizeEvent updater "" -- trigger event with initial screen size
  createWindowSizeListener updater -- event for window sizing
  createKeypressListener updater -- event for keypresses
  createSwipeListener updater -- event for swipe gestures

-- touches
createSwipeListener :: Updater -> Effect Unit
createSwipeListener updater = do
  let
    leftSwipeFn = updater LeftArrow

    rightSwipeFn = updater RightArrow

    elementId = "wrapper"
  runEffectFn3 setupSwipes elementId leftSwipeFn rightSwipeFn

-- keypresses
createKeypressListener :: Updater -> Effect Unit
createKeypressListener updater = do
  listener <- eventListener (readKeyboardEvent updater)
  window' <- getWindowEventTarget
  addEventListener (EventType "keydown") listener false window'

readKeyboardEvent :: Updater -> Event -> Effect Unit
readKeyboardEvent updater e = case code <$> fromEvent e of
  Just "ArrowLeft" -> updater LeftArrow
  Just "ArrowRight" -> updater RightArrow
  Just "Space" -> updater Pause
  Just keyCode -> updater (KeyPress keyCode)
  _ -> pure unit

-- window size
createWindowSizeListener :: Updater -> Effect Unit
createWindowSizeListener updater = do
  listener <- eventListener (readResizeEvent updater)
  window' <- getWindowEventTarget
  addEventListener (EventType "resize") listener false window'

getWindowEventTarget :: Effect EventTarget
getWindowEventTarget = toEventTarget <$> window

readResizeEvent :: forall e. Updater -> e -> Effect Unit
readResizeEvent updater _ = do
  { width, height } <- getWindowSize
  updater (ResizeWindow width height)

getWindowSize :: Effect { width :: Int, height :: Int }
getWindowSize = do
  window' <- window
  width <- innerWidth window'
  height <- innerHeight window'
  pure { width, height }
