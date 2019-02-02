module Egg.Types.CurrentFrame (CurrentFrame, createCurrentFrame, inc, dec, getCurrentFrame) where

import Prelude

type Maximum = Int
type Current = Int

data CurrentFrame = CurrentFrame Maximum Current

derive instance eqCurrentFrame  :: Eq CurrentFrame
derive instance ordCurrentFrame :: Ord CurrentFrame
instance showCurrentFrame :: Show CurrentFrame where
  show (CurrentFrame max current)
    = "Frame " <> show current <> ", maxiumum " <> show max

createCurrentFrame :: Maximum -> CurrentFrame
createCurrentFrame max = CurrentFrame max 0

inc :: CurrentFrame -> CurrentFrame
inc (CurrentFrame max current)
  = if (current + 1) >= max
    then CurrentFrame max 0
    else CurrentFrame max (current + 1)

dec :: CurrentFrame -> CurrentFrame
dec (CurrentFrame max current)
  = if (current - 1) < 0
    then CurrentFrame max (max -1)
    else CurrentFrame max (current - 1)

getCurrentFrame :: CurrentFrame -> Int
getCurrentFrame (CurrentFrame _ i) = i
