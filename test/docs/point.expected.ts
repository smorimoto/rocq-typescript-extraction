export interface Point {
  readonly px: number;
  readonly py: number;
}

export const swap = (p: Point): Point => ({ px: p.py, py: p.px });
