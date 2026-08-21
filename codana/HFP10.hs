{-# LANGUAGE InstanceSigs #-}

module HFP10 where

-- Applicative
-- see :t Applicative

data MyMaybe a = No | Yes a
  deriving Show

instance Functor MyMaybe where
  fmap _ No = No
  fmap f (Yes x) = Yes (f x)

instance Applicative MyMaybe where
  pure :: a -> MyMaybe a
  pure x = Yes x
  (<*>) :: MyMaybe (a -> b) -> MyMaybe a -> MyMaybe b
  (<*>) No _       = No
  (<*>) _ No       = No
  (<*>) (Yes f) ma = fmap f ma

  -- see (+) <$> (Yes 4) <*> (Yes 6)
  --     (\x y z -> x + y + z) <$> (Yes 4) <*> (Yes 6) <*> (Yes 10)
  --     pure (+2) <*> (Yes 3)

