  $ bun ./method-member.cases.ts
  module methods preserve their results through direct calls and bindings
  {
    arg0: 2,
    arg1: {
      arg0: 3,
      arg1: {
        arg0: 1,
        arg1: {
          tag: 'Nil'
        },
        tag: 'Cons'
      },
      tag: 'Cons'
    },
    tag: 'Cons'
  }
  {
    arg0: 2,
    arg1: {
      arg0: 3,
      arg1: {
        tag: 'Nil'
      },
      tag: 'Cons'
    },
    tag: 'Cons'
  }
  {
    arg0: 1,
    arg1: {
      arg0: 2,
      arg1: {
        tag: 'Nil'
      },
      tag: 'Cons'
    },
    tag: 'Cons'
  }
  a consumer calls an unrestricted method directly
  {
    arg0: 'b',
    arg1: {
      arg0: 'c',
      arg1: {
        arg0: 'a',
        arg1: {
          tag: 'Nil'
        },
        tag: 'Cons'
      },
      tag: 'Cons'
    },
    tag: 'Cons'
  }
