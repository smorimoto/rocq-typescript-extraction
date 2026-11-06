  $ bun ./unknown.cases.ts
  a result whose type depends on the argument has the union of the branch types
  {
    tag: 'O'
  }
  {
    actual: {
      tag: 'False'
    },
    expected: {
      tag: 'False'
    }
  }
  a constant of a logical type is undefined
  undefined
  a proof passed to a polymorphic function is undefined
  0
  {
    actual: {
      arg0: undefined,
      arg1: {
        arg0: undefined,
        arg1: {
          tag: 'Nil'
        },
        tag: 'Cons'
      },
      tag: 'Cons'
    },
    expected: {
      arg0: undefined,
      arg1: {
        arg0: undefined,
        arg1: {
          tag: 'Nil'
        },
        tag: 'Cons'
      },
      tag: 'Cons'
    }
  }
