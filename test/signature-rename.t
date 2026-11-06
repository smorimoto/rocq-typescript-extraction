  $ bun ./signature-rename.cases.ts
  a functor calls the member that the module type names
  {
    arg0: 1,
    arg1: {
      arg0: 1,
      arg1: {
        arg0: 5,
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
    arg0: 1,
    arg1: {
      arg0: 1,
      arg1: {
        arg0: 2,
        arg1: {
          tag: 'Nil'
        },
        tag: 'Cons'
      },
      tag: 'Cons'
    },
    tag: 'Cons'
  }
  a member keeps its own name beside one renamed onto it
  {
    arg0: 3,
    arg1: {
      tag: 'Nil'
    },
    tag: 'Cons'
  }
