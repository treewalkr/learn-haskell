data Circle = Circle Radius deriving (Show, Eq)
data Square = Square Side deriving (Show, Eq)

type Radius = Float
type Side = Float
type PetalSize = Side
type InnerSquare = Square
type OuterSquare = Square

data Petal = Petal
    { outer :: OuterSquare
    , inner :: InnerSquare
    , circle :: Circle
    }
    deriving (Show, Eq)

data Rose
    = Pollen
    | Rose
        { petal :: Petal
        , innerRose :: Rose
        }
    deriving (Show, Eq)

mkPetal :: PetalSize -> Petal
mkPetal d =
    Petal
        { outer = Square d
        , inner = Square (sqrt (0.5) * d)
        , circle = Circle (0.5 * d)
        }

mkRose :: PetalSize -> Rose
mkRose d
    | d < 0.001 = Pollen
    | otherwise = Rose{petal = mkPetal d, innerRose = mkRose (d * 0.5)}

class Shape a where
    area :: a -> Float

instance Shape Circle where
    area (Circle r) = pi * r * r

instance Shape Square where
    area (Square s) = s * s

instance Shape Petal where
    area :: Petal -> Float
    area (Petal _ s c) = area c - area s

instance Shape Rose where
    area Pollen = 0
    area (Rose p r) = area p + area r

depth :: Rose -> Int
depth Pollen = 0
depth (Rose _ r) = 1 + depth r