  $ bun ./sample.cases.ts
  M.two and four evaluate to Peano numerals
  2
  4
  8
  size counts the nodes of a tree of any element type
  3
  0
  even and odd are mutually recursive and return bool values
  {
    actual: {
      tag: 'True'
    },
    expected: {
      tag: 'True'
    }
  }
  {
    actual: {
      tag: 'False'
    },
    expected: {
      tag: 'False'
    }
  }
  'True'
  compose applies f then g
  5
  swap exchanges record fields and bump builds a one-node tree
  2
  1
  {
    l: {
      tag: 'Leaf'
    },
    r: {
      tag: 'Leaf'
    },
    tag: 'Node',
    x: {
      arg0: {
        arg0: {
          tag: 'O'
        },
        tag: 'S'
      },
      tag: 'S'
    }
  }
