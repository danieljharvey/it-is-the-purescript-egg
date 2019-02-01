module Egg.Data.InitialiseLevel where

import Egg.Types.GameState (GameState, createGameState)
import Egg.Types.Board (Board)

import Egg.Logic.CreatePlayers (getPlayersFromBoard)

initialiseGameState :: Board -> GameState
initialiseGameState board 
  = initialGameState { players = getPlayersFromBoard board }
  where
    initialGameState
      = createGameState board
