module Egg.Logic.Board where

import Prelude
import Egg.Types.Board
import Graphics.Canvas
import Data.Int (toNumber)

createBoardSize :: Int -> BoardSize
createBoardSize i
  = { width: i
    , height: i
    }

invertTranslation :: TranslateTransform -> TranslateTransform
invertTranslation trans 
  = { translateX: -1.0 * trans.translateX 
    , translateY: -1.0 * trans.translateY
    }

createCenteredTranslation :: Int -> TranslateTransform
createCenteredTranslation i
  = { translateX: toNumber (i / 2) 
    , translateY: toNumber (i / 2)
    }