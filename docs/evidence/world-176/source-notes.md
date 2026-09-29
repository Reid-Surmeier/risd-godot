# Final-review correction #176 — source comparison

The current final review is retained in build commit25efc30d. This candidate is not selected yet.

Sources already recorded with provenance: `image-work/grand-gallery-v2/source/arch-outside.png`, `wide-north-bench.png`, and the Site Specific gallery-2456 photograph in `image-work/floor-168-board-v2/references/`. These establish visible proportions, not surveyed dimensions.

- Portal photograph shows blockwork extending beyond the outer shafts and broad stone footings. Previous source has backing courses but most are concealed behind the shafts. Widen the existing backing courses/base and outer impost, preserving the clear opening and carved shaft/capital geometry. Separate course joints remain narrow.
- The closer gallery-2456 view shows a thick rounded cushion, a substantial supporting rail and four turned supports along each long side. Increase the cushion side depth and rail section, and replace the four square legs with eight tapered supports and small collars per bench. Keep footprints/navigation envelopes unchanged.
- Both gallery photographs visibly show high dark ventilation slots, fine vertical panel seams and small neutral artwork-label plates. Add those features to the existing walls/painting nodes. Exact label wording is unresolved in the photographs; plates carry no invented museum text. Source proportions/positions are approximate within the existing room.

Reuse existing materials and native geometry. No paid generation or new texture imagery. Accepted floor, skylight and painting/frame geometry remain unchanged. Full rebake and independent native/browser review required before selection.

## Second candidate diagnosis

The sidewall UV used the same U coordinate for all vertices of each quad, stretching one texture column. Side vertices now advance U across each segment. The top crown used the bounding rectangle distance at rounded corners, raising those corners above the straight rim; a shared rounded-rectangle distance now keeps the rim level and gives it an elliptical roll. Twelve side samples replace four. The private geometry check asserts rim parity and nonzero side UV span.

The wall joint boxes protruded only millimetres and aliased into dashes. The long walls now use contiguous coplanar panels with narrow, low-contrast joint strips; there is no overlapping raised strip. Portal backing courses touch instead of leaving open six-millimetre gaps. These are rendering corrections, not claimed museum measurements. Captions remain unresolved blank plates in this candidate.

## Third candidate portal joins

The frieze relief skin stood 2mm in front of its block and had open horizontal edges. Those edges are now closed into the backing. The capital bottom used a squared cross-section above a round shaft; its lower fifth now blends from the shaft circle into the carved profile. Two shallow, filled shaft joints and shaped individual low bases follow features visible in arch-outside.png; dimensions are approximate, not a survey. The source topology check still reports zero reversed triangles and zero relief winding failures. Bench and wall source geometry is unchanged from their passing second-candidate reviews.
