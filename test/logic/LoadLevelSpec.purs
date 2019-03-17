module Test.Logic.LoadLevel where

import Test.Spec.Assertions

import Egg.Logic.LoadLevel (readLevel, readLevelJSON)

import Prelude (Unit, bind, discard, show, (<>), (>))
import Test.Spec (Spec, describe, it)
import Effect.Aff (Aff)
import Data.Array (range)
import Data.Maybe (isJust)
import Data.String (length)
import Data.Traversable (traverse_)
import Data.Tuple (Tuple(..))

import Node.FS.Aff (readTextFile)
import Node.Encoding (Encoding(..))

loadLevelFromFile :: Int -> Aff String
loadLevelFromFile i = do
  let path = "./public/levels/" <> show i <> ".json"
  readTextFile UTF8 path

levelIds :: Array Int
levelIds = range 1 19

canLoadFiles :: Int -> Aff Unit
canLoadFiles i = do
  str <- loadLevelFromFile i
  length str `shouldSatisfy` (_ > 0)

canLoadLevel :: Int -> Aff Unit
canLoadLevel i = do
  str <- loadLevelFromFile i
  Tuple (isJust (readLevel str)) i `shouldEqual` (Tuple true i)

canReadJSON :: Int -> Aff Unit
canReadJSON i = do
  str <- loadLevelFromFile i
  Tuple (isJust (readLevelJSON str)) i `shouldEqual` (Tuple true i)

tests :: Spec Unit
tests =
  describe "LoadLevel" do
    describe "canLoadFiles" do
      it "Loads files for levels 1-19" do
        traverse_ canLoadFiles levelIds
    describe "readLevelJSON" do
      it "Reads JSON for levels 1-19" do
        traverse_ canReadJSON levelIds
    describe "readLevel" do
      it "Reads levels 1-19" do
        traverse_ canLoadLevel levelIds
