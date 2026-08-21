module HFP08 where

-- type classes
-- see :t (+), :t (==), :i Num

data Point = Point {
  coordinate :: (Double, Double)
} 
pointA :: Point
pointA = Point (5.5, 5)

pointA' :: Point
pointA' = Point { coordinate = (5.5, 5) }

-- Eq
instance Eq Point where
  (==) (Point (x1, y1)) (Point (x2, y2))
    | x1 == x2 && y1 == y2 = True
    | otherwise            = False

-- Num
instance Num Point where
  (+) (Point (x1, y1)) ( Point (x2, y2)) = Point ((x1 + x2), (y1 + y2))

-- Show
instance Show Point where
  show (Point (x, y)) = "x: " ++ show x ++ " y: " ++ show y

-- Distance 
-- TODO: Make this make more sense
class Distance a where
  distance :: a -> a -> Double

instance Distance Point where
  distance (Point (x1, y1)) (Point (x2, y2)) = sqrt ((x1-x2)^2 + (y1-y2)^2)
