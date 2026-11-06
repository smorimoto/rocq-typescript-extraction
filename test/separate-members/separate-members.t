  $ bun ./separate-members.cases.ts
  members named like methods of an application of another file
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
    arg0: 3,
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
  {
    arg0: 3,
    arg1: {
      tag: 'Nil'
    },
    tag: 'Cons'
  }
  a functor of another file whose body aliases a nested module
  {
    arg0: 'b',
    arg1: {
      tag: 'Nil'
    },
    tag: 'Cons'
  }
