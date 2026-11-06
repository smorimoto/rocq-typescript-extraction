  $ bun ./constructors.cases.ts
  a constructor the command names is exported with its type and the other builders
  [
    'area',
    'box',
    'dot',
    'line',
    's'
  ]
  {
    n: 3,
    tag: 'Line'
  }
  {
    actual: {
      n: 3,
      tag: 'Line'
    },
    expected: {
      n: 3,
      tag: 'Line'
    }
  }
  a constructor of a mapped type exports its realiser
  42
  a match on a const initialised by a constructor call
  4
