module Egg.Canvas where

import Control.Parallel (parTraverse)
import Data.Maybe (Maybe(..))
import Data.Array as Array
import Data.Either (Either(..))
import Data.Tuple (Tuple(..))
import Data.List (List)
import Data.Int (toNumber)
import Data.Map as Map
import Effect.Exception (Error, error)
import Effect (Effect, foreachE)
import Effect.Console (log)
import Graphics.Canvas
import Prelude (Unit, bind, discard, mempty, pure, show, unit, ($), (<$>), (<>))
import Effect.Class (liftEffect)
import Effect.Aff (Aff, makeAff)

import Effect.Random (randomInt)

import Egg.Types.ResourceUrl (ResourceUrl)
import Egg.Data.TileSet (tileResources)

type ImageSourceMap = (Map.Map ResourceUrl CanvasImageSource)

canvasSize :: Int
canvasSize = 320

setupGame :: CanvasElement -> Aff Unit
setupGame element = do
  context2d <- liftEffect $ getContext2D element
  liftEffect $ sizeCanvas element (toNumber canvasSize)
  imageMap <- loadImages tileResources
  liftEffect $ drawMany context2d imageMap
  liftEffect $ log "Yeah!"
  pure unit

-- draw all the images
drawMany :: Context2D -> ImageSourceMap -> Effect Unit
drawMany context2d imageMap = foreachE keysArr draw
  where
    keysArr
      = (Array.fromFoldable (Map.keys imageMap))
    draw i
      = do
        log "Drawing!"
        drawTileFromImageMap context2d imageMap i
        pure unit

-- get canvas object from dom
getCanvas :: Effect (Maybe CanvasElement)
getCanvas = do
  getCanvasElementById "canvas"

-- resize canvas
sizeCanvas :: CanvasElement -> Number -> Effect Unit
sizeCanvas element x = do
  _ <- setCanvasWidth element x
  _ <- setCanvasHeight element x
  pure unit

-- load all images and put handles to resources in a nice map
loadImages :: List ResourceUrl -> Aff ImageSourceMap
loadImages resourceUrls = Map.fromFoldable <$> parTraverse tryLoadImageAff resourceUrls

-- Aff version of tryLoadImage from Canvas.Graphics
tryLoadImageAff :: ResourceUrl -> Aff (Tuple ResourceUrl CanvasImageSource)
tryLoadImageAff resourceUrl = makeAff affCallback
  where
    -- what we want to do, inside a function so we can be provided with successFn first
    affCallback successFn
      = do
        tryLoadImage (show resourceUrl) (tryLoadImageCallback successFn)
        pure mempty -- return an empty cancellation function

    -- our callback for tryLoadImage, which calls the Aff success callback
    tryLoadImageCallback successFn
      = (\maybeImg ->
            successFn (tidyImageReturn resourceUrl maybeImg))

-- take our Maybe CanvasImageSource, add a fallback error, and bundle in the
-- ResourceUrl on success so we know what the hell it is
tidyImageReturn ::
  ResourceUrl ->
  Maybe CanvasImageSource ->
  Either Error (Tuple ResourceUrl CanvasImageSource)
tidyImageReturn resourceUrl maybeImg
  = case maybeImg of
      Nothing -> Left $ error ("Could not load file: " <> show resourceUrl)
      Just img -> Right (Tuple resourceUrl img)

drawTile :: Context2D -> CanvasImageSource -> Effect Unit
drawTile context image = do
  x <- toNumber <$> randomInt 0 canvasSize
  y <- toNumber <$> randomInt 0 canvasSize
  drawImage context image x y

drawTileFromImageMap :: Context2D -> ImageSourceMap -> ResourceUrl -> Effect Unit
drawTileFromImageMap context map res = case Map.lookup res map of
  Just found -> drawTile context found
  Nothing    -> log ("Couldn't find " <> show res)
