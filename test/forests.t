  $ bun ./forests.cases.ts
  the members of a mutually recursive group named like array methods
  {
    actual: {
      children: {
        rest: {
          rest: {
            tag: 'Nil'
          },
          t: {
            children: {
              rest: {
                tag: 'Nil'
              },
              t: {
                children: {
                  tag: 'Nil'
                },
                tag: 'Node',
                x: 8
              },
              tag: 'Cons'
            },
            tag: 'Node',
            x: 6
          },
          tag: 'Cons'
        },
        t: {
          children: {
            tag: 'Nil'
          },
          tag: 'Node',
          x: 4
        },
        tag: 'Cons'
      },
      tag: 'Node',
      x: 2
    },
    expected: {
      children: {
        rest: {
          rest: {
            tag: 'Nil'
          },
          t: {
            children: {
              rest: {
                tag: 'Nil'
              },
              t: {
                children: {
                  tag: 'Nil'
                },
                tag: 'Node',
                x: 8
              },
              tag: 'Cons'
            },
            tag: 'Node',
            x: 6
          },
          tag: 'Cons'
        },
        t: {
          children: {
            tag: 'Nil'
          },
          tag: 'Node',
          x: 4
        },
        tag: 'Cons'
      },
      tag: 'Node',
      x: 2
    }
  }
  {
    actual: {
      children: {
        tag: 'Nil'
      },
      tag: 'Node',
      x: 2
    },
    expected: {
      children: {
        tag: 'Nil'
      },
      tag: 'Node',
      x: 2
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
  a local mutually recursive group named like array methods
  true
  false
  the members of groups named like the methods of built-ins
  10
  {
    actual: {
      rest: {
        rest: {
          rest: {
            rest: {
              tag: 'Nil'
            },
            t: {
              children: {
                tag: 'Nil'
              },
              tag: 'Node',
              x: 4
            },
            tag: 'Cons'
          },
          t: {
            children: {
              tag: 'Nil'
            },
            tag: 'Node',
            x: 3
          },
          tag: 'Cons'
        },
        t: {
          children: {
            tag: 'Nil'
          },
          tag: 'Node',
          x: 2
        },
        tag: 'Cons'
      },
      t: {
        children: {
          tag: 'Nil'
        },
        tag: 'Node',
        x: 1
      },
      tag: 'Cons'
    },
    expected: {
      rest: {
        rest: {
          rest: {
            rest: {
              tag: 'Nil'
            },
            t: {
              children: {
                tag: 'Nil'
              },
              tag: 'Node',
              x: 4
            },
            tag: 'Cons'
          },
          t: {
            children: {
              tag: 'Nil'
            },
            tag: 'Node',
            x: 3
          },
          tag: 'Cons'
        },
        t: {
          children: {
            tag: 'Nil'
          },
          tag: 'Node',
          x: 2
        },
        tag: 'Cons'
      },
      t: {
        children: {
          tag: 'Nil'
        },
        tag: 'Node',
        x: 1
      },
      tag: 'Cons'
    }
  }
  true
  false
  {
    actual: {
      children: {
        rest: {
          rest: {
            tag: 'Nil'
          },
          t: {
            children: {
              tag: 'Nil'
            },
            tag: 'Node',
            x: 3
          },
          tag: 'Cons'
        },
        t: {
          children: {
            tag: 'Nil'
          },
          tag: 'Node',
          x: 2
        },
        tag: 'Cons'
      },
      tag: 'Node',
      x: 1
    },
    expected: {
      children: {
        rest: {
          rest: {
            tag: 'Nil'
          },
          t: {
            children: {
              tag: 'Nil'
            },
            tag: 'Node',
            x: 3
          },
          tag: 'Cons'
        },
        t: {
          children: {
            tag: 'Nil'
          },
          tag: 'Node',
          x: 2
        },
        tag: 'Cons'
      },
      tag: 'Node',
      x: 1
    }
  }
  {
    actual: {
      children: {
        rest: {
          rest: {
            tag: 'Nil'
          },
          t: {
            children: {
              tag: 'Nil'
            },
            tag: 'Node',
            x: 3
          },
          tag: 'Cons'
        },
        t: {
          children: {
            tag: 'Nil'
          },
          tag: 'Node',
          x: 2
        },
        tag: 'Cons'
      },
      tag: 'Node',
      x: 1
    },
    expected: {
      children: {
        rest: {
          rest: {
            tag: 'Nil'
          },
          t: {
            children: {
              tag: 'Nil'
            },
            tag: 'Node',
            x: 3
          },
          tag: 'Cons'
        },
        t: {
          children: {
            tag: 'Nil'
          },
          tag: 'Node',
          x: 2
        },
        tag: 'Cons'
      },
      tag: 'Node',
      x: 1
    }
  }
  {
    actual: {
      children: {
        rest: {
          rest: {
            tag: 'Nil'
          },
          t: {
            children: {
              rest: {
                tag: 'Nil'
              },
              t: {
                children: {
                  tag: 'Nil'
                },
                tag: 'Node',
                x: 2
              },
              tag: 'Cons'
            },
            tag: 'Node',
            x: 2
          },
          tag: 'Cons'
        },
        t: {
          children: {
            tag: 'Nil'
          },
          tag: 'Node',
          x: 2
        },
        tag: 'Cons'
      },
      tag: 'Node',
      x: 1
    },
    expected: {
      children: {
        rest: {
          rest: {
            tag: 'Nil'
          },
          t: {
            children: {
              rest: {
                tag: 'Nil'
              },
              t: {
                children: {
                  tag: 'Nil'
                },
                tag: 'Node',
                x: 2
              },
              tag: 'Cons'
            },
            tag: 'Node',
            x: 2
          },
          tag: 'Cons'
        },
        t: {
          children: {
            tag: 'Nil'
          },
          tag: 'Node',
          x: 2
        },
        tag: 'Cons'
      },
      tag: 'Node',
      x: 1
    }
  }
