  $ bun ./inline-matches.cases.ts
  a match on a boolean is a conditional, in a body and in an argument
  1
  2
  2
  5
  5
  36
  3
  a match of the boolean literals is its test or the negation
  true
  false
  false
  true
  true
  false
  false
  false
  true
  a match on a number binds the predecessor once per branch
  true
  false
  1
  5
  5
  0
  1
  9
  a match on an array reads the head in place and binds the tail
  7
  1
  10
  0
  6
  a match on a tuple reads its elements in place
  [
    'a',
    1
  ]
  a match on three constructors is a chain of ifs
  1
  0
  -1
  0
  4
  8
