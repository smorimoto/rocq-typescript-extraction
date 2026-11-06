  $ bun ./let-poly.cases.ts
  a local identity is used at two types
  {
    actual: {
      arg0: {
        arg0: {
          tag: 'O'
        },
        tag: 'S'
      },
      arg1: {
        tag: 'True'
      },
      tag: 'Pair'
    },
    expected: {
      arg0: {
        arg0: {
          tag: 'O'
        },
        tag: 'S'
      },
      arg1: {
        tag: 'True'
      },
      tag: 'Pair'
    }
  }
  a local function over lists is used on two element types
  {
    actual: {
      arg0: {
        arg0: {
          arg0: {
            tag: 'O'
          },
          tag: 'S'
        },
        tag: 'S'
      },
      arg1: {
        tag: 'False'
      },
      tag: 'Pair'
    },
    expected: {
      arg0: {
        arg0: {
          arg0: {
            tag: 'O'
          },
          tag: 'S'
        },
        tag: 'S'
      },
      arg1: {
        tag: 'False'
      },
      tag: 'Pair'
    }
  }
  {
    actual: {
      arg0: {
        tag: 'O'
      },
      arg1: {
        tag: 'False'
      },
      tag: 'Pair'
    },
    expected: {
      arg0: {
        tag: 'O'
      },
      arg1: {
        tag: 'False'
      },
      tag: 'Pair'
    }
  }
  a local fix is used on two list types
  5
  0
  a local mutual fix is used on two list types
  {
    actual: {
      arg0: {
        tag: 'True'
      },
      arg1: {
        tag: 'False'
      },
      tag: 'Pair'
    },
    expected: {
      arg0: {
        tag: 'True'
      },
      arg1: {
        tag: 'False'
      },
      tag: 'Pair'
    }
  }
  a function of a group that omits a type parameter of the group
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
  a generic local function reads a parameter of a generic definition
  {
    actual: {
      arg0: {
        arg0: 'a',
        arg1: {
          arg0: {
            tag: 'O'
          },
          tag: 'S'
        },
        tag: 'Pair'
      },
      arg1: {
        arg0: 'a',
        arg1: {
          tag: 'True'
        },
        tag: 'Pair'
      },
      tag: 'Pair'
    },
    expected: {
      arg0: {
        arg0: 'a',
        arg1: {
          arg0: {
            tag: 'O'
          },
          tag: 'S'
        },
        tag: 'Pair'
      },
      arg1: {
        arg0: 'a',
        arg1: {
          tag: 'True'
        },
        tag: 'Pair'
      },
      tag: 'Pair'
    }
  }
  a generic local function inside a lifted one
  {
    actual: {
      arg0: {
        arg0: {
          arg0: {
            tag: 'O'
          },
          tag: 'S'
        },
        arg1: {
          tag: 'O'
        },
        tag: 'Pair'
      },
      arg1: {
        arg0: {
          tag: 'True'
        },
        arg1: {
          tag: 'O'
        },
        tag: 'Pair'
      },
      tag: 'Pair'
    },
    expected: {
      arg0: {
        arg0: {
          arg0: {
            tag: 'O'
          },
          tag: 'S'
        },
        arg1: {
          tag: 'O'
        },
        tag: 'Pair'
      },
      arg1: {
        arg0: {
          tag: 'True'
        },
        arg1: {
          tag: 'O'
        },
        tag: 'Pair'
      },
      tag: 'Pair'
    }
  }
  a lifted let inside an expression
  {
    actual: {
      arg0: {
        arg0: {
          arg0: {
            tag: 'O'
          },
          tag: 'S'
        },
        tag: 'S'
      },
      arg1: {
        tag: 'True'
      },
      tag: 'Pair'
    },
    expected: {
      arg0: {
        arg0: {
          arg0: {
            tag: 'O'
          },
          tag: 'S'
        },
        tag: 'S'
      },
      arg1: {
        tag: 'True'
      },
      tag: 'Pair'
    }
  }
  {
    actual: {
      arg0: {
        arg0: {
          tag: 'O'
        },
        tag: 'S'
      },
      arg1: {
        tag: 'False'
      },
      tag: 'Pair'
    },
    expected: {
      arg0: {
        arg0: {
          tag: 'O'
        },
        tag: 'S'
      },
      arg1: {
        tag: 'False'
      },
      tag: 'Pair'
    }
  }
  {
    actual: {
      arg0: {
        tag: 'O'
      },
      arg1: {
        tag: 'False'
      },
      tag: 'Pair'
    },
    expected: {
      arg0: {
        tag: 'O'
      },
      arg1: {
        tag: 'False'
      },
      tag: 'Pair'
    }
  }
  a module object holds its member and not the function lifted out of it
  {
    actual: {
      arg0: {
        arg0: {
          tag: 'O'
        },
        tag: 'S'
      },
      arg1: {
        tag: 'False'
      },
      tag: 'Pair'
    },
    expected: {
      arg0: {
        arg0: {
          tag: 'O'
        },
        tag: 'S'
      },
      arg1: {
        tag: 'False'
      },
      tag: 'Pair'
    }
  }
  [
    'both'
  ]
  a partial application used at two types computes through the cast
  {
    actual: {
      arg0: {
        arg0: {
          tag: 'O'
        },
        tag: 'S'
      },
      arg1: {
        tag: 'False'
      },
      tag: 'Pair'
    },
    expected: {
      arg0: {
        arg0: {
          tag: 'O'
        },
        tag: 'S'
      },
      arg1: {
        tag: 'False'
      },
      tag: 'Pair'
    }
  }
