# Owner corrections — September 28 evening

Owner screenshots reject the isolated architecture preview. This is not acceptance of Portal14. The delivered diagnostic scene intentionally hid the visitor; future owner build must use the complete app with its selected character and retained layout.

1. Camera: `_update_camera` forced all view modes to a 58-degree close follow camera near the arch. Source repair restricts the recess constraint to the already-selected original follow mode; cutaway modes keep their FOV and use gallery layers in the arch. Private source regression and navigation pass. Final runtime visual movement remains to inspect.
2. Ceiling: source contains skylight glazing, but surface partition classified the low recess roof as an end wall. Flat overhead surfaces now use the ceiling group. This does not yet establish that the owner's skylight complaint is resolved; new ceiling captures are required.
3. Door: `_arch_end` retained stacked box trim while the opposite door had profile extrusions. Reused that existing moulding construction at the arch-side casing, plinth, crown and skirting. Needs baked close-up review.
4. Floor: source Muse texture contains several painted timber bands. Previous UV span crossed their edges inside individual modeled parquet planks, creating apparent overlapping boards. Trial now samples within one band. Geometry/threshold continuity and visual grain repetition remain review items.
5. Bench: one Muse cloth output plus modeled paired tuft depressions, rounded corners/edge and thin open frame. Probe caught reversed side faces; corrected before the room bake. Direct-lit self-review shows texture and tufting, but is not final room or independent acceptance.

No frozen public interface/error/acceptance test was changed. No architecture assets integrated into the build branch. #167 remains open. Prior independent reviewer hit quota without a final verdict; do not invent a pass.

## Self-review follow-up

First room bake showed an over-repeated six-pane skylight texture and tufting lost in coarse lightmap UVs. Corrected grid scale, cloth tint and cushion-specific lightmap density. Camera captures then caught the near wall obscuring the visitor inside the arch; source wall groups now distinguish positive-z recess sides/front/back and select its correct near cutaway. Source capture confirms visible prototype visitor and retained FOV in the recess. This prototype visitor is older than the selected build character and is not an owner handoff. Stopped the superseded second bake through its wrapper (prior files restored) and started a fresh third bake including all fixes.
