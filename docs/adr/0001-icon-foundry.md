# ADR 0001: Icons are generated, reduced, and certified — never drawn by code

Status: accepted
Date: 2026-08-30

## Context

The game needs fifty icons, each in four interaction states, in the idiom of five that Reid drew by hand: 64 pixels, a cobalt-marble-gold grammar, hard stair-stepped edges, one hard light from the upper left.

Drawing fifty by hand is weeks. Generating them is minutes, but no diffusion model draws a pixel-exact 64-pixel icon: it draws a picture *of* one, at whatever resolution it likes, in however many colours it likes.

## Decision

Three stages, and each may only do its own job.

1. **Generation.** Qwen draws the still; Seedance performs the states. Models make every pixel. No procedurally drawn icon art, ever.
2. **Reduction.** Deterministic code snaps to the 64 grid with NEAREST, locks the palette taken from the Anchor with no dithering, and reassembles at held cadence. This is the only code permitted to touch generated pixels, and it may only *reduce* — never invent.
3. **Certification.** A conformed run is measured against its Anchor. Uncertified output is evidence, kept as evidence. It never ships.

The still is approved by a person looking at it at magnification beside the five originals. That approved still becomes the **Anchor**, and nothing animates before its Anchor exists.

## Consequences

**The still brief stops asking for pixel art.** At 1024 pixels the generated candidates look far too smooth to be sprites — near-photographic faces, pixel steps a fraction of the originals'. That looked like failure and is not: reduction turns all four candidates into genuine 64-pixel icons in 13 colours. So the brief asks for a well-drawn icon in the right palette, light and proportion, and lets reduction make the pixels. That is a cheaper thing to ask for and a more reliable one.

**Certification has to compare against the Anchor, not only against itself.** A run whose frames are stable relative to each other can still have drifted into a different picture — and in practice the drifted states were the *steadiest*. Measured on two takes: states a person accepted scored 0.955 and 0.979 against the Anchor; states a person rejected scored 0.466 and 0.529.

**An Anchor may not sit on an opaque background.** If it does, the shape being measured is that rectangle, and every state certifies no matter what it drew. Caught on the first take, where all four states passed and two were visibly wrong.

**Cost is knowable in advance.** Video calls are priced strictly by duration and size — seventeen four-second calls all cost $0.05432 exactly, and a twelve-second call cost 3.0x that. One Asset Pass of four candidates is $0.163. A first-try icon is about $0.33 all in.

## Alternatives rejected

**Prompt for pixel art and ship the output.** Produces fake pixel art: soft edges, hundreds of colours, no grid. Cannot meet "exact to these".

**Use the model as a sketch engine and draw the final pixels by hand.** Honest and highest quality, but fifty icons is weeks of work, which is the problem this exists to solve.

**Draw the icons procedurally.** Ruled out by the owner. It would also produce a set that looks like code wrote it, which is the one thing the hand-drawn five prove matters.
