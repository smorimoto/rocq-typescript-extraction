  $ bun ./naming.cases.ts
  a name that becomes a reserved word or an earlier name gets a suffix
  {
    tag: 'New'
  }
  {
    actual: {
      arg0: {
        tag: 'O'
      },
      tag: 'S'
    },
    expected: {
      arg0: {
        tag: 'O'
      },
      tag: 'S'
    }
  }
  [
    1,
    2
  ]
  4
  a module whose name a type has takes a suffix, as a value would
  {
    actual: {
      tag: 'Old'
    },
    expected: {
      tag: 'Old'
    }
  }
  constructor fields take the kernel binder names, camelCased
  'x'
  {
    actual: {
      contents: 'x',
      other: {
        tag: 'MkA'
      },
      tag: 'Box'
    },
    expected: {
      contents: 'x',
      other: {
        tag: 'MkA'
      },
      tag: 'Box'
    }
  }
  a binder named tag or a reserved word falls back to positional fields
  {
    actual: {
      arg0: {
        arg0: {
          tag: 'O'
        },
        tag: 'S'
      },
      arg1: {
        arg0: {
          arg0: {
            tag: 'O'
          },
          tag: 'S'
        },
        tag: 'S'
      },
      tag: 'Tagged'
    },
    expected: {
      arg0: {
        arg0: {
          tag: 'O'
        },
        tag: 'S'
      },
      arg1: {
        arg0: {
          arg0: {
            tag: 'O'
          },
          tag: 'S'
        },
        tag: 'S'
      },
      tag: 'Tagged'
    }
  }
  2
  2
  3
  primed and non-ASCII binders are valid parameters
  5
  3
  a nested module may share its name with an enclosing module
  {
    actual: {
      tag: 'Right'
    },
    expected: {
      tag: 'Right'
    }
  }
  {
    actual: {
      tag: 'Down'
    },
    expected: {
      tag: 'Down'
    }
  }
  {
    actual: {
      tag: 'Round'
    },
    expected: {
      tag: 'Round'
    }
  }
  {
    actual: {
      tag: 'Large'
    },
    expected: {
      tag: 'Large'
    }
  }
  a name that is not an identifier is escaped
  [
    0,
    1,
    2
  ]
  {
    actual: {
      _2: {
        arg0: {
          tag: 'O'
        },
        tag: 'S'
      },
      tag: 'Indexed',
      x2: {
        arg0: {
          arg0: {
            tag: 'O'
          },
          tag: 'S'
        },
        tag: 'S'
      }
    },
    expected: {
      _2: {
        arg0: {
          tag: 'O'
        },
        tag: 'S'
      },
      tag: 'Indexed',
      x2: {
        arg0: {
          arg0: {
            tag: 'O'
          },
          tag: 'S'
        },
        tag: 'S'
      }
    }
  }
  3
  a name that JavaScript or TypeScript reserves takes a suffix
  2
  {
    actual: {
      tag: 'Error'
    },
    expected: {
      tag: 'Error'
    }
  }
  'Ok'
  [
    'Then',
    'Else'
  ]
  a name that differs from a reserved one only in case is kept
  6
  a constructor named like a parameter of inlined code takes a suffix
  {
    tag: 'X'
  }
  {
    tag: 'True'
  }
  2
