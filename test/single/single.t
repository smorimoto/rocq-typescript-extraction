  $ bun ./single.cases.ts
  the printed declarations of tree and mirror form a working module
  {
    actual: {
      l: {
        tag: 'Leaf'
      },
      r: {
        l: {
          tag: 'Leaf'
        },
        r: {
          tag: 'Leaf'
        },
        tag: 'Node',
        x: 'a'
      },
      tag: 'Node',
      x: 'b'
    },
    expected: {
      l: {
        tag: 'Leaf'
      },
      r: {
        l: {
          tag: 'Leaf'
        },
        r: {
          tag: 'Leaf'
        },
        tag: 'Node',
        x: 'a'
      },
      tag: 'Node',
      x: 'b'
    }
  }
