"""Turn each icon's Form and Tell into an Asset Pass Edit Brief.

The template is the one that produced the approved UI-01 Search Anchor: the five
hand-drawn icons are the sole style authority, the Form becomes a named region's
`change`, and the Tell becomes that region's `preserve` line — which is what made the
Tell survive generation rather than being a sentence nobody acted on.
"""
import json, os, re, sys

INVARIANTS = [
    "Use only the palette present in the reference: the four-step cobalt ramp from pale sky highlight through mid blue to deep navy, the four-step warm white marble ramp from near-white through cream to grey-beige shadow, and the dark navy outline. No colour outside these ramps.",
    "Reproduce the reference's raster character exactly: hard stair-stepped edges, visible square pixels at the diagonals, no anti-aliasing on the silhouette, no smooth vector curve anywhere.",
    "One light source, high and to the upper left, exactly as in all five references: the top-left facets carry a one-to-two pixel bright specular, the lower-right facets carry the darkest step of their ramp.",
    "Keep the same figure-to-tile proportion as the references: the drawn object fills most of the square with a small even margin, and sits on a small soft grey contact shadow at its base.",
    "Keep the reference's three-quarter, slightly-above viewpoint. Objects are seen at an angle, not flat-on.",
    "At most one gold element in the whole icon. Gold marks attention or reward and never colours an object.",
]

NEGATIVES = [
    "No anti-aliased or feathered edges, no soft airbrushed shading, no smooth vector illustration, no modern flat-design treatment, no gradient meshes.",
    "No text, letters, numbers, or lettering of any kind anywhere in the image.",
    "No second icon, no grid of variations, no colour swatches, no background scene, no desk, no hands.",
    "No colour outside the cobalt, marble, gold and navy-outline ramps.",
    "No border, frame, tile, panel, badge, caption or watermark around the icon.",
]

REFERENCE_ROLE = (
    "The reference image is a strip of five finished icons — a blue funnel, a blue flashlight throwing a gold star, "
    "a marble bust on a blue plinth, a framed picture with a check badge, and a marble bust wrapped in blue arrows. "
    "It is the authoritative STYLE source and the only style source: palette, bevel, outline weight, raster character, "
    "lighting direction, three-quarter projection, figure scale within the tile, and the small soft contact shadow. "
    "Where this icon reuses a form the references already contain — the marble bust, the cobalt plinth, the funnel — "
    "the reference is also the authority for that form. Nothing else is taken from it."
)

# The grammar's composition families, so the canvas line matches what the icon is.
FAMILY = {
    "MED": "The icon is a record card or framed picture with a small square badge overlapping its lower-right corner.",
    "DEP": "The icon is a single object standing on a small stepped cobalt plinth, exactly like the bust in reference icon three.",
    "NAV": "One single object centred in the square.",
    "REC": "One single object centred in the square.",
    "ACT": "One single object centred in the square.",
    "UI":  "One single object centred in the square.",
}

def brief_for(icon, seed):
    fam = FAMILY.get(icon["id"].split("-")[0], FAMILY["ACT"])
    return {
        "provider": "openrouter",
        "model": "qwen/qwen-image-3-pro",
        "objective": (
            f"Draw one new interface icon that belongs to the set of five in the reference image, as if drawn by the "
            f"same hand in the same sitting. The icon is called \"{icon['name']}\" and it means: {icon['function'] or icon['name']}. "
            f"Draw exactly this: {icon['form']}"
        ),
        "reference_role": REFERENCE_ROLE,
        "preservation_invariants": INVARIANTS,
        "canvas": [
            "One single icon centred in a square frame on a plain flat white background.",
            "No border, no frame, no tile, no panel, no label, no caption, no number, no watermark.",
            fam,
        ],
        "regions": [
            {
                "name": icon["name"].lower(),
                "change": icon["form"],
                "preserve": [icon["tell"]],
            }
        ],
        "exact_copy": [],
        "negative_constraints": NEGATIVES,
        # Two candidates, not four. Measured 2026-08-30: the upstream refuses at about 300 s
        # with HTTP 524 and OpenRouter bills for it anyway, so a slow call costs money and
        # returns nothing. A four-candidate 1K call sits close to that ceiling — one
        # succeeded at 127 s, the next ran to 300 s and was billed $0.30398 for no image.
        # Halving the work per call moves the whole distribution away from the ceiling, and
        # two delivered candidates beat four that never arrive.
        "output": {"aspect_ratio": "1:1", "count": 2, "resolution": "1K", "seed": seed},
        "_icon": {"id": icon["id"], "name": icon["name"], "tell": icon["tell"]},
    }

if __name__ == "__main__":
    icons = json.load(open(sys.argv[1]))
    outdir = sys.argv[2]
    os.makedirs(outdir, exist_ok=True)
    made = 0
    for i, ic in enumerate(icons):
        if ic["status"] == "rejected":
            continue
        if ic["id"] == "UI-01":
            continue  # its Anchor is approved already
        b = brief_for(ic, 5100 + i * 7)
        slug = ic["id"].lower() + "-" + re.sub(r"[^a-z0-9]+", "-", ic["name"].lower()).strip("-")
        json.dump(b, open(os.path.join(outdir, f"{slug}.json"), "w"), indent=2)
        made += 1
    print(f"wrote {made} Asset Pass briefs to {outdir}")
