  $ bun ./loops.cases.ts
  a self call that is no tail stays a call
  [
    0,
    1,
    1,
    3,
    3
  ]
  a function that reads a parameter a self call changes keeps the recursion
  6
  10
