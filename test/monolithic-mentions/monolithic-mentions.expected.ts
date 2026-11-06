export interface Point {
  readonly px: number;
  readonly py: number;
}

const origin: Point = { px: 0, py: 0 };
const wrap = <A>(a: A, p: Point): readonly [A, Point] => [a, p];

export type Outline =
  /* Point */
  readonly Point[];

export type Fields = { [K in "px" | "py"]: Point };

export const sample = (n: number): readonly [number, Point] => wrap(n, origin);
export const hold = (o: Outline): Outline => o;
export const labelled = (s0: "Point"): "Point" => s0;
export const named = (k: typeof origin): typeof origin => k;
export const sided = (e: Point | Point): Point | Point => e;
export const fieldsId = (k: Fields): Fields => k;
