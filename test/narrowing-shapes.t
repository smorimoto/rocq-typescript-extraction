  $ bun ./narrowing-shapes.cases.ts
  a match on a local or a global known to be one constructor
  1
  2
  {
    actual: {
      tag: 'Green'
    },
    expected: {
      tag: 'Green'
    }
  }
  1
  1
  1
  a match on a term known to be one of two constructors
  0
  1
  0
  1
  0
  0
  a match on a variable that an enclosing branch narrows
  [
    0,
    2,
    7
  ]
  [
    0,
    2,
    4
  ]
  [
    2,
    1,
    3
  ]
  [
    2,
    0,
    0
  ]
  a match on a term that is not narrowed keeps every branch
  0
  3
  4
