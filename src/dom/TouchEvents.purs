module Egg.Dom.TouchEvents where

import Prelude (Unit)
import Effect (Effect)
import Effect.Uncurried (EffectFn3)

foreign import setupSwipes :: EffectFn3 String (Effect Unit) (Effect Unit) Unit
