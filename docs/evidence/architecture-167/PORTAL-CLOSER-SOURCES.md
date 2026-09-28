# Closer primary portal references — 2026-09-28

The museum's [Hand of the Maker](https://risdmuseum.org/art-design/projects-publications/articles/hand-maker)
article identifies the French Romanesque Portal, circa 1150, and links two
high-resolution photographs. These resolve details missing from the owner
video still; they are reference photographs, not accepted runtime textures.

| Image | Official source | Local inspection copy | SHA-256 |
| --- | --- | --- | --- |
| Full portal, 2672×3000 | [RISDM 40-014 v_01.jpg](https://risdmuseum.cdn.picturepark.com/v/VDCtrE5O/) | `/tmp/risd-167-official-portal.jpg` | `cd04ead6f1417086ff0aa62da7767dc295e49c6cd4b23793778be26e5947ab90` |
| Capital detail, 3000×2250 | [RISDM 40-014 v_02.jpg](https://risdmuseum.cdn.picturepark.com/v/ybp7tGBQ/) | `/tmp/risd-167-official-capitals.jpg` | `cb28be559253b75005bb1585e047b0fb3e65469c93a1c24f81b60369269e42fd` |

Visual observations from those photographs: each side has three staggered
supports, including a narrow middle shaft; the impost changes depth above
them and contains multiple carved tiers. Capital faces include distinct leaf,
animal and scroll forms. The outer arch also carries a shallow carved band.
These are observed forms, not recovered dimensions. Perspective and lighting
still prevent a measured section or exact depth reconstruction.

The current two-support candidate is therefore an oversimplification, not a
faithful reconstruction of this new evidence. Future geometry should retain
the existing opening/traversal envelope while using these clearer forms.
No raw photograph has been added to runtime or committed as distributable
art. No paid generation was required to obtain these primary references.

The offline authoring command accepts the two inspection downloads explicitly:

```bash
godot --headless --path . --script modules/shell/prototype/gallery_walk4/portal_relief_prepare.gd -- /tmp/risd-167-official-portal.jpg /tmp/risd-167-official-capitals.jpg
```

The script records six perspective-bounded capital fields, ordered left outer,
middle, inner, then right inner, middle, outer, plus two separate impost fields.
Exact sampling quadrilaterals are in that source script. The detailed photograph
uses a nine-pixel box footprint before the 96×96 relief grid; the full-portal
faces use three pixels. This is a bounded authoring guide, not photogrammetry.
Body widths and stepped support positions remain within the pre-existing
portal surround envelope, and the gallery opening/traversal coordinates remain
unchanged. Source photos are not runtime dependencies or albedo decals.

The parent also supplied the renovation contractor's
[Grand Gallery project](https://www.sitespecificllc.com/rhode-island-school-of-design-radeke-museum)
photo, locally `/tmp/risd-site-specific-2447.webp`. It is useful reference for
floor borders, trim and bench frame proportions, not a measured room survey
or runtime photo. It was inspected after the portal8 bake and did not inform
that candidate's generated geometry.
