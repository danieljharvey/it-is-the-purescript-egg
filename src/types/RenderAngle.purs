module Egg.Types.RenderAngle where

import Prelude
import Math as Math
import Data.Int (toNumber)

newtype RenderAngle = RenderAngle Int

derive newtype instance eqRenderAngle :: Eq RenderAngle
derive newtype instance ordRenderAngle :: Ord RenderAngle
derive newtype instance showRenderAngle :: Show RenderAngle
derive newtype instance semiringRenderAngle :: Semiring RenderAngle
derive newtype instance ringRenderAngle :: Ring RenderAngle

instance semigroupRenderAngle :: Semigroup RenderAngle where
  append = increase

newtype RenderAngleRad = RenderAngleRad Number

toRadians :: RenderAngle -> RenderAngleRad
toRadians (RenderAngle renderAngle)
  = RenderAngleRad $ (toNumber renderAngle) * (Math.pi / 180.0)

invertAngle :: RenderAngle -> RenderAngle
invertAngle (RenderAngle angle)
  = RenderAngle (-1 * angle)

increase :: RenderAngle -> RenderAngle -> RenderAngle
increase fst snd
  = if total > RenderAngle 359 
    then total - RenderAngle 360
    else total
  where
    total
      = fst + snd

decrease :: RenderAngle -> RenderAngle -> RenderAngle
decrease fst snd
  = if total < RenderAngle 0
    then total + RenderAngle 360
    else total
  where
    total
      = fst - snd