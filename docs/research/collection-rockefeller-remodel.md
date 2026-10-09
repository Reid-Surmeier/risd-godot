# Collection Rockefeller room prototype — 2026-09-30

Owner requested more low polygon Muse assets, verified against the RISD API, correct doorway/room spacing, and the latest Main Hall lighting, shaders and frame presentation. Scope remains standalone Collection prototype, issues #178/#182/#183. No 3D Viewer files, production Tenant interfaces, errors or acceptance tests changed. Heartbeat is disabled; this session is the only Collection worker.

## Catalogue and visual verification

[Official API documentation](https://risdmuseum.org/art-design/projects-publications/articles/risd-museum-collection-api) specifies `field_on_view=1`; `on_view=1` is ignored. API text alone does not prove a room placement. We compared official catalogue carousel photographs with the upright IMG_6380 source video. Scrapling's installed Fetcher obtained HTTP 200; ordinary requests encountered Cloudflare 403. Untouched responses, HTML (in official-page-sources.tar.gz), photographs and hashes are saved in `image-work/collection-room-remodel/catalogue/`.

| Source object | Verified catalogue identity | Placement evidence |
| --- | --- | --- |
| Floral settee | [2017.74.5](https://risdmuseum.org/art-design/collection/settee-2017745), 94 × 139 × 77 cm | IMG_6380/397–401 floral upholstery and carved front |
| Wavy-back chair | [2017.74.7.1](https://risdmuseum.org/art-design/collection/armchair-20177471), 93 × 82 × 57 cm | /289 and /417 near the bookcase wall; .7.2 uses the representative pair model, exact partner photo not separately checked |
| Pierced-loop entrance chair | [2017.74.12](https://risdmuseum.org/art-design/collection/armchair-20177412), 94 × 68 × 58 cm | /389–393 three overlapping back loops, dark wood and blue floral seat |
| Left gilt mirror | [2017.74.4.2](https://risdmuseum.org/art-design/collection/mirror-20177442), 231.1 × 91.4 cm | /289 right-side central scroll |
| Right gilt mirror | [2017.74.4.1](https://risdmuseum.org/art-design/collection/mirror-20177441), same dimensions | /313 and /417 opposite scroll |
| Covered tureen and stand | [2017.74.39.18a-c](https://risdmuseum.org/art-design/collection/dragons-compartments-pattern-covered-tureen-and-stand-2017743918a-c), 45.7 × 55.9 × 35.6 cm | /429–443 pink medallions, compartment motifs and handles |
| Portrait above bookcase | [John Constable, Portrait of Mrs. Edwards, 58.197](https://risdmuseum.org/art-design/collection/portrait-mrs-edwards-58197), canvas 76 × 63.7 cm | /292 and /405 bonnet, frilled neckline, brooch, hand arrangement |

The [official Rockefeller Gallery tour](https://risdmuseum.org/exhibitions-events/events/member-tour-rockefeller-gallery) associates English furniture, large Rococo mirrors and Rockefeller-service porcelain with this gallery. This supports the room identification; the video remains the placement source. Catalogue rights flags are preserved. Private review only. Writing table 2017.74.8 remains a candidate, and is not inserted as a verified object. The sofa portrait, bust and remaining porcelain figures remain unidentified.

## Muse and geometry

Six new one-output OpenRouter `meta/muse-image` requests: settee, wavy-back chair, pierced-loop chair, covered tureen, left mirror, and Mrs. Edwards frame. Each receipt records $0.01; new recorded spend $0.06, map cumulative $0.11. Receipt spend state remains `unknown` and retry state `never-resubmit`; none was blindly repeated. Native outputs, ordered references, prompts, hashes and complete sanitized run records are retained. Agent inspection is recorded in `review.json`; no owner acceptance is inferred.

Furniture uses separately modeled seats, arms, shelves and legs plus shaped Muse reliefs and upholstery. Mirrors use shaped extrusions. Tureen uses a 16-sided elliptical profile with projected front decoration; its rear pattern and hidden form are inferred. Pierced fronts use alpha cutouts, not full carved channels through their sides. Bookcase shelf porcelain and bust are unfinished. Authentic Constable artwork is a separate unchanged catalogue image inside the source-specific Muse frame; the frame opening is fitted by the existing Main Hall nine-slice helper.

Mirrors now crop the actual foreground before applying catalogue dimensions, fixing the undersized appearance caused by native magenta margins. The distinct left/right designs replace the repeated partner proxy. Wavy-back chairs move to the bookcase wall; the distinct pierced-loop chair occupies the entrance-side wall.

Captured spacing remains a provisional guide, never a rendered point cloud. The back wall moves to z=-7.20 in the doorway-centred local frame, agreeing with neutral source wall tracks around source z=-0.19. The left sofa wall x=-2.75 approximates observed x=-2.70. Right extent x=3.65 is provisional. IMG_6384/207 fixed casing floor rays move the shared opening plane about 0.66 m from the previous moving-leaf proxy. Cross-source fixed-jamb checks disagree by up to 0.7 m: this is a hypothesis, not a surveyed solution. IMG_6380/245 enters from the right-hand purple corridor; the new opening is at local z≈-2.0 with a bounded stub. Its extent and width are inferred; no unseen next room is invented.

## Latest Main Hall presentation

`presentation-reuse.json` records read-only source hashes from the latest inspected Main Hall checkout at 2b0b015a. Exact page frame/clock art, GameCube RGB6 shader, floor oak shader and selected Muse board atlas, wall texture, CRT luminance, squiggle, haze and painting helper are copied into this isolated prototype. The old visitor asset and its current dynamic lighting code are reused. The native Main Hall wall texture remains archived unchanged; its grain is retinted to the source-observed ivory plaster using a recorded deterministic transformation (RGB 231/226/217 plus 15% centred grey variation). Straight boards follow this room's video rather than the Hall's herringbone plan. The frame fits a 1080-square desktop and the game opening is measured from the native art; an assertion guards the TextureRect expansion ordering regression.

Static surfaces use native UV2 and LightmapGI with Main Hall lamp and artwork-spot colour/energy (spots adapted to the lower ceiling), two bounces, custom environment and dynamic actor probes. Floor UV2 is continuous across board joins. Stable mesh IDs preserve LightmapGI paths when the scene is wrapped in the frame presentation. The radial visitor contact card follows the Hall recipe. Runtime and browser preview rendering are verified on RTX 4070 SUPER; native lightmap baking uses software Vulkan lavapipe because this WSL session cannot initialize the NVIDIA Vulkan device. No claim of GPU baking is made.

Validation and checkpoint: see `docs/evidence/collection-reconstruction/main-worker-rockefeller-20260930/`. Full museum map, exact measurements, hidden asset surfaces and production integration remain open.

Close-up inspection caught magenta on the entrance-chair seat: its upholstery crop crossed the isolated background. All furniture now sample interior keyed cloth regions, with a runnable assertion rejecting more than 0.1% transparent background. Native Muse outputs remain unchanged.
