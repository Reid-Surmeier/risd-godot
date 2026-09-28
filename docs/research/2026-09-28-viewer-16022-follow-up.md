# Viewer identity: independent 16.022 follow-up

**No new identity is proved.** Slot 03 remains unidentified: accession 16.022 is neither confirmed nor rejected. Slot 02 and the sixteen panel crops also remain unidentified in this pass. This supplements the [prior comparison](2026-09-28-viewer-primary-record-comparison.md), without revising its findings or claiming completion of #169.

## Accession 16.022: evidence and retrieval limits

RISD's [Wood in the Middle Ages](https://risdmuseum.org/art-design/projects-publications/articles/wood-middle-ages), section “The Collection,” explicitly names **John the Baptist (16.022)** and limewood, and presents southern Germany as a likely origin based on that material. These are statements about the museum object, not identifications of our scan. The retrieved article supplies no photograph or object-record link for this accession. Its [parent publication](https://risdmuseum.org/art-design/projects-publications/articles/wood-sculptures-risd) lists seven individual object studies, but none for John the Baptist. Neither retrieved page enables a visual match.

The following attempts returned browser-tool errors, not usable records or JSON:

| Attempted direct URL | Interpretation |
| --- | --- |
| [Guessed John the Baptist record](https://risdmuseum.org/art-design/collection/john-baptist-16022) | No record retrieved; URL is unverified |
| [Guessed Saint John the Baptist record](https://risdmuseum.org/art-design/collection/saint-john-baptist-16022) | No record retrieved; URL is unverified |
| [Collection search for 16.022](https://risdmuseum.org/art-design/collection?search_api_fulltext=16.022) | No search results retrieved |
| [Collection API query](https://risdmuseum.org/api/v1/collection?search_api_fulltext=16.022&items_per_page=25) | No JSON retrieved |

Shell retrieval additionally failed DNS resolution for `risdmuseum.org`. These are access failures in this session, **not evidence that the object, photograph, or endpoint does not exist**. RISD-only searches for the accession, title, and title with “bust” or “limewood” did not supply another photograph usable here; this was not an exhaustive collection search.

I inspected the exact [slot 03 PNG](https://github.com/Reid-Surmeier/risd-godot/blob/ae5e3bbe25f99c6c70c63889b88e6ca7012acd8f/modules/sculpture_viewer/assets/scans/20260811123051-front.png). Discriminating details for a future photograph comparison are the high exposed forehead enclosed by open hair curls; narrow, individually waved beard locks with an uneven divided lower end; parted lips; dense repeated wavy texture across the image-left shoulder; a reddish diagonal garment edge beside the exposed chest; and broad folded drapery at image right. These are observations of scan pixels, not claims about material or saintly identity. No official 16.022 image was obtained against which to test them. A partial scan cannot establish whether the original was a bust or a full figure.

## Slot 02 and panel source check

RISD's [1988 handbook publication listing](https://risdmuseum.org/art-design/projects-publications/publications/handbook-museum-art-rhode-island-school-design) includes **Stela, Northern Wei Dynasty**, under Unknown Maker, Chinese. Its indexed first-party text was retrievable, but opening the page failed and no associated object photograph or accession was retrieved. This is a search lead only; neither that title nor its cultural attribution belongs in slot 02 yet.

The inspected [slot 02 PNG](https://github.com/Reid-Surmeier/risd-godot/blob/ae5e3bbe25f99c6c70c63889b88e6ca7012acd8f/modules/sculpture_viewer/assets/scans/20260811122415-front.png) has an arched relief with small seated figures across its crown, a larger seated central figure between standing attendants, a separate lower register of figures, and a stepped rectangular base. An identification must match the arrangement, individual carving, and surviving edge geometry, not merely the word “stela.” No such comparison was achieved.

I inspected the full [owner panel](https://github.com/Reid-Surmeier/risd-godot/blob/ae5e3bbe25f99c6c70c63889b88e6ca7012acd8f/modules/sculpture_viewer/assets/setup/panel-2x.png) and the upstream [desktop source JSON](https://github.com/Reid-Surmeier/figma-ui-ux-qwen-pipeline/blob/7ee5e9c/painting-tool-prototype/references/statue-viewer-desktop/source.json) through its local copy at `/home/reidsurmeier/orca/workspaces/figma-ui-ux-qwen-pipeline/painting-tool-prototype/references/statue-viewer-desktop/source.json`. That JSON documents a different, 2276×5101 sidebar image and layout; it contains no accession mapping. No source sheet for the sixteen crops was found in this bounded check. This does not establish that none exists elsewhere in owner files.

## Reproducibility and unknowns

Recomputed SHA-256 file hashes matched the existing inventory:

| Input | SHA-256 |
| --- | --- |
| Slot 03 | `30c8fce99f4d74fd6ebb56cde9793cbd629235f8062444a821d0b654f3f6de3e` |
| Slot 02 | `5ecb033f9efca6071bf580b2d487a2bcf50f6492ab8ec6d115cbf6a50b5b3267` |
| Full panel | `d6cdb4c2c3ff042ea3380868184d297ea608f733bd377723cc71fd792f5b99d5` |

Titles, accessions, departments, museum descriptions, and rights remain unverified for these eighteen entries. The [owner provenance record](https://github.com/Reid-Surmeier/risd-godot/blob/ae5e3bbe25f99c6c70c63889b88e6ca7012acd8f/modules/sculpture_viewer/PROVENANCE.md) carries unresolved rights; no museum object-image license obtained elsewhere establishes rights to the Proton scans or composite panel. The next useful evidence is an accession-linked photograph of 16.022, the handbook stela photograph/record, or the owner's original accession/source-photo sheet.

Read the requested contract, module map, module record, and prior report. Live issue retrieval failed through both `gh` and the browser; this pass follows the user's explicit research scope. Only this report was added, via `apply_patch`; no paid services were used (USD 0). Verification: `git diff --check` passed; the new untracked report was also checked with `git diff --no-index --check /dev/null <report>`.
