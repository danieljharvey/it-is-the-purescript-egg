module Egg.Logic.LoadLevel where

import Prelude

import Data.Maybe (Maybe(..), fromMaybe)
import Data.Map as M
import Data.Either (hush)
import Data.String (trim)
import Data.Argonaut.Parser (jsonParser)
import Data.Argonaut.Decode (decodeJson)

import Matrix as Mat

import Egg.Types.Level (JSONLevel, Level)
import Egg.Types.Board (Board, BoardSize, JSONBoard)
import Egg.Types.Tile (JSONTile, Tile, TileMap, emptyTile)

import Egg.Data.TileSet (tiles)

createBoard :: TileMap -> JSONBoard -> Maybe Board
createBoard tiles json = (map <<< map) (tileFromJSON tiles) matrix
  where
    matrix :: Maybe (Mat.Matrix JSONTile)
    matrix = Mat.fromArray json

checkWidthAndHeight :: Board -> BoardSize -> Maybe BoardSize
checkWidthAndHeight board bs
  = if (bs.width == (Mat.width board) && bs.height == (Mat.height board))
    then Just bs
    else Nothing

convert :: TileMap -> JSONLevel -> Maybe Level
convert tiles json = do
    levelId   <- pure json.levelID
    board     <- createBoard tiles json.board
    boardSize <- checkWidthAndHeight board json.boardSize
    pure { board:     board
         , boardSize: boardSize
         , levelId:   levelId
         }

cleanString :: String -> String
cleanString
  = trim

readLevelJSON :: String -> Maybe JSONLevel
readLevelJSON str = do
  json <- hush (jsonParser str)
  hush (decodeJson json)
 

readLevel :: String -> Maybe Level
readLevel str = do
    jsonLevel <- readLevelJSON str
    convert tiles jsonLevel

tileFromJSON :: TileMap -> JSONTile -> Tile
tileFromJSON tiles json
  = getTileById tiles (json.id)

getTileById :: TileMap -> Int -> Tile
getTileById tiles i = fromMaybe emptyTile foundTile
  where
    foundTile = M.lookup i tiles
