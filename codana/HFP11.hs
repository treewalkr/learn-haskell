module HFP11 where

-- see :i Monad
-- (>>=) or bind

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

instance Monad MyMaybe where
  (>>=) :: MyMaybe a -> (a -> MyMaybe b) -> MyMaybe b
  (>>=) No _ = No
  (>>=) (Yes x) f = f x

safeHead :: [Int] -> MyMaybe Int
safeHead [] = No
safeHead xs = Yes (head xs)

safeDiv _ 0 = No
safeDiv x y = Yes (div x y)

headAndDiv :: [Int] -> Int -> MyMaybe Int
headAndDiv xs y =
  case safeHead xs of
    No    -> No
    Yes x -> case safeDiv x y of
      No    -> No
      Yes y -> Yes y

headAndDiv' :: [Int] -> Int -> MyMaybe Int
headAndDiv' xs y =
  safeHead xs >>= \x 
    -> safeDiv x y >>= \n
      -> Yes n -- optional

-- do notation
headAndDiv'' :: [Int] -> Int -> MyMaybe Int
headAndDiv'' xs y = do
  x <- safeHead xs
  n <- safeDiv x y
  Yes n

