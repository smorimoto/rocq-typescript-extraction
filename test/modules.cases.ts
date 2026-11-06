import { Areas, Geometry, Ten, total } from "./modules.ts";
import type { GeometryFigure, GeometryUnitsBox } from "./modules.ts";
import { print } from "./observe.ts";
import { ofNumber, toNumber } from "./support.ts";

console.log(
  "a module is an object of its values, and its types are named after it"
);

{
  const c: GeometryFigure = Geometry.circle(ofNumber(3));
  const scaled = Geometry.scale(ofNumber(2), c);
  print(scaled);

  const side = Geometry.figureRect(
    (r) => r,
    () => ofNumber(0),
    Geometry.square(ofNumber(4))
  );

  print(toNumber(side));
}

console.log("a nested module and its record type");

{
  const b: GeometryUnitsBox = Geometry.Units.unitBox;
  print(toNumber(Geometry.Units.width(b)));
  print(toNumber(Geometry.Units.height(b)));
}

console.log("a module that refers to another module");

print(toNumber(Areas.side(Areas.doubled)));

print(toNumber(Areas.boxArea({ height: ofNumber(4), width: ofNumber(3) })));

console.log(
  "a module with a signature, and a top-level value using every module"
);

print(toNumber(Ten.size));

print(toNumber(total));
