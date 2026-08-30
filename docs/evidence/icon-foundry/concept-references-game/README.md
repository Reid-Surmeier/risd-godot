# Game concept references

Real pixel-art icons from shipped games, taken from pret decompilation repositories —
the same provenance route the motion references use. Nothing here was drawn or
synthesised; the only processing was keying out the flat backdrop on twelve of them so
the subject reads on its own.

**Subject matter only, never style.** These say *what a thing is* — what a desk, a glass
ornament, a sea map, a fossil, a coin case actually look like as drawn objects. Style
comes from Reid's five originals and nothing else.

## Why these were added

Forty-one icons generated against a single generic style strip came back looking like one
family — "too AI looking", and all in the same blue-and-marble range. Two causes:

1. **No subject reference.** The model had a text description and a generic style, and
   nothing concrete of the right subject. A funnel described in words becomes a generic
   isometric funnel.
2. **No colour range to draw on.** The five originals are mostly blue and marble because
   of what those five depict. Used as the only reference, everything inherits that.

This pool carries **236 distinct subject colours** — mossy greens, parchment tan, amber,
terracotta, brass, pink — none of which existed in the earlier reference material.

## Sources

| Source | What it gives |
| --- | --- |
| `pret/pokeemerald` `graphics/decorations` | furniture, glass ornament, plants, figures on stands, a plinth |
| `pret/pokeemerald` `graphics/items/icons` | coin case, sea map, scope, letter, fossils, pouch |
| `pret/pokefirered` `graphics/items/icons` | a second GBA palette — cooler, higher contrast: amber, fossils, town map |

## Owner corrections applied

- **DEP-11 Coins & medals** was matched to Crystal's `money` — cash and banknotes. Reid
  called that insensitive and he is right: the icon means a numismatics collection, not
  currency or value. Replaced with Emerald's `coin_case`, which reads as a collection in
  a case.
- **ACT-03 Sketchbook** was matched to Crystal's `knotes` — a sticky note with an
  underline. Removed. Replaced with Crystal's `contents`, an open bound book.
