const __readCell = <T>(cells: readonly (readonly [T])[], index: number): T => {
  const cell = cells[index];

  if (cell === undefined) {
    throw new Error("Invalid continuation stack access");
  }

  return cell[0];
};

const __writeCell = <T>(cells: [T][], index: number, value: T): void => {
  const cell = cells[index];

  if (cell === undefined) {
    cells[index] = [value];
  } else {
    cell[0] = value;
  }
};

export interface True {
  readonly tag: "True";
}

export interface False {
  readonly tag: "False";
}

export type Bool = True | False;

export const true0: True = { tag: "True" };
export const false0: False = { tag: "False" };

export interface O {
  readonly tag: "O";
}

export interface S {
  readonly tag: "S";
  readonly arg0: Nat;
}

export type Nat = O | S;

export const o: O = { tag: "O" };
export const s = (arg0: Nat): Nat => ({ arg0, tag: "S" });

export interface Pair<A, B> {
  readonly tag: "Pair";
  readonly arg0: A;
  readonly arg1: B;
}

export type Prod<A, B> = Pair<A, B>;

export const pair = <A, B>(arg0: A, arg1: B): Pair<A, B> => ({
  arg0,
  arg1,
  tag: "Pair",
});

const fst = <A, B>(p: Prod<A, B>): A => p.arg0;
const snd = <A, B>(p: Prod<A, B>): B => p.arg1;

export interface Eq {
  readonly tag: "Eq";
}

export interface Lt {
  readonly tag: "Lt";
}

export interface Gt {
  readonly tag: "Gt";
}

export type Comparison = Eq | Lt | Gt;

export const eq: Eq = { tag: "Eq" };
export const lt: Lt = { tag: "Lt" };
export const gt: Gt = { tag: "Gt" };

const compOpp = (r: Comparison): Comparison => {
  switch (r.tag) {
    case "Eq": {
      return eq;
    }

    case "Lt": {
      return gt;
    }

    case "Gt": {
      return lt;
    }

    default: {
      return r satisfies never;
    }
  }
};

const add = (n: Nat, m: Nat): Nat => {
  let depth = 0;
  let n1 = n;

  for (;;) {
    let returned: Nat;

    switch (n1.tag) {
      case "O": {
        returned = m;
        break;
      }

      case "S": {
        depth += 1;
        n1 = n1.arg0;
        continue;
      }

      default: {
        returned = n1 satisfies never;
      }
    }

    for (;;) {
      if (depth === 0) {
        return returned;
      }

      depth -= 1;
      returned = s(returned);
    }
  }
};

export interface XI {
  readonly tag: "XI";
  readonly arg0: Positive;
}

export interface XO {
  readonly tag: "XO";
  readonly arg0: Positive;
}

export interface XH {
  readonly tag: "XH";
}

export type Positive = XI | XO | XH;

export const xI = (arg0: Positive): Positive => ({ arg0, tag: "XI" });
export const xO = (arg0: Positive): Positive => ({ arg0, tag: "XO" });
export const xH: XH = { tag: "XH" };

export interface N0 {
  readonly tag: "N0";
}

export interface Npos {
  readonly tag: "Npos";
  readonly arg0: Positive;
}

export type N = N0 | Npos;

export const n0: N0 = { tag: "N0" };
export const npos = (arg0: Positive): N => ({ arg0, tag: "Npos" });

export interface Z0 {
  readonly tag: "Z0";
}

export interface Zpos {
  readonly tag: "Zpos";
  readonly arg0: Positive;
}

export interface Zneg {
  readonly tag: "Zneg";
  readonly arg0: Positive;
}

export type Z = Z0 | Zpos | Zneg;

export const z0: Z0 = { tag: "Z0" };
export const zpos = (arg0: Positive): Z => ({ arg0, tag: "Zpos" });
export const zneg = (arg0: Positive): Z => ({ arg0, tag: "Zneg" });

const Pos$succ = (x: Positive): Positive => {
  let depth = 0;
  let x0 = x;

  for (;;) {
    let returned: Positive;

    switch (x0.tag) {
      case "XI": {
        depth += 1;
        x0 = x0.arg0;
        continue;
      }

      case "XO": {
        returned = xI(x0.arg0);
        break;
      }

      case "XH": {
        returned = xO(xH);
        break;
      }

      default: {
        returned = x0 satisfies never;
      }
    }

    for (;;) {
      if (depth === 0) {
        return returned;
      }

      depth -= 1;
      returned = xO(returned);
    }
  }
};

