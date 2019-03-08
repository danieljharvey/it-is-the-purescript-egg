module Egg.Types.InputEvent where

import Data.Eq (class Eq)
import Data.Ord (class Ord)
import Data.Show (class Show, show)
import Data.Semigroup ((<>))

data InputEvent
  = ResizeWindow Int Int
  | KeyPress String
  | LeftArrow
  | RightArrow
  | Pause

derive instance eqInputEvent  :: Eq InputEvent
derive instance ordInputEvent :: Ord InputEvent

instance showInputEvent :: Show InputEvent where
  show (ResizeWindow x y) = "ResizeWindow " <> (show x) <> ", " <> (show y)
  show (KeyPress s)       = "KeyPress " <> s
  show LeftArrow          = "LeftArrow"
  show RightArrow         = "RightArrow"
  show Pause              = "Pause"