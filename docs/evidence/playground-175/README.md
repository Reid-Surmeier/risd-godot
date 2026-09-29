# Retained Playground readability — #175

Runtime `8c4753f8`. Build code `da232fe7` + `16cd1090` + `8c4753f8`; public interface/errors/frozen acceptance unchanged. Only the Feng Shui browsing child reflows; retained desktop geometry and all other Tabs are preserved.

## Pictures

- Before: [old tiny browsing page](../final-review-162/tabs/playground-explore.png).
- After: [Explore](browser/Page_explore.png), [Search](browser/Page_search.png), [detail](browser/detail.png), [saved item](browser/saved.png), [last item reached by wheel](browser/scroll-end.png).
- [Independent Astra medium image-only verdict](review.md): visible text, Korean glyphs, controls, clipping, detail and retained desktop PASS. Small gray metadata remains soft. Review pictures came from16cd1090; the only subsequent runtime change corrects reported save state, with no drawing/layout change.

## Actual checks

- `scripts/check.sh`, `git diff --check`: PASS. Baseline retains known shutdown ObjectDB warnings; not claimed warning-free.
- Frozen standalone square harness: real page navigation, search and shared RISD save PASS.
- `embedded_check.gd`: reuses those interactions at590×790; validates readable12px minimum logical text scale, Korean coverage, contained detail and correct parent reporting of child save state. PASS. The first fixture accidentally retained1920×1080 window size; it was corrected to explicitly size the child and rerun, not accepted.
- Exported browser: four pages, typed portrait search, open/close detail, real public-block save, wheel to final catalog item and outer page scrollY0 PASS; errors[]. Last visible item is “dear younger me,” catalog ID50672783. The save check initially exposed desktop state shadowing child state, which was fixed. A later assertion also wrongly compared numeric JSON IDs against Godot’s persisted float-form strings; corrected numerical comparison passes without changing existing save IDs. Diagnostic log retained.
- Full-app five-shape containment and real Collection movement: PASS, errors[]. Latest tested game-shown≈24.9s on configured hardware; #141 remains open, no universal performance claim.

## Shared build

https://windows-wsl.taile06c45.ts.net/risd-playground-01a0e95d/

Durable export: `build/playground-8c4753f8`. HTTPS index and game gzip verified. SHA-256 `0e19616a9cba8eb0a360145adf7574d4ac24d1edb6ca655caa7e5b91bb38ef85`.

No paid generation. Existing Liberation Sans plus599KB installed-font Hangul subset, provenance and licence recorded in owning module.

#162 still has gallery findings in #176 and evidence limits; owner’s final integrated approval remains open. This evidence does not close the map.
