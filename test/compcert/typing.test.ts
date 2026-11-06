import { expect, test } from "bun:test";

import { array, list, present, success } from "./support.ts";
import * as C from "./typing.ts";

const attrs: C.Attr = { attrAlignas: C.none, attrVolatile: false };

const convention: C.CallingConvention = {
  ccStructret: false,
  ccUnproto: false,
  ccVararg: C.none,
};

const int = C.tint0(C.i32, C.signed, attrs);

const pair = C.tstruct(10n, attrs);

const pairDefinition = C.composite(
  10n,
  C.struct,
  list([C.memberPlain(11n, int), C.memberPlain(12n, int)]),
  attrs
);

const fn = (body: C.Statement): C.Function0 => ({
  fnBody: body,
  fnCallconv: convention,
  fnParams: list([[2n, int]]),
  fnReturn: int,
  fnVars: list([[4n, pair]]),
});

const check = (body: C.Statement) =>
  C.checkProgram(list([pairDefinition]), list([[1n, fn(body)]]));

const bodyOf = (result: ReturnType<typeof check>): C.Statement => {
  const [entry] = array(success(result).progDefs);

  if (entry === undefined) {
    throw new Error("Expected a definition in the checked program");
  }

  const [, definition] = entry;

  if (definition.tag !== "Gfun" || definition.f.tag !== "Internal") {
    throw new Error("Expected an internal function in the checked program");
  }

  return definition.f.arg0.fnBody;
};

test("deep expressions and sequences do not consume the JavaScript call stack", () => {
  const depth = 20_000;
  let expr = C.integer(0n);
  let body: C.Statement = C.sreturn(C.some(C.integer(0n)));

  for (let i = 0; i < depth; i += 1) {
    expr = C.ebinop(C.oadd, expr, C.integer(1n), C.tvoid);
    body = C.ssequence(C.sskip, body);
  }

  let checked = bodyOf(check(C.ssequence(C.sdo(expr), body)));

  if (checked.tag !== "Ssequence" || checked.arg0.tag !== "Sdo") {
    throw new Error("Expected the checked expression and sequence");
  }

  let cursor = checked.arg0.arg0;
  let expressions = 0;
  let wrongTypes = 0;

  while (cursor.tag === "Ebinop") {
    if (cursor.ty.tag !== "Tint0") {
      wrongTypes += 1;
    }

    expressions += 1;
    cursor = cursor.r1;
  }

  expect(expressions).toBe(depth);
  expect(wrongTypes).toBe(0);
  expect<C.Expr>(cursor).toEqual(C.integer(0n));
  checked = checked.arg1;
  let sequences = 0;

  while (checked.tag === "Ssequence") {
    sequences += 1;
    checked = checked.arg1;
  }

  expect(sequences).toBe(depth);
  expect<C.Statement>(checked).toEqual(C.sreturn(C.some(C.integer(0n))));
});

test("deep mutual recursion between expressions and argument lists uses no call stack", () => {
  const depth = 20_000;
  const callee = C.evalof(C.evar(1n, C.tvoid), C.tvoid);
  let expr = C.integer(9n);

  for (let i = 0; i < depth; i += 1) {
    expr = C.ecall(callee, C.econs(expr, C.enil), C.tvoid);
  }

  const body = bodyOf(check(C.sreturn(C.some(expr))));

  if (body.tag !== "Sreturn") {
    throw new Error("Expected a return statement");
  }

  let cursor = present(body.arg0);
  let calls = 0;

  while (cursor.tag === "Ecall" && cursor.rargs.tag === "Econs") {
    calls += 1;
    cursor = cursor.rargs.r1;
  }

  expect(calls).toBe(depth);
  expect(cursor).toEqual(C.integer(9n));
});
