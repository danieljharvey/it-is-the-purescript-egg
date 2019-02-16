module Egg.Dom.Canvas where

import Control.Parallel (parTraverse)
import Data.Maybe (Maybe)
import Data.Either (Either, note)
import Data.Tuple (Tuple(..))
import Data.Int (toNumber)
import Data.Map as Map
import Data.Traversable (class Foldable, class Traversable)
import Data.List (List)
import Effect.Exception (Error, error)
import Effect (Effect)
import Graphics.Canvas (CanvasElement, CanvasImageSource, Context2D, clearRect, drawImage, drawImageFull, fillRect, getCanvasElementById, getContext2D, setCanvasHeight, setCanvasWidth, setFillStyle, tryLoadImage)
import Prelude
import Effect.Class (liftEffect)
import Effect.Aff (Aff, makeAff)

import Egg.Types.Board (BoardSize)
import Egg.Types.Coord
import Egg.Types.ResourceUrl (ResourceUrl)
import Egg.Types.Canvas (CanvasData, ImageSourceMap)

tileSize :: Int
tileSize = 64

canvasSize :: Int
canvasSize = 640

setupCanvas :: List ResourceUrl -> Aff CanvasData
setupCanvas gameResources = do
  element <- getCanvas
  context2d <- liftEffect $ getContext2D element
  liftEffect $ sizeCanvas element (toNumber canvasSize)
  imageMap <- loadImages gameResources
  pure { element    : element
       , context    : context2d
       , imageMap   : imageMap
       , canvasSize : canvasSize
       }

-- get canvas object from dom
getCanvas :: Aff CanvasElement
getCanvas = makeAff affCallback
  where
    affCallback successFn
      = do
        maybeCanvas <- getCanvasElementById "canvas"
        let eitherCanvasOrError = orError "Could not find canvas" maybeCanvas
        successFn eitherCanvasOrError
        pure mempty -- returns an empty canceller

-- resize canvas
sizeCanvas :: CanvasElement -> Number -> Effect Unit
sizeCanvas element x = do
  _ <- setCanvasWidth element x
  _ <- setCanvasHeight element x
  pure unit

-- load all images and put handles to resources in a nice map
loadImages :: forall t. Foldable t => Traversable t => t ResourceUrl -> Aff ImageSourceMap
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
tidyImageReturn
  :: ResourceUrl
  -> Maybe CanvasImageSource
  -> Either Error (Tuple ResourceUrl CanvasImageSource)
tidyImageReturn resourceUrl maybeImage
    = (\img -> Tuple resourceUrl img)
  <$> orError ("Could not load file: " <> show resourceUrl) maybeImage

orError
  :: forall a.
     String
  -> Maybe a
  -> Either Error a
orError msg a = note (error msg) a

clearScreen :: Context2D -> BoardSize -> Effect Unit
clearScreen context size = do
  clearRect context
    { x: 0.0
    , y: 0.0
    , width: toNumber (size.width * tileSize)
    , height: toNumber (size.height * tileSize)
    }

drawTile
  :: Context2D
  -> CanvasImageSource
  -> Coord
  -> Effect Unit
drawTile context image coord =
  drawImage context image x y
    where
      x = toNumber $ totalX coord
      y = toNumber $ totalY coord

fillTile
  :: Context2D
  -> Coord
  -> Effect Unit
fillTile context (Coord coord) = do
  let rect = { x: toNumber $ (coord.x * tileSize) + 5
             , y: toNumber $ (coord.y * tileSize) + 5
             , width: toNumber $ tileSize - 10
             , height: toNumber $ tileSize - 10
             }
  setFillStyle context "rgba(255,0,0,0.5)"
  fillRect context rect

clearTile
  :: Context2D
  -> Coord
  -> Effect Unit
clearTile context (Coord coord)
  = clearRect context rect
    where
      rect = { x: toNumber $ coord.x * tileSize
             , y: toNumber $ coord.y * tileSize
             , width: toNumber $ tileSize
             , height: toNumber $ tileSize
             }

drawPlayer
  :: Context2D
  -> CanvasImageSource
  -> Coord
  -> Int
  -> Effect Unit
drawPlayer context image coord frame
  = do
    drawImageFull context image sx sy tileSize' tileSize' destX destY tileSize' tileSize'
    pure unit
    where
      destX = toNumber $ totalX coord
      destY = toNumber $ totalY coord
      sx = toNumber $ frame * tileSize
      sy = 0.0
      tileSize' = toNumber tileSize
