-- ============================================================================
-- HFP02 · Lists in Haskell
-- ----------------------------------------------------------------------------
-- Lists are the workhorse data structure in Haskell: homogeneous, linked,
-- and manipulated through recursion / comprehensions rather than loops.
-- Load in GHCi:   ghci HFP02.hs
-- GHCi commands?  see the "Section 0" cheat-sheet in HFP01.hs
-- ============================================================================

module HFP02 where


-- ============================================================================
-- 1. Building lists  (literals & ranges)
-- ----------------------------------------------------------------------------
-- [a]  is read as "list of a".  All elements must share the same type.
-- A range  [lo .. hi]  enumerates from lo to hi inclusive.
-- A stepped range  [a, b .. hi]  infers the step from (b - a).
-- ============================================================================

a :: [Int]        -- "a has type list-of-Int"
a = [1, 2, 3, 4, 5]

a' :: [Int]
a' = [1 .. 5]     -- range: same as [1,2,3,4,5]

a'' = [1, 3 .. 100]   -- step of 2: 1, 3, 5, ..., 99 (odd numbers)


-- ============================================================================
-- 2. List comprehensions
-- ----------------------------------------------------------------------------
-- Syntax:  [ output | x <- input, predicate, ... ]
-- Reads like set-builder notation. Multiple generators & filters are allowed.
-- ============================================================================

b :: [Int]
b = [x ^ 2 | x <- [1 .. 100]]            -- squares of 1..100

b' = [x ^ 2 | x <- [1 .. 100], isEven x] -- squares of the EVEN numbers only

isEven :: Int -> Bool
isEven x = x `mod` 2 == 0    -- (Haskell ships a built-in `even` that does this)


-- ============================================================================
-- 3. Essential list functions
-- ----------------------------------------------------------------------------
--   (++)   concatenate two lists
--   (!!)   index into a list           (zero-based)
--   head   first element
--   tail   everything BUT the first    (still a list)
--   take   first N elements            (works on infinite lists too)
-- ============================================================================

c  = [1, 2, 3]
c' = [4, 5, 6]

d = c ++ c'      -- concat:            [1,2,3,4,5,6]

e = d !! 2       -- index:             3   (0-based)

f = head c       -- first element:     1

g = tail d       -- drop the head:     [2,3,4,5,6]

h = take 3 [1 ..]   -- first 3 of an INFINITE list:  [1,2,3]


-- ============================================================================
-- 4. Polymorphism  (type variables)
-- ----------------------------------------------------------------------------
-- Ask GHCi for the type of (++) and you get:
--
--     (++) :: [a] -> [a] -> [a]
--
-- The lowercase `a` is a TYPE VARIABLE — it stands for "any type", not a
-- concrete one like Int or Bool. So (++) works on lists of ANYTHING:
-- strings, lists of lists, anything. This is called *parametric polymorphism*.
--
-- The other functions above are polymorphic too — try them in GHCi:
--
--     :t (!!)    =>  (!!) :: [a] -> Int -> a
--     :t head    =>  head :: [a] -> a
--     :t tail    =>  tail :: [a] -> [a]
--     :t take    =>  take :: Int -> [a] -> [a]
--
-- Notice how `a` flows through: whatever type the list holds is the type you
-- get back. That contract is enforced by the compiler.
-- ============================================================================


-- ============================================================================
-- 5. Strings are just lists of characters
-- ----------------------------------------------------------------------------
-- String  is a type synonym for  [Char].  So every list function works on
-- strings for free:  head "abc" == 'a',  "ab" ++ "cd" == "abcd",  etc.
-- ============================================================================

k :: Char
k = 'a'          -- a single character uses single quotes

l :: [Char]
l = "abcdefg"    -- a string literal uses double quotes

l' :: String     -- String and [Char] are the SAME type
l' = 'a' : ['b' .. 'g']   -- 'a' consed onto the range b..g  =>  "abcdefg"


-- ============================================================================
-- 6. The cons operator  (:)   — pronounced "cons"
-- ----------------------------------------------------------------------------
-- (:)  prepends ONE element to the front of a list:   x : xs
-- Every list is ultimately built this way, ending in the empty list [].
-- (:) is RIGHT-associative, so the explicit parentheses below are optional.
-- ============================================================================

m  = [1, 2, 3, 4, 5]

m'  = 1 : 2 : 3 : 4 : 5 : []                     -- same list, fully consed

m'' = (1 : (2 : (3 : (4 : (5 : [])))))           -- same again, fully parenthesised
