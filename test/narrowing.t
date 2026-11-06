  $ bun ./narrowing.cases.ts
  a match on a constant is the branch of its constructor
  {
    actual: {
      tag: 'Leaf'
    },
    expected: {
      tag: 'Leaf'
    }
  }
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
      l: {
        tag: 'Leaf'
      },
      r: {
        tag: 'Leaf'
      },
      tag: 'Node',
      x: {
        tag: 'O'
      }
    },
    expected: {
      l: {
        tag: 'Leaf'
      },
      r: {
        tag: 'Leaf'
      },
      tag: 'Node',
      x: {
        tag: 'O'
      }
    }
  }
  a match through a chain of constants and on a local
  {
    actual: {
      tag: 'Dot'
    },
    expected: {
      tag: 'Dot'
    }
  }
  0
  0
  0
  a consumer matches an imported constant on every constructor
  'dot'
  0
  1
