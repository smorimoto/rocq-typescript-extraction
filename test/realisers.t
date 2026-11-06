  $ bun ./realisers.cases.ts
  a mapped type asked for by name brings its realisers into its module
  3
  'full 3'
  a module asked for brings the realisers of its mapped type
  [
    1,
    2
  ]
  3
  a mapped type asked for at the top level exports its realisers
  42
  'succ 2'
  the type that the code of an exported realiser names is exported
  {
    actual: {
      hi: 5,
      lo: 2
    },
    expected: {
      hi: 5,
      lo: 2
    }
  }
  3
