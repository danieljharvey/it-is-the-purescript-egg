module Test.Main where

import Prelude
import Effect (Effect)
import Test.Spec.Reporter.Console (consoleReporter)
import Test.Spec.Runner (run)

import Test.Logic.TakeTurn as TakeTurn
import Test.Logic.Movement as Movement

main :: Effect Unit
main = run [consoleReporter] do
  TakeTurn.tests
  Movement.tests
