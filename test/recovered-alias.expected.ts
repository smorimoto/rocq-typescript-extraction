const __fail = (message: string): never => {
  throw new Error(message);
};

const __coerces = <From, To>(_value: From): _value is From & To => true;

const __magic = <From, To>(value: From): To =>
  __coerces<From, To>(value) ? value : __fail("unreachable cast");

const s = (n: number): number => n + 1;

export interface PayloadsMissing {
  readonly tag: "Missing";
}

export interface PayloadsItem {
  readonly tag: "Item";
  readonly value: number;
}

export type PayloadsItemValue = PayloadsMissing | PayloadsItem;

const Payloads$missing: PayloadsMissing = { tag: "Missing" };

const Payloads$item = (value: number): PayloadsItemValue => ({
  tag: "Item",
  value,
});

const Payloads$itemValueRect = <A>(
  missing: A,
  item: (_: number) => A,
  i: PayloadsItemValue
): A => {
  switch (i.tag) {
    case "Missing": {
      return missing;
    }

    case "Item": {
      return item(i.value);
    }

    default: {
      return i satisfies never;
    }
  }
};

const Payloads$itemValueRec = <A>(
  missing: A,
  item: (_: number) => A,
  i: PayloadsItemValue
): A => {
  switch (i.tag) {
    case "Missing": {
      return missing;
    }

    case "Item": {
      return item(i.value);
    }

    default: {
      return i satisfies never;
    }
  }
};

export type PayloadsItem0 = PayloadsItemValue;

const Payloads$witness: PayloadsItemValue = Payloads$item(
  s(s(s(s(s(s(s(s(s(s(s(0)))))))))))
);

export interface PayloadsPrimary {
  readonly tag: "Primary";
}

export interface PayloadsSecondary {
  readonly tag: "Secondary";
}

export type PayloadsChoice = PayloadsPrimary | PayloadsSecondary;

const Payloads$primary: PayloadsPrimary = { tag: "Primary" };
const Payloads$secondary: PayloadsSecondary = { tag: "Secondary" };

const Payloads$choiceRect = <A>(
  primary: A,
  secondary: A,
  c: PayloadsChoice
): A => {
  switch (c.tag) {
    case "Primary": {
      return primary;
    }

    case "Secondary": {
      return secondary;
    }

    default: {
      return c satisfies never;
    }
  }
};

const Payloads$choiceRec = <A>(
  primary: A,
  secondary: A,
  c: PayloadsChoice
): A => {
  switch (c.tag) {
    case "Primary": {
      return primary;
    }

    case "Secondary": {
      return secondary;
    }

    default: {
      return c satisfies never;
    }
  }
};

export type PayloadsPayload<C extends PayloadsChoice> =
  C extends PayloadsPrimary ? PayloadsItem0 : boolean;

export const Payloads = {
  choiceRec: Payloads$choiceRec,
  choiceRect: Payloads$choiceRect,
  item: Payloads$item,
  itemValueRec: Payloads$itemValueRec,
  itemValueRect: Payloads$itemValueRect,
  missing: Payloads$missing,
  primary: Payloads$primary,
  secondary: Payloads$secondary,
  witness: Payloads$witness,
} as const;

export interface PAYLOAD<Item> {
  readonly witness: Item;
}

export interface CONTAINER<AliasItem> {
  readonly Alias: PAYLOAD<AliasItem>;
}

export interface ReadResult<AliasItem> {
  readonly get0: AliasItem;
}

export const Read = <AliasItem>(
  C: CONTAINER<AliasItem>
): ReadResult<AliasItem> => {
  const get0: AliasItem = C.Alias.witness;

  return { get0 };
};

const Container$choose = <B extends boolean>(
  b: B
): B extends true ? PayloadsItemValue : boolean =>
  b
    ? __magic<PayloadsItemValue, B extends true ? PayloadsItemValue : boolean>(
        Payloads$item(s(s(s(s(s(s(s(0))))))))
      )
    : __magic<boolean, B extends true ? PayloadsItemValue : boolean>(false);

const Container$select = <C extends PayloadsChoice>(
  c: C
): PayloadsPayload<C> => {
  switch (c.tag) {
    case "Primary": {
      return __magic<PayloadsItemValue, PayloadsPayload<C>>(
        Payloads$item(s(s(s(s(s(s(s(0))))))))
      );
    }

    case "Secondary": {
      return __magic<boolean, PayloadsPayload<C>>(false);
    }

    default: {
      return c satisfies never;
    }
  }
};

export const Container = {
  Alias: Payloads,
  choose: Container$choose,
  select: Container$select,
} as const;

export const Applied = Read<PayloadsItemValue>(Container);
