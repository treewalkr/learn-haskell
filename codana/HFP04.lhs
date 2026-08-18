HFP04 · Higher-Order Functions: map and filter
===============================================

A *higher-order function* is a function that takes another function as an
argument (or returns one). This is where Haskell starts to feel different:
functions are values, so you can pass them around like numbers or lists.
This lesson builds `map` and `filter` from scratch by noticing a repeated
pattern — the same way abstraction works everywhere in programming.

Load it in GHCi:

    ghci HFP04.lhs

> module HFP04 where
>
> import Data.Char (toUpper)


1. Functions as arguments
-------------------------

Look at the type of `superFunction`: its first parameter is not an `Int`
but a whole function `(Int -> Int -> Int)`. Whatever function you hand it,
`superFunction` calls it on `(x + 2)` and `(y + 2)`:

> superFunction :: (Int -> Int -> Int) -> Int -> Int -> Int
> superFunction f x y = f (x + 2) (y + 2)

Try it in GHCi and watch the behaviour change with the argument:

    superFunction (+) 1 2   =>  7     -- (1+2) + (2+2)
    superFunction (*) 1 2   =>  12    -- (1+2) * (2+2)
    superFunction max 1 2   =>  4     -- max (1+2) (2+2)

Passing `(*)` instead of `(+)` changes the *strategy* while the surrounding
code stays fixed. That is the whole idea.


2. A repeated pattern
---------------------

Here are two ordinary recursive functions (the `[]` / `(x : xs)` skeleton
from HFP03). One squares every element, the other subtracts one:

> squareAllElements :: [Int] -> [Int]
> squareAllElements []       = []
> squareAllElements (x : xs) = x ^ 2 : squareAllElements xs
>
> minusOneAllElements :: [Int] -> [Int]
> minusOneAllElements []       = []
> minusOneAllElements (x : xs) = x - 1 : minusOneAllElements xs

Squint at them: the *shape* is identical. The only difference is what we do
to the head — `x ^ 2` versus `x - 1`. Whenever two functions differ only in
one expression, that expression wants to become a parameter.


3. Abstracting the pattern: myMap
---------------------------------

Promote "what to do to each element" into a function argument. First a
monomorphic warm-up, restricted to `Int`:

> myMap' :: (Int -> Int) -> [Int] -> [Int]
> myMap' _ []       = []
> myMap' f (x : xs) = f x : myMap' f xs

Now loosen the types. The input and output lists don't even need to hold
the same type, so two type variables `a` and `b` (recall polymorphism in
HFP02):

> myMap :: (a -> b) -> [a] -> [b]
> myMap _ []       = []
> myMap f (x : xs) = f x : myMap f xs

One function, infinitely many uses — the transformation is supplied at the
call site:

    myMap (+ 2)  [1 .. 20]
    myMap (^ 2)  [1 .. 10]
    myMap toUpper "haskell"   -- => "HASKELL"

Prelude already ships exactly this function; ask for its type and compare:

    :t map     =>  map :: (a -> b) -> [a] -> [b]


4. The same trick with a predicate: filter
------------------------------------------

Filtering has the same story, only the choice is "keep or drop" instead of
"transform". Two concrete versions first:

> filterEven :: [Int] -> [Int]
> filterEven []       = []
> filterEven (x : xs)
>   | even x    = x : filterEven xs
>   | otherwise = filterEven xs
>
> filterIfMoreThanTen :: [Int] -> [Int]
> filterIfMoreThanTen []       = []
> filterIfMoreThanTen (x : xs)
>   | x > 10    = x : filterIfMoreThanTen xs
>   | otherwise = filterIfMoreThanTen xs

Same skeleton, different condition. Promote the condition to a function
argument — a *predicate* `a -> Bool`:

> myFilter :: (a -> Bool) -> [a] -> [a]
> myFilter _ []           = []
> myFilter predicate (x : xs)
>   | predicate x = x : myFilter predicate xs
>   | otherwise   = myFilter predicate xs

Again, try it and compare with the built-in:

    myFilter even [1 .. 20]   -- => [2,4,6,8,10,12,14,16,18,20]
    :t filter                 -- => filter :: (a -> Bool) -> [a] -> [a]

You have met this idea before: the list comprehension
`[x ^ 2 | x <- [1 .. 100], isEven x]` in HFP02 is a filter (the predicate
part) fused with a map (the `x ^ 2` part).


5. The takeaway
---------------

- `map f` and `filter p` capture the two most common ways to walk a list,
  so you almost never write that recursion by hand.
- Higher-order functions let you abstract over *behaviour*, not just data:
  `(a -> b)` and `(a -> Bool)` are the seams.
- When you spot yourself copy-pasting a recursive skeleton, promote the
  varying expression into a parameter — that is how `map` and `filter`
  were born (and how you will invent your own).