const Pos$addAddCarry = {
  add: (x: Positive, y: Positive): Positive => {
    const frames: [number][] = [];
    let depth = 0;
    let x0 = x;
    let y0 = y;
    let which = 0;

    for (;;) {
      let returned: Positive;

      switch (which) {
        case 0: {
          switch (x0.tag) {
            case "XI": {
              switch (y0.tag) {
                case "XI": {
                  __writeCell(frames, depth, 0);
                  depth += 1;
                  const x1: Positive = x0.arg0;
                  const y1: Positive = y0.arg0;

                  switch (x1.tag) {
                    case "XI": {
                      switch (y1.tag) {
                        case "XI": {
                          __writeCell(frames, depth, 1);
                          depth += 1;
                          x0 = x1.arg0;
                          y0 = y1.arg0;
                          which = 1;
                          continue;
                        }

                        case "XO": {
                          __writeCell(frames, depth, 0);
                          depth += 1;
                          x0 = x1.arg0;
                          y0 = y1.arg0;
                          which = 1;
                          continue;
                        }

                        case "XH": {
                          returned = xI(Pos$succ(x1.arg0));
                          break;
                        }

                        default: {
                          returned = y1 satisfies never;
                        }
                      }

                      break;
                    }

                    case "XO": {
                      switch (y1.tag) {
                        case "XI": {
                          __writeCell(frames, depth, 0);
                          depth += 1;
                          x0 = x1.arg0;
                          y0 = y1.arg0;
                          which = 1;
                          continue;
                        }

                        case "XO": {
                          __writeCell(frames, depth, 1);
                          depth += 1;
                          x0 = x1.arg0;
                          y0 = y1.arg0;
                          continue;
                        }

                        case "XH": {
                          returned = xO(Pos$succ(x1.arg0));
                          break;
                        }

                        default: {
                          returned = y1 satisfies never;
                        }
                      }

                      break;
                    }

                    case "XH": {
                      switch (y1.tag) {
                        case "XI": {
                          returned = xI(Pos$succ(y1.arg0));
                          break;
                        }

                        case "XO": {
                          returned = xO(Pos$succ(y1.arg0));
                          break;
                        }

                        case "XH": {
                          returned = xI(xH);
                          break;
                        }

                        default: {
                          returned = y1 satisfies never;
                        }
                      }

                      break;
                    }

                    default: {
                      returned = x1 satisfies never;
                    }
                  }

                  break;
                }

                case "XO": {
                  __writeCell(frames, depth, 1);
                  depth += 1;
                  x0 = x0.arg0;
                  y0 = y0.arg0;
                  continue;
                }

                case "XH": {
                  returned = xO(Pos$succ(x0.arg0));
                  break;
                }

                default: {
                  returned = y0 satisfies never;
                }
              }

              break;
            }

            case "XO": {
              switch (y0.tag) {
                case "XI": {
                  __writeCell(frames, depth, 1);
                  depth += 1;
                  x0 = x0.arg0;
                  y0 = y0.arg0;
                  continue;
                }

                case "XO": {
                  __writeCell(frames, depth, 0);
                  depth += 1;
                  x0 = x0.arg0;
                  y0 = y0.arg0;
                  continue;
                }

                case "XH": {
                  returned = xI(x0.arg0);
                  break;
                }

                default: {
                  returned = y0 satisfies never;
                }
              }

              break;
            }

            case "XH": {
              switch (y0.tag) {
                case "XI": {
                  returned = xO(Pos$succ(y0.arg0));
                  break;
                }

                case "XO": {
                  returned = xI(y0.arg0);
                  break;
                }

                case "XH": {
                  returned = xO(xH);
                  break;
                }

                default: {
                  returned = y0 satisfies never;
                }
              }

              break;
            }

            default: {
              returned = x0 satisfies never;
            }
          }

          break;
        }

        default: {
          switch (x0.tag) {
            case "XI": {
              switch (y0.tag) {
                case "XI": {
                  __writeCell(frames, depth, 1);
                  depth += 1;
                  x0 = x0.arg0;
                  y0 = y0.arg0;
                  continue;
                }

                case "XO": {
                  __writeCell(frames, depth, 0);
                  depth += 1;
                  x0 = x0.arg0;
                  y0 = y0.arg0;
                  continue;
                }

                case "XH": {
                  returned = xI(Pos$succ(x0.arg0));
                  break;
                }

                default: {
                  returned = y0 satisfies never;
                }
              }

              break;
            }

            case "XO": {
              switch (y0.tag) {
                case "XI": {
                  __writeCell(frames, depth, 0);
                  depth += 1;
                  x0 = x0.arg0;
                  y0 = y0.arg0;
                  continue;
                }

                case "XO": {
                  __writeCell(frames, depth, 1);
                  depth += 1;
                  const x1: Positive = x0.arg0;
                  const y1: Positive = y0.arg0;

                  switch (x1.tag) {
                    case "XI": {
                      switch (y1.tag) {
                        case "XI": {
                          __writeCell(frames, depth, 0);
                          depth += 1;
                          x0 = x1.arg0;
                          y0 = y1.arg0;
                          continue;
                        }

                        case "XO": {
                          __writeCell(frames, depth, 1);
                          depth += 1;
                          x0 = x1.arg0;
                          y0 = y1.arg0;
                          which = 0;
                          continue;
                        }

                        case "XH": {
                          returned = xO(Pos$succ(x1.arg0));
                          break;
                        }

                        default: {
                          returned = y1 satisfies never;
                        }
                      }

                      break;
                    }

                    case "XO": {
                      switch (y1.tag) {
                        case "XI": {
                          __writeCell(frames, depth, 1);
                          depth += 1;
                          x0 = x1.arg0;
                          y0 = y1.arg0;
                          which = 0;
                          continue;
                        }

                        case "XO": {
                          __writeCell(frames, depth, 0);
                          depth += 1;
                          x0 = x1.arg0;
                          y0 = y1.arg0;
                          which = 0;
                          continue;
                        }

                        case "XH": {
                          returned = xI(x1.arg0);
                          break;
                        }

                        default: {
                          returned = y1 satisfies never;
                        }
                      }

                      break;
                    }

                    case "XH": {
                      switch (y1.tag) {
                        case "XI": {
                          returned = xO(Pos$succ(y1.arg0));
                          break;
                        }

                        case "XO": {
                          returned = xI(y1.arg0);
                          break;
                        }

                        case "XH": {
                          returned = xO(xH);
                          break;
                        }

                        default: {
                          returned = y1 satisfies never;
                        }
                      }

                      break;
                    }

                    default: {
                      returned = x1 satisfies never;
                    }
                  }

                  break;
                }

                case "XH": {
                  returned = xO(Pos$succ(x0.arg0));
                  break;
                }

                default: {
                  returned = y0 satisfies never;
                }
              }

              break;
            }

            case "XH": {
              switch (y0.tag) {
                case "XI": {
                  returned = xI(Pos$succ(y0.arg0));
                  break;
                }

                case "XO": {
                  returned = xO(Pos$succ(y0.arg0));
                  break;
                }

                case "XH": {
                  returned = xI(xH);
                  break;
                }

                default: {
                  returned = y0 satisfies never;
                }
              }

              break;
            }

            default: {
              returned = x0 satisfies never;
            }
          }
        }
      }

      for (;;) {
        if (depth === 0) {
          return returned;
        }

        depth -= 1;

        switch (__readCell(frames, depth)) {
          case 0: {
            returned = xO(returned);
            break;
          }

          default: {
            returned = xI(returned);
          }
        }
      }
    }
  },
  addCarry: (x: Positive, y: Positive): Positive => {
    const frames: [number][] = [];
    let depth = 0;
    let x0 = x;
    let y0 = y;
    let which = 1;

    for (;;) {
      let returned: Positive;

      switch (which) {
        case 0: {
          switch (x0.tag) {
            case "XI": {
              switch (y0.tag) {
                case "XI": {
                  __writeCell(frames, depth, 0);
                  depth += 1;
                  const x1: Positive = x0.arg0;
                  const y1: Positive = y0.arg0;

                  switch (x1.tag) {
                    case "XI": {
                      switch (y1.tag) {
                        case "XI": {
                          __writeCell(frames, depth, 1);
                          depth += 1;
                          x0 = x1.arg0;
                          y0 = y1.arg0;
                          which = 1;
                          continue;
                        }

                        case "XO": {
                          __writeCell(frames, depth, 0);
                          depth += 1;
                          x0 = x1.arg0;
                          y0 = y1.arg0;
                          which = 1;
                          continue;
                        }

                        case "XH": {
                          returned = xI(Pos$succ(x1.arg0));
                          break;
                        }

                        default: {
                          returned = y1 satisfies never;
                        }
                      }

                      break;
                    }

                    case "XO": {
                      switch (y1.tag) {
                        case "XI": {
                          __writeCell(frames, depth, 0);
                          depth += 1;
                          x0 = x1.arg0;
                          y0 = y1.arg0;
                          which = 1;
                          continue;
                        }

                        case "XO": {
                          __writeCell(frames, depth, 1);
                          depth += 1;
                          x0 = x1.arg0;
                          y0 = y1.arg0;
                          continue;
                        }

                        case "XH": {
                          returned = xO(Pos$succ(x1.arg0));
                          break;
                        }

                        default: {
                          returned = y1 satisfies never;
                        }
                      }

                      break;
                    }

                    case "XH": {
                      switch (y1.tag) {
                        case "XI": {
                          returned = xI(Pos$succ(y1.arg0));
                          break;
                        }

                        case "XO": {
                          returned = xO(Pos$succ(y1.arg0));
                          break;
                        }

                        case "XH": {
                          returned = xI(xH);
                          break;
                        }

                        default: {
                          returned = y1 satisfies never;
                        }
                      }

                      break;
                    }

                    default: {
                      returned = x1 satisfies never;
                    }
                  }

                  break;
                }

                case "XO": {
                  __writeCell(frames, depth, 1);
                  depth += 1;
                  x0 = x0.arg0;
                  y0 = y0.arg0;
                  continue;
                }

                case "XH": {
                  returned = xO(Pos$succ(x0.arg0));
                  break;
                }

                default: {
                  returned = y0 satisfies never;
                }
              }

              break;
            }

            case "XO": {
              switch (y0.tag) {
                case "XI": {
                  __writeCell(frames, depth, 1);
                  depth += 1;
                  x0 = x0.arg0;
                  y0 = y0.arg0;
                  continue;
                }

                case "XO": {
                  __writeCell(frames, depth, 0);
                  depth += 1;
                  x0 = x0.arg0;
                  y0 = y0.arg0;
                  continue;
                }

                case "XH": {
                  returned = xI(x0.arg0);
                  break;
                }

                default: {
                  returned = y0 satisfies never;
                }
              }

              break;
            }

            case "XH": {
              switch (y0.tag) {
                case "XI": {
                  returned = xO(Pos$succ(y0.arg0));
                  break;
                }

                case "XO": {
                  returned = xI(y0.arg0);
                  break;
                }

                case "XH": {
                  returned = xO(xH);
                  break;
                }

                default: {
                  returned = y0 satisfies never;
                }
              }

              break;
            }

            default: {
              returned = x0 satisfies never;
            }
          }

          break;
        }

        default: {
          switch (x0.tag) {
            case "XI": {
              switch (y0.tag) {
                case "XI": {
                  __writeCell(frames, depth, 1);
                  depth += 1;
                  x0 = x0.arg0;
                  y0 = y0.arg0;
                  continue;
                }

                case "XO": {
                  __writeCell(frames, depth, 0);
                  depth += 1;
                  x0 = x0.arg0;
                  y0 = y0.arg0;
                  continue;
                }

                case "XH": {
                  returned = xI(Pos$succ(x0.arg0));
                  break;
                }

                default: {
                  returned = y0 satisfies never;
                }
              }

              break;
            }

            case "XO": {
              switch (y0.tag) {
                case "XI": {
                  __writeCell(frames, depth, 0);
                  depth += 1;
                  x0 = x0.arg0;
                  y0 = y0.arg0;
                  continue;
                }

                case "XO": {
                  __writeCell(frames, depth, 1);
                  depth += 1;
                  const x1: Positive = x0.arg0;
                  const y1: Positive = y0.arg0;

                  switch (x1.tag) {
                    case "XI": {
                      switch (y1.tag) {
                        case "XI": {
                          __writeCell(frames, depth, 0);
                          depth += 1;
                          x0 = x1.arg0;
                          y0 = y1.arg0;
                          continue;
                        }

                        case "XO": {
                          __writeCell(frames, depth, 1);
                          depth += 1;
                          x0 = x1.arg0;
                          y0 = y1.arg0;
                          which = 0;
                          continue;
                        }

                        case "XH": {
                          returned = xO(Pos$succ(x1.arg0));
                          break;
                        }

                        default: {
                          returned = y1 satisfies never;
                        }
                      }

                      break;
                    }

                    case "XO": {
                      switch (y1.tag) {
                        case "XI": {
                          __writeCell(frames, depth, 1);
                          depth += 1;
                          x0 = x1.arg0;
                          y0 = y1.arg0;
                          which = 0;
                          continue;
                        }

                        case "XO": {
                          __writeCell(frames, depth, 0);
                          depth += 1;
                          x0 = x1.arg0;
                          y0 = y1.arg0;
                          which = 0;
                          continue;
                        }

                        case "XH": {
                          returned = xI(x1.arg0);
                          break;
                        }

                        default: {
                          returned = y1 satisfies never;
                        }
                      }

                      break;
                    }

                    case "XH": {
                      switch (y1.tag) {
                        case "XI": {
                          returned = xO(Pos$succ(y1.arg0));
                          break;
                        }

                        case "XO": {
                          returned = xI(y1.arg0);
                          break;
                        }

                        case "XH": {
                          returned = xO(xH);
                          break;
                        }

                        default: {
                          returned = y1 satisfies never;
                        }
                      }

                      break;
                    }

                    default: {
                      returned = x1 satisfies never;
                    }
                  }

                  break;
                }

                case "XH": {
                  returned = xO(Pos$succ(x0.arg0));
                  break;
                }

                default: {
                  returned = y0 satisfies never;
                }
              }

              break;
            }

            case "XH": {
              switch (y0.tag) {
                case "XI": {
                  returned = xI(Pos$succ(y0.arg0));
                  break;
                }

                case "XO": {
                  returned = xO(Pos$succ(y0.arg0));
                  break;
                }

                case "XH": {
                  returned = xI(xH);
                  break;
                }

                default: {
                  returned = y0 satisfies never;
                }
              }

              break;
            }

            default: {
              returned = x0 satisfies never;
            }
          }
        }
      }

      for (;;) {
        if (depth === 0) {
          return returned;
        }

        depth -= 1;

        switch (__readCell(frames, depth)) {
          case 0: {
            returned = xO(returned);
            break;
          }

          default: {
            returned = xI(returned);
          }
        }
      }
    }
  },
};

const { add: Pos$add, addCarry: Pos$addCarry } = Pos$addAddCarry;

const Pos$predDouble = (x: Positive): Positive => {
  let depth = 0;
  let x0 = x;

  for (;;) {
    let returned: Positive;

    switch (x0.tag) {
      case "XI": {
        returned = xI(xO(x0.arg0));
        break;
      }

      case "XO": {
        depth += 1;
        x0 = x0.arg0;
        continue;
      }

      case "XH": {
        returned = xH;
        break;
      }

      default: {
        returned = x0 satisfies never;
      }
    }

    for (;;) {
      if (depth === 0) {
        return returned;
      }

      depth -= 1;
      returned = xI(returned);
    }
  }
};

const Pos$predN = (x: Positive): N => {
  switch (x.tag) {
    case "XI": {
      return npos(xO(x.arg0));
    }

    case "XO": {
      return npos(Pos$predDouble(x.arg0));
    }

    case "XH": {
      return n0;
    }

    default: {
      return x satisfies never;
    }
  }
};

interface PosIsNul {
  readonly tag: "IsNul";
}

interface PosIsPos {
  readonly tag: "IsPos";
  readonly arg0: Positive;
}

interface PosIsNeg {
  readonly tag: "IsNeg";
}

type PosMask = PosIsNul | PosIsPos | PosIsNeg;

const Pos$isNul: PosIsNul = { tag: "IsNul" };
const Pos$isPos = (arg0: Positive): PosMask => ({ arg0, tag: "IsPos" });
const Pos$isNeg: PosIsNeg = { tag: "IsNeg" };

const Pos$succDoubleMask = (x: PosMask): PosMask => {
  switch (x.tag) {
    case "IsNul": {
      return Pos$isPos(xH);
    }

    case "IsPos": {
      return Pos$isPos(xI(x.arg0));
    }

    case "IsNeg": {
      return Pos$isNeg;
    }

    default: {
      return x satisfies never;
    }
  }
};

const Pos$doubleMask = (x: PosMask): PosMask => {
  switch (x.tag) {
    case "IsPos": {
      return Pos$isPos(xO(x.arg0));
    }

    default: {
      return x;
    }
  }
};

const Pos$doublePredMask = (x: Positive): PosMask => {
  switch (x.tag) {
    case "XI": {
      return Pos$isPos(xO(xO(x.arg0)));
    }

    case "XO": {
      return Pos$isPos(xO(Pos$predDouble(x.arg0)));
    }

    case "XH": {
      return Pos$isNul;
    }

    default: {
      return x satisfies never;
    }
  }
};

