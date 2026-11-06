  $ bun ./statements.cases.ts
  a match in a branch of a conditional returns from each case
  5
  0
  a call around a match is pushed into its cases
  8
  2
  a let in a branch stays in its case
  4
  8
  a context that computes reads a variable the cases assign
  6
  5
  7
  two matches of one call, the first through a variable
  7
  6
  a let bound to a match is assigned in its cases
  8
  0
  a let whose body computes more is assigned in its cases
  10
  2
  a let whose body binds is assigned in its cases
  10
  9
  a context that holds a constructor reads the assigned variable
  3
  4
  [
    4,
    1
  ]
  a match on the result of a match
  3
  7
  a partial application of a match on a pair
  6
  a top-level constant whose value is a match
  4
  a top-level match on a constant
  1
  a let in a lazy constructor runs when the cell is forced
  12
  16
