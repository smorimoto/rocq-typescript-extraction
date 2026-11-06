  $ bun ./curried-type-family.cases.ts
  heterogeneous curried actions retain their runtime arguments and result
  [
    7,
    9,
    0,
    true,
    false,
    false,
    true
  ]
  the final result can itself be a function
  [
    true,
    false,
    true,
    false
  ]
  a quantified callback retains the result parameter of the action family
  [
    0,
    13
  ]
