From TypeScriptExtraction Require Import Number.
Set Warnings "+typescript-extraction-unchecked-casts".
From Mentions Require Import Points Boxes.

Definition seen (o : outline) : outline := hold o.
Definition via (n : nat) : wrap nat := sample n.
Definition text (s : label) : label := labelled s.
Definition of_origin (k : kind) : kind := named k.
Definition unioned (e : either) : either := sided e.
Definition collided (c : collide) : collide := crashed c.
Definition rekeyed (k : keyed) : keyed := keyed_id k.
Definition refields (k : fields) : fields := fields_id k.
Definition repicked (p : picked) : picked := picked_id p.

TypeScript Separate Extraction
  seen via text of_origin unioned collided rekeyed refields repicked.
