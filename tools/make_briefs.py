"""Turn each icon's Form and Tell into an Asset Pass Edit Brief.

The template is the one that produced the approved UI-01 Search Anchor: the five
hand-drawn icons are the sole style authority, the Form becomes a named region's
`change`, and the Tell becomes that region's `preserve` line — which is what made the
Tell survive generation rather than being a sentence nobody acted on.
"""
import json, os, re, sys

INVARIANTS = [
    "Reproduce the reference's raster character exactly: hard stair-stepped edges, visible square pixels at the diagonals, no anti-aliasing on the silhouette, no smooth vector curve anywhere.",
    "One light source, high and to the upper left, exactly as in all five references: the top-left facets carry a one-to-two pixel bright specular, the lower-right facets carry the darkest step of their ramp.",
    "Keep the same figure-to-tile proportion as the references: the drawn object fills most of the square with a small even margin, and sits on a small soft grey contact shadow at its base.",
    "Keep the reference's three-quarter, slightly-above viewpoint. Objects are seen at an angle, not flat-on.",
    "Keep the reference's outline treatment: a hard dark outline around every form, one to two pixels, never a soft edge.",
    "Shade every material in a small number of flat steps, four or so, the way the references do — not with smooth gradients. Few colours per material, hard edges between them.",
    "The interface furniture follows the reference's blue: plinths, badges, arrows, tool bodies and controls are the same cobalt as the funnel and the arrows. The object being depicted is not interface furniture and keeps its own true colours.",
]

NEGATIVES = [
    "No anti-aliased or feathered edges, no soft airbrushed shading, no smooth vector illustration, no modern flat-design treatment, no gradient meshes.",
    "No text, letters, numbers, or lettering of any kind anywhere in the image.",
    "No second icon, no grid of variations, no colour swatches, no background scene, no desk, no hands.",
    "No photographic realism and no continuous tone: every material is a handful of flat steps with hard edges between them.",
    "No border, frame, tile, panel, badge, caption or watermark around the icon.",
]

REFERENCE_ROLE = (
    "The reference image is a strip of five finished icons — a blue funnel, a blue flashlight throwing a gold star, "
    "a marble bust on a blue plinth, a framed picture with a check badge, and a marble bust wrapped in blue arrows. "
    "It is a STYLE GUIDE and nothing more. Take from it how things are drawn: the bevel, the outline weight, the hard "
    "stair-stepped raster character, the lighting direction, the three-quarter projection, the figure's scale within "
    "the tile, the small soft contact shadow, and the habit of shading each material in a few flat steps. "
    "Do NOT treat it as a colour chart. It is a set of five icons that happen to be mostly blue and marble because of "
    "what those five depict; it does not mean every icon in the set is blue and marble. The object this icon depicts "
    "takes its own true colours — a painting has a painting in it, terracotta is terracotta, fabric is dyed, glaze is "
    "glazed. Only the interface furniture — plinths, badges, arrows, tool bodies — follows the reference's blue. "
    "Where this icon reuses a form the references already contain, such as the marble bust or the cobalt plinth, the "
    "reference is also the authority for that form."
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
