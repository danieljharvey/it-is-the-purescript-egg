module Egg.Types.PathMap where

import Data.Maybe (fromMaybe)
import Egg.Types.Board (BoardSize)
import Egg.Types.Coord
import Matrix as Mat

-- map of where we can go
type PathMap = Mat.Matrix Boolean

getMapSize :: PathMap -> BoardSize
getMapSize pathMap
  = { width: Mat.width pathMap, height: Mat.height pathMap }

checkSquare :: PathMap -> Coord -> Boolean
checkSquare pathMap (Coord c)
  = fromMaybe false (Mat.get c.x c.y pathMap)

createEmpty :: Int -> PathMap
createEmpty i
  = Mat.repeat i i true