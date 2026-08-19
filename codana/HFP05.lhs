HFP05 · Lambdas and Folds
=========================

Two ideas that unlock the rest of Haskell. *Lambdas* let you write a
function without naming it, right where it's used. *Folds* are the master
recursion pattern: `sum`, `product`, `length`, `map` and `filter` are all
the same fold wearing different hats. By the end, the `[] / (x : xs)`
skeleton you wrote by hand in HFP03 will look like manual labour.

Load it in GHCi:

    ghci HFP05.lhs

> module HFP05 where
>
> import Prelude hiding (foldl')   -- so our practice fold can keep the name


1. Anonymous functions (lambdas)
--------------------------------

You met lambdas briefly in HFP04 §5 — here is the complete picture.

The backslash `\` is the Greek letter λ, and the name comes from the
lambda calculus, the mathematical system Haskell is rooted in. A lambda is
a function with no name, written exactly where you need it:

    (\x -> x * 2) 21      -- => 42

It behaves identically to a named definition — these two are the same
function, one just stays anonymous:

> double :: Int -> Int
> double = (\x -> x * 2)

    double x = x * 2      -- same thing, equation style

Multiple arguments just add arrows, and the body extends as far right as
it can (parenthesise when needed):

    \x y -> x * 10 + y
    \x -> (\y -> x + y)   -- currying! a lambda returning a lambda (HFP01 §5)

Where lambdas shine is as one-off arguments to higher-order functions —
"sort by the second field", "keep multiples of three", "combine with a
running max" — logic too specific to deserve a top-level name:

    myMap (\x -> x ^ 2 + 1) [1 .. 5]
    myFilter (\x -> x `mod` 3 == 0) [1 .. 20]

One limit worth knowing: a lambda cannot pattern-match across several
equations the way `f [] = ... ; f (x:xs) = ...` does. When you need that,
either use a `case` expression inside the lambda, or just name the
function — naming is free.


2. Three functions, one shape
-----------------------------

Here are three old friends from HFP03, rewritten in prefix style so the
skeleton is easier to see:

> mySum :: [Int] -> Int
> mySum []       = 0                       -- base case
> mySum (x : xs) = (+) x (mySum xs)        -- combine head with result-of-rest
>
> myProduct :: [Int] -> Int
> myProduct []       = 1                   -- base case
> myProduct (x : xs) = (*) x (myProduct xs)
>
> myLength :: [a] -> Int
> myLength []       = 0                    -- base case
> myLength (x : xs) = (+) 1 (myLength xs)  -- ignore x, count the rest

Same skeleton, three times. The only things that vary:

    the combining function:   (+)      (*)        (+ 1 . const)
    the value for []:         0        1          0

HFP04 taught the move: when two functions differ only in an expression,
promote that expression to a parameter. Here TWO things vary, so we take
two parameters — and we get the most general list-consumer of them all.


3. foldr: fold from the right
-----------------------------

> foldr' :: (a -> b -> b) -> b -> [a] -> b
> foldr' _ z []     = z
> foldr' f z (x:xs) = f x (foldr' f z xs)

Read the type as a recipe: give me a way to combine one element with the
result for the rest of the list (`a -> b -> b`), a value for the empty
list (`z`), and a list — I'll give you a single summary (`b`).

The old functions become one-liners:

    foldr' (+) 0 [1 .. 20]    -- => mySum      (note the 0!)
    foldr' (*) 1 [1 .. 20]    -- => myProduct
    foldr' (\_ acc -> acc + 1) 0 [1 .. 10]   -- => myLength => 10

Why "from the right"? Unroll the recursion and the combining happens
right-to-left, innermost pair first:

    foldr' (-) 0 [1,2,3]
    = 1 - (2 - (3 - 0))
    = 1 - (2 - 3)
    = 2

(That is also why the accumulator-less `foldr' (+) [1..20]` you sometimes
see in old notes is a type error — `foldr'` demands its seed `z` before
the list.)


4. foldl: fold from the left
----------------------------

The mirror image. Note the flipped argument order in the combining
function — the accumulator comes FIRST:

> foldl' :: (b -> a -> b) -> b -> [a] -> b
> foldl' _ acc []     = acc
> foldl' f acc (x:xs) = foldl' f (f acc x) xs

(Name housekeeping: Prelude already exports a strict `foldl'`, so the
import at the top hides it and lets ours keep the name. The real
`Data.List.foldl'` is the *strict* fold — same result, but it doesn't
leak memory, which is why real code usually reaches for it. Our
hand-rolled recursion above matches the lazy `foldl`.)

The recursion threads a growing accumulator left-to-right:

    foldl' (-) 0 [1,2,3]
    = ((0 - 1) - 2) - 3
    = -6

Subtraction is not commutative, which makes it the perfect probe for
direction — same seed, same list, different answers:

    foldr' (-) 0 [1,2,3]   -- =>  2     (1 - (2 - (3 - 0)))
    foldl' (-) 0 [1,2,3]   -- => -6     (((0 - 1) - 2) - 3)


5. Everything is a fold
-----------------------

`map` and `filter` from HFP04 are folds too. For `map`, the combining
function conses the transformed head onto the folded tail, and the empty
list maps to the empty list:

> map' :: (a -> b) -> [a] -> [b]
> map' f = foldr' (\x acc -> f x : acc) []

    map' (* 10) [1,2,3]    -- => [10,20,30]

(If you sneak a peak at the naive attempt `foldr' ... xs` — folding only
the tail — you get `[20,30]`: the head is silently dropped. Fold over the
whole list; the pattern binding `(x:xs)` in the fold equation already did
that job for you.)

Same story with a predicate:

> filter' :: (a -> Bool) -> [a] -> [a]
> filter' p = foldr' (\x acc -> if p x then x : acc else acc) []

    filter' even [1 .. 10]   -- => [2,4,6,8,10]

So the whole HFP03/HFP04 toolkit collapses into one table:

    mySum      = foldr' (+) 0
    myProduct  = foldr' (*) 1
    myLength   = foldr' (\_ acc -> acc + 1) 0
    map' f     = foldr' (\x acc -> f x : acc) []
    filter' p  = foldr' (\x acc -> if p x then x : acc else acc) []
    id         = foldr' (:) []      -- reassembles the list itself!

And laziness gives a superpower: because `foldr'` computes the head
combination first, it can produce output before reaching the end of the
list — even a list with no end:

    take 5 (map' (* 10) [1 ..])      -- => [10,20,30,40,50]
    take 5 (foldr' (:) [] [1 ..])    -- => [1,2,3,4,5]

`foldl` cannot do this: it must chase the accumulator to the very end
before anything is produced, so on `[1 ..]` it simply never finishes.
(Feeding `foldl (+) 0 [1..]` into GHCi will hang — try it with a timeout.)


6. A debugging bonus: scanl
---------------------------

`scanl` is `foldl` that shows its work — it returns EVERY intermediate
accumulator instead of only the last one:

    scanl (+) 0 [1 .. 4]    -- => [0,1,3,6,10]

When a fold gives you a surprising number, `scanl` is how you watch it
being built.


7. Exercises
------------

Write each using `foldr'`, a lambda where needed. Answers at the bottom.

1. `myAnd :: [Bool] -> Bool` — True only if every element is True.
2. `myMaximum :: [Int] -> Int` — the largest element (assume all
   non-negative, so seeding with 0 is fair).
3. `keepEvens :: [Int] -> [Int]` — but write it as a fold, not `filter`.
4. Predict, then check in GHCi: `foldr' (-) 100 [1,2,3]` and
   `foldl' (-) 100 [1,2,3]`.

Answers:

    1. myAnd = foldr' (&&) True
    2. myMaximum = foldr' max 0
    3. keepEvens = foldr' (\x acc -> if even x then x : acc else acc) []
    4. foldr': 1 - (2 - (3 - 100)) = -98      foldl': ((100-1)-2)-3 = 94


8. The takeaway
---------------

- A lambda (`\x -> ...`) is an unnamed function written at the point of
  use — the natural fuel for higher-order functions.
- `foldr` and `foldl` are the abstraction of EVERY recursive list walk:
  supply the combining function and the seed, drop the skeleton.
- `foldr` combines from the right and can short-circuit on infinite
  lists; `foldl` threads an accumulator from the left and always runs to
  the end.
- Non-commutative operators like `(-)` expose the direction; `scanl`
  exposes the intermediate steps.
- When you next write `f [] = z ; f (x:xs) = ...` by hand, ask which
  fold you are re-implementing.
