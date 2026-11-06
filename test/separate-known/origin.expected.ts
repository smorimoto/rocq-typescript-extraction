export interface Dot {
  readonly tag: "Dot";
}

export interface Line {
  readonly tag: "Line";
  readonly n: number;
}

export type Figure = Dot | Line;

export const dot: Dot = { tag: "Dot" };
export const line = (n: number): Figure => ({ n, tag: "Line" });
export const origin: Figure = dot;
