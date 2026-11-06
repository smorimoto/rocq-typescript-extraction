import * as $Boxes from "./boxes.ts";
import * as $Datatypes from "./datatypes.ts";

const { s } = $Datatypes;
export const filled = (n: number): number => $Boxes.Box.full(n);

export const contents = (b: number): number =>
  $Boxes.Box.matchBox(
    (): number => $Boxes.Box.zero,
    (n: number): number => n,
    b
  );

export const bigger = (b: number): number => $Boxes.Box.full(s(contents(b)));
