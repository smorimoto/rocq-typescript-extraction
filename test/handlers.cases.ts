import {
  cons,
  handle,
  handlers,
  idle,
  nil,
  quiet,
  run,
  three,
} from "./handlers.ts";
import type { Handler, List } from "./handlers.ts";
import { print } from "./observe.ts";
import { toArray } from "./support.ts";

console.log("a constant constructor is a value of every instance of its type");

{
  const waiting: Handler<number> = idle;
  const named: Handler<string> = idle;

  const queue: List<Handler<number>> = cons(
    idle,
    cons(
      handle((n: number) => n * 2),
      nil
    )
  );

  print(run(waiting, 3));
  print(run(quiet, 3));
  print({ actual: named, expected: idle });
  print(toArray(queue).map((h) => run(h, 3)));
}

console.log("a match on a handler runs its function");

print(three);

print(toArray(handlers).map((h) => run(h, 2)));
