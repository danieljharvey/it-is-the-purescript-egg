module Main where

import Data.Int (toNumber)
import Effect (Effect)
import Prelude
import Effect.Class (liftEffect)
import Effect.Aff (Aff, launchAff_)
import Egg.Dom.Canvas (setupCanvas, sizeCanvas)
import Data.Maybe (Maybe(..))
import Egg.Data.TileSet (tileResources)
import Egg.Data.PlayerTypes (spriteResources)
import Egg.Dom.Loader (loadLevel)
import Egg.Dom.Renderer (renderGameState)
import Egg.Types.Canvas (CanvasData)
import Egg.Types.Level (Level)
import Egg.Types.ResourceUrl (ResourceUrl)
import Egg.Logic.InitialiseLevel (initialiseGameState)
import Data.List (List)

main :: Effect Unit
main = launchAff_ setupGame

setupGame :: Aff Unit
setupGame = do
  canvas <- setupCanvas imageResources
  mLevel <- loadLevel 3
  case mLevel of
    Just level -> liftEffect (start canvas level)
    _          -> pure unit

start :: CanvasData -> Level -> Effect Unit
start canvas level
  = do
    sizeCanvas canvas.element (toNumber level.boardSize.width * 64.0)
    let gameState = initialiseGameState level.board
    renderGameState canvas Nothing gameState

imageResources :: List ResourceUrl
imageResources = tileResources <> spriteResources
