  $ bun ./higher-kinded.cases.ts
  an application to list instantiates the lambda of list
  {
    actual: {
      tag: 'Nil'
    },
    expected: {
      tag: 'Nil'
    }
  }
  {
    actual: {
      arg0: 3,
      arg1: {
        tag: 'Nil'
      },
      tag: 'Cons'
    },
    expected: {
      arg0: 3,
      arg1: {
        tag: 'Nil'
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
  {
    actual: {
      tag: 'Nil'
    },
    expected: {
      tag: 'Nil'
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
  a type of two parameters and a constraint
  {
    actual: {
      arg0: [
        1,
        true
      ],
      arg1: {
        tag: 'Nil'
      },
      tag: 'Cons'
    },
    expected: {
      arg0: [
        1,
        true
      ],
      arg1: {
        tag: 'Nil'
      },
      tag: 'Cons'
    }
  }
  {
    actual: {
      arg0: 2,
      arg1: {
        tag: 'Nil'
      },
      tag: 'Cons'
    },
    expected: {
      arg0: 2,
      arg1: {
        tag: 'Nil'
      },
      tag: 'Cons'
    }
  }
  {
    actual: {
      arg0: 2,
      arg1: {
        tag: 'Nil'
      },
      tag: 'Cons'
    },
    expected: {
      arg0: 2,
      arg1: {
        tag: 'Nil'
      },
      tag: 'Cons'
    }
  }
  {
    actual: {
      arg0: 2,
      arg1: {
        tag: 'Nil'
      },
      tag: 'Cons'
    },
    expected: {
      arg0: 2,
      arg1: {
        tag: 'Nil'
      },
      tag: 'Cons'
    }
  }
  a consumer declares its own lambda and applies the functor
  [
    2,
    3
  ]
  []
  [
    [
      1,
      true
    ]
  ]
  {
    actual: {
      arg0: [
        1,
        true
      ],
      arg1: {
        tag: 'Nil'
      },
      tag: 'Cons'
    },
    expected: {
      arg0: [
        1,
        true
      ],
      arg1: {
        tag: 'Nil'
      },
      tag: 'Cons'
    }
  }
