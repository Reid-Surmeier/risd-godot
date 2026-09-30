# Webcam site audit — 2026-09-30

[Issue218](https://github.com/Reid-Surmeier/risd-godot/issues/218). Scope: the standalone webcam site, runtime assets, browser/server adapters, export, deployment and authoring/test support. Other RISD modules are independent of this site.

Ranked complexity findings, all applied:

- delete: two server/authoring reference images from the browser resource pack. Native export exclusions; retain repository inputs and provenance. [export_presets.cfg](../export_presets.cfg)
- delete: the separate image planning command before generation. The maintained image --execute command already plans and validates before reserving/submitting. [server.ts](../server/server.ts)
- native: the canvas resize policy HTML string rewrite. Godot's html/canvas_resize_policy=1 produces the same setting. [export.sh](../export.sh)

net: -1 lines, -0 deps possible.

## Efficiency verification

Resource pack: 3,932,496 bytes → 2,574,456 bytes, a 1,358,040-byte (34.5%) reduction. Native ZIP export inspection confirms both unused reference imports are absent and every runtime image/shader/video plus main/interface scripts remains. No accepted source asset was deleted. Godot documents export filtering and selected resource modes in its [export guide](https://docs.godotengine.org/en/stable/tutorials/export/exporting_projects.html).

The removed dry-plan subprocess measured 2,075ms on the droplet with the same maintained tool, locked fixture references, explicit model/budget and no provider credential/submission. Tool invocations per capture fall from three to two. The execute CLI still authenticates its artifact, reads/hashes/validates references, plans, validates model/count/spend and durably reserves the one submission. The new unpaid provider-command check and existing accounting/timeout checks pass.

The whole-repo scan found no safe dependency to remove. Godot remains the application runtime; Effect is the frozen Generation seam; MediaPipe provides requested on-device expression tracking; native DOM controls provide keyboard/touch access. Those are active requirements. The ledger, credential launcher, receipt authentication, cancellation and short-lived result storage enforce existing requirements. Authoring trials and provenance are already excluded from the browser export and remain useful records.

Scene-only export was rejected: this installed Godot reports no dependencies for this project's GDScript preloads, yielding a pack without its runtime assets. Existing native export exclusions are the smaller working solution; runtime dependency checks and browser playtests protect it. No custom exporter, dependency scanner, engine build, cache framework or frontend rewrite was added.
