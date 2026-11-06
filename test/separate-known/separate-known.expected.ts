import * as $Origin from "./origin.ts";

const { origin } = $Origin;
export const fromOrigin: number = origin.tag === "Dot" ? 0 : origin.n;
export const fromDot = 0;
