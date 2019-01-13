module Egg.Canvas where

import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Console (log)
import Graphics.Canvas
import Prelude (Unit, bind, discard, pure, unit, (<>), show)

import Egg.Types.ResourceUrl

setupGame :: CanvasElement -> Effect Unit
setupGame element = do
  sizeCanvas element 320.0
  startLoadImage element (createResourceUrl Image "fabric.png")
  pure unit

getCanvas :: Effect (Maybe CanvasElement)
getCanvas = do
  getCanvasElementById "canvas"

sizeCanvas :: CanvasElement -> Number -> Effect Unit
sizeCanvas element x = do
  _ <- setCanvasWidth element x
  _ <- setCanvasHeight element x
  pure unit

startLoadImage :: CanvasElement -> ResourceUrl -> Effect Unit
startLoadImage element resourceUrl = do
  tryLoadImage (show resourceUrl) (receiveLoadImage element resourceUrl)

receiveLoadImage :: CanvasElement -> ResourceUrl -> Maybe CanvasImageSource -> Effect Unit
receiveLoadImage element resourceUrl maybeImg = case maybeImg of
  Just canvasImageSource -> do
                            log ("Loaded!" <> show resourceUrl)
                            drawTile element canvasImageSource
  _                      -> log ("Oh bum, could not load " <> show resourceUrl)


drawTile :: CanvasElement -> CanvasImageSource -> Effect Unit
drawTile element image = do
  context <- getContext2D element
  drawImage context image 20.0 20.0
