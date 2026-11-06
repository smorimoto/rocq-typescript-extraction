import { print } from "../observe.ts";
import { array, list, messages, present, success } from "./support.ts";
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

const errors = (result: ReturnType<typeof check>): (string | bigint)[] => {
  if (result.tag !== "Error") {
    throw new Error("Expected the program to be rejected");
  }

  return messages(result.arg0);
};

console.log("typechecking rebuilds annotations from declarations");

{
  const input = C.sreturn(
    C.some(
      C.ebinop(
        C.oadd,
        C.evalof(C.evar(2n, C.tvoid), C.tvoid),
        C.integer(7n),
        C.tvoid
      )
    )
  );

  print({
    actual: bodyOf(check(input)),
    expected: C.sreturn(
      C.some(
        C.ebinop(C.oadd, C.evalof(C.evar(2n, int), int), C.integer(7n), int)
      )
    ),
  });
  print({
    actual: input,
    expected: C.sreturn(
      C.some(
        C.ebinop(
          C.oadd,
          C.evalof(C.evar(2n, C.tvoid), C.tvoid),
          C.integer(7n),
          C.tvoid
        )
      )
    ),
  });
}

console.log(
  "field access, calls and switch cases are retyped across functions"
);

{
  const functionType = C.tfunction(list([int]), int, convention);

  const input = C.ssequence(
    C.sdo(
      C.eassign(
        C.efield(C.evalof(C.evar(4n, C.tvoid), C.tvoid), 12n, C.tvoid),
        C.ecall(
          C.evalof(C.evar(5n, C.tvoid), C.tvoid),
          C.econs(C.integer(8n), C.enil),
          C.tvoid
        ),
        C.tvoid
      )
    ),
    C.sswitch(
      C.evalof(
        C.efield(C.evalof(C.evar(4n, C.tvoid), C.tvoid), 12n, C.tvoid),
        C.tvoid
      ),
      C.lScons(
        C.some(8n),
        C.sreturn(C.some(C.integer(1n))),
        C.lScons(C.none, C.sreturn(C.some(C.integer(0n))), C.lSnil)
      )
    )
  );

  const result = C.checkProgram(
    list([pairDefinition]),
    list([
      [1n, fn(input)],
      [5n, fn(C.sreturn(C.some(C.integer(8n))))],
    ])
  );

  print(array(success(result).progDefs).length);
  print({
    actual: bodyOf(result),
    expected: C.ssequence(
      C.sdo(
        C.eassign(
          C.efield(C.evalof(C.evar(4n, pair), pair), 12n, int),
          C.ecall(
            C.evalof(C.evar(5n, functionType), functionType),
            C.econs(C.integer(8n), C.enil),
            int
          ),
          int
        )
      ),
      C.sswitch(
        C.evalof(C.efield(C.evalof(C.evar(4n, pair), pair), 12n, int), int),
        C.lScons(
          C.some(8n),
          C.sreturn(C.some(C.integer(1n))),
          C.lScons(C.none, C.sreturn(C.some(C.integer(0n))), C.lSnil)
        )
      )
    ),
  });
}

console.log("nested errors retain function and identifier context");

{
  const invalid = C.sdo(C.evalof(C.evar(999n, C.tvoid), C.tvoid));
  const result = check(C.swhile(C.integer(1n), C.ssequence(C.sskip, invalid)));
  print(errors(result));
  const pointer = C.eaddrof(C.evar(2n, C.tvoid), C.tvoid);
  print(errors(check(C.sdo(C.ebinop(C.oadd, pointer, pointer, C.tvoid)))));
}

console.log("composite layouts respect x86-64 alignment and nested arrays");

{
  const members = list([
    C.memberPlain(21n, C.tint0(C.i8, C.unsigned, attrs)),
    C.memberPlain(22n, C.tpointer(int, attrs)),
    C.memberPlain(23n, C.tarray(pair, 3n, attrs)),
  ]);

  const env = success(
    C.buildCompositeEnv(
      list([
        pairDefinition,
        C.composite(20n, C.struct, members, attrs),
        C.composite(30n, C.union, members, attrs),
      ])
    )
  );

  const structure = present(C.PTree.get0(20n, env));
  const union = present(C.PTree.get0(30n, env));
  print([structure.coSizeof, structure.coAlignof]);
  print([union.coSizeof, union.coAlignof]);
  print({
    actual: array(success(C.layoutStruct(env, members))),
    expected: [
      [[23n, 16n], C.full],
      [[22n, 8n], C.full],
      [[21n, 0n], C.full],
    ],
  });
}

console.log(
  "composite construction rejects duplicates and incomplete by-value members"
);

{
  const duplicate = C.buildCompositeEnv(list([pairDefinition, pairDefinition]));

  if (duplicate.tag !== "Error") {
    throw new Error("Expected duplicate composite rejection");
  }

  print(messages(duplicate.arg0));

  const incomplete = C.buildCompositeEnv(
    list([C.composite(20n, C.struct, list([C.memberPlain(21n, pair)]), attrs)])
  );

  if (incomplete.tag !== "Error") {
    throw new Error("Expected incomplete composite rejection");
  }

  print(messages(incomplete.arg0));
}
