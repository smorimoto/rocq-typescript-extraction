  $ bun ./lists.cases.ts
  option: safeHead distinguishes the empty list
  {
    tag: 'None'
  }
  {
    arg0: 'a',
    tag: 'Some'
  }
  prod: swapPair exchanges the components
  {
    actual: {
      arg0: true,
      arg1: 1,
      tag: 'Pair'
    },
    expected: {
      arg0: true,
      arg1: 1,
      tag: 'Pair'
    }
  }
  list recursion and Corelib list functions
  6
  [
    1,
    2
  ]
  [
    0,
    2,
    4,
    6
  ]
  [
    11,
    12
  ]
  12
  3
  {
    tag: 'Nil'
  }
  Corelib arithmetic on nat
  4
  'Lt'
  'True'
  'False'
  'False'
  5
  a lambda whose body binds a scrutinee has a block body
  [
    2,
    0
  ]
