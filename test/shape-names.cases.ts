import { print } from "./observe.ts";
import {
  Forms,
  Frame,
  blob,
  empty,
  form,
  formArea,
  formS,
  reform,
  reform0,
  twice,
} from "./shape-names.ts";
import type { Form, FrameT, Holder } from "./shape-names.ts";
import { toArray } from "./support.ts";

console.log("a constructor named with the word keeps it in its tag");

{
  const square: Form = form(3);

  print(square.tag);
  print(formArea(square));
  print(formArea(blob(5)));
  print(toArray(formS).map(formArea));
  print({ actual: Forms.unitSquare, expected: form(1) });
}

console.log("a field, a parameter, and a type parameter named with the word");

{
  const framed: FrameT = { border: 1, form: 4 };
  const none: Holder<number> = empty;

  print(Frame.form(framed));
  print(Frame.inner(framed));
  print(twice(2));
  print(reform(2));
  print(reform0(2));
  print(none.tag);
}
