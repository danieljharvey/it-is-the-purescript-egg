module Main where

import Data.Int (toNumber)
import Effect (Effect)
import Prelude
import Effect.Class (liftEffect)
import Effect.Aff (Aff, launchAff_)
import Effect.Random (randomInt)
import Egg.Dom.Canvas (setupCanvas, sizeCanvas)

import Effect.Console as Console
import Data.Maybe (Maybe(..))
import Egg.Data.TileSet (tileResources)
import Egg.Data.PlayerTypes (spriteResources)
import Egg.Dom.Loader (loadLevel, loadLevelFromUrl)
import Egg.Dom.Renderer (renderGameState)
import Egg.Dom.Events (setupEvents)
import Egg.Types.Canvas (CanvasData)
import Egg.Types.Level (Level)
import Egg.Types.ResourceUrl (ResourceUrl)
import Egg.Types.GameState (GameState) 
import Egg.Types.GamePlayType (GamePlayType(..), LevelUrl(..))
import Egg.Logic.InitialiseLevel (initialiseGameState)
import Egg.Dom.AnimationLoop (animationLoop, createBlankState)
import Egg.Logic.TakeTurn as TakeTurn
import Data.List (List)

foreign import getWindowLevelUrl :: Effect String 

getGameMode :: Effect GamePlayType
getGameMode = do
  url <- getWindowLevelUrl
  Console.log url
  case url of
       "" -> pure $ RegularGame
       a -> pure $ LevelTest (LevelUrl a)  

main :: Effect Unit
main = do
  gameMode <- getGameMode
  case gameMode of
    RegularGame -> launchAff_ setupRegularGame
    LevelTest url -> launchAff_ (setupTestGame url)  

-- test a level from the passed url
setupTestGame :: LevelUrl -> Aff Unit
setupTestGame levelUrl = do
  canvas <- setupCanvas imageResources
  mLevel <- loadLevelFromUrl levelUrl
  case mLevel of
       Just level -> liftEffect (start canvas level (pure unit))
       _ -> pure unit 

-- regular game where we choose a random JSON file from /public/levels
setupRegularGame :: Aff Unit
setupRegularGame = setupCanvas imageResources >>= startNewLevel

startNewLevel :: CanvasData -> Aff Unit
startNewLevel canvas = do
  levelId <- liftEffect $ randomInt 1 21
  mLevel <- loadLevel levelId
  case mLevel of
    Just level -> liftEffect (start canvas level (startNewLevel canvas))
    _ -> pure unit

start :: CanvasData -> Level -> Aff Unit -> Effect Unit
start canvas level restartAff = do
  sizeCanvas canvas.buffer.element (toNumber level.boardSize.width * 64.0)
  sizeCanvas canvas.screen.element (toNumber level.boardSize.width * 64.0)
  refs <- createBlankState (initialiseGameState level.board)
  animationLoop refs TakeTurn.go (renderCallback canvas) (launchAff_ restartAff)
  setupEvents refs.inputEvent

renderCallback :: CanvasData -> GameState -> GameState -> Effect Unit
renderCallback canvasData old new = renderGameState canvasData old new

imageResources :: List ResourceUrl
imageResources = tileResources <> spriteResources
