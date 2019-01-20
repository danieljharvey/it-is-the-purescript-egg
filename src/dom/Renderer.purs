module Egg.Dom.Renderer where

import Prelude
import Effect

import Egg.Types.Board
import Egg.Types.Coord


render :: RenderMap -> Board -> Effect Unit
render = ?bum

drawRenderItem :: RenderItem -> Effect Unit
drawRenderItem item = ?item
