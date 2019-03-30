module Egg.Types.PathList where

import Prelude
import Data.Array (fromFoldable, concat, nubEq)
import Data.Array.NonEmpty as NEA
import Data.Foldable (length)
import Data.Maybe (Maybe)
import Data.Map as M
import Egg.Types.SmallCoord (SmallCoord)

newtype PathList
  = PathList (M.Map SmallCoord (NEA.NonEmptyArray SmallCoord))

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

itemToList :: NEA.NonEmptyArray SmallCoord -> PathList
itemToList arr
  = PathList (M.singleton (NEA.head arr) arr)

listToItems :: PathList -> Array (NEA.NonEmptyArray SmallCoord)
listToItems (PathList p)
  = fromFoldable (M.values p)

listLength :: PathList -> Int
listLength (PathList p)
  = length p

isKey :: SmallCoord -> PathList -> Boolean
isKey coord (PathList p)
  = M.member coord p

lookup :: SmallCoord -> PathList -> Maybe (NEA.NonEmptyArray SmallCoord)
lookup coord (PathList p)
  = M.lookup coord p

getPreviouslyFound :: PathList -> Array SmallCoord
getPreviouslyFound (PathList p)
  = nubEq $ concat lists
  where
    lists :: Array (Array SmallCoord)
    lists
      = NEA.toArray <$> (fromFoldable (M.values p))

-- starting point for any path finding
singleton :: SmallCoord -> PathList
singleton coord
  = PathList (M.singleton coord (NEA.singleton coord))