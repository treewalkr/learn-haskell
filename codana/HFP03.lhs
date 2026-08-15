HFP03 · Pattern Matching, Guards & Recursion in Haskell
========================================================

Load it in GHCi:

    ghci HFP03.lhs

> module HFP03 where


1. Pattern matching
-------------------

Haskell branches by *matching the shape of data*. Each equation tries its
patterns from top to bottom — the **first match wins** and its right-hand
side is used. `_` is a wildcard matching anything. If every pattern fails
you get a runtime error, so it's wise to finish with a catch-all.

> isNine :: Int -> Bool
> isNine 9 = True    -- literal pattern: only matches the value 9
> isNine _ = False   -- wildcard:       catches everything else

Order matters — the first equation to match wins:

> isSevenOrNine :: Int -> Bool
> isSevenOrNine 7 = True
> isSevenOrNine 9 = True
> isSevenOrNine _ = False


2. Pattern matching on lists
----------------------------

A list is *either* empty `[]` or an element consed onto a list `(x : xs)`.
Pattern matching mirrors that shape exactly, giving the standard idiom for
consuming a list recursively:

    f []     = <base case>
    f (x:xs) = <use x> ... f xs

> sumList :: [Int] -> Int
> sumList []       = 0                    -- base case: sum of nothing is 0
> sumList (x : xs) = x + sumList xs       -- head + sum of the rest

Note the base case below is **1**, not 0 — a product of nothing is 1:

> productList :: [Int] -> Int
> productList []       = 1
> productList (x : xs) = x * productList xs


3. Top-level pattern binding
----------------------------

This is the curiosity of the file. `(x : xs)` on the *left* of `=` is a
pattern, so this line destructures the list and binds two names at the top
level:

> (x : xs) = [1, 2, 3, 4, 5]

so `x == 1` and `xs == [2,3,4,5]`. Try both in GHCi. Why is that legal?
Because `(:)` is a *constructor* — `:t (:)` says

    (:) :: a -> [a] -> [a]

and patterns are built from constructors, so we can invert one.

Here's the same recursion *without* pattern-matching the equations, using
`head`/`tail` instead. It works, but `head []` crashes — the `[]` pattern
above can never crash, which is why it's preferred:

> sumList' :: [Int] -> Int
> sumList' [] = 0
> sumList' el = head el + sumList' (tail el)


4. Branching: if-then-else vs guards
------------------------------------

`if-then-else` is an *expression* — it returns a value and the `else` is
mandatory. Guards (`|`) read like a decision table and shine when there
are several conditions. `otherwise` is simply `True`, the always-taken
final guard.

Sum only the elements divisible by both 5 and 3 — first with if-then-else:

> sumListWithConditions :: [Int] -> Int
> sumListWithConditions [] = 0
> sumListWithConditions (x : xs) =
>   if isModuloOf x 5 3
>     then x + sumListWithConditions xs   -- keep x
>     else sumListWithConditions xs       -- skip x

then the same logic with guards — flatter and easier to extend:

> sumListWithConditions' :: [Int] -> Int
> sumListWithConditions' [] = 0
> sumListWithConditions' (x : xs)
>   | isModuloOf x 5 3 = x + sumListWithConditions' xs
>   | otherwise        = sumListWithConditions' xs

> isModuloOf :: Int -> Int -> Int -> Bool
> isModuloOf e x y = e `mod` x == 0 && e `mod` y == 0


5. Recursion practice
---------------------

The classic algorithms, all built from the same `[]` / `(x : xs)` skeleton.

Reverse a list: take the head and stick it *after* the reversed tail:

> myReverse :: [a] -> [a]
> myReverse []       = []
> myReverse (x : xs) = myReverse xs ++ [x]

Membership test:

> hasElem :: Int -> [Int] -> Bool
> hasElem _ []       = False
> hasElem e (x : xs)
>   | e == x    = True
>   | otherwise = hasElem e xs
