module Egg.Types.PathList where

import Prelude
import Data.Array (fromFoldable)
import Data.Array.NonEmpty as NEA
import Data.Foldable
import Data.Map as M
import Egg.Types.Coord (Coord)

newtype PathList
  = PathList (M.Map Coord (NEA.NonEmptyArray Coord))

derive newtype instance eqPathList :: Eq PathList
derive newtype instance ordPathList :: Ord PathList
derive newtype instance showPathList :: Show PathList

instance semigroupPathList :: Semigroup PathList where
  append (PathList a) (PathList b)
    = PathList $ M.unionWith compareLengths a b
    where
      compareLengths a' b'
        = if NEA.length b' < NEA.length a'
          then b'
          else a'

-- Monoid just gives us a wrapper around an empty list
instance monoidPathList :: Monoid PathList where
  mempty = PathList $ mempty

itemToList :: NEA.NonEmptyArray Coord -> PathList
itemToList arr
  = PathList (M.singleton (NEA.head arr) arr)

listToItems :: PathList -> Array (NEA.NonEmptyArray Coord)
listToItems (PathList p)
  = fromFoldable (M.values p)

listLength :: PathList -> Int
listLength (PathList p)
  = length p

-- starting point for any path finding
singleton :: Coord -> PathList
singleton coord
  = PathList (M.singleton coord (NEA.singleton coord))