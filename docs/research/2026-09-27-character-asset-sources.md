# Animal Crossing character asset sources

Checked 2026-09-27 for Reid's request to replace the generated gallery character. This is source research, not an imported or animation-verified deliverable. Only archive metadata and bounded archive-header byte ranges were retrieved; no complete game archive or implementation changed.

## Recommendation

**Evaluate the user-selected New Horizons 2.0.0 archive first.** Its actual 7z index contains the human player body, hair, clothing components and textures. This was verified from the compressed archive header, not inferred from a search result. New Leaf remains the smaller-download, older-console visual alternative below; it is no longer the primary recommendation after Reid supplied the New Horizons source.

The key limitation is already known: **the exporter explicitly did not include animations**. A better mesh can replace the poor silhouette, but idle/walk/turn still need a separately verified animation route. Target the project's **Godot Compatibility** runtime and a single assembled GLB, with authored silhouette and textures preserved.

No Nintendo grant for redistributing these extracted assets in this project's downloadable game was established. Conversion to GLB does not supply that grant. Keep that provenance fact separate from technical feasibility.

## User-selected archive: live verification

Primary source: [nimaid's original export post](https://www.reddit.com/r/ac_newhorizons/comments/qtmv3x/all_models_textures_ripped_for_acnh_200_daepng/), [Internet Archive item](https://archive.org/details/acnh-2.0.0-models), and [live metadata endpoint](https://archive.org/metadata/acnh-2.0.0-models).

The uploader says these are Switch-Toolbox COLLADA/PNG exports of ACNH 2.0.0, with rigs retained and animations omitted. Direct metadata retrieval succeeded on 2026-09-27 and identifies `ACNH_2.0.0_Exported_Model_DAE+PNG.7z`, **8,511,887,414 bytes**, MD5 `4c42817aa486e124169ff721534eb2bc`, matching the author's published checksum. That checksum was read from metadata, not recomputed over an undownloaded archive.

[Server-side archive listing](https://archive.org/download/acnh-2.0.0-models/ACNH_2.0.0_Exported_Model_DAE%2BPNG.7z/) returned HTTP 200, but exposed only directory rows, not model/texture download links. HTTP `Range` requests returned 206 and permitted retrieving the 32-byte signature header and compressed directory header. Native `7z l -slt` successfully parsed this sparse scratch archive. No model payload bytes were needed to prove these exact members:

| Verified archive member | Uncompressed bytes | Archive CRC32 |
| --- | ---: | --- |
| `Model/PlayerBody.Nin_NX_NVN/PlayerBody.dae` | 494,520 | `1AA31D18` |
| `Model/PlayerBody.Nin_NX_NVN/mSkin_Alb.png` | 12,494 | `775B038F` |
| `Model/PlayerBody.Nin_NX_NVN/mSkin_Mix.png` | 1,600 | `6F0A124F` |
| `Model/PlayerBody.Nin_NX_NVN/mSkin_Nrm.png` | 13,080 | `199E3B96` |
| `Model/PlayerHair00.Nin_NX_NVN/PlayerHair00.dae` | 135,124 | `5676DAF9` |
| `Model/PlayerHair00.Nin_NX_NVN/mHair_AlbGry.png` | 20,247 | `F2328C0C` |

The header also lists cheek, nose, paint and sock maps for PlayerBody. These names establish concrete files to evaluate; they do not yet prove how the material channels should be combined or the exact face/body coverage of the mesh.

**Selective-download limitation:** the archive is solid LZMA2 (`Solid = +`), with three compressed blocks. All sample members above belong to block 2, whose packed size is **2,659,428,418 bytes**. A local extractor cannot normally fetch just the DAE's compressed bytes independently from this solid block; it must decode preceding data in the block. Header-only inspection is cheap; extraction is not necessarily cheap. The 7z header was approximately 1.9 MB; including one overlapping preliminary tail request, this investigation transferred approximately 3 MB of archive ranges, not 8.5 GB. A torrent is not needed for the verified index and was not used.

Individual-member requests for `PlayerBody.dae` and `mSkin_Alb.png` through the archive download path both reached a **45-second read timeout**, with no member payload saved. This does not prove those members are unavailable; it is the observed blocker to the no-bulk retrieval path. The verified fallback is a bounded download/decode of the relevant solid block, or a separately hosted copy of just the identified player components. Do not claim a retrieved or usable character from the header alone.

Reproduction inputs for the successful header inspection: total length `8511887414`; signature range `0-31`; packed-header range `8509980676-8511887413`; parse with `7z l -slt` after writing those ranges at their original offsets in a sparse scratch file. The full index found 154,096 non-directory members across the three solid blocks. Local scratch evidence: `/tmp/acnh-character-listing.txt` (full member index) and `/tmp/acnh-archive-listing.html` (server listing). The sparse `.7z` is deliberately incomplete and is not an asset download.

## Sources and what is actually verified

| Candidate | Evidence | Limitations and fit |
| --- | --- | --- |
| [New Leaf — Villager, The Models Resource](https://models.spriters-resource.com/3ds/animalcrossingnewleaf/asset/301846/) | The source site's indexed asset page identifies the human playable character, uploader Centrixe the Dodo, 1.34 MB ZIP, 1,215 items, and DAE/PNG/TXT formats. Listed parts include dresses, pants, legs, hair, and a readme. | Smaller fallback candidate for an older-console silhouette. Parts require assembly. Skeleton weights and idle/walk clips have **not** been verified. Direct HTTP retrieval returned 403 in this session; the manifest was visible through the search index. “Listed download” is not “successfully downloaded.” |
| [New Leaf catalog](https://models.spriters-resource.com/3ds/animalcrossingnewleaf/page-3/) | Separates the human playable Villager from animal villagers and special characters. | Useful when choosing a character; the word “villager” in search results is ambiguous. Catalog quantity does not establish animation completeness. |
| [New Horizons catalog](https://models.spriters-resource.com/nintendo_switch/animalcrossingnewhorizons/page-1/) | Source catalog lists animal species and named special characters. | Good for a specifically chosen animal NPC. The checked catalog section does not establish an assembled, animated human player download. New Horizons shading/materials may demand more conversion than New Leaf. |
| [SSlamon — Animal Crossing Player Model](https://sketchfab.com/3d-models/animal-crossing-player-model-701a20b9786740378c2d67df3d810ef8) | Uploader describes an editable base model, 1.7k triangles / 855 vertices, changed arm spacing, and omitted nose. Page advertises download and CC Attribution. | Not a verified complete game rip or animated replacement. Incomplete appearance, unspecified rig/clips, and underlying Nintendo provenance remain unresolved. A user-selected license badge is not evidence about ownership of every component. |

The New Leaf asset page's 1,215 entries are the archive listing, not 1,215 finished characters. Its indexed manifest supports formats and component names; it does not prove that the ZIP bytes remain retrievable or that animation data exists inside the DAE files.

## What GitHub provides

[CTR-Studio](https://github.com/MapStudioProject/CTR-Studio) is an MIT-licensed editor for 3DS BCH/BCRES. Its README explicitly documents export/replacement of models with rigs, custom bones, vertex colors and UV layers, plus conversion of skeletal animations to Maya `.anim`. This is the relevant fallback when original-format New Leaf model and animation files are available. It is a conversion tool, not a ready-made Nintendo asset library. A conversion spike still needs to establish how its exported animation joins the selected skeleton and reaches GLB.

[Switch-Toolbox](https://github.com/KillzXGaming/Switch-Toolbox) documents BFRES model/animation import and export and skeletal/material animation preview. Its README now says it is archived and no longer developed, and current XCI/NSP/NCA loading is unsupported. It is GPL-3.0 software; that license covers the tool, not Animal Crossing art processed with it. It is a fallback for original-format New Horizons data, not the simplest starting point for one human character.

The [OpenCrossing-Anbernic repository](https://github.com/GabeConway/OpenCrossing-Anbernic) is another useful distinction: its own README says game assets are not shipped and the user supplies a disc image. A GitHub game port is therefore not automatically a model download source. This search did not establish a trustworthy GitHub repository offering one ready-to-import, complete Animal Crossing human with validated idle and walk clips.

## Minimal conversion and acceptance trial

1. Retrieve only the selected character archive; retain source URL, uploader, retrieval date, SHA-256, readme, and asset-rights status. Inspect the archive and DAE XML before importing: geometries, controllers/skin weights, skeleton hierarchy, material image paths, and animation channels. Stop describing it as “rigged and animated” unless both are present.
2. Assemble one appearance in a compatible DCC, preserve the authored silhouette and UVs, and export GLB with embedded textures and skeleton. Do not run the Nintendo character through another generative remodeling pass. Check the installed converter's COLLADA support rather than assuming every Blender version supports the same importers.
3. If clips are absent, inventory source-compatible animation files before selecting an animation route. Do not substitute the existing bad limb motion and call the replacement complete. Establish root motion versus in-place motion, loop length, movement speed, and positive forward direction.
4. Validate the GLB in the actual runtime: idle, start/stop, full turn, diagonal movement, front/side/back views, feet on floor, no clothing separation, no sliding or reversed facing. Record clip names/durations and take a short movement capture. Compare silhouette at gameplay camera distance, not just a large model preview.
5. Only after that trial, replace the production character and confirm the same route through entryway and room. Character geometry, camera collision, and room geometry remain distinct fixes; a new character cannot by itself fix wall visibility or the white floor area.

GLB is the proposed interchange because [Godot's importer documentation](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_3d_scenes/available_formats.html) recommends glTF 2.0. Validation must run in this project's Godot Compatibility renderer. Format support is not proof that a particular converted asset preserves Nintendo material or animation behavior.

## Rights and an alternative

[Nintendo's content-sharing guidelines](https://www.nintendo.co.jp/networkservice_guideline/en/index.html) address sharing gameplay videos and screenshots. They are not a model redistribution license for an independent game. None of the checked Nintendo-model listings established an express grant covering this project's distribution. Keep extraction provenance, converter license, and permission to redistribute the resulting model as separate records; do not label the Nintendo art MIT/GPL because a converter uses that license.

If a clearly licensed production asset is required, [Quaternius Ultimate Modular Characters](https://quaternius.com/packs/ultimatemodularcharacters.html) advertises CC0, 11 characters and 24 animations, and FBX/OBJ/glTF/Blend availability. This is a credible existing rigged-character alternative, but it is **not** Animal Crossing art and has not been visually approved for this project. It should not silently replace the user's requested aesthetic.

## Evidence limits

The binary ACNH archive header and real member index were inspected; model payloads, rigs, clips, and converted models have not yet been inspected. No bulk download, torrent, paid generation, asset installation, or scene edits occurred. The next decisive evidence is one retrieved New Horizons player appearance with its actual skeleton and a separately supplied working walk loop.
