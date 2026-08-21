HFP06 · Custom Data Types
=========================

So far every type we used — `Int`, `Bool`, `[a]`, `Double` — came from the
Prelude. This lesson defines new types from scratch. Two moves cover
almost everything: a type can be a *choice* of values (enumeration) or a
*bundle* of values (record). Add type parameters and recursion, and you
can build lists, trees, blockchains — any shape you like.

Load it in GHCi:

    ghci HFP06.lhs

> module HFP06 where


1. Enumerations: a type as a choice of values
---------------------------------------------

You already know one such type — `Bool` itself is defined exactly like
this (try `:i Bool` in GHCi and scroll to the top):

    data Bool = False | True

The recipe: `data Name = Constructor1 | Constructor2 | ...`. For our own
yes/no type:

> data Choice = No | Yes deriving (Show, Eq)

Each capitalised name on the right is a *data constructor* — a value of
type `Choice`. They take no arguments here, so they are values already:

    :t Yes   =>  Yes :: Choice

`deriving (Show, Eq)` asks the compiler to auto-generate printing (`Show`,
so GHCi can display `Yes`) and equality (`Eq`, so `Yes == No` works) —
free boilerplate.

Pattern matching drives the logic, first-match-wins as always (HFP03):

> and' :: Choice -> Choice -> Choice
> and' Yes Yes = Yes
> and' _ _     = No

    and' Yes Yes   -- => Yes
    and' Yes No   -- => No


2. Product types: a bundle of values
------------------------------------

The other move: one value holding several fields. `Employee` bundles two
names and an age:

> data Employee = Employee FirstName LastName Age deriving Show
>
> john :: Employee
> john = Employee "John" "Doe" 33

Yes, `Employee` appears twice — the left one is the TYPE constructor, the
right one the DATA constructor. They live in different namespaces, which
is why sharing a name is legal and conventional.

`type` introduces a *type synonym* — a readability alias, not a new type:

> type FirstName = String
> type LastName = String
> type Age = Int

(`FirstName` and `String` are fully interchangeable to the compiler; if
you want a genuinely distinct type that catches mix-ups, that's `newtype`
— a later lesson. Also note Haskell doesn't care that these synonyms are
declared after first use — top-level order is free.)

Constructors with fields are pattern-matched positionally:

> getFirstName :: Employee -> FirstName
> getFirstName (Employee firstName _ _) = firstName
>
> getLastName :: Employee -> LastName
> getLastName (Employee _ lastName _) = lastName

    john                -- => Employee "John" "Doe" 33
    getFirstName john   -- => "John"


3. Type constructors vs data constructors
-----------------------------------------

Both can take zero or more arguments — but they operate at different
levels:

- a TYPE constructor takes *types* and makes a type: `Employee` (none),
  `Square` (one), `[ ]` (one), `Map` (two).
- a DATA constructor takes *values* and makes a value: `No` (none),
  `Employee` (three: two strings and an Int).

Ask GHCi for a constructor's type and the truth appears — a data
constructor with fields is just a function (curried, per HFP01 §5!):

    :t Employee     =>  Employee :: FirstName -> LastName -> Age -> Employee
    :t Square       =>  Square   :: a -> Square a
    :t GenesisBlock =>  GenesisBlock :: Chain a     -- no fields: already a value


4. Record syntax: getters for free
----------------------------------

Positional matching works but is brittle — swap two same-typed fields and
nothing warns you. Naming the fields with record syntax generates a
getter per field:

> data Employee' = Employee'
>   { firstName :: String
>   , lastName  :: String
>   , age       :: Int
>   } deriving Show
>
> john' :: Employee'
> john' = Employee'
>   { firstName = "John"
>   , lastName  = "Doe"
>   , age       = 33
>   }

The getters are ordinary top-level functions:

    :t firstName      =>  firstName :: Employee' -> String
    firstName john'   -- => "John"
    age john'         -- => 33

Printing got nicer too — GHCi shows field names:

    john'   -- => Employee' {firstName = "John", lastName = "Doe", age = 33}

