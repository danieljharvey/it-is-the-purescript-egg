module Egg.Types.ScreenSize where

import Data.Eq (class Eq)
import Data.Ord
import Data.Show
import Data.Semigroup

screenSize :: Int -> Int -> ScreenSize
screenSize x y 
  = ScreenSize (max x 1) (max y 1)

getWidth :: ScreenSize -> Int
getWidth (ScreenSize x _) = x

getHeight :: ScreenSize -> Int
getHeight (ScreenSize _ y) = y

smallest :: ScreenSize -> Int
smallest s = min (getWidth s) (getHeight s)

data ScreenSize
  = ScreenSize Int Int

derive instance eqScreenSize  :: Eq ScreenSize
derive instance ordScreenSize :: Ord ScreenSize

instance showScreenSize :: Show ScreenSize where
  show (ScreenSize x y) = "ScreenSize " <> show x <> ", " <> show y