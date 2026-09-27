# Provenance of modules/playground_page

## Square pages (#164)

The four native page layouts reproduce selected prototype #158 A at commit `542f1394`; the source is `modules/playground_page/prototype-158/index.html` at that commit. `import_square_assets.py` imports the original 12 public connection records and 25 verified RISD works. Their unchanged downloaded/copied image bytes, source URLs, providers, SHA-256 hashes and zero cost are recorded in `assets/square/provenance.json`. `assets/square/catalog.json` retains the records, connection timestamps, source identity and RISD rights evidence. Runtime copies belong here so exported games do not depend on the evidence tree. No images were generated and no paid service was used.

`assets/fonts/LiberationSans-Regular.ttf` is the installed Liberation Sans regular font, used for the selected prototype's Arial-compatible typography. Source: `/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf`; SHA-256 `4659bc0c58c5028dd488ec928d41d9265db43d9b669fc14ca8b0832daca7b144`. Its packaged licence is `assets/fonts/Liberation-LICENSE.txt`.

## Retained desktop

Every pixel file is the owner's, copied unchanged from this repository except `assets/filters.png`, which is a plain crop (no resampling) of an owner file. Nothing is hand-drawn or generated. The layout itself is the owner's picture of 2026-09-14, `docs/evidence/playground/layout-reference.png` (2186x1362, SHA-256 `1e3d7792f794d1775aee92c3ace579258911202dc2280ffab9955fc700caf589`, dropped as `.orca/drops/Screenshot 2026-09-14 at 8.53.22 PM.png`, ticket #62). The window positions and scales in `playground_page.gd` were measured by template-matching each file below into that picture.

| File | Origin | SHA-256 | What it is |
| --- | --- | --- | --- |
| `assets/postpet.png` | `modules/playground_page/assets/reference.png` (renamed), itself `docs/evidence/collection-page/reference.png` at commit `758af6e129a0d41ffe40e309d817140c216f4a66` (ticket #26) | `d596106f9c0938166b225cceecad55dead4dd68ddfad43544f134fd8c392997f` | the Digital Playground (PostPet) window, RISD Museum version (header "Collections page", "Info / Saved objects"), 859x803 RGBA |
| `assets/phone.png` | `modules/phone_page/assets/reference.png` (moved when the Phone Tab folded in, ticket #62), itself `docs/evidence/phone/reference.png` at commit `758af6e129a0d41ffe40e309d817140c216f4a66` (ticket #33) | `dde862c13c5b7975983167dc6effee4ec4089f103f90fc87f66bbd75e1b64506` | the Nokia handset, 269x537 RGBA |
| `assets/options.png` | `modules/collection_page/assets/options.png` at commit `1bdda5a` (see collection_page's PROVENANCE.md for its origin) | `a06c6b034232f42e1350f367b10862d60fe39d7a5e6e651660045275a1a07349` | オプション (options) window |
| `assets/trade.png` | `modules/collection_page/assets/trade.png` at commit `1bdda5a` | `ca85d0e25341042cfa64b36c6fbdfbcedb770a4fc2074f17744b3d667df55d7e` | 交換ウィンドウ (trade) window |
| `assets/chat.png` | `modules/collection_page/assets/chat.png` at commit `1bdda5a` | `f1cee08cb0b3528594863ee6ecd14256b7e41f269540caedef0f45b06cf022b5` | Global Chatroom window |
| `assets/filters.png` | the region (13, 550, 535x245) of `modules/collection_page/assets/layout-reference.png` (SHA-256 `e51cbb29…`) at commit `1bdda5a` — the same region collection_page cuts at run time — saved as PNG by PIL `crop` | `65bf75c42049b1fdec56157dbbcfa3c65f71ec7788f782a29323a24c89059444` | Search filters window |
| `assets/websurfer-window.webp` | approved Muse output copied byte-for-byte from `prototype/websurfer-interaction/references/websurfer-window.webp` in the owner's prototype worktree | `17d0c45467b6389610d73971422b1bb8192a7c49df175c08db113687fd23721b` | RISD Museum WebSurfer window; its invisible controls animate source pixels without replacement text |
| `assets/sketchbook-journal.png` | owner-supplied conversation attachment, 2026-09-21 | `4e553be5a084b9fc238c93de1bd309e2b37eba38992f6bce8db800ddf0ca1b05` | オープンニン journal window; stored bytes stay unchanged, while the two title controls are palette-conformed to black and white at render time |
| `assets/fengshui.png` | owner-supplied conversation attachment, 2026-09-23 (Feng Shui Professional Edition screenshot, 2854x2286, SHA-256 `d1e7adc84026af5d27fda58ec424fd20fe81080575c56c6086e10704977d8a82`, kept as `docs/evidence/playground-fengshui/fengshui-original.png`): PIL crop (20, 17)–(2833, 2253) inside the screenshot's rounded rim, then halved with LANCZOS | `248ff409500a5f023c6abcee3560dd4dcb96cb09e06e15f746a62b1777c21261` | Feng Shui window, 1406x1118 RGBA; its client area shows the live Are.na profile in the web build |
| `assets/fonts/PixelMplus12-Regular.ttf` | byte-identical copy of `modules/atlas/fonts/PixelMplus12-Regular.ttf`; M+ FONTS licence in adjacent `LICENSE.txt` | `02f19467ea7cc235cc06c570b7f6c3b0a12a6f682bc8d74c43f2d323d97bcd12` | source-matched editable journal text |
| `remove-pink.gdshader` | `modules/collection_page/remove-pink.gdshader` at commit `1bdda5a`, unchanged | — | keys the magenta border of a window screenshot |

Why copies: collection_page's interface exposes only `create` and `state`, and its frozen verifier reads these files from its own `assets/` folder, so moving them into a shared module would change frozen files of a module this ticket does not name. One shared HUD-window module is a follow-up Issue.

Rights: as in collection_page — the HUD windows are screenshots of a third-party game's interface supplied by the owner; the RISD Museum material's rights record is pending on ticket #35. Nothing here asserts a licence.