const Pos$subMaskSubMaskCarry = {
  subMask: (x: Positive, y: Positive): PosMask => {
    const frames: [number][] = [];
    let depth = 0;
    let x0 = x;
    let y0 = y;
    let which = 0;

    for (;;) {
      let returned: PosMask;

      switch (which) {
        case 0: {
          switch (x0.tag) {
            case "XI": {
              switch (y0.tag) {
                case "XI": {
                  __writeCell(frames, depth, 0);
                  depth += 1;
                  x0 = x0.arg0;
                  y0 = y0.arg0;
                  continue;
                }

                case "XO": {
                  __writeCell(frames, depth, 1);
                  depth += 1;
                  x0 = x0.arg0;
                  y0 = y0.arg0;
                  continue;
                }

                case "XH": {
                  returned = Pos$isPos(xO(x0.arg0));
                  break;
                }

                default: {
                  returned = y0 satisfies never;
                }
              }

              break;
            }

            case "XO": {
              switch (y0.tag) {
                case "XI": {
                  __writeCell(frames, depth, 1);
                  depth += 1;
                  const x1: Positive = x0.arg0;
                  const y1: Positive = y0.arg0;

                  switch (x1.tag) {
                    case "XI": {
                      switch (y1.tag) {
                        case "XI": {
                          __writeCell(frames, depth, 1);
                          depth += 1;
                          x0 = x1.arg0;
                          y0 = y1.arg0;
                          which = 1;
                          continue;
                        }

                        case "XO": {
                          __writeCell(frames, depth, 0);
                          depth += 1;
                          x0 = x1.arg0;
                          y0 = y1.arg0;
                          continue;
                        }

                        case "XH": {
                          returned = Pos$isPos(Pos$predDouble(x1.arg0));
                          break;
                        }

                        default: {
                          returned = y1 satisfies never;
                        }
                      }

                      break;
                    }

                    case "XO": {
                      switch (y1.tag) {
                        case "XI": {
                          __writeCell(frames, depth, 0);
                          depth += 1;
                          x0 = x1.arg0;
                          y0 = y1.arg0;
                          which = 1;
                          continue;
                        }

                        case "XO": {
                          __writeCell(frames, depth, 1);
                          depth += 1;
                          x0 = x1.arg0;
                          y0 = y1.arg0;
                          which = 1;
                          continue;
                        }

                        case "XH": {
                          returned = Pos$doublePredMask(x1.arg0);
                          break;
                        }

                        default: {
                          returned = y1 satisfies never;
                        }
                      }

                      break;
                    }

                    case "XH": {
                      returned = Pos$isNeg;
                      break;
                    }

                    default: {
                      returned = x1 satisfies never;
                    }
                  }

                  break;
                }

                case "XO": {
                  __writeCell(frames, depth, 0);
                  depth += 1;
                  x0 = x0.arg0;
                  y0 = y0.arg0;
                  continue;
                }

                case "XH": {
                  returned = Pos$isPos(Pos$predDouble(x0.arg0));
                  break;
                }

                default: {
                  returned = y0 satisfies never;
                }
              }

              break;
            }

            case "XH": {
              returned = y0.tag === "XH" ? Pos$isNul : Pos$isNeg;
              break;
            }

            default: {
              returned = x0 satisfies never;
            }
          }

          break;
        }

        default: {
          switch (x0.tag) {
            case "XI": {
              switch (y0.tag) {
                case "XI": {
                  __writeCell(frames, depth, 1);
                  depth += 1;
                  x0 = x0.arg0;
                  y0 = y0.arg0;
                  continue;
                }

                case "XO": {
                  __writeCell(frames, depth, 0);
                  depth += 1;
                  const x1: Positive = x0.arg0;
                  const y1: Positive = y0.arg0;

                  switch (x1.tag) {
                    case "XI": {
                      switch (y1.tag) {
                        case "XI": {
                          __writeCell(frames, depth, 0);
                          depth += 1;
                          x0 = x1.arg0;
                          y0 = y1.arg0;
                          which = 0;
                          continue;
                        }

                        case "XO": {
                          __writeCell(frames, depth, 1);
                          depth += 1;
                          x0 = x1.arg0;
                          y0 = y1.arg0;
                          which = 0;
                          continue;
                        }

                        case "XH": {
                          returned = Pos$isPos(xO(x1.arg0));
                          break;
                        }

                        default: {
                          returned = y1 satisfies never;
                        }
                      }

                      break;
                    }

                    case "XO": {
                      switch (y1.tag) {
                        case "XI": {
                          __writeCell(frames, depth, 1);
                          depth += 1;
                          x0 = x1.arg0;
                          y0 = y1.arg0;
                          continue;
                        }

                        case "XO": {
                          __writeCell(frames, depth, 0);
                          depth += 1;
                          x0 = x1.arg0;
                          y0 = y1.arg0;
                          which = 0;
                          continue;
                        }

                        case "XH": {
                          returned = Pos$isPos(Pos$predDouble(x1.arg0));
                          break;
                        }

                        default: {
                          returned = y1 satisfies never;
                        }
                      }

                      break;
                    }

                    case "XH": {
                      returned = y1.tag === "XH" ? Pos$isNul : Pos$isNeg;
                      break;
                    }

                    default: {
                      returned = x1 satisfies never;
                    }
                  }

                  break;
                }

                case "XH": {
                  returned = Pos$isPos(Pos$predDouble(x0.arg0));
                  break;
                }

                default: {
                  returned = y0 satisfies never;
                }
              }

              break;
            }

            case "XO": {
              switch (y0.tag) {
                case "XI": {
                  __writeCell(frames, depth, 0);
                  depth += 1;
                  x0 = x0.arg0;
                  y0 = y0.arg0;
                  continue;
                }

                case "XO": {
                  __writeCell(frames, depth, 1);
                  depth += 1;
                  x0 = x0.arg0;
                  y0 = y0.arg0;
                  continue;
                }

                case "XH": {
                  returned = Pos$doublePredMask(x0.arg0);
                  break;
                }

                default: {
                  returned = y0 satisfies never;
                }
              }

              break;
            }

            case "XH": {
              returned = Pos$isNeg;
              break;
            }

            default: {
              returned = x0 satisfies never;
            }
          }
        }
      }

      for (;;) {
        if (depth === 0) {
          return returned;
        }

        depth -= 1;

        switch (__readCell(frames, depth)) {
          case 0: {
            returned = Pos$doubleMask(returned);
            break;
          }

          default: {
            returned = Pos$succDoubleMask(returned);
          }
        }
      }
    }
  },
  subMaskCarry: (x: Positive, y: Positive): PosMask => {
    const frames: [number][] = [];
    let depth = 0;
    let x0 = x;
    let y0 = y;
    let which = 1;

    for (;;) {
      let returned: PosMask;

      switch (which) {
        case 0: {
          switch (x0.tag) {
            case "XI": {
              switch (y0.tag) {
                case "XI": {
                  __writeCell(frames, depth, 0);
                  depth += 1;
                  x0 = x0.arg0;
                  y0 = y0.arg0;
                  continue;
                }

                case "XO": {
                  __writeCell(frames, depth, 1);
                  depth += 1;
                  x0 = x0.arg0;
                  y0 = y0.arg0;
                  continue;
                }

                case "XH": {
                  returned = Pos$isPos(xO(x0.arg0));
                  break;
                }

                default: {
                  returned = y0 satisfies never;
                }
              }

              break;
            }

            case "XO": {
              switch (y0.tag) {
                case "XI": {
                  __writeCell(frames, depth, 1);
                  depth += 1;
                  const x1: Positive = x0.arg0;
                  const y1: Positive = y0.arg0;

                  switch (x1.tag) {
                    case "XI": {
                      switch (y1.tag) {
                        case "XI": {
                          __writeCell(frames, depth, 1);
                          depth += 1;
                          x0 = x1.arg0;
                          y0 = y1.arg0;
                          which = 1;
                          continue;
                        }

                        case "XO": {
                          __writeCell(frames, depth, 0);
                          depth += 1;
                          x0 = x1.arg0;
                          y0 = y1.arg0;
                          continue;
                        }

                        case "XH": {
                          returned = Pos$isPos(Pos$predDouble(x1.arg0));
                          break;
                        }

                        default: {
                          returned = y1 satisfies never;
                        }
                      }

                      break;
                    }

                    case "XO": {
                      switch (y1.tag) {
                        case "XI": {
                          __writeCell(frames, depth, 0);
                          depth += 1;
                          x0 = x1.arg0;
                          y0 = y1.arg0;
                          which = 1;
                          continue;
                        }

                        case "XO": {
                          __writeCell(frames, depth, 1);
                          depth += 1;
                          x0 = x1.arg0;
                          y0 = y1.arg0;
                          which = 1;
                          continue;
                        }

                        case "XH": {
                          returned = Pos$doublePredMask(x1.arg0);
                          break;
                        }

                        default: {
                          returned = y1 satisfies never;
                        }
                      }

                      break;
                    }

                    case "XH": {
                      returned = Pos$isNeg;
                      break;
                    }

                    default: {
                      returned = x1 satisfies never;
                    }
                  }

                  break;
                }

                case "XO": {
                  __writeCell(frames, depth, 0);
                  depth += 1;
                  x0 = x0.arg0;
                  y0 = y0.arg0;
                  continue;
                }

                case "XH": {
                  returned = Pos$isPos(Pos$predDouble(x0.arg0));
                  break;
                }

                default: {
                  returned = y0 satisfies never;
                }
              }

              break;
            }

            case "XH": {
              returned = y0.tag === "XH" ? Pos$isNul : Pos$isNeg;
              break;
            }

            default: {
              returned = x0 satisfies never;
            }
          }

          break;
        }

        default: {
          switch (x0.tag) {
            case "XI": {
              switch (y0.tag) {
                case "XI": {
                  __writeCell(frames, depth, 1);
                  depth += 1;
                  x0 = x0.arg0;
                  y0 = y0.arg0;
                  continue;
                }

                case "XO": {
                  __writeCell(frames, depth, 0);
                  depth += 1;
                  const x1: Positive = x0.arg0;
                  const y1: Positive = y0.arg0;

                  switch (x1.tag) {
                    case "XI": {
                      switch (y1.tag) {
                        case "XI": {
                          __writeCell(frames, depth, 0);
                          depth += 1;
                          x0 = x1.arg0;
                          y0 = y1.arg0;
                          which = 0;
                          continue;
                        }

                        case "XO": {
                          __writeCell(frames, depth, 1);
                          depth += 1;
                          x0 = x1.arg0;
                          y0 = y1.arg0;
                          which = 0;
                          continue;
                        }

                        case "XH": {
                          returned = Pos$isPos(xO(x1.arg0));
                          break;
                        }

                        default: {
                          returned = y1 satisfies never;
                        }
                      }

                      break;
                    }

                    case "XO": {
                      switch (y1.tag) {
                        case "XI": {
                          __writeCell(frames, depth, 1);
                          depth += 1;
                          x0 = x1.arg0;
                          y0 = y1.arg0;
                          continue;
                        }

                        case "XO": {
                          __writeCell(frames, depth, 0);
                          depth += 1;
                          x0 = x1.arg0;
                          y0 = y1.arg0;
                          which = 0;
                          continue;
                        }

                        case "XH": {
                          returned = Pos$isPos(Pos$predDouble(x1.arg0));
                          break;
                        }

                        default: {
                          returned = y1 satisfies never;
                        }
                      }

                      break;
                    }

                    case "XH": {
                      returned = y1.tag === "XH" ? Pos$isNul : Pos$isNeg;
                      break;
                    }

                    default: {
                      returned = x1 satisfies never;
                    }
                  }

                  break;
                }

                case "XH": {
                  returned = Pos$isPos(Pos$predDouble(x0.arg0));
                  break;
                }

                default: {
                  returned = y0 satisfies never;
                }
              }

              break;
            }

            case "XO": {
              switch (y0.tag) {
                case "XI": {
                  __writeCell(frames, depth, 0);
                  depth += 1;
                  x0 = x0.arg0;
                  y0 = y0.arg0;
                  continue;
                }

                case "XO": {
                  __writeCell(frames, depth, 1);
                  depth += 1;
                  x0 = x0.arg0;
                  y0 = y0.arg0;
                  continue;
                }

                case "XH": {
                  returned = Pos$doublePredMask(x0.arg0);
                  break;
                }

                default: {
                  returned = y0 satisfies never;
                }
              }

              break;
            }

            case "XH": {
              returned = Pos$isNeg;
              break;
            }

            default: {
              returned = x0 satisfies never;
            }
          }
        }
      }

      for (;;) {
        if (depth === 0) {
          return returned;
        }

        depth -= 1;

        switch (__readCell(frames, depth)) {
          case 0: {
            returned = Pos$doubleMask(returned);
            break;
          }

          default: {
            returned = Pos$succDoubleMask(returned);
          }
        }
      }
    }
  },
};

const { subMask: Pos$subMask } = Pos$subMaskSubMaskCarry;

const Pos$sub = (x: Positive, y: Positive): Positive => {
  const s0: PosMask = Pos$subMask(x, y);

  switch (s0.tag) {
    case "IsPos": {
      return s0.arg0;
    }

    default: {
      return xH;
    }
  }
};

const Pos$mul = (x: Positive, y: Positive): Positive => {
  const frames: [number][] = [];
  let depth = 0;
  let x0 = x;

  for (;;) {
    let returned: Positive;

    switch (x0.tag) {
      case "XI": {
        __writeCell(frames, depth, 0);
        depth += 1;
        x0 = x0.arg0;
        continue;
      }

      case "XO": {
        __writeCell(frames, depth, 1);
        depth += 1;
        x0 = x0.arg0;
        continue;
      }

      case "XH": {
        returned = y;
        break;
      }

      default: {
        returned = x0 satisfies never;
      }
    }

    for (;;) {
      if (depth === 0) {
        return returned;
      }

      depth -= 1;

      switch (__readCell(frames, depth)) {
        case 0: {
          returned = Pos$add(y, xO(returned));
          break;
        }

        default: {
          returned = xO(returned);
        }
      }
    }
  }
};

const Pos$iter = <A>(f: (_: A) => A, x: A, n: Positive): A => {
  const saved: [Positive][] = [];
  let top = 0;
  const frames: [number][] = [];
  let depth = 0;
  let x0 = x;
  let n1 = n;

  for (;;) {
    let returned: A;

    switch (n1.tag) {
      case "XI": {
        __writeCell(frames, depth, 0);
        depth += 1;
        __writeCell(saved, top, n1.arg0);
        top += 1;
        n1 = n1.arg0;
        continue;
      }

      case "XO": {
        __writeCell(frames, depth, 1);
        depth += 1;
        __writeCell(saved, top, n1.arg0);
        top += 1;
        n1 = n1.arg0;
        continue;
      }

      case "XH": {
        returned = f(x0);
        break;
      }

      default: {
        returned = n1 satisfies never;
      }
    }

    let resuming = true;

    while (resuming) {
      if (depth === 0) {
        return returned;
      }

      depth -= 1;

      switch (__readCell(frames, depth)) {
        case 0: {
          top -= 1;
          const arg0: Positive = __readCell(saved, top);
          __writeCell(frames, depth, 2);
          depth += 1;
          x0 = returned;
          n1 = arg0;
          resuming = false;
          continue;
        }

        case 1: {
          top -= 1;
          const arg0: Positive = __readCell(saved, top);
          x0 = returned;
          n1 = arg0;
          resuming = false;
          continue;
        }

        default: {
          returned = f(returned);
        }
      }
    }
  }
};

const Pos$div2 = (p: Positive): Positive => {
  switch (p.tag) {
    case "XI": {
      return p.arg0;
    }

    case "XO": {
      return p.arg0;
    }

    case "XH": {
      return xH;
    }

    default: {
      return p satisfies never;
    }
  }
};

const Pos$div2Up = (p: Positive): Positive => {
  switch (p.tag) {
    case "XI": {
      return Pos$succ(p.arg0);
    }

    case "XO": {
      return p.arg0;
    }

    case "XH": {
      return xH;
    }

    default: {
      return p satisfies never;
    }
  }
};

const Pos$compareCont = (
  r: Comparison,
  x: Positive,
  y: Positive
): Comparison => {
  let r0 = r;
  let x0 = x;
  let y0 = y;

  for (;;) {
    switch (x0.tag) {
      case "XI": {
        switch (y0.tag) {
          case "XI": {
            x0 = x0.arg0;
            y0 = y0.arg0;
            continue;
          }

          case "XO": {
            r0 = gt;
            x0 = x0.arg0;
            y0 = y0.arg0;
            continue;
          }

          case "XH": {
            return gt;
          }

          default: {
            return y0 satisfies never;
          }
        }
      }

      case "XO": {
        switch (y0.tag) {
          case "XI": {
            r0 = lt;
            x0 = x0.arg0;
            y0 = y0.arg0;
            continue;
          }

          case "XO": {
            x0 = x0.arg0;
            y0 = y0.arg0;
            continue;
          }

          case "XH": {
            return gt;
          }

          default: {
            return y0 satisfies never;
          }
        }
      }

      case "XH": {
        switch (y0.tag) {
          case "XH": {
            return r0;
          }

          default: {
            return lt;
          }
        }
      }

      default: {
        return x0 satisfies never;
      }
    }
  }
};

const Pos$compare = (x: Positive, x0: Positive): Comparison =>
  Pos$compareCont(eq, x, x0);

const Pos$eqb = (p: Positive, q: Positive): Bool => {
  let p0 = p;
  let q0 = q;

  for (;;) {
    switch (p0.tag) {
      case "XI": {
        switch (q0.tag) {
          case "XI": {
            p0 = p0.arg0;
            q0 = q0.arg0;
            continue;
          }

          default: {
            return false0;
          }
        }
      }

      case "XO": {
        switch (q0.tag) {
          case "XO": {
            p0 = p0.arg0;
            q0 = q0.arg0;
            continue;
          }

          default: {
            return false0;
          }
        }
      }

      case "XH": {
        switch (q0.tag) {
          case "XH": {
            return true0;
          }

          default: {
            return false0;
          }
        }
      }

      default: {
        return p0 satisfies never;
      }
    }
  }
};

const Pos$leb = (x: Positive, y: Positive): Bool => {
  const s0: Comparison = Pos$compare(x, y);

  switch (s0.tag) {
    case "Gt": {
      return false0;
    }

    default: {
      return true0;
    }
  }
};

const Pos$sqrtremStep = (
  f: (_: Positive) => Positive,
  g: (_: Positive) => Positive,
  p: Prod<Positive, PosMask>
): Prod<Positive, PosMask> => {
  switch (p.arg1.tag) {
    case "IsPos": {
      const sʹ: Positive = xI(xO(p.arg0));
      const rʹ: Positive = g(f(p.arg1.arg0));
      const s0: Bool = Pos$leb(sʹ, rʹ);

      switch (s0.tag) {
        case "True": {
          return pair<Positive, PosMask>(xI(p.arg0), Pos$subMask(rʹ, sʹ));
        }

        case "False": {
          return pair<Positive, PosMask>(xO(p.arg0), Pos$isPos(rʹ));
        }

        default: {
          return s0 satisfies never;
        }
      }
    }

    default: {
      return pair<Positive, PosMask>(
        xO(p.arg0),
        Pos$subMask(g(f(xH)), xO(xO(xH)))
      );
    }
  }
};

const Pos$sqrtrem = (p: Positive): Prod<Positive, PosMask> => {
  const frames: [number][] = [];
  let depth = 0;
  let p0 = p;

  for (;;) {
    let returned: Prod<Positive, PosMask>;
    const p1 = p0;

    switch (p1.tag) {
      case "XI": {
        const s0: Positive = p1.arg0;

        switch (s0.tag) {
          case "XI": {
            __writeCell(frames, depth, 0);
            depth += 1;
            p0 = s0.arg0;
            continue;
          }

          case "XO": {
            __writeCell(frames, depth, 1);
            depth += 1;
            p0 = s0.arg0;
            continue;
          }

          case "XH": {
            returned = pair<Positive, PosMask>(xH, Pos$isPos(xO(xH)));
            break;
          }

          default: {
            returned = s0 satisfies never;
          }
        }

        break;
      }

      case "XO": {
        const s0: Positive = p1.arg0;

        switch (s0.tag) {
          case "XI": {
            __writeCell(frames, depth, 2);
            depth += 1;
            p0 = s0.arg0;
            continue;
          }

          case "XO": {
            __writeCell(frames, depth, 3);
            depth += 1;
            p0 = s0.arg0;
            continue;
          }

          case "XH": {
            returned = pair<Positive, PosMask>(xH, Pos$isPos(xH));
            break;
          }

          default: {
            returned = s0 satisfies never;
          }
        }

        break;
      }

      case "XH": {
        returned = pair<Positive, PosMask>(xH, Pos$isNul);
        break;
      }

      default: {
        returned = p1 satisfies never;
      }
    }

    for (;;) {
      if (depth === 0) {
        return returned;
      }

      depth -= 1;

      switch (__readCell(frames, depth)) {
        case 0: {
          const v = returned;
          returned = Pos$sqrtremStep(
            (x: Positive): Positive => xI(x),
            (x: Positive): Positive => xI(x),
            v
          );
          break;
        }

        case 1: {
          const v = returned;
          returned = Pos$sqrtremStep(
            (x: Positive): Positive => xO(x),
            (x: Positive): Positive => xI(x),
            v
          );
          break;
        }

        case 2: {
          const v = returned;
          returned = Pos$sqrtremStep(
            (x: Positive): Positive => xI(x),
            (x: Positive): Positive => xO(x),
            v
          );
          break;
        }

        default: {
          const v = returned;
          returned = Pos$sqrtremStep(
            (x: Positive): Positive => xO(x),
            (x: Positive): Positive => xO(x),
            v
          );
        }
      }
    }
  }
};

const Pos$sqrt = (p: Positive): Positive => fst(Pos$sqrtrem(p));

const Pos$nsuccDouble = (x: N): N => {
  switch (x.tag) {
    case "N0": {
      return npos(xH);
    }

    case "Npos": {
      return npos(xI(x.arg0));
    }

    default: {
      return x satisfies never;
    }
  }
};

const Pos$ndouble = (n: N): N => {
  switch (n.tag) {
    case "N0": {
      return n0;
    }

    case "Npos": {
      return npos(xO(n.arg0));
    }

    default: {
      return n satisfies never;
    }
  }
};

const Pos$lor = (p: Positive, q: Positive): Positive => {
  const frames: [number][] = [];
  let depth = 0;
  let p0 = p;
  let q0 = q;

  for (;;) {
    let returned: Positive;

    switch (p0.tag) {
      case "XI": {
        switch (q0.tag) {
          case "XI": {
            __writeCell(frames, depth, 0);
            depth += 1;
            p0 = p0.arg0;
            q0 = q0.arg0;
            continue;
          }

          case "XO": {
            __writeCell(frames, depth, 0);
            depth += 1;
            p0 = p0.arg0;
            q0 = q0.arg0;
            continue;
          }

          case "XH": {
            returned = p0;
            break;
          }

          default: {
            returned = q0 satisfies never;
          }
        }

        break;
      }

      case "XO": {
        switch (q0.tag) {
          case "XI": {
            __writeCell(frames, depth, 0);
            depth += 1;
            p0 = p0.arg0;
            q0 = q0.arg0;
            continue;
          }

          case "XO": {
            __writeCell(frames, depth, 1);
            depth += 1;
            p0 = p0.arg0;
            q0 = q0.arg0;
            continue;
          }

          case "XH": {
            returned = xI(p0.arg0);
            break;
          }

          default: {
            returned = q0 satisfies never;
          }
        }

        break;
      }

      case "XH": {
        returned = q0.tag === "XO" ? xI(q0.arg0) : q0;
        break;
      }

      default: {
        returned = p0 satisfies never;
      }
    }

    for (;;) {
      if (depth === 0) {
        return returned;
      }

      depth -= 1;

      switch (__readCell(frames, depth)) {
        case 0: {
          returned = xI(returned);
          break;
        }

        default: {
          returned = xO(returned);
        }
      }
    }
  }
};

const Pos$land = (p: Positive, q: Positive): N => {
  const frames: [number][] = [];
  let depth = 0;
  let p0 = p;
  let q0 = q;

  for (;;) {
    let returned: N;

    switch (p0.tag) {
      case "XI": {
        switch (q0.tag) {
          case "XI": {
            __writeCell(frames, depth, 0);
            depth += 1;
            p0 = p0.arg0;
            q0 = q0.arg0;
            continue;
          }

          case "XO": {
            __writeCell(frames, depth, 1);
            depth += 1;
            p0 = p0.arg0;
            q0 = q0.arg0;
            continue;
          }

          case "XH": {
            returned = npos(xH);
            break;
          }

          default: {
            returned = q0 satisfies never;
          }
        }

        break;
      }

      case "XO": {
        switch (q0.tag) {
          case "XI": {
            __writeCell(frames, depth, 1);
            depth += 1;
            p0 = p0.arg0;
            q0 = q0.arg0;
            continue;
          }

          case "XO": {
            __writeCell(frames, depth, 1);
            depth += 1;
            p0 = p0.arg0;
            q0 = q0.arg0;
            continue;
          }

          case "XH": {
            returned = n0;
            break;
          }

          default: {
            returned = q0 satisfies never;
          }
        }

        break;
      }

      case "XH": {
        returned = q0.tag === "XO" ? n0 : npos(xH);
        break;
      }

      default: {
        returned = p0 satisfies never;
      }
    }

    for (;;) {
      if (depth === 0) {
        return returned;
      }

      depth -= 1;

      switch (__readCell(frames, depth)) {
        case 0: {
          returned = Pos$nsuccDouble(returned);
          break;
        }

        default: {
          returned = Pos$ndouble(returned);
        }
      }
    }
  }
};

const Pos$ldiff = (p: Positive, q: Positive): N => {
  const frames: [number][] = [];
  let depth = 0;
  let p0 = p;
  let q0 = q;

  for (;;) {
    let returned: N;

    switch (p0.tag) {
      case "XI": {
        switch (q0.tag) {
          case "XI": {
            __writeCell(frames, depth, 0);
            depth += 1;
            p0 = p0.arg0;
            q0 = q0.arg0;
            continue;
          }

          case "XO": {
            __writeCell(frames, depth, 1);
            depth += 1;
            p0 = p0.arg0;
            q0 = q0.arg0;
            continue;
          }

          case "XH": {
            returned = npos(xO(p0.arg0));
            break;
          }

          default: {
            returned = q0 satisfies never;
          }
        }

        break;
      }

      case "XO": {
        switch (q0.tag) {
          case "XI": {
            __writeCell(frames, depth, 0);
            depth += 1;
            p0 = p0.arg0;
            q0 = q0.arg0;
            continue;
          }

          case "XO": {
            __writeCell(frames, depth, 0);
            depth += 1;
            p0 = p0.arg0;
            q0 = q0.arg0;
            continue;
          }

          case "XH": {
            returned = npos(p0);
            break;
          }

          default: {
            returned = q0 satisfies never;
          }
        }

        break;
      }

      case "XH": {
        returned = q0.tag === "XO" ? npos(xH) : n0;
        break;
      }

      default: {
        returned = p0 satisfies never;
      }
    }

    for (;;) {
      if (depth === 0) {
        return returned;
      }

      depth -= 1;

      switch (__readCell(frames, depth)) {
        case 0: {
          returned = Pos$ndouble(returned);
          break;
        }

        default: {
          returned = Pos$nsuccDouble(returned);
        }
      }
    }
  }
};

const Pos$lxor = (p: Positive, q: Positive): N => {
  const frames: [number][] = [];
  let depth = 0;
  let p0 = p;
  let q0 = q;

  for (;;) {
    let returned: N;

    switch (p0.tag) {
      case "XI": {
        switch (q0.tag) {
          case "XI": {
            __writeCell(frames, depth, 0);
            depth += 1;
            p0 = p0.arg0;
            q0 = q0.arg0;
            continue;
          }

          case "XO": {
            __writeCell(frames, depth, 1);
            depth += 1;
            p0 = p0.arg0;
            q0 = q0.arg0;
            continue;
          }

          case "XH": {
            returned = npos(xO(p0.arg0));
            break;
          }

          default: {
            returned = q0 satisfies never;
          }
        }

        break;
      }

      case "XO": {
        switch (q0.tag) {
          case "XI": {
            __writeCell(frames, depth, 1);
            depth += 1;
            p0 = p0.arg0;
            q0 = q0.arg0;
            continue;
          }

          case "XO": {
            __writeCell(frames, depth, 0);
            depth += 1;
            p0 = p0.arg0;
            q0 = q0.arg0;
            continue;
          }

          case "XH": {
            returned = npos(xI(p0.arg0));
            break;
          }

          default: {
            returned = q0 satisfies never;
          }
        }

        break;
      }

      case "XH": {
        switch (q0.tag) {
          case "XI": {
            returned = npos(xO(q0.arg0));
            break;
          }

          case "XO": {
            returned = npos(xI(q0.arg0));
            break;
          }

          case "XH": {
            returned = n0;
            break;
          }

          default: {
            returned = q0 satisfies never;
          }
        }

        break;
      }

      default: {
        returned = p0 satisfies never;
      }
    }

    for (;;) {
      if (depth === 0) {
        return returned;
      }

      depth -= 1;

      switch (__readCell(frames, depth)) {
        case 0: {
          returned = Pos$ndouble(returned);
          break;
        }

        default: {
          returned = Pos$nsuccDouble(returned);
        }
      }
    }
  }
};

const Pos$iterOp = <A>(op: (_: A) => (_: A) => A, p: Positive, a: A): A => {
  const saved: [A][] = [];
  let top = 0;
  let p0 = p;
  let a0 = a;

  for (;;) {
    let returned: A;

    switch (p0.tag) {
      case "XI": {
        __writeCell(saved, top, a0);
        top += 1;
        p0 = p0.arg0;
        a0 = op(a0)(a0);
        continue;
      }

      case "XO": {
        p0 = p0.arg0;
        a0 = op(a0)(a0);
        continue;
      }

      case "XH": {
        returned = a0;
        break;
      }

      default: {
        returned = p0 satisfies never;
      }
    }

    for (;;) {
      if (top === 0) {
        return returned;
      }

      top -= 1;
      const a00: A = __readCell(saved, top);
      returned = op(a00)(returned);
    }
  }
};

const Pos$toNat = (x: Positive): Nat =>
  Pos$iterOp(
    (x0: Nat) =>
      (x1: Nat): Nat =>
        add(x0, x1),
    x,
    s(o)
  );

const Pos$ofSuccNat = (n: Nat): Positive => {
  let depth = 0;
  let n1 = n;

  for (;;) {
    let returned: Positive;

    switch (n1.tag) {
      case "O": {
        returned = xH;
        break;
      }

      case "S": {
        depth += 1;
        n1 = n1.arg0;
        continue;
      }

      default: {
        returned = n1 satisfies never;
      }
    }

    for (;;) {
      if (depth === 0) {
        return returned;
      }

      depth -= 1;
      returned = Pos$succ(returned);
    }
  }
};

const N1$succDouble = (x: N): N => {
  switch (x.tag) {
    case "N0": {
      return npos(xH);
    }

    case "Npos": {
      return npos(xI(x.arg0));
    }

    default: {
      return x satisfies never;
    }
  }
};

const N1$double0 = (n: N): N => {
  switch (n.tag) {
    case "N0": {
      return n0;
    }

    case "Npos": {
      return npos(xO(n.arg0));
    }

    default: {
      return n satisfies never;
    }
  }
};

const N1$succPos = (n: N): Positive => {
  switch (n.tag) {
    case "N0": {
      return xH;
    }

    case "Npos": {
      return Pos$succ(n.arg0);
    }

    default: {
      return n satisfies never;
    }
  }
};

const N1$sub = (n: N, m: N): N => {
  switch (n.tag) {
    case "N0": {
      return n0;
    }

    case "Npos": {
      switch (m.tag) {
        case "N0": {
          return n;
        }

        case "Npos": {
          const s0: PosMask = Pos$subMask(n.arg0, m.arg0);

          switch (s0.tag) {
            case "IsPos": {
              return npos(s0.arg0);
            }

            default: {
              return n0;
            }
          }
        }

        default: {
          return m satisfies never;
        }
      }
    }

    default: {
      return n satisfies never;
    }
  }
};

const N1$compare = (n: N, m: N): Comparison => {
  switch (n.tag) {
    case "N0": {
      switch (m.tag) {
        case "N0": {
          return eq;
        }

        case "Npos": {
          return lt;
        }

        default: {
          return m satisfies never;
        }
      }
    }

    case "Npos": {
      switch (m.tag) {
        case "N0": {
          return gt;
        }

        case "Npos": {
          return Pos$compare(n.arg0, m.arg0);
        }

        default: {
          return m satisfies never;
        }
      }
    }

    default: {
      return n satisfies never;
    }
  }
};

const N1$leb = (x: N, y: N): Bool => {
  const s0: Comparison = N1$compare(x, y);

  switch (s0.tag) {
    case "Gt": {
      return false0;
    }

    default: {
      return true0;
    }
  }
};

const N1$posDivEucl = (a: Positive, b: N): Prod<N, N> => {
  const frames: [number][] = [];
  let depth = 0;
  let a0 = a;

  for (;;) {
    let returned: Prod<N, N>;

    switch (a0.tag) {
      case "XI": {
        __writeCell(frames, depth, 0);
        depth += 1;
        a0 = a0.arg0;
        continue;
      }

      case "XO": {
        __writeCell(frames, depth, 1);
        depth += 1;
        a0 = a0.arg0;
        continue;
      }

      case "XH": {
        switch (b.tag) {
          case "N0": {
            returned = pair<N, N>(n0, npos(xH));
            break;
          }

          case "Npos": {
            returned =
              b.arg0.tag === "XH"
                ? pair<N, N>(npos(xH), n0)
                : pair<N, N>(n0, npos(xH));
            break;
          }

          default: {
            returned = b satisfies never;
          }
        }

        break;
      }

      default: {
        returned = a0 satisfies never;
      }
    }

    for (;;) {
      if (depth === 0) {
        return returned;
      }

      depth -= 1;

      switch (__readCell(frames, depth)) {
        case 0: {
          const rʹ: N = N1$succDouble(returned.arg1);
          const s0: Bool = N1$leb(b, rʹ);
          returned =
            s0.tag === "True"
              ? pair(N1$succDouble(returned.arg0), N1$sub(rʹ, b))
              : pair(N1$double0(returned.arg0), rʹ);
          break;
        }

        default: {
          const rʹ: N = N1$double0(returned.arg1);
          const s0: Bool = N1$leb(b, rʹ);
          returned =
            s0.tag === "True"
              ? pair(N1$succDouble(returned.arg0), N1$sub(rʹ, b))
              : pair(N1$double0(returned.arg0), rʹ);
        }
      }
    }
  }
};

const N1$lor = (n: N, m: N): N => {
  switch (n.tag) {
    case "N0": {
      return m;
    }

    case "Npos": {
      switch (m.tag) {
        case "N0": {
          return n;
        }

        case "Npos": {
          return npos(Pos$lor(n.arg0, m.arg0));
        }

        default: {
          return m satisfies never;
        }
      }
    }

    default: {
      return n satisfies never;
    }
  }
};

const N1$land = (n: N, m: N): N => {
  switch (n.tag) {
    case "N0": {
      return n0;
    }

    case "Npos": {
      switch (m.tag) {
        case "N0": {
          return n0;
        }

        case "Npos": {
          return Pos$land(n.arg0, m.arg0);
        }

        default: {
          return m satisfies never;
        }
      }
    }

    default: {
      return n satisfies never;
    }
  }
};

const N1$ldiff = (n: N, m: N): N => {
  switch (n.tag) {
    case "N0": {
      return n0;
    }

    case "Npos": {
      switch (m.tag) {
        case "N0": {
          return n;
        }

        case "Npos": {
          return Pos$ldiff(n.arg0, m.arg0);
        }

        default: {
          return m satisfies never;
        }
      }
    }

    default: {
      return n satisfies never;
    }
  }
};

const N1$lxor = (n: N, m: N): N => {
  switch (n.tag) {
    case "N0": {
      return m;
    }

    case "Npos": {
      switch (m.tag) {
        case "N0": {
          return n;
        }

        case "Npos": {
          return Pos$lxor(n.arg0, m.arg0);
        }

        default: {
          return m satisfies never;
        }
      }
    }

    default: {
      return n satisfies never;
    }
  }
};

const Z1$double0 = (x: Z): Z => {
  switch (x.tag) {
    case "Z0": {
      return z0;
    }

    case "Zpos": {
      return zpos(xO(x.arg0));
    }

    case "Zneg": {
      return zneg(xO(x.arg0));
    }

    default: {
      return x satisfies never;
    }
  }
};

const Z1$succDouble = (x: Z): Z => {
  switch (x.tag) {
    case "Z0": {
      return zpos(xH);
    }

    case "Zpos": {
      return zpos(xI(x.arg0));
    }

    case "Zneg": {
      return zneg(Pos$predDouble(x.arg0));
    }

    default: {
      return x satisfies never;
    }
  }
};

const Z1$predDouble = (x: Z): Z => {
  switch (x.tag) {
    case "Z0": {
      return zneg(xH);
    }

    case "Zpos": {
      return zpos(Pos$predDouble(x.arg0));
    }

    case "Zneg": {
      return zneg(xI(x.arg0));
    }

    default: {
      return x satisfies never;
    }
  }
};

const Z1$posSub = (x: Positive, y: Positive): Z => {
  const frames: [number][] = [];
  let depth = 0;
  let x0 = x;
  let y0 = y;

  for (;;) {
    let returned: Z;

    switch (x0.tag) {
      case "XI": {
        switch (y0.tag) {
          case "XI": {
            __writeCell(frames, depth, 0);
            depth += 1;
            x0 = x0.arg0;
            y0 = y0.arg0;
            continue;
          }

          case "XO": {
            __writeCell(frames, depth, 1);
            depth += 1;
            x0 = x0.arg0;
            y0 = y0.arg0;
            continue;
          }

          case "XH": {
            returned = zpos(xO(x0.arg0));
            break;
          }

          default: {
            returned = y0 satisfies never;
          }
        }

        break;
      }

      case "XO": {
        switch (y0.tag) {
          case "XI": {
            __writeCell(frames, depth, 2);
            depth += 1;
            x0 = x0.arg0;
            y0 = y0.arg0;
            continue;
          }

          case "XO": {
            __writeCell(frames, depth, 0);
            depth += 1;
            x0 = x0.arg0;
            y0 = y0.arg0;
            continue;
          }

          case "XH": {
            returned = zpos(Pos$predDouble(x0.arg0));
            break;
          }

          default: {
            returned = y0 satisfies never;
          }
        }

        break;
      }

      case "XH": {
        switch (y0.tag) {
          case "XI": {
            returned = zneg(xO(y0.arg0));
            break;
          }

          case "XO": {
            returned = zneg(Pos$predDouble(y0.arg0));
            break;
          }

          case "XH": {
            returned = z0;
            break;
          }

          default: {
            returned = y0 satisfies never;
          }
        }

        break;
      }

      default: {
        returned = x0 satisfies never;
      }
    }

    for (;;) {
      if (depth === 0) {
        return returned;
      }

      depth -= 1;

      switch (__readCell(frames, depth)) {
        case 0: {
          returned = Z1$double0(returned);
          break;
        }

        case 1: {
          returned = Z1$succDouble(returned);
          break;
        }

        default: {
          returned = Z1$predDouble(returned);
        }
      }
    }
  }
};

const Z1$add = (x: Z, y: Z): Z => {
  switch (x.tag) {
    case "Z0": {
      return y;
    }

    case "Zpos": {
      switch (y.tag) {
        case "Z0": {
          return x;
        }

        case "Zpos": {
          return zpos(Pos$add(x.arg0, y.arg0));
        }

        case "Zneg": {
          return Z1$posSub(x.arg0, y.arg0);
        }

        default: {
          return y satisfies never;
        }
      }
    }

    case "Zneg": {
      switch (y.tag) {
        case "Z0": {
          return x;
        }

        case "Zpos": {
          return Z1$posSub(y.arg0, x.arg0);
        }

        case "Zneg": {
          return zneg(Pos$add(x.arg0, y.arg0));
        }

        default: {
          return y satisfies never;
        }
      }
    }

    default: {
      return x satisfies never;
    }
  }
};

const Z1$opp = (x: Z): Z => {
  switch (x.tag) {
    case "Z0": {
      return z0;
    }

    case "Zpos": {
      return zneg(x.arg0);
    }

    case "Zneg": {
      return zpos(x.arg0);
    }

    default: {
      return x satisfies never;
    }
  }
};

const Z1$sub = (m: Z, n: Z): Z => Z1$add(m, Z1$opp(n));

const Z1$mul = (x: Z, y: Z): Z => {
  switch (x.tag) {
    case "Z0": {
      return z0;
    }

    case "Zpos": {
      switch (y.tag) {
        case "Z0": {
          return z0;
        }

        case "Zpos": {
          return zpos(Pos$mul(x.arg0, y.arg0));
        }

        case "Zneg": {
          return zneg(Pos$mul(x.arg0, y.arg0));
        }

        default: {
          return y satisfies never;
        }
      }
    }

    case "Zneg": {
      switch (y.tag) {
        case "Z0": {
          return z0;
        }

        case "Zpos": {
          return zneg(Pos$mul(x.arg0, y.arg0));
        }

        case "Zneg": {
          return zpos(Pos$mul(x.arg0, y.arg0));
        }

        default: {
          return y satisfies never;
        }
      }
    }

    default: {
      return x satisfies never;
    }
  }
};

const Z1$powPos = (z: Z, x: Positive): Z =>
  Pos$iter((x0: Z): Z => Z1$mul(z, x0), zpos(xH), x);

const Z1$pow = (x: Z, y: Z): Z => {
  switch (y.tag) {
    case "Z0": {
      return zpos(xH);
    }

    case "Zpos": {
      return Z1$powPos(x, y.arg0);
    }

    case "Zneg": {
      return z0;
    }

    default: {
      return y satisfies never;
    }
  }
};

const Z1$compare = (x: Z, y: Z): Comparison => {
  switch (x.tag) {
    case "Z0": {
      switch (y.tag) {
        case "Z0": {
          return eq;
        }

        case "Zpos": {
          return lt;
        }

        case "Zneg": {
          return gt;
        }

        default: {
          return y satisfies never;
        }
      }
    }

    case "Zpos": {
      switch (y.tag) {
        case "Zpos": {
          return Pos$compare(x.arg0, y.arg0);
        }

        default: {
          return gt;
        }
      }
    }

    case "Zneg": {
      switch (y.tag) {
        case "Zneg": {
          return compOpp(Pos$compare(x.arg0, y.arg0));
        }

        default: {
          return lt;
        }
      }
    }

    default: {
      return x satisfies never;
    }
  }
};

const Z1$leb = (x: Z, y: Z): Bool => {
  const s0: Comparison = Z1$compare(x, y);

  switch (s0.tag) {
    case "Gt": {
      return false0;
    }

    default: {
      return true0;
    }
  }
};

const Z1$ltb = (x: Z, y: Z): Bool => {
  const s0: Comparison = Z1$compare(x, y);

  switch (s0.tag) {
    case "Lt": {
      return true0;
    }

    default: {
      return false0;
    }
  }
};

const Z1$eqb = (x: Z, y: Z): Bool => {
  switch (x.tag) {
    case "Z0": {
      switch (y.tag) {
        case "Z0": {
          return true0;
        }

        default: {
          return false0;
        }
      }
    }

    case "Zpos": {
      switch (y.tag) {
        case "Zpos": {
          return Pos$eqb(x.arg0, y.arg0);
        }

        default: {
          return false0;
        }
      }
    }

    case "Zneg": {
      switch (y.tag) {
        case "Zneg": {
          return Pos$eqb(x.arg0, y.arg0);
        }

        default: {
          return false0;
        }
      }
    }

    default: {
      return x satisfies never;
    }
  }
};

const Z1$max = (n: Z, m: Z): Z => {
  const s0: Comparison = Z1$compare(n, m);

  switch (s0.tag) {
    case "Lt": {
      return m;
    }

    default: {
      return n;
    }
  }
};

const Z1$min = (n: Z, m: Z): Z => {
  const s0: Comparison = Z1$compare(n, m);

  switch (s0.tag) {
    case "Gt": {
      return m;
    }

    default: {
      return n;
    }
  }
};

const Z1$toNat = (z: Z): Nat => {
  switch (z.tag) {
    case "Zpos": {
      return Pos$toNat(z.arg0);
    }

    default: {
      return o;
    }
  }
};

const Z1$ofNat = (n: Nat): Z => {
  switch (n.tag) {
    case "O": {
      return z0;
    }

    case "S": {
      return zpos(Pos$ofSuccNat(n.arg0));
    }

    default: {
      return n satisfies never;
    }
  }
};

const Z1$ofN = (n: N): Z => {
  switch (n.tag) {
    case "N0": {
      return z0;
    }

    case "Npos": {
      return zpos(n.arg0);
    }

    default: {
      return n satisfies never;
    }
  }
};

const Z1$toPos = (z: Z): Positive => {
  switch (z.tag) {
    case "Zpos": {
      return z.arg0;
    }

    default: {
      return xH;
    }
  }
};

const Z1$posDivEucl = (a: Positive, b: Z): Prod<Z, Z> => {
  const frames: [number][] = [];
  let depth = 0;
  let a0 = a;

  for (;;) {
    let returned: Prod<Z, Z>;

    switch (a0.tag) {
      case "XI": {
        __writeCell(frames, depth, 0);
        depth += 1;
        a0 = a0.arg0;
        continue;
      }

      case "XO": {
        __writeCell(frames, depth, 1);
        depth += 1;
        a0 = a0.arg0;
        continue;
      }

      case "XH": {
        const s0: Bool = Z1$leb(zpos(xO(xH)), b);
        returned =
          s0.tag === "True"
            ? pair<Z, Z>(z0, zpos(xH))
            : pair<Z, Z>(zpos(xH), z0);
        break;
      }

      default: {
        returned = a0 satisfies never;
      }
    }

    for (;;) {
      if (depth === 0) {
        return returned;
      }

      depth -= 1;

      switch (__readCell(frames, depth)) {
        case 0: {
          const rʹ: Z = Z1$add(Z1$mul(zpos(xO(xH)), returned.arg1), zpos(xH));
          const s0: Bool = Z1$ltb(rʹ, b);
          returned =
            s0.tag === "True"
              ? pair(Z1$mul(zpos(xO(xH)), returned.arg0), rʹ)
              : pair(
                  Z1$add(Z1$mul(zpos(xO(xH)), returned.arg0), zpos(xH)),
                  Z1$sub(rʹ, b)
                );
          break;
        }

        default: {
          const rʹ: Z = Z1$mul(zpos(xO(xH)), returned.arg1);
          const s0: Bool = Z1$ltb(rʹ, b);
          returned =
            s0.tag === "True"
              ? pair(Z1$mul(zpos(xO(xH)), returned.arg0), rʹ)
              : pair(
                  Z1$add(Z1$mul(zpos(xO(xH)), returned.arg0), zpos(xH)),
                  Z1$sub(rʹ, b)
                );
        }
      }
    }
  }
};

const Z1$divEucl = (a: Z, b: Z): Prod<Z, Z> => {
  switch (a.tag) {
    case "Z0": {
      return pair<Z, Z>(z0, z0);
    }

    case "Zpos": {
      switch (b.tag) {
        case "Z0": {
          return pair<Z, Z>(z0, a);
        }

        case "Zpos": {
          return Z1$posDivEucl(a.arg0, b);
        }

        case "Zneg": {
          const s0: Prod<Z, Z> = Z1$posDivEucl(a.arg0, zpos(b.arg0));

          switch (s0.arg1.tag) {
            case "Z0": {
              return pair<Z, Z>(Z1$opp(s0.arg0), z0);
            }

            default: {
              return pair(
                Z1$opp(Z1$add(s0.arg0, zpos(xH))),
                Z1$add(b, s0.arg1)
              );
            }
          }
        }

        default: {
          return b satisfies never;
        }
      }
    }

    case "Zneg": {
      switch (b.tag) {
        case "Z0": {
          return pair<Z, Z>(z0, a);
        }

        case "Zpos": {
          const s0: Prod<Z, Z> = Z1$posDivEucl(a.arg0, b);

          switch (s0.arg1.tag) {
            case "Z0": {
              return pair<Z, Z>(Z1$opp(s0.arg0), z0);
            }

            default: {
              return pair(
                Z1$opp(Z1$add(s0.arg0, zpos(xH))),
                Z1$sub(b, s0.arg1)
              );
            }
          }
        }

        case "Zneg": {
          const s0: Prod<Z, Z> = Z1$posDivEucl(a.arg0, zpos(b.arg0));

          return pair(s0.arg0, Z1$opp(s0.arg1));
        }

        default: {
          return b satisfies never;
        }
      }
    }

    default: {
      return a satisfies never;
    }
  }
};

const Z1$div = (a: Z, b: Z): Z => {
  const s0: Prod<Z, Z> = Z1$divEucl(a, b);

  return s0.arg0;
};

const Z1$modulo = (a: Z, b: Z): Z => {
  const s0: Prod<Z, Z> = Z1$divEucl(a, b);

  return s0.arg1;
};

const Z1$quotrem = (a: Z, b: Z): Prod<Z, Z> => {
  switch (a.tag) {
    case "Z0": {
      return pair<Z, Z>(z0, z0);
    }

    case "Zpos": {
      switch (b.tag) {
        case "Z0": {
          return pair<Z, Z>(z0, a);
        }

        case "Zpos": {
          const s0: Prod<N, N> = N1$posDivEucl(a.arg0, npos(b.arg0));

          return pair(Z1$ofN(s0.arg0), Z1$ofN(s0.arg1));
        }

        case "Zneg": {
          const s0: Prod<N, N> = N1$posDivEucl(a.arg0, npos(b.arg0));

          return pair(Z1$opp(Z1$ofN(s0.arg0)), Z1$ofN(s0.arg1));
        }

        default: {
          return b satisfies never;
        }
      }
    }

    case "Zneg": {
      switch (b.tag) {
        case "Z0": {
          return pair<Z, Z>(z0, a);
        }

        case "Zpos": {
          const s0: Prod<N, N> = N1$posDivEucl(a.arg0, npos(b.arg0));

          return pair(Z1$opp(Z1$ofN(s0.arg0)), Z1$opp(Z1$ofN(s0.arg1)));
        }

        case "Zneg": {
          const s0: Prod<N, N> = N1$posDivEucl(a.arg0, npos(b.arg0));

          return pair(Z1$ofN(s0.arg0), Z1$opp(Z1$ofN(s0.arg1)));
        }

        default: {
          return b satisfies never;
        }
      }
    }

    default: {
      return a satisfies never;
    }
  }
};

const Z1$quot = (a: Z, b: Z): Z => fst(Z1$quotrem(a, b));
const Z1$rem = (a: Z, b: Z): Z => snd(Z1$quotrem(a, b));

const Z1$even = (z: Z): Bool => {
  switch (z.tag) {
    case "Z0": {
      return true0;
    }

    case "Zpos": {
      switch (z.arg0.tag) {
        case "XO": {
          return true0;
        }

        default: {
          return false0;
        }
      }
    }

    case "Zneg": {
      switch (z.arg0.tag) {
        case "XO": {
          return true0;
        }

        default: {
          return false0;
        }
      }
    }

    default: {
      return z satisfies never;
    }
  }
};

const Z1$div2 = (z: Z): Z => {
  switch (z.tag) {
    case "Z0": {
      return z0;
    }

    case "Zpos": {
      switch (z.arg0.tag) {
        case "XH": {
          return z0;
        }

        default: {
          return zpos(Pos$div2(z.arg0));
        }
      }
    }

    case "Zneg": {
      return zneg(Pos$div2Up(z.arg0));
    }

    default: {
      return z satisfies never;
    }
  }
};

const Z1$sqrtrem = (n: Z): Prod<Z, Z> => {
  switch (n.tag) {
    case "Zpos": {
      const s0: Prod<Positive, PosMask> = Pos$sqrtrem(n.arg0);

      switch (s0.arg1.tag) {
        case "IsPos": {
          return pair<Z, Z>(zpos(s0.arg0), zpos(s0.arg1.arg0));
        }

        default: {
          return pair<Z, Z>(zpos(s0.arg0), z0);
        }
      }
    }

    default: {
      return pair<Z, Z>(z0, z0);
    }
  }
};

const Z1$shiftl = (a: Z, n: Z): Z => {
  switch (n.tag) {
    case "Z0": {
      return a;
    }

    case "Zpos": {
      return Pos$iter((x: Z): Z => Z1$mul(zpos(xO(xH)), x), a, n.arg0);
    }

    case "Zneg": {
      return Pos$iter(Z1$div2, a, n.arg0);
    }

    default: {
      return n satisfies never;
    }
  }
};

const Z1$shiftr = (a: Z, n: Z): Z => Z1$shiftl(a, Z1$opp(n));

const Z1$lor = (a: Z, b: Z): Z => {
  switch (a.tag) {
    case "Z0": {
      return b;
    }

    case "Zpos": {
      switch (b.tag) {
        case "Z0": {
          return a;
        }

        case "Zpos": {
          return zpos(Pos$lor(a.arg0, b.arg0));
        }

        case "Zneg": {
          return zneg(N1$succPos(N1$ldiff(Pos$predN(b.arg0), npos(a.arg0))));
        }

        default: {
          return b satisfies never;
        }
      }
    }

    case "Zneg": {
      switch (b.tag) {
        case "Z0": {
          return a;
        }

        case "Zpos": {
          return zneg(N1$succPos(N1$ldiff(Pos$predN(a.arg0), npos(b.arg0))));
        }

        case "Zneg": {
          return zneg(
            N1$succPos(N1$land(Pos$predN(a.arg0), Pos$predN(b.arg0)))
          );
        }

        default: {
          return b satisfies never;
        }
      }
    }

    default: {
      return a satisfies never;
    }
  }
};

const Z1$land = (a: Z, b: Z): Z => {
  switch (a.tag) {
    case "Z0": {
      return z0;
    }

    case "Zpos": {
      switch (b.tag) {
        case "Z0": {
          return z0;
        }

        case "Zpos": {
          return Z1$ofN(Pos$land(a.arg0, b.arg0));
        }

        case "Zneg": {
          return Z1$ofN(N1$ldiff(npos(a.arg0), Pos$predN(b.arg0)));
        }

        default: {
          return b satisfies never;
        }
      }
    }

    case "Zneg": {
      switch (b.tag) {
        case "Z0": {
          return z0;
        }

        case "Zpos": {
          return Z1$ofN(N1$ldiff(npos(b.arg0), Pos$predN(a.arg0)));
        }

        case "Zneg": {
          return zneg(N1$succPos(N1$lor(Pos$predN(a.arg0), Pos$predN(b.arg0))));
        }

        default: {
          return b satisfies never;
        }
      }
    }

    default: {
      return a satisfies never;
    }
  }
};

const Z1$lxor = (a: Z, b: Z): Z => {
  switch (a.tag) {
    case "Z0": {
      return b;
    }

    case "Zpos": {
      switch (b.tag) {
        case "Z0": {
          return a;
        }

        case "Zpos": {
          return Z1$ofN(Pos$lxor(a.arg0, b.arg0));
        }

        case "Zneg": {
          return zneg(N1$succPos(N1$lxor(npos(a.arg0), Pos$predN(b.arg0))));
        }

        default: {
          return b satisfies never;
        }
      }
    }

    case "Zneg": {
      switch (b.tag) {
        case "Z0": {
          return a;
        }

        case "Zpos": {
          return zneg(N1$succPos(N1$lxor(Pos$predN(a.arg0), npos(b.arg0))));
        }

        case "Zneg": {
          return Z1$ofN(N1$lxor(Pos$predN(a.arg0), Pos$predN(b.arg0)));
        }

        default: {
          return b satisfies never;
        }
      }
    }

    default: {
      return a satisfies never;
    }
  }
};

const Ops$posSucc = (x: Positive): Positive => Pos$succ(x);
const Ops$posAdd = (x: Positive, x0: Positive): Positive => Pos$add(x, x0);

const Ops$posAddCarry = (x: Positive, x0: Positive): Positive =>
  Pos$addCarry(x, x0);

const Ops$posPredDouble = (x: Positive): Positive => Pos$predDouble(x);
const Ops$posPredN = (x: Positive): N => Pos$predN(x);
const Ops$posSub = (x: Positive, x0: Positive): Positive => Pos$sub(x, x0);
const Ops$posMul = (x: Positive, x0: Positive): Positive => Pos$mul(x, x0);
const Ops$posDiv2 = (x: Positive): Positive => Pos$div2(x);
const Ops$posDiv2Up = (x: Positive): Positive => Pos$div2Up(x);

const Ops$posCompareCont = (
  x: Comparison,
  x0: Positive,
  x1: Positive
): Comparison => Pos$compareCont(x, x0, x1);

const Ops$posCompare = (x: Positive, x0: Positive): Comparison =>
  Pos$compare(x, x0);

const Ops$posEqb = (x: Positive, x0: Positive): Bool => Pos$eqb(x, x0);
const Ops$posLeb = (x: Positive, x0: Positive): Bool => Pos$leb(x, x0);
const Ops$posSqrt = (x: Positive): Positive => Pos$sqrt(x);
const Ops$posNsuccDouble = (x: N): N => Pos$nsuccDouble(x);
const Ops$posNdouble = (x: N): N => Pos$ndouble(x);
const Ops$posLor = (x: Positive, x0: Positive): Positive => Pos$lor(x, x0);
const Ops$posLand = (x: Positive, x0: Positive): N => Pos$land(x, x0);
const Ops$posLdiff = (x: Positive, x0: Positive): N => Pos$ldiff(x, x0);
const Ops$posLxor = (x: Positive, x0: Positive): N => Pos$lxor(x, x0);
const Ops$posToNat = (x: Positive): Nat => Pos$toNat(x);
const Ops$posOfSuccNat = (x: Nat): Positive => Pos$ofSuccNat(x);
const Ops$nSuccDouble = (x: N): N => N1$succDouble(x);
const Ops$nDouble = (x: N): N => N1$double0(x);
const Ops$nSuccPos = (x: N): Positive => N1$succPos(x);
const Ops$nSub = (x: N, x0: N): N => N1$sub(x, x0);
const Ops$nCompare = (x: N, x0: N): Comparison => N1$compare(x, x0);
const Ops$nLeb = (x: N, x0: N): Bool => N1$leb(x, x0);

const Ops$nPosDivEucl = (x: Positive, x0: N): Prod<N, N> =>
  N1$posDivEucl(x, x0);

const Ops$nLor = (x: N, x0: N): N => N1$lor(x, x0);
const Ops$nLand = (x: N, x0: N): N => N1$land(x, x0);
const Ops$nLdiff = (x: N, x0: N): N => N1$ldiff(x, x0);
const Ops$nLxor = (x: N, x0: N): N => N1$lxor(x, x0);
const Ops$zDouble = (x: Z): Z => Z1$double0(x);
const Ops$zSuccDouble = (x: Z): Z => Z1$succDouble(x);
const Ops$zPredDouble = (x: Z): Z => Z1$predDouble(x);
const Ops$zPosSub = (x: Positive, x0: Positive): Z => Z1$posSub(x, x0);
const Ops$zAdd = (x: Z, x0: Z): Z => Z1$add(x, x0);
const Ops$zOpp = (x: Z): Z => Z1$opp(x);
const Ops$zSub = (x: Z, x0: Z): Z => Z1$sub(x, x0);
const Ops$zMul = (x: Z, x0: Z): Z => Z1$mul(x, x0);
const Ops$zPowPos = (x: Z, x0: Positive): Z => Z1$powPos(x, x0);
const Ops$zPow = (x: Z, x0: Z): Z => Z1$pow(x, x0);
const Ops$zCompare = (x: Z, x0: Z): Comparison => Z1$compare(x, x0);
const Ops$zLeb = (x: Z, x0: Z): Bool => Z1$leb(x, x0);
const Ops$zLtb = (x: Z, x0: Z): Bool => Z1$ltb(x, x0);
const Ops$zEqb = (x: Z, x0: Z): Bool => Z1$eqb(x, x0);
const Ops$zMax = (x: Z, x0: Z): Z => Z1$max(x, x0);
const Ops$zMin = (x: Z, x0: Z): Z => Z1$min(x, x0);
const Ops$zToNat = (x: Z): Nat => Z1$toNat(x);
const Ops$zOfNat = (x: Nat): Z => Z1$ofNat(x);
const Ops$zOfN = (x: N): Z => Z1$ofN(x);
const Ops$zToPos = (x: Z): Positive => Z1$toPos(x);

const Ops$zPosDivEucl = (x: Positive, x0: Z): Prod<Z, Z> =>
  Z1$posDivEucl(x, x0);

const Ops$zDivEucl = (x: Z, x0: Z): Prod<Z, Z> => Z1$divEucl(x, x0);
const Ops$zDiv = (x: Z, x0: Z): Z => Z1$div(x, x0);
const Ops$zModulo = (x: Z, x0: Z): Z => Z1$modulo(x, x0);
const Ops$zQuotrem = (x: Z, x0: Z): Prod<Z, Z> => Z1$quotrem(x, x0);
const Ops$zQuot = (x: Z, x0: Z): Z => Z1$quot(x, x0);
const Ops$zRem = (x: Z, x0: Z): Z => Z1$rem(x, x0);
const Ops$zEven = (x: Z): Bool => Z1$even(x);
const Ops$zDiv2 = (x: Z): Z => Z1$div2(x);
const Ops$zSqrtrem = (x: Z): Prod<Z, Z> => Z1$sqrtrem(x);
const Ops$zShiftl = (x: Z, x0: Z): Z => Z1$shiftl(x, x0);
const Ops$zShiftr = (x: Z, x0: Z): Z => Z1$shiftr(x, x0);
const Ops$zLor = (x: Z, x0: Z): Z => Z1$lor(x, x0);
const Ops$zLand = (x: Z, x0: Z): Z => Z1$land(x, x0);
const Ops$zLxor = (x: Z, x0: Z): Z => Z1$lxor(x, x0);

export const Ops = {
  nCompare: Ops$nCompare,
  nDouble: Ops$nDouble,
  nLand: Ops$nLand,
  nLdiff: Ops$nLdiff,
  nLeb: Ops$nLeb,
  nLor: Ops$nLor,
  nLxor: Ops$nLxor,
  nPosDivEucl: Ops$nPosDivEucl,
  nSub: Ops$nSub,
  nSuccDouble: Ops$nSuccDouble,
  nSuccPos: Ops$nSuccPos,
  posAdd: Ops$posAdd,
  posAddCarry: Ops$posAddCarry,
  posCompare: Ops$posCompare,
  posCompareCont: Ops$posCompareCont,
  posDiv2: Ops$posDiv2,
  posDiv2Up: Ops$posDiv2Up,
  posEqb: Ops$posEqb,
  posLand: Ops$posLand,
  posLdiff: Ops$posLdiff,
  posLeb: Ops$posLeb,
  posLor: Ops$posLor,
  posLxor: Ops$posLxor,
  posMul: Ops$posMul,
  posNdouble: Ops$posNdouble,
  posNsuccDouble: Ops$posNsuccDouble,
  posOfSuccNat: Ops$posOfSuccNat,
  posPredDouble: Ops$posPredDouble,
  posPredN: Ops$posPredN,
  posSqrt: Ops$posSqrt,
  posSub: Ops$posSub,
  posSucc: Ops$posSucc,
  posToNat: Ops$posToNat,
  zAdd: Ops$zAdd,
  zCompare: Ops$zCompare,
  zDiv: Ops$zDiv,
  zDiv2: Ops$zDiv2,
  zDivEucl: Ops$zDivEucl,
  zDouble: Ops$zDouble,
  zEqb: Ops$zEqb,
  zEven: Ops$zEven,
  zLand: Ops$zLand,
  zLeb: Ops$zLeb,
  zLor: Ops$zLor,
  zLtb: Ops$zLtb,
  zLxor: Ops$zLxor,
  zMax: Ops$zMax,
  zMin: Ops$zMin,
  zModulo: Ops$zModulo,
  zMul: Ops$zMul,
  zOfN: Ops$zOfN,
  zOfNat: Ops$zOfNat,
  zOpp: Ops$zOpp,
  zPosDivEucl: Ops$zPosDivEucl,
  zPosSub: Ops$zPosSub,
  zPow: Ops$zPow,
  zPowPos: Ops$zPowPos,
  zPredDouble: Ops$zPredDouble,
  zQuot: Ops$zQuot,
  zQuotrem: Ops$zQuotrem,
  zRem: Ops$zRem,
  zShiftl: Ops$zShiftl,
  zShiftr: Ops$zShiftr,
  zSqrtrem: Ops$zSqrtrem,
  zSub: Ops$zSub,
  zSuccDouble: Ops$zSuccDouble,
  zToNat: Ops$zToNat,
  zToPos: Ops$zToPos,
} as const;
