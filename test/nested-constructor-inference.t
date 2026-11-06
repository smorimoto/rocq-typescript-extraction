  $ bun ./nested-constructor-inference.cases.ts
  custom tuple constructors retain the element union of heterogeneous lists
  {
    actual: {
      arg0: [
        1n,
        {
          tag: 'Red'
        }
      ],
      arg1: {
        arg0: [
          2n,
          {
            tag: 'Blue'
          }
        ],
        arg1: {
          tag: 'Nil'
        },
        tag: 'Cons'
      },
      tag: 'Cons'
    },
    expected: {
      arg0: [
        1n,
        {
          tag: 'Red'
        }
      ],
      arg1: {
        arg0: [
          2n,
          {
            tag: 'Blue'
          }
        ],
        arg1: {
          tag: 'Nil'
        },
        tag: 'Cons'
      },
      tag: 'Cons'
    }
  }
  record literals retain the element union of heterogeneous lists
  {
    actual: {
      arg0: {
        number: 1n,
        shade: {
          tag: 'Red'
        }
      },
      arg1: {
        arg0: {
          number: 2n,
          shade: {
            tag: 'Blue'
          }
        },
        arg1: {
          tag: 'Nil'
        },
        tag: 'Cons'
      },
      tag: 'Cons'
    },
    expected: {
      arg0: {
        number: 1n,
        shade: {
          tag: 'Red'
        }
      },
      arg1: {
        arg0: {
          number: 2n,
          shade: {
            tag: 'Blue'
          }
        },
        arg1: {
          tag: 'Nil'
        },
        tag: 'Cons'
      },
      tag: 'Cons'
    }
  }
