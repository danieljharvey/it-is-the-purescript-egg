module Egg.Types.SmallCoord  where

import Prelude
import Egg.Types.Coord (Coord(..))

data SmallCoord 
  = SmallCoord Int Int
    
derive instance eqSmallCoord :: Eq SmallCoord
derive instance ordSmallCoord :: Ord SmallCoord

instance showSmallCoord :: Show SmallCoord where
  show (SmallCoord x y) = "(" <> show x <> ", " <> show y <> ")"

instance semigroupSmallCoord :: Semigroup SmallCoord where
  append (SmallCoord fx fy) (SmallCoord sx sy)
    = SmallCoord (fx + sx) (fy + sy)
          
fromCoord :: Coord -> SmallCoord
fromCoord (Coord c)
  = SmallCoord c.x c.y

toCoord :: SmallCoord -> Coord
toCoord (SmallCoord x' y')
  = Coord { x: x'
          , y: y'
          , offsetX: 0
          , offsetY: 0
          }