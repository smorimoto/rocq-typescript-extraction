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

const s = (n: number): number => n + 1;

const add: (_0: number, _1: number) => number = (
  n: number,
  m: number
): number => n + m;

export interface Op0 {
  readonly tag: "Op0";
}

export interface Op1 {
  readonly tag: "Op1";
}

export interface Op2 {
  readonly tag: "Op2";
}

export interface Op3 {
  readonly tag: "Op3";
}

export interface Op4 {
  readonly tag: "Op4";
}

export interface Op5 {
  readonly tag: "Op5";
}

export interface Op6 {
  readonly tag: "Op6";
}

export interface Op7 {
  readonly tag: "Op7";
}

export interface Op8 {
  readonly tag: "Op8";
}

export interface Op9 {
  readonly tag: "Op9";
}

export interface Op10 {
  readonly tag: "Op10";
}

export interface Op11 {
  readonly tag: "Op11";
}

export interface Op12 {
  readonly tag: "Op12";
}

export interface Op13 {
  readonly tag: "Op13";
}

export interface Op14 {
  readonly tag: "Op14";
}

export interface Op15 {
  readonly tag: "Op15";
}

export interface Op16 {
  readonly tag: "Op16";
}

export interface Op17 {
  readonly tag: "Op17";
}

export interface Op18 {
  readonly tag: "Op18";
}

export interface Op19 {
  readonly tag: "Op19";
}

export interface Op20 {
  readonly tag: "Op20";
}

export interface Op21 {
  readonly tag: "Op21";
}

export interface Op22 {
  readonly tag: "Op22";
}

export interface Op23 {
  readonly tag: "Op23";
}

export type Opcode =
  | Op0
  | Op1
  | Op2
  | Op3
  | Op4
  | Op5
  | Op6
  | Op7
  | Op8
  | Op9
  | Op10
  | Op11
  | Op12
  | Op13
  | Op14
  | Op15
  | Op16
  | Op17
  | Op18
  | Op19
  | Op20
  | Op21
  | Op22
  | Op23;

export const op0: Op0 = { tag: "Op0" };
export const op1: Op1 = { tag: "Op1" };
export const op2: Op2 = { tag: "Op2" };
export const op3: Op3 = { tag: "Op3" };
export const op4: Op4 = { tag: "Op4" };
export const op5: Op5 = { tag: "Op5" };
export const op6: Op6 = { tag: "Op6" };
export const op7: Op7 = { tag: "Op7" };
export const op8: Op8 = { tag: "Op8" };
export const op9: Op9 = { tag: "Op9" };
export const op10: Op10 = { tag: "Op10" };
export const op11: Op11 = { tag: "Op11" };
export const op12: Op12 = { tag: "Op12" };
export const op13: Op13 = { tag: "Op13" };
export const op14: Op14 = { tag: "Op14" };
export const op15: Op15 = { tag: "Op15" };
export const op16: Op16 = { tag: "Op16" };
export const op17: Op17 = { tag: "Op17" };
export const op18: Op18 = { tag: "Op18" };
export const op19: Op19 = { tag: "Op19" };
export const op20: Op20 = { tag: "Op20" };
export const op21: Op21 = { tag: "Op21" };
export const op22: Op22 = { tag: "Op22" };
export const op23: Op23 = { tag: "Op23" };

