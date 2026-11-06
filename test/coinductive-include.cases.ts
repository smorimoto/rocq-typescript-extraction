import { Driver } from "./coinductive-include.ts";
import type { DriverInterBuffer } from "./coinductive-include.ts";
import { print } from "./observe.ts";

console.log("a functor accepts an included coinductive signature");

{
  const driver = Driver<number>({});

  const tail: DriverInterBuffer<number> = () => ({
    bufHead: 7,
    bufTail: tail,
    tag: "BufCons",
  });

  const buffer = driver.Consumer.prepend(3, tail);

  print(driver.Consumer.head(buffer));
  print(driver.Consumer.head(driver.Inter.bufTail(buffer)));
}
