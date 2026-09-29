# #168 floor board atlas — second bounded source-led trial

This trial uses two 2500×1667 photographs of the actual RISD Grand Gallery
published by [Site Specific's Radeke Museum renovation page](https://www.sitespecificllc.com/rhode-island-school-of-design-radeke-museum).
Direct source images: [gallery 2456](https://images.squarespace-cdn.com/content/v1/5b4e471e3e2d09b93dd1391a/1538580055481-M5QJ9LZ5N0MN0QVBJ9OA/RISDMUSEUM-20171204-2456.jpg?format=2500w)
and [gallery 2447](https://images.squarespace-cdn.com/content/v1/5b4e471e3e2d09b93dd1391a/1538580038099-9KDN5L1T1W9AMTF7738A/RISDMUSEUM-20171204-2447.jpg?format=2500w).
The downloaded reference copies are evidence, not runtime textures or proof of
permission to redistribute those photographs; keep them local, not in a public
commit. The first, `2456`, shows the
lighter parquet across the room from the side; the second, `2447`, shows the
parquet and perimeter from the doorway. The exact prompt requests eight
distinct diffuse board faces, not a precomposed floor. Polygon geometry,
texture assignment and baking remain separate Godot steps.

The ninth four-face atlas failed independent rendered-floor review at commit
`e48034a9`: repeated V columns, comb-like grain, flat appearance and
native/Web sharpness difference. This new source-backed atlas is one image,
one OpenRouter Muse edit attempt, budget USD 0.01. Its output is unselected
until a saved-bake native/Web visual gate and independent blind review pass.

The one OpenRouter `meta/muse-image` request completed as
`run-e098a83f7967ea5cc2ba2c2e`. Its materialized WebP and trial runtime
copy `textures/oak-board-atlas-168-v2.webp` have SHA-256
`8b568b890e7ffa5a2ef86173b21222b3bc6374d7abea15be5ea1865532524aec`.
The run state records actual cost USD 0.01, but retains `spendState: unknown`
and `retryState: never-resubmit` for safety. An independent GPT-6 Astra
medium image-only source preflight **passed as an input only**: eight distinct
pale oak faces, plausible soft grain and safely croppable tile separators;
the faces are somewhat more uniform than the photos and two are warmer.
This is not a rendered-floor verdict or an integration approval.

The saved-bake 720/1600 native and exported-Web packet passed the browser-error
check but **failed** a fresh image-only floor review: board ends blended into
continuous chevrons, with overly uniform grain/finish and softer native output.
The first floor version remained unselected. A subsequent no-rebake seam/tone
probe passed a fresh image-only native/Web review at 720/1600 square with minor
sheen/grain and scene-wide native-softness reservations. It is the selected
floor visual candidate, pending navigation and repository checks before build
integration; this says nothing about other world-asset batches.
