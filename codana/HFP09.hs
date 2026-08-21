{-# LANGUAGE InstanceSigs #-}

module HFP09 where

import Data.Char (toUpper)

-- functor
-- functor is like a map but works on structures
-- in category theory it maps from category to category that preserve structure

-- see `:i Functor`

data MyMaybe a = No | Yes a
  deriving Show

instance Functor MyMaybe where
  fmap :: (a -> b) -> MyMaybe a -> MyMaybe b
  fmap _ No = No
  fmap f (Yes x) = Yes (f x)

-- optional (<$)
  (<$) :: a -> MyMaybe b -> MyMaybe a
  (<$) _ No = No
  (<$) x (Yes _) = Yes x


-- what if MyMaybe is not a functor
-- we need to implement multiple functions

-- TODO: implement plusMyMaybe
-- TODO: implement multiplyMyMaybe
-- and point the pain in the ass if we don't use functor

-- example of using functor

text :: [Char]
text = "Haskell"

upperText :: [Char]
upperText = fmap toUpper text

-- we can also do this
upperText' = fmap (fmap toUpper) (Yes "haskell")

upperText'' = fmap toUpper <$> Yes "haskell"

-- another example use fmap with our previous block chain
data Chain a = GenesisBlock | Block (Chain a) a
  deriving Show

chain1 :: Chain Int
chain1 = Block (Block GenesisBlock 2) 4

instance Functor Chain where
  fmap :: (a -> b) -> Chain a -> Chain b
  fmap _ GenesisBlock = GenesisBlock
  fmap f (Block chain x) =  Block (fmap f chain) (f x)
