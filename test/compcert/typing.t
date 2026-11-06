  $ bun ./typing.cases.ts
  typechecking rebuilds annotations from declarations
  {
    actual: {
      arg0: {
        arg0: {
          op: {
            tag: 'Oadd'
          },
          r1: {
            l: {
              tag: 'Evar',
              ty: {
                arg0: {
                  tag: 'I32'
                },
                arg1: {
                  tag: 'Signed'
                },
                arg2: {
                  attrAlignas: {
                    tag: 'None'
                  },
                  attrVolatile: false
                },
                tag: 'Tint0'
              },
              x: 2n
            },
            tag: 'Evalof',
            ty: {
              arg0: {
                tag: 'I32'
              },
              arg1: {
                tag: 'Signed'
              },
              arg2: {
                attrAlignas: {
                  tag: 'None'
                },
                attrVolatile: false
              },
              tag: 'Tint0'
            }
          },
          r2: {
            tag: 'Eval',
            ty: {
              arg0: {
                tag: 'I32'
              },
              arg1: {
                tag: 'Signed'
              },
              arg2: {
                attrAlignas: {
                  tag: 'None'
                },
                attrVolatile: false
              },
              tag: 'Tint0'
            },
            v: {
              arg0: 7n,
              tag: 'Vint'
            }
          },
          tag: 'Ebinop',
          ty: {
            arg0: {
              tag: 'I32'
            },
            arg1: {
              tag: 'Signed'
            },
            arg2: {
              attrAlignas: {
                tag: 'None'
              },
              attrVolatile: false
            },
            tag: 'Tint0'
          }
        },
        tag: 'Some'
      },
      tag: 'Sreturn'
    },
    expected: {
      arg0: {
        arg0: {
          op: {
            tag: 'Oadd'
          },
          r1: {
            l: {
              tag: 'Evar',
              ty: {
                arg0: {
                  tag: 'I32'
                },
                arg1: {
                  tag: 'Signed'
                },
                arg2: {
                  attrAlignas: {
                    tag: 'None'
                  },
                  attrVolatile: false
                },
                tag: 'Tint0'
              },
              x: 2n
            },
            tag: 'Evalof',
            ty: {
              arg0: {
                tag: 'I32'
              },
              arg1: {
                tag: 'Signed'
              },
              arg2: {
                attrAlignas: {
                  tag: 'None'
                },
                attrVolatile: false
              },
              tag: 'Tint0'
            }
          },
          r2: {
            tag: 'Eval',
            ty: {
              arg0: {
                tag: 'I32'
              },
              arg1: {
                tag: 'Signed'
              },
              arg2: {
                attrAlignas: {
                  tag: 'None'
                },
                attrVolatile: false
              },
              tag: 'Tint0'
            },
            v: {
              arg0: 7n,
              tag: 'Vint'
            }
          },
          tag: 'Ebinop',
          ty: {
            arg0: {
              tag: 'I32'
            },
            arg1: {
              tag: 'Signed'
            },
            arg2: {
              attrAlignas: {
                tag: 'None'
              },
              attrVolatile: false
            },
            tag: 'Tint0'
          }
        },
        tag: 'Some'
      },
      tag: 'Sreturn'
    }
  }
  {
    actual: {
      arg0: {
        arg0: {
          op: {
            tag: 'Oadd'
          },
          r1: {
            l: {
              tag: 'Evar',
              ty: {
                tag: 'Tvoid'
              },
              x: 2n
            },
            tag: 'Evalof',
            ty: {
              tag: 'Tvoid'
            }
          },
          r2: {
            tag: 'Eval',
            ty: {
              arg0: {
                tag: 'I32'
              },
              arg1: {
                tag: 'Signed'
              },
              arg2: {
                attrAlignas: {
                  tag: 'None'
                },
                attrVolatile: false
              },
              tag: 'Tint0'
            },
            v: {
              arg0: 7n,
              tag: 'Vint'
            }
          },
          tag: 'Ebinop',
          ty: {
            tag: 'Tvoid'
          }
        },
        tag: 'Some'
      },
      tag: 'Sreturn'
    },
    expected: {
      arg0: {
        arg0: {
          op: {
            tag: 'Oadd'
          },
          r1: {
            l: {
              tag: 'Evar',
              ty: {
                tag: 'Tvoid'
              },
              x: 2n
            },
            tag: 'Evalof',
            ty: {
              tag: 'Tvoid'
            }
          },
          r2: {
            tag: 'Eval',
            ty: {
              arg0: {
                tag: 'I32'
              },
              arg1: {
                tag: 'Signed'
              },
              arg2: {
                attrAlignas: {
                  tag: 'None'
                },
                attrVolatile: false
              },
              tag: 'Tint0'
            },
            v: {
              arg0: 7n,
              tag: 'Vint'
            }
          },
          tag: 'Ebinop',
          ty: {
            tag: 'Tvoid'
          }
        },
        tag: 'Some'
      },
      tag: 'Sreturn'
    }
  }
  field access, calls and switch cases are retyped across functions
  2
  {
    actual: {
      arg0: {
        arg0: {
          l: {
            f: 12n,
            l: {
              l: {
                tag: 'Evar',
                ty: {
                  arg0: 10n,
                  arg1: {
                    attrAlignas: {
                      tag: 'None'
                    },
                    attrVolatile: false
                  },
                  tag: 'Tstruct'
                },
                x: 4n
              },
              tag: 'Evalof',
              ty: {
                arg0: 10n,
                arg1: {
                  attrAlignas: {
                    tag: 'None'
                  },
                  attrVolatile: false
                },
                tag: 'Tstruct'
              }
            },
            tag: 'Efield',
            ty: {
              arg0: {
                tag: 'I32'
              },
              arg1: {
                tag: 'Signed'
              },
              arg2: {
                attrAlignas: {
                  tag: 'None'
                },
                attrVolatile: false
              },
              tag: 'Tint0'
            }
          },
          r: {
            r1: {
              l: {
                tag: 'Evar',
                ty: {
                  arg0: {
                    arg0: {
                      arg0: {
                        tag: 'I32'
                      },
                      arg1: {
                        tag: 'Signed'
                      },
                      arg2: {
                        attrAlignas: {
                          tag: 'None'
                        },
                        attrVolatile: false
                      },
                      tag: 'Tint0'
                    },
                    arg1: {
                      tag: 'Nil'
                    },
                    tag: 'Cons'
                  },
                  arg1: {
                    arg0: {
                      tag: 'I32'
                    },
                    arg1: {
                      tag: 'Signed'
                    },
                    arg2: {
                      attrAlignas: {
                        tag: 'None'
                      },
                      attrVolatile: false
                    },
                    tag: 'Tint0'
                  },
                  arg2: {
                    ccStructret: false,
                    ccUnproto: false,
                    ccVararg: {
                      tag: 'None'
                    }
                  },
                  tag: 'Tfunction'
                },
                x: 5n
              },
              tag: 'Evalof',
              ty: {
                arg0: {
                  arg0: {
                    arg0: {
                      tag: 'I32'
                    },
                    arg1: {
                      tag: 'Signed'
                    },
                    arg2: {
                      attrAlignas: {
                        tag: 'None'
                      },
                      attrVolatile: false
                    },
                    tag: 'Tint0'
                  },
                  arg1: {
                    tag: 'Nil'
                  },
                  tag: 'Cons'
                },
                arg1: {
                  arg0: {
                    tag: 'I32'
                  },
                  arg1: {
                    tag: 'Signed'
                  },
                  arg2: {
                    attrAlignas: {
                      tag: 'None'
                    },
                    attrVolatile: false
                  },
                  tag: 'Tint0'
                },
                arg2: {
                  ccStructret: false,
                  ccUnproto: false,
                  ccVararg: {
                    tag: 'None'
                  }
                },
                tag: 'Tfunction'
              }
            },
            rargs: {
              r1: {
                tag: 'Eval',
                ty: {
                  arg0: {
                    tag: 'I32'
                  },
                  arg1: {
                    tag: 'Signed'
                  },
                  arg2: {
                    attrAlignas: {
                      tag: 'None'
                    },
                    attrVolatile: false
                  },
                  tag: 'Tint0'
                },
                v: {
                  arg0: 8n,
                  tag: 'Vint'
                }
              },
              rl: {
                tag: 'Enil'
              },
              tag: 'Econs'
            },
            tag: 'Ecall',
            ty: {
              arg0: {
                tag: 'I32'
              },
              arg1: {
                tag: 'Signed'
              },
              arg2: {
                attrAlignas: {
                  tag: 'None'
                },
                attrVolatile: false
              },
              tag: 'Tint0'
            }
          },
          tag: 'Eassign',
          ty: {
            arg0: {
              tag: 'I32'
            },
            arg1: {
              tag: 'Signed'
            },
            arg2: {
              attrAlignas: {
                tag: 'None'
              },
              attrVolatile: false
            },
            tag: 'Tint0'
          }
        },
        tag: 'Sdo'
      },
      arg1: {
        arg0: {
          l: {
            f: 12n,
            l: {
              l: {
                tag: 'Evar',
                ty: {
                  arg0: 10n,
                  arg1: {
                    attrAlignas: {
                      tag: 'None'
                    },
                    attrVolatile: false
                  },
                  tag: 'Tstruct'
                },
                x: 4n
              },
              tag: 'Evalof',
              ty: {
                arg0: 10n,
                arg1: {
                  attrAlignas: {
                    tag: 'None'
                  },
                  attrVolatile: false
                },
                tag: 'Tstruct'
              }
            },
            tag: 'Efield',
            ty: {
              arg0: {
                tag: 'I32'
              },
              arg1: {
                tag: 'Signed'
              },
              arg2: {
                attrAlignas: {
                  tag: 'None'
                },
                attrVolatile: false
              },
              tag: 'Tint0'
            }
          },
          tag: 'Evalof',
          ty: {
            arg0: {
              tag: 'I32'
            },
            arg1: {
              tag: 'Signed'
            },
            arg2: {
              attrAlignas: {
                tag: 'None'
              },
              attrVolatile: false
            },
            tag: 'Tint0'
          }
        },
        arg1: {
          arg0: {
            arg0: 8n,
            tag: 'Some'
          },
          arg1: {
            arg0: {
              arg0: {
                tag: 'Eval',
                ty: {
                  arg0: {
                    tag: 'I32'
                  },
                  arg1: {
                    tag: 'Signed'
                  },
                  arg2: {
                    attrAlignas: {
                      tag: 'None'
                    },
                    attrVolatile: false
                  },
                  tag: 'Tint0'
                },
                v: {
                  arg0: 1n,
                  tag: 'Vint'
                }
              },
              tag: 'Some'
            },
            tag: 'Sreturn'
          },
          arg2: {
            arg0: {
              tag: 'None'
            },
            arg1: {
              arg0: {
                arg0: {
                  tag: 'Eval',
                  ty: {
                    arg0: {
                      tag: 'I32'
                    },
                    arg1: {
                      tag: 'Signed'
                    },
                    arg2: {
                      attrAlignas: {
                        tag: 'None'
                      },
                      attrVolatile: false
                    },
                    tag: 'Tint0'
                  },
                  v: {
                    arg0: 0n,
                    tag: 'Vint'
                  }
                },
                tag: 'Some'
              },
              tag: 'Sreturn'
            },
            arg2: {
              tag: 'LSnil'
            },
            tag: 'LScons'
          },
          tag: 'LScons'
        },
        tag: 'Sswitch'
      },
      tag: 'Ssequence'
    },
    expected: {
      arg0: {
        arg0: {
          l: {
            f: 12n,
            l: {
              l: {
                tag: 'Evar',
                ty: {
                  arg0: 10n,
                  arg1: {
                    attrAlignas: {
                      tag: 'None'
                    },
                    attrVolatile: false
                  },
                  tag: 'Tstruct'
                },
                x: 4n
              },
              tag: 'Evalof',
              ty: {
                arg0: 10n,
                arg1: {
                  attrAlignas: {
                    tag: 'None'
                  },
                  attrVolatile: false
                },
                tag: 'Tstruct'
              }
            },
            tag: 'Efield',
            ty: {
              arg0: {
                tag: 'I32'
              },
              arg1: {
                tag: 'Signed'
              },
              arg2: {
                attrAlignas: {
                  tag: 'None'
                },
                attrVolatile: false
              },
              tag: 'Tint0'
            }
          },
          r: {
            r1: {
              l: {
                tag: 'Evar',
                ty: {
                  arg0: {
                    arg0: {
                      arg0: {
                        tag: 'I32'
                      },
                      arg1: {
                        tag: 'Signed'
                      },
                      arg2: {
                        attrAlignas: {
                          tag: 'None'
                        },
                        attrVolatile: false
                      },
                      tag: 'Tint0'
                    },
                    arg1: {
                      tag: 'Nil'
                    },
                    tag: 'Cons'
                  },
                  arg1: {
                    arg0: {
                      tag: 'I32'
                    },
                    arg1: {
                      tag: 'Signed'
                    },
                    arg2: {
                      attrAlignas: {
                        tag: 'None'
                      },
                      attrVolatile: false
                    },
                    tag: 'Tint0'
                  },
                  arg2: {
                    ccStructret: false,
                    ccUnproto: false,
                    ccVararg: {
                      tag: 'None'
                    }
                  },
                  tag: 'Tfunction'
                },
                x: 5n
              },
              tag: 'Evalof',
              ty: {
                arg0: {
                  arg0: {
                    arg0: {
                      tag: 'I32'
                    },
                    arg1: {
                      tag: 'Signed'
                    },
                    arg2: {
                      attrAlignas: {
                        tag: 'None'
                      },
                      attrVolatile: false
                    },
                    tag: 'Tint0'
                  },
                  arg1: {
                    tag: 'Nil'
                  },
                  tag: 'Cons'
                },
                arg1: {
                  arg0: {
                    tag: 'I32'
                  },
                  arg1: {
                    tag: 'Signed'
                  },
                  arg2: {
                    attrAlignas: {
                      tag: 'None'
                    },
                    attrVolatile: false
                  },
                  tag: 'Tint0'
                },
                arg2: {
                  ccStructret: false,
                  ccUnproto: false,
                  ccVararg: {
                    tag: 'None'
                  }
                },
                tag: 'Tfunction'
              }
            },
            rargs: {
              r1: {
                tag: 'Eval',
                ty: {
                  arg0: {
                    tag: 'I32'
                  },
                  arg1: {
                    tag: 'Signed'
                  },
                  arg2: {
                    attrAlignas: {
                      tag: 'None'
                    },
                    attrVolatile: false
                  },
                  tag: 'Tint0'
                },
                v: {
                  arg0: 8n,
                  tag: 'Vint'
                }
              },
              rl: {
                tag: 'Enil'
              },
              tag: 'Econs'
            },
            tag: 'Ecall',
            ty: {
              arg0: {
                tag: 'I32'
              },
              arg1: {
                tag: 'Signed'
              },
              arg2: {
                attrAlignas: {
                  tag: 'None'
                },
                attrVolatile: false
              },
              tag: 'Tint0'
            }
          },
          tag: 'Eassign',
          ty: {
            arg0: {
              tag: 'I32'
            },
            arg1: {
              tag: 'Signed'
            },
            arg2: {
              attrAlignas: {
                tag: 'None'
              },
              attrVolatile: false
            },
            tag: 'Tint0'
          }
        },
        tag: 'Sdo'
      },
      arg1: {
        arg0: {
          l: {
            f: 12n,
            l: {
              l: {
                tag: 'Evar',
                ty: {
                  arg0: 10n,
                  arg1: {
                    attrAlignas: {
                      tag: 'None'
                    },
                    attrVolatile: false
                  },
                  tag: 'Tstruct'
                },
                x: 4n
              },
              tag: 'Evalof',
              ty: {
                arg0: 10n,
                arg1: {
                  attrAlignas: {
                    tag: 'None'
                  },
                  attrVolatile: false
                },
                tag: 'Tstruct'
              }
            },
            tag: 'Efield',
            ty: {
              arg0: {
                tag: 'I32'
              },
              arg1: {
                tag: 'Signed'
              },
              arg2: {
                attrAlignas: {
                  tag: 'None'
                },
                attrVolatile: false
              },
              tag: 'Tint0'
            }
          },
          tag: 'Evalof',
          ty: {
            arg0: {
              tag: 'I32'
            },
            arg1: {
              tag: 'Signed'
            },
            arg2: {
              attrAlignas: {
                tag: 'None'
              },
              attrVolatile: false
            },
            tag: 'Tint0'
          }
        },
        arg1: {
          arg0: {
            arg0: 8n,
            tag: 'Some'
          },
          arg1: {
            arg0: {
              arg0: {
                tag: 'Eval',
                ty: {
                  arg0: {
                    tag: 'I32'
                  },
                  arg1: {
                    tag: 'Signed'
                  },
                  arg2: {
                    attrAlignas: {
                      tag: 'None'
                    },
                    attrVolatile: false
                  },
                  tag: 'Tint0'
                },
                v: {
                  arg0: 1n,
                  tag: 'Vint'
                }
              },
              tag: 'Some'
            },
            tag: 'Sreturn'
          },
          arg2: {
            arg0: {
              tag: 'None'
            },
            arg1: {
              arg0: {
                arg0: {
                  tag: 'Eval',
                  ty: {
                    arg0: {
                      tag: 'I32'
                    },
                    arg1: {
                      tag: 'Signed'
                    },
                    arg2: {
                      attrAlignas: {
                        tag: 'None'
                      },
                      attrVolatile: false
                    },
                    tag: 'Tint0'
                  },
                  v: {
                    arg0: 0n,
                    tag: 'Vint'
                  }
                },
                tag: 'Some'
              },
              tag: 'Sreturn'
            },
            arg2: {
              tag: 'LSnil'
            },
            tag: 'LScons'
          },
          tag: 'LScons'
        },
        tag: 'Sswitch'
      },
      tag: 'Ssequence'
    }
  }
  nested errors retain function and identifier context
  [
    'In function ',
    1n,
    ': ',
    'unbound variable ',
    999n
  ]
  [
    'In function ',
    1n,
    ': ',
    'operator +'
  ]
  composite layouts respect x86-64 alignment and nested arrays
  [
    40n,
    8n
  ]
  [
    24n,
    8n
  ]
  {
    actual: [
      [
        [
          23n,
          16n
        ],
        {
          tag: 'Full'
        }
      ],
      [
        [
          22n,
          8n
        ],
        {
          tag: 'Full'
        }
      ],
      [
        [
          21n,
          0n
        ],
        {
          tag: 'Full'
        }
      ]
    ],
    expected: [
      [
        [
          23n,
          16n
        ],
        {
          tag: 'Full'
        }
      ],
      [
        [
          22n,
          8n
        ],
        {
          tag: 'Full'
        }
      ],
      [
        [
          21n,
          0n
        ],
        {
          tag: 'Full'
        }
      ]
    ]
  }
  composite construction rejects duplicates and incomplete by-value members
  [
    'Multiple definitions of struct or union ',
    10n
  ]
  [
    'Incomplete struct or union ',
    20n
  ]
