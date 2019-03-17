module Egg.Dom.Canvas where

import Egg.Logic.Board (createBoardSize, createCenteredTranslation, createTileTranslation, invertTranslation)
import Egg.Types.Canvas (CanvasData, CanvasInfo, ImageSourceMap)
import Egg.Types.Coord (Coord(..), totalX, totalY)
import Egg.Types.Board (BoardSize)
import Egg.Types.ResourceUrl (ResourceUrl)
import Egg.Types.RenderAngle (RenderAngle, RenderAngleRad(..), invertAngle, toRadians)
import Graphics.Canvas (CanvasElement, CanvasImageSource, Context2D, TranslateTransform, canvasElementToImageSource, clearRect, drawImage, drawImageFull, drawImageScale, fillRect, getCanvasElementById, getContext2D, rotate, setCanvasHeight, setCanvasWidth, setFillStyle, translate, tryLoadImage)
import Prelude

import Control.Parallel (parTraverse)
import Data.Either (Either, note)
import Data.Int (toNumber)
import Data.List (List)
import Data.Map as Map
import Data.Maybe (Maybe)
import Data.Traversable (class Foldable, class Traversable)
import Data.Tuple (Tuple(..))
import Effect (Effect)
import Effect.Aff (Aff, makeAff)
import Effect.Class (liftEffect)
import Effect.Exception (Error, error)


tileSize :: Int
tileSize = 64

bufferSize :: Int
bufferSize = 640

canvasSize :: Int
canvasSize = 480

newtype CanvasDomId = CanvasDomId String

setupCanvas :: List ResourceUrl -> Aff CanvasData
setupCanvas gameResources = do
  element <- getCanvas (CanvasDomId "buffer-canvas")
  context2d <- liftEffect $ getContext2D element
  onScreenElement <- getCanvas (CanvasDomId "canvas")
  onScreenContext <- liftEffect $ getContext2D onScreenElement
  imageMap <- loadImages gameResources
  pure { screen: { element: onScreenElement, context: onScreenContext, size: canvasSize }
       , buffer: { element, context: context2d, size: bufferSize }
       , imageMap
       }

-- get canvas object from dom
getCanvas :: CanvasDomId -> Aff CanvasElement
getCanvas (CanvasDomId canvasId) = makeAff affCallback
  where
  affCallback successFn = do
    maybeCanvas <- getCanvasElementById canvasId
    let eitherCanvasOrError = orError ("Could not find canvas #" <> canvasId) maybeCanvas
    successFn eitherCanvasOrError
    -- returns an empty canceller
    pure mempty
    
-- resize canvas
sizeCanvas ::
  CanvasElement ->
  Number ->
  Effect Unit
sizeCanvas element x = do
  _ <- setCanvasWidth element x
  _ <- setCanvasHeight element x
  pure unit

-- load all images and put handles to resources in a nice map
loadImages ::
  forall t.
  Foldable t =>
  Traversable t =>
  t ResourceUrl ->
  Aff ImageSourceMap
loadImages resourceUrls = Map.fromFoldable <$> parTraverse tryLoadImageAff resourceUrls

-- Aff version of tryLoadImage from Canvas.Graphics
tryLoadImageAff ::
  ResourceUrl ->
  Aff (Tuple ResourceUrl CanvasImageSource)
tryLoadImageAff resourceUrl = makeAff affCallback
  where
  -- what we want to do, inside a function so we can be provided with successFn first
  affCallback successFn = do
    tryLoadImage (show resourceUrl) (tryLoadImageCallback successFn)
    pure mempty
  -- return an empty cancellation function
  -- our callback for tryLoadImage, which calls the Aff success callback
  tryLoadImageCallback successFn = (\maybeImg ->
    successFn (tidyImageReturn resourceUrl maybeImg))

-- take our Maybe CanvasImageSource, add a fallback error, and bundle in the
-- ResourceUrl on success so we know what the hell it is
tidyImageReturn ::
  ResourceUrl ->
  Maybe CanvasImageSource ->
  Either Error (Tuple ResourceUrl CanvasImageSource)
tidyImageReturn resourceUrl maybeImage = (\img ->
  Tuple resourceUrl img) <$> orError ("Could not load file: " <> show resourceUrl) maybeImage

orError :: forall a. String -> Maybe a -> Either Error a
orError msg a = note (error msg) a

clearScreen :: Context2D -> BoardSize -> Effect Unit
clearScreen context size = do
  clearRect context { x: 0.0
                    , y: 0.0
                    , width: toNumber (size.width * tileSize)
                    , height: toNumber (size.height * tileSize)
                    }

copyBufferToCanvas :: CanvasInfo -> CanvasInfo -> RenderAngle -> Effect Unit
copyBufferToCanvas buffer screen angle = do
  clearScreen screen.context (createBoardSize screen.size)
  withTranslate (createCenteredTranslation screen.size) screen.context $ do
    withRotate angle screen.context $ do
      drawWithOffset buffer.element screen.context screen.size

drawWithOffset :: CanvasElement -> Context2D -> Int -> Effect Unit
drawWithOffset element dest screenSize = 
  drawImageScale 
    dest source offset offset size size
  where
    source
      = canvasElementToImageSource element
    size 
      = toNumber screenSize
    offset
      = (-1.0) * toNumber (screenSize / 2)

withTranslate :: TranslateTransform -> Context2D -> Effect Unit -> Effect Unit
withTranslate trans dest callback = do
  _ <- translate dest trans
  callback
  translate dest (invertTranslation trans)

-- rotate the drawing surface, do your operation, then puts it back
withRotate :: RenderAngle -> Context2D -> Effect Unit -> Effect Unit
withRotate angle dest callback = do
  _ <- rotate' dest angle
  callback
  rotate' dest (invertAngle angle)

rotate' :: Context2D -> RenderAngle -> Effect Unit
rotate' dest angle = do
  let (RenderAngleRad rad) = toRadians angle
  rotate dest rad

drawTile :: Context2D -> CanvasImageSource -> Coord -> Effect Unit
drawTile context image coord = drawImage context image x y
  where
  x = toNumber $ totalX coord
  y = toNumber $ totalY coord

fillTile :: Context2D -> Coord -> Effect Unit
fillTile context (Coord coord) = do
  let rect = { x: toNumber $ (coord.x * tileSize) + 5
             , y: toNumber $ (coord.y * tileSize) + 5
             , width: toNumber $ tileSize - 10
             , height: toNumber $ tileSize - 10
             }
  setFillStyle context "rgba(255,0,0,0.5)"
  fillRect context rect

clearTile :: Context2D -> Coord -> Effect Unit
clearTile context (Coord coord) = clearRect context rect
  where
  rect = { x: toNumber $ coord.x * tileSize
         , y: toNumber $ coord.y * tileSize
         , width: toNumber $ tileSize
         , height: toNumber $ tileSize
         }

drawPlayer :: Context2D -> CanvasImageSource -> RenderAngle -> Coord -> Int -> Effect Unit
drawPlayer context image angle coord frame = do
  withTranslate (createTileTranslation coord) context $ do
    withRotate (invertAngle angle) context $ do
      drawImageFull context image sx sy tileSize' tileSize' destX destY tileSize' tileSize'
  where
    destX = -1.0 * toNumber (tileSize / 2) 
    destY = -1.0 * toNumber (tileSize / 2) 
    sx = toNumber $ frame * tileSize
    sy = 0.0
    tileSize' = toNumber tileSize
