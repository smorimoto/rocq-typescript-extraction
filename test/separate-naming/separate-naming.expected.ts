import * as $Forms from "./shapes.ts";

const { sides } = $Forms;
export const corners = (x: $Forms.Polygon): number => sides(x);
