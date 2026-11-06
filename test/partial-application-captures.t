  $ bun ./partial-application-captures.cases.ts
  partial applications retain each iteration's arguments
  {
    actual: {
      arg0: 2n,
      arg1: {
        arg0: 5n,
        arg1: {
          arg0: 11n,
          arg1: {
            tag: 'Nil'
          },
          tag: 'Cons'
        },
        tag: 'Cons'
      },
      tag: 'Cons'
    },
    expected: {
      arg0: 2n,
      arg1: {
        arg0: 5n,
        arg1: {
          arg0: 11n,
          arg1: {
            tag: 'Nil'
          },
          tag: 'Cons'
        },
        tag: 'Cons'
      },
      tag: 'Cons'
    }
  }
  {
    actual: {
      arg0: 2n,
      arg1: {
        arg0: 5n,
        arg1: {
          arg0: 11n,
          arg1: {
            tag: 'Nil'
          },
          tag: 'Cons'
        },
        tag: 'Cons'
      },
      tag: 'Cons'
    },
    expected: {
      arg0: 2n,
      arg1: {
        arg0: 5n,
        arg1: {
          arg0: 11n,
          arg1: {
            tag: 'Nil'
          },
          tag: 'Cons'
        },
        tag: 'Cons'
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
  closures retain nested pattern narrowing
  12n
  0n
  0n
  partial recursive calls capture the current subtrees and continuation
  75n
  25n
  7n