Records bring *update syntax* — copy-with-changes, without touching the
original:

    age (john' { age = 34 })   -- => 34

And both pattern styles still work, positional or by name:

> getAgePos :: Employee' -> Int
> getAgePos (Employee' _ _ a) = a
>
> getAgeRec :: Employee' -> Int
> getAgeRec (Employee' { age = a }) = a


5. Polymorphic datatypes
------------------------

A type constructor can take a type parameter, exactly like `a` in
`[a]` (HFP02 §4) — the same shape, many element types:

> data Square a = Square a deriving Show

> intSquare :: Square Int
> intSquare = Square 5
>
> dblSquare :: Square Double
> dblSquare = Square 4.5


Functions over them carry the constraint where needed — `area` works for
any numeric side:

> area :: Num a => Square a -> a
> area (Square side) = side * side

    area intSquare   -- => 25
    area dblSquare   -- => 20.25


6. Recursive datatypes: build your own list
-------------------------------------------

A data constructor's arguments may mention the very type being defined.
That's how linked structures exist. Here is a blockchain-shaped list —
either the `GenesisBlock` or an older chain with one more `Block` glued
on the front:

> data Chain a = GenesisBlock | Block (Chain a) a deriving Show

Look familiar? This is the list type from HFP03 wearing different names:

    data [a] = []        | (:)        a    [a]    -- conceptual
    data Chain a = GenesisBlock | Block (Chain a) a -- ours

(One honest difference: `(:)` takes the element first, `Block` takes the
chain first — argument order is the designer's choice.)

Build chains by nesting constructors:

> chain    :: Chain Int
> chain    = GenesisBlock
>
> chain'   :: Chain Int
> chain'   = Block chain 3
>
> chain''  :: Chain Int
> chain''  = Block chain' 17
>
> chain''' :: Chain Int
> chain''' = Block chain'' 11

    chain'''   -- => Block (Block (Block GenesisBlock 3) 17) 11

And consume them with the exact `[]` / `(x : xs)` skeleton from HFP03 —
here with the unused field matched as `_` rather than named:

> len' :: Chain a -> Int
> len' GenesisBlock      = 0
> len' (Block rest _)    = 1 + len' rest
>
> sumChain :: Num a => Chain a -> a
> sumChain GenesisBlock   = 0
> sumChain (Block rest v) = v + sumChain rest

    len' chain'''      -- => 3
    sumChain chain'''  -- => 31   (11 + 17 + 3)

If you feel you've written `sumChain` before — you have: it is `mySum`
from HFP05 in disguise. Any recursive type gets consumed by the same
recursion; folds generalise to those too (that road leads to `Foldable`).


7. Exercises
------------

1. `or' :: Choice -> Choice -> Choice` — Yes if EITHER input is Yes.
2. `not' :: Choice -> Choice` — flip the value.
3. `birthday :: Employee' -> Employee'` — a copy of an employee with the
   age incremented (record update, not pattern matching).
4. Brainteaser, then check in GHCi: what is `map Square [1, 2, 3]`, and
   what is its type? Why does that even work?

Answers:

    1. or' No No = No
       or' _  _  = Yes
    2. not' Yes = No
       not' No  = Yes
    3. birthday e = e { age = age e + 1 }
    4. map Square [1,2,3]  =>  [Square 1,Square 2,Square 3]
       It works because Square is a function (a -> Square a), and every
       function can be mapped (HFP04) and partially applied (HFP01 §5).


8. The takeaway
---------------

- `data` declares a type as a choice (sum) of constructors; constructors
  with fields bundle (product) values.
- Type constructors make types; data constructors make values — and a
  constructor with fields IS a curried function.
- `type` aliases existing types; records generate getters and update
  syntax; `deriving` hands you Show/Eq for free.
- Type parameters (`Square a`) give polymorphic shapes; recursion in
  constructors (`Chain a`) gives linked structures — your own `[]`.
- Everything is consumed the same way: pattern match the constructors,
  recurse on the self-referential field.
