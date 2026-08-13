-- ============================================================================
-- HFP01 · Functions in Haskell
-- ----------------------------------------------------------------------------
-- A quick tour through arithmetic, function composition, and currying.
-- Load in GHCi:   ghci HFP01.hs
-- Then try:       doubleSquare 3   =>  36
-- ============================================================================

module HFP01 where

-- ============================================================================
-- 0. GHCi cheat-sheet  (every command has a short alias)
-- ----------------------------------------------------------------------------
-- Start GHCi on this file:   ghci HFP01.hs
-- Once inside, these are the commands you'll use constantly:
--
--   :load <file>   (:l)   Compile & bring a file's definitions into scope.
--                          :l HFP01.hs
--
--   :reload        (:r)   Reload the currently loaded file after you edit it.
--                          (no argument — just :r)
--
--   :type <expr>   (:t)   Show the TYPE of an expression WITHOUT running it.
--                          :t double       =>  double :: Int -> Int
--                          :t raise        =>  raise :: Int -> Int -> Int
--                          :t 1 + 1        =>  1 + 1 :: Num a => a
--
--   :info <name>   (:i)   Show a name's definition, type, and typeclass
--                          INSTANCES. Great for exploring the language.
--                          :i Int          (everything Int belongs to)
--                          :i (+)          (which class defines +)
--                          :i Num          (the methods of the Num class)
--
-- Rule of thumb:  :t answers "what type is this?"
--                 :i answers "what IS this thing, and what can it do?"
-- ============================================================================


-- ============================================================================
-- 1. Arithmetic operators
-- ----------------------------------------------------------------------------
-- Every operator can be written two ways:
--   • infix   :  placed between its arguments   (e.g. 1 + 1)
--   • prefix  :  wrapped in parentheses          (e.g. (+) 1 1)
-- Both forms are identical; pick whichever reads best.
-- ============================================================================

a  = 1 + 1        -- infix form
a' = (+) 1 1      -- prefix form (same value)

b  = 3 - 1
b' = (-) 3 1      -- (-) must be parenthesised so it isn't read as a negative sign

c  = 4 * 2
c' = (*) 4 2

d  = 5 / 2        -- fractional division   (Fractional  => 2.5)
d' = (/) 5 2


-- ============================================================================
-- 2. Integer division, modulo, and powers
-- ----------------------------------------------------------------------------
-- `div` and `mod` work on whole numbers (the Integral typeclass).
-- Any normal function can be turned into an infix operator by wrapping it in
-- backticks:   5 `div` 2
-- ============================================================================

e  :: Int         -- an explicit type signature
e  = div 5 2      -- prefix: integral division (5 div 2 == 2)
e' = 5 `div` 2    -- infix:  same thing, often clearer

g  = mod 3 2      -- modulo: 3 mod 2 == 1
g' = 3 `mod` 2

h  = 2 ^ 3        -- exponentiation, infix
h' = (^) 2 3      -- exponentiation, prefix

i  = 2 ^ 3 ^ 4    -- right-associative => 2 ^ (3 ^ 4)   (huge!)
i' = (2 ^ 3) ^ 4  -- explicit grouping => (2 ^ 3) ^ 4


-- ============================================================================
-- 3. Defining functions
-- ----------------------------------------------------------------------------
-- A function definition is:   name args = body
-- The type signature above it is optional but recommended.
-- ============================================================================

-- Pythagorean hypotenuse:  sqrt(x² + y²)
hypotenuse :: Double -> Double -> Double
hypotenuse x y = sqrt (x ^ 2 + y ^ 2)

-- Multiply a number by two.
double :: Int -> Int
double x = 2 * x

-- Square a number.
square :: Int -> Int
square x = x ^ 2


-- ============================================================================
-- 4. Function composition  (.)
-- ----------------------------------------------------------------------------
-- (f . g) x  ==  f (g x)
-- Read "." as "after". So `square . double` means "square AFTER double":
--   doubleSquare 3  =  square (double 3)  =  square 6  =  36
-- Notice the argument isn't written — this point-free style is idiomatic.
-- ============================================================================

doubleSquare :: Int -> Int
doubleSquare = square . double   -- "square after double"


-- ============================================================================
-- 5. Currying & partial application
-- ----------------------------------------------------------------------------
-- In Haskell every function takes exactly ONE argument.
-- A "multi-argument" function really takes one arg and returns another function
-- that expects the rest. That's why the signature uses `->` all the way:
--
--     raise :: Int -> (Int -> Int)
--     raise x  =>  a function waiting for y, computing y ^ x
--
-- Supplying only the first argument is called a *partial application*.
-- ============================================================================

raise :: Int -> (Int -> Int)   -- the parentheses show the curried grouping
raise x y = y ^ x             -- raise x, to the power of... no wait: y ^ x

-- Partial application: fix the exponent to 2, get a "square-like" function.
raiseTwo :: Int -> Int
raiseTwo = raise 2            -- raiseTwo 5  ==  5 ^ 2  ==  25
