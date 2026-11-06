  $ bun ./lifting.cases.ts
  a lifted binder keeps its dependency wherever it stands
  [
    0,
    0,
    false
  ]
  [
    2,
    5,
    7
  ]
  [
    'x',
    false
  ]
  two binders, one tested in the other's branch
  [
    3,
    true
  ]
  {
    actual: {
      arg0: 1,
      arg1: {
        tag: 'Nil'
      },
      tag: 'Cons'
    },
    expected: {
      arg0: 1,
      arg1: {
        tag: 'Nil'
      },
      tag: 'Cons'
    }
  }
