# Provenance of modules/collection_page

Every file below was copied unchanged (the two scripts excepted, see their headers) from
`Reid-Surmeier/qwen-image-pipeline`, branch `prototype/81-image-viewer`, commit `5d55209`, folder
`godot/prototype-image-viewer/`, on 2026-09-13. SHA-256 is of the source file at that commit, which for
every non-script file is also the byte-identical copy here. Nothing in the module is hand-drawn: the
windows are the owner's own screenshots, the viewer's chrome and artworks are regions of the owner's
reference sheet, and the only pixels Godot adds are the prototype's one-pixel rounded outline and
resize grip. Left behind: `viewer.tscn` (one node carrying `viewer.gd`; the node is built in code
here), `project.godot`, `export_presets.cfg`, `run.sh`, `playtest.mjs`, `evidence/`, `web/`,
`README.md`, `assets/SOURCES.md` (its table is carried below).

**Rights: the seven artworks on the reference sheet are RISD Museum material whose rights record is
pending on ticket #35; the eight HUD windows are screenshots of a third-party game's interface,
supplied by the owner with no rights statement beyond that.** They ship here as draft-mockup evidence,
as the other prototypes' pixels do; nothing in this module asserts a licence for them.

## Where the pixels come from (records outside this repository)

| Pixels | Origin | Record |
| --- | --- | --- |
| `reference.png` | the owner's seven-artwork Image Viewer screenshot (4591x2816), pasted into the prototype session as `orca-paste-1788871973810-2fd26ef1-8eee-499c-a00f-ee95924f971b.png` | prototype `README.md` @ `5d55209` |
| `assets/{equipment,options,status,trade,chat,party,bottom}.png` | seven owner-supplied window screenshots (Images 1–7 of the prototype session, `orca-paste-1788872786356…` through `…817835…`) | prototype `assets/SOURCES.md` @ `5d55209` |
| `assets/layout-reference.png` | the owner's desktop layout screenshot (`.orca/drops/Screenshot 2026-09-08 at 9.07.06 AM.png`, 2052x1352); the Search filters window is cut from it at (13, 550, 535, 245) at run time | prototype `assets/SOURCES.md` @ `5d55209` |

The owner's reference for this port (map #23 Notes, 2026-09-13 late) is the same desktop layout
screenshot; `desktop.gd`'s placements are its 1944x1280 review coordinates, `viewer.gd`'s frame rect
and artwork scale are the prototype's accepted state (the owner enlarged the artworks by half and
widened the gallery to the bottom bar's right edge in `077f993`; every window became draggable with
stacking in `5d55209`).

## Files

| File | Source path | SHA-256 | Note |
| --- | --- | --- | --- |
| `modules/collection_page/viewer.gd` | `godot/prototype-image-viewer/viewer.gd` | `ae905c4cee539a6a8320c5d93645e0f2a348a3dbaf0127756b0aae6cbc8d001b` | ported (edited; see the script header) |
| `modules/collection_page/desktop.gd` | `godot/prototype-image-viewer/desktop.gd` | `7b5bbe89c8538d929c736ea01320b4310bb51cf196e7e1da6aa61b8626b64a80` | ported (edited; see the script header) |
| `modules/collection_page/remove-pink.gdshader` | `godot/prototype-image-viewer/remove-pink.gdshader` | `a8c11066ff25bc14a5ba08e227ea342dd84c6fa071261c4df035ac0b1ca26314` | keys the magenta border of a window screenshot (outer 32 source px; 3 for the filters cut) |
| `modules/collection_page/reference.png` | `godot/prototype-image-viewer/reference.png` | `c39ac61850b59fe297ffc2a09fcd30adbdb37c78181275248344a5e5016ad501` | the Image Viewer sheet: header, footer ("number of works: 12") and the seven artworks are sampled from it |
| `modules/collection_page/assets/equipment.png` | `godot/prototype-image-viewer/assets/equipment.png` | `cd5406de0e17372792bedd52205d83e0a746d3c68ab0d497cc9b02fccb087262` | 装備アイテム (equipment) window, owner-supplied |
| `modules/collection_page/assets/options.png` | `godot/prototype-image-viewer/assets/options.png` | `a06c6b034232f42e1350f367b10862d60fe39d7a5e6e651660045275a1a07349` | オプション (options) window, owner-supplied |
| `modules/collection_page/assets/status.png` | `godot/prototype-image-viewer/assets/status.png` | `4293f42a1463ee99cfc4bf97f57b8148a3ee62e9dc0770ed029011c43d733565` | SakumaRiri status bar, owner-supplied |
| `modules/collection_page/assets/trade.png` | `godot/prototype-image-viewer/assets/trade.png` | `ca85d0e25341042cfa64b36c6fbdfbcedb770a4fc2074f17744b3d667df55d7e` | 交換ウィンドウ (trade) window, owner-supplied |
| `modules/collection_page/assets/chat.png` | `godot/prototype-image-viewer/assets/chat.png` | `f1cee08cb0b3528594863ee6ecd14256b7e41f269540caedef0f45b06cf022b5` | Global Chatroom window, owner-supplied |
| `modules/collection_page/assets/party.png` | `godot/prototype-image-viewer/assets/party.png` | `53448920c5c9c9d711f2a4f20bf22d5935c3173972e2bc0c7062cf1bfead0b75` | パーティー (party) window, owner-supplied |
| `modules/collection_page/assets/bottom.png` | `godot/prototype-image-viewer/assets/bottom.png` | `09c077c70d82875e3da6d8c8bfe7c4de9a98a5fa4150cc045ba81e9c66d4f262` | the bottom bar, owner-supplied |
| `modules/collection_page/assets/layout-reference.png` | `godot/prototype-image-viewer/assets/layout-reference.png` | `e51cbb294653573b43432f623df7277a86adbeddb0d2f0d7c31b36928592075d` | the owner's desktop layout; the Search filters window is cut from it |

12 files.