export const branchCount = (n: number, op: Opcode): number => {
  const frames: [number][] = [];
  let depth = 0;
  let n0 = n;

  for (;;) {
    let returned: number;

    if (n0 === 0) {
      returned = 0;
    } else {
      const m: number = n0 - 1;

      switch (op.tag) {
        case "Op0": {
          __writeCell(frames, depth, 0);
          depth += 1;
          n0 = m;
          continue;
        }

        case "Op1": {
          __writeCell(frames, depth, 1);
          depth += 1;
          n0 = m;
          continue;
        }

        case "Op2": {
          __writeCell(frames, depth, 2);
          depth += 1;
          n0 = m;
          continue;
        }

        case "Op3": {
          __writeCell(frames, depth, 3);
          depth += 1;
          n0 = m;
          continue;
        }

        case "Op4": {
          __writeCell(frames, depth, 4);
          depth += 1;
          n0 = m;
          continue;
        }

        case "Op5": {
          __writeCell(frames, depth, 5);
          depth += 1;
          n0 = m;
          continue;
        }

        case "Op6": {
          __writeCell(frames, depth, 6);
          depth += 1;
          n0 = m;
          continue;
        }

        case "Op7": {
          __writeCell(frames, depth, 7);
          depth += 1;
          n0 = m;
          continue;
        }

        case "Op8": {
          __writeCell(frames, depth, 8);
          depth += 1;
          n0 = m;
          continue;
        }

        case "Op9": {
          __writeCell(frames, depth, 9);
          depth += 1;
          n0 = m;
          continue;
        }

        case "Op10": {
          __writeCell(frames, depth, 10);
          depth += 1;
          n0 = m;
          continue;
        }

        case "Op11": {
          __writeCell(frames, depth, 11);
          depth += 1;
          n0 = m;
          continue;
        }

        case "Op12": {
          __writeCell(frames, depth, 12);
          depth += 1;
          n0 = m;
          continue;
        }

        case "Op13": {
          __writeCell(frames, depth, 13);
          depth += 1;
          n0 = m;
          continue;
        }

        case "Op14": {
          __writeCell(frames, depth, 14);
          depth += 1;
          n0 = m;
          continue;
        }

        case "Op15": {
          __writeCell(frames, depth, 15);
          depth += 1;
          n0 = m;
          continue;
        }

        case "Op16": {
          __writeCell(frames, depth, 16);
          depth += 1;
          n0 = m;
          continue;
        }

        case "Op17": {
          __writeCell(frames, depth, 17);
          depth += 1;
          n0 = m;
          continue;
        }

        case "Op18": {
          __writeCell(frames, depth, 18);
          depth += 1;
          n0 = m;
          continue;
        }

        case "Op19": {
          __writeCell(frames, depth, 19);
          depth += 1;
          n0 = m;
          continue;
        }

        case "Op20": {
          __writeCell(frames, depth, 20);
          depth += 1;
          n0 = m;
          continue;
        }

        case "Op21": {
          __writeCell(frames, depth, 21);
          depth += 1;
          n0 = m;
          continue;
        }

        case "Op22": {
          __writeCell(frames, depth, 22);
          depth += 1;
          n0 = m;
          continue;
        }

        case "Op23": {
          __writeCell(frames, depth, 23);
          depth += 1;
          n0 = m;
          continue;
        }

        default: {
          returned = op satisfies never;
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
          returned = add(returned, s(0));
          break;
        }

        case 1: {
          returned = add(returned, s(s(0)));
          break;
        }

        case 2: {
          returned = add(returned, s(s(s(0))));
          break;
        }

        case 3: {
          returned = add(returned, s(s(s(s(0)))));
          break;
        }

        case 4: {
          returned = add(returned, s(s(s(s(s(0))))));
          break;
        }

        case 5: {
          returned = add(returned, s(s(s(s(s(s(0)))))));
          break;
        }

        case 6: {
          returned = add(returned, s(s(s(s(s(s(s(0))))))));
          break;
        }

        case 7: {
          returned = add(returned, s(s(s(s(s(s(s(s(0)))))))));
          break;
        }

        case 8: {
          returned = add(returned, s(s(s(s(s(s(s(s(s(0))))))))));
          break;
        }

        case 9: {
          returned = add(returned, s(s(s(s(s(s(s(s(s(s(0)))))))))));
          break;
        }

        case 10: {
          returned = add(returned, s(s(s(s(s(s(s(s(s(s(s(0))))))))))));
          break;
        }

        case 11: {
          returned = add(returned, s(s(s(s(s(s(s(s(s(s(s(s(0)))))))))))));
          break;
        }

        case 12: {
          returned = add(returned, s(s(s(s(s(s(s(s(s(s(s(s(s(0))))))))))))));
          break;
        }

        case 13: {
          returned = add(returned, s(s(s(s(s(s(s(s(s(s(s(s(s(s(0)))))))))))))));
          break;
        }

        case 14: {
          returned = add(
            returned,
            s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(0)))))))))))))))
          );
          break;
        }

        case 15: {
          returned = add(
            returned,
            s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(0))))))))))))))))
          );
          break;
        }

        case 16: {
          returned = add(
            returned,
            s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(0)))))))))))))))))
          );
          break;
        }

        case 17: {
          returned = add(
            returned,
            s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(0))))))))))))))))))
          );
          break;
        }

        case 18: {
          returned = add(
            returned,
            s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(0)))))))))))))))))))
          );
          break;
        }

        case 19: {
          returned = add(
            returned,
            s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(0))))))))))))))))))))
          );
          break;
        }

        case 20: {
          returned = add(
            returned,
            s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(0)))))))))))))))))))))
          );
          break;
        }

        case 21: {
          returned = add(
            returned,
            s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(0))))))))))))))))))))))
          );
          break;
        }

        case 22: {
          returned = add(
            returned,
            s(
              s(
                s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(0)))))))))))))))))))))
              )
            )
          );
          break;
        }

        default: {
          returned = add(
            returned,
            s(
              s(
                s(
                  s(
                    s(
                      s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(s(0)))))))))))))))))))
                    )
                  )
                )
              )
            )
          );
        }
      }
    }
  }
};
