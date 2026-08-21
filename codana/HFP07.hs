module HFP07 where

import Prelude hiding (fst, snd)

-- tuples (pairs)
-- see :i (,)
-- (,) 1 2 is valid

fst :: (a, b) -> a
fst (a, _) = a

snd :: (a, b) -> b
snd (_, b) = b

type Point = (Int, Int)

moveUp :: Point -> Point
moveUp (x, y) = (x, y + 1)

-- Maybe
safeDiv :: Int -> Int -> Maybe Int
safeDiv _ 0 = Nothing
safeDiv a b = Just (div a b)

-- TODO: implement safeHead (let the LLM do it)

-- Either

safeDiv' :: Int -> Int -> Either String Int
safeDiv' _ 0 = Left "Devided by zero"
safeDiv' a b = Right (div a b)

-- TODO implement safeHead' that returns Either


