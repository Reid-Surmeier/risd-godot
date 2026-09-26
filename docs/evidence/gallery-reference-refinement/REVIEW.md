# Reference refinement experiment

Prototype issue: https://github.com/Reid-Surmeier/risd-godot/issues/132
First checkpoint runtime: f873b58. Latest shader/geometry runtime: 6e56edf. Research: ffec4bd, local branch research/animal-crossing-reference-refinement. No push or PR. Existing Muse oak and slate are retained unchanged; no new paid generation in this experiment.

User's third image guides white-surface rendering only. No reference layout, furnishings or extra paintings were copied. Larger herringbone units and stepped base trim are prototype modelling changes; museum dimensions and artwork placements are unchanged.

Two blind Astra high visual rounds, one motion follow-up, two primary-source research agents, and a separate code review were used. The second blind visual verdict is NOT-EXACT: character height ~32% and soles ~79% down match the selected screenshot closely, but composition depth, fine floor grain and coherent local lighting/white-face separation do not. The code reviewer found no concrete functional regression in the tracked diff.

Native Compatibility checks passed: 23/23 paintings; OtherWall both directions; toolbar remains hidden after closing details; seven audible-player starts in two seconds, zero while walking into a wall; hidden-wall click excluded; both bench paths reached; FUZZ 0/300; HALF-VISIBLE opens E6. Runtime Light3D count is zero. Bake has 118 lightmap users, with only glazing excluded from GI ray geometry. Shader RGB6 ordering has no TIME/noise input, but that alone is not proof of zero crawl.

Chrome on ANGLE D3D12 RTX4070SUPER,1600x900: median16.7ms in standing/walking/turning, p95≤16.8ms. Transfer149,280,158 bytes; prior material build149,339,218. Native texture bytes188,356,387; browser GPU texture memory was not measured. Real OtherWall/F6/camera dropdown/lighting-toggle interactions passed. Browser has the preexisting favicon404, unsupported2DMSAA and arrow_cursor metadata diagnostics; no new resource-loader/runtime failure. Native bake and shutdown diagnostics are preserved in logs.

Test-audit note: an initial audio assertion incorrectly demanded that polling AudioStreamPlayer.playing observe exactly the contact texture in the same frame. Audio starts and software-rendered pose samples are asynchronous, so that assertion failed despite seven correct starts. It was removed; the final check asserts the externally observable cadence and silence while blocked. Exact audiovisual phase and audio timbre remain unverified, not declared passed. No tests or thresholds were changed for navigation/render failures. The current sounds remain the previously sourced Wild World clips, not verified GameCube replacements.

Outstanding: directional generated character motion; stronger room depth without moving the actual collection; a quieter Muse oak treatment; deliberate lamp-to-pool alignment and white architectural shading. These remain within the open prototype, pending owner visual reaction. Do not mark the map or prototype complete from agent verdicts.

Negative control: restoring the old distance/10fps cadence made the real two-second walking check fail with four contacts; the working source was restored. This verifies that the cadence test rejects the specific prior timing regression. Motion follow-up found improved scale/filtering, persistent back-facing art, and fine floor aliasing as a remaining risk.

## Shader and geometry continuation — 6e56edf

The native lit oak shader reduces fine-grain contrast and widens mip sampling; the Muse source image is unchanged. Bench cushions now have chamfered corners and bevelled top faces, and the cornice has a sloped fascia/underside. Room dimensions, collection placement and collisions are retained. The medium-quality native bake uses daylight across the gallery at (-60,-75,0); this reduces the harsh skylight shape without introducing runtime Light3D nodes. No additional Muse calls or paid spend ($0).

Blind Astra high review preferred the quieter floor and found useful white-face and bench volume. A subsequent architecture trial reduced the dark skylight shape and conspicuous bright triangle. A small hard-edged notch remains. Code review found an inverted bottom-cap winding; it was fixed before the final bake. The custom shader and its UID are tracked.

Full rendered regression on the final shader/geometry passed: 23/23 artwork routes, both wall crossings, seven contacts in two seconds and zero blocked, FUZZ 0/300, and 32 sloped bench faces with matching normals/winding. The last daylight-angle adjustment was followed by the lighting-only render check and architecture captures. Repository checks and git diff --check passed. Known bake/shutdown diagnostics remain in their logs.

Final Chrome check: 1600×900, ANGLE D3D12 RTX4070SUPER, median16.7ms in every phase, p95≤16.8ms; transfer149,229,316 bytes. Real clicks crossed east and west; camera dropdown and lighting comparison passed. Baseline diagnostics are unchanged, with no new resource-loader/runtime failure. The first browser attempt timed out because the old local test server was absent; the retry used a fresh local server and passed against the f873b58 measurements. geometry-browser.log and geometry-browser.json contain the successful run.

Remaining: not-exact. Repeated wall pools, room depth/composition, directional character animation, and GameCube audio fidelity remain unresolved. The new video has no audio and does not verify timbre or exact audiovisual phase.
