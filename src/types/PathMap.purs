module Egg.Types.PathMap where

import Data.Maybe (fromMaybe)
import Egg.Types.Board (BoardSize)
import Egg.Types.SmallCoord
import Matrix as Mat

-- map of where we can go
type PathMap = Mat.Matrix Boolean

getMapSize :: PathMap -> BoardSize
getMapSize pathMap
  = { width: Mat.width pathMap, height: Mat.height pathMap }

checkSquare :: PathMap -> SmallCoord -> Boolean
checkSquare pathMap (SmallCoord x y)
  = fromMaybe false (Mat.get x y pathMap)

createEmpty :: Int -> PathMap
createEmpty i
  = Mat.repeat i i true