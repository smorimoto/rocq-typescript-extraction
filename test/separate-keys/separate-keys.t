  $ bun ./separate-keys.cases.ts
  a functor over the module type of another file reads the module's members
  {
    k: 1,
    rest: {
      k: 2,
      rest: {
        tag: 'Empty'
      },
      tag: 'Node',
      v: false
    },
    tag: 'Node',
    v: true
  }
  {
    arg0: false,
    tag: 'Some'
  }
  {
    tag: 'Empty'
  }
  the module keeps its own set0 and empty beside the renamed set and Empty
  {
    k: 4,
    rest: {
      tag: 'Empty'
    },
    tag: 'Node',
    v: 'x'
  }
  {
    tag: 'Empty'
  }
