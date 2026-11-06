  $ bun ./separate-kinds.cases.ts
  applications to a module of another file
  {
    actual: {
      arg0: 3,
      arg1: {
        tag: 'Nil'
      },
      tag: 'Cons'
    },
    expected: {
      arg0: 3,
      arg1: {
        tag: 'Nil'
      },
      tag: 'Cons'
    }
  }
  {
    actual: {
      tag: 'Nil'
    },
    expected: {
      tag: 'Nil'
    }
  }
  {
    actual: {
      tag: 'Nil'
    },
    expected: {
      tag: 'Nil'
    }
  }
  a consumer lambda extends the TypeLambda of the module type's file
  [
    4,
    8
  ]
  []
