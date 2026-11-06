  $ bun ./dependent.cases.ts
  a parameter whose type depends on an earlier one follows it
  3
  1
  3
  a packet is narrowed by the argument its payload depends on
  4
  [
    3,
    0
  ]
  a call with a constructor argument has the type of its branch
  [
    0,
    false,
    false
  ]
  [
    0,
    1,
    true,
    4,
    4
  ]
  a pair of dependent calls keeps the dependency of each
  [
    0,
    0
  ]
  [
    false,
    false
  ]
  each branch of a dependent match keeps its own function type
  1
  true
