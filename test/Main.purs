module Test.Main where

import Prelude
import Effect (Effect)
import Effect.Aff (launchAff_)
import Test.Spec.Reporter.Console (consoleReporter)
import Test.Spec.Runner (runSpec)
import Test.Logic.TakeTurn as TakeTurn
import Test.Logic.Movement as Movement
import Test.Logic.Action as Action
import Test.Logic.Map as Map
import Test.Logic.RenderMap as RenderMap
import Test.Logic.LoadLevel as LoadLevel
import Test.Logic.Collisions as Collisions
import Test.Logic.PathFinder as PathFinder

main :: Effect Unit
main =
  launchAff_
    $ runSpec [ consoleReporter ] do
        TakeTurn.tests
        Movement.tests
        Action.tests
        Map.tests
        RenderMap.tests
        LoadLevel.tests
        Collisions.tests
        PathFinder.tests
