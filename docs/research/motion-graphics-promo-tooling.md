# Tooling for short promo motion graphics like the @nohluhn reel

Checked 2026-09-22. The goal is a code-driven, diffable pipeline in which Claude edits and animates, paid generation goes through OpenRouter only, and the owner reviews on a scrubbable timeline over Tailscale. "Verified" means I ran the command or read the primary source linked. "Inferred" means my own judgment.

## 1. The reference reel

The file is `nohluhn-CwLWHD5IriM.mp4` in the session scratchpad. ffprobe reports 28.37 s, 480×406, h264 at 30 fps (847 frames), and AAC at 44.1 kHz stereo. Twelve frames and a contact sheet are in `scratchpad/reel-frames/`.

**Visual style (verified by looking at the frames):**
- It is a fake Nintendo DSi–era handheld OS for a fictional brand, "NOHLUHN", with "© 2012 Nohluhn" on the screens. Each frame holds two portrait panels side by side, like a DS held sideways (inferred from the layout).
- The screens are copies of real handheld UI: a boot/logo screen with a pinwheel, a speech-bubble chat with a Japanese caption, a Pictochat-style drawing pad with an **Erase** button, walls of binary text, an "Emoter" camera lens with "Photos remaining: 82", a photo browser ("Slideshow / View by Sticker") with a scrollbar, and a voice "Recorder" with a waveform and a timestamp dated 2012/08/11.
- UI panels alternate with low-resolution live footage: a girl in a school uniform, a $3.99 price tag reading "No Exchange Electronics", sticky notes, a dark room with a TV showing "Where are you?", and a night field. The footage looks like a camera or phone photo from about 2012. It has soft, compressed pixels and low light.
- The piece is mostly hard cuts, with some one- or two-frame flashes (clusters of detections within 0.1 s). A small glitchy window slides in over black at about 5–6 s. The last about 5 s go dark (blackdetect found near-black at 22.8–23.1, 23.6–24.0, 24.3–24.7, and 26.3–27.5 s).

**Cut rhythm (verified with `ffmpeg -vf "select='gt(scene,0.3)',showinfo"`):**
- The filter reported 42 raw detections at a threshold of 0.3 and 66 at 0.15. When detections less than 0.2 s apart are merged into one event, there are **20 cuts**: 0.10, 0.83, 5.00, 5.43, 5.87, 7.47, 8.17, 8.90, 9.57, 11.13, 12.57, 13.27, 13.67, 14.93, 15.57, 16.30, 17.20, 18.70, 20.80, and 23.10 s.
- The shape is a slow open (a 4.2 s hold on the logo and chat), a dense middle from 5 to 17 s (cuts every 0.4–1.5 s, mean about 0.85 s), a slower tail from 17 to 23 s, and a dark hold to the end.

**Cuts against beats (verified).** librosa 0.11 was not installed, so I ran it in a throwaway `uv run --with librosa` environment; nothing was installed system-wide. aubio is not installed.
- `beat_track` estimates **86.1 BPM**, with 35 beats and 100 onsets from `onset_detect`.
- Only **3 of 20 cuts** fall within ±67 ms (2 frames) of a tracked beat. Random cut times hit a beat 16% of the time (a baseline of 2,000 random trials), so 3 of 20 (15%) is chance level. For onsets, 9 of 20 cuts (45%) land within ±67 ms, against a random baseline of 47%.
- **Conclusion:** the cuts are not locked to the beat grid. Several of them sit 60–100 ms from a beat, which could be a deliberate "late" feel, but the data does not show it (inferred). The reel is paced by the editor's taste, with density rising in the middle section. A beat map is still useful as a guide, but the pipeline must allow cuts off the grid.

**Techniques the style needs (inferred from the above):**
1. Pixel-exact recreation of handheld OS UI with animated UI states: cursor, button press, scrollbar, typing text, drawing strokes, and a waveform. This is HTML/CSS/SVG work, not generation.
2. Degradation of real or generated footage: downscaling, compression, low light, and a 2012-camera look. This is ffmpeg work (`scale` with neighbor/area, `noise`, `eq`, low-bitrate re-encode).
3. Hard cuts, one- or two-frame flash cuts, and small sliding/glitch windows. This needs frame-level timeline control.
4. A cut list that can snap to beats or onsets but can also be freely offset.
5. Slow motion or speed ramps on footage (not obvious in this reel, but in the brief).

## 2. Generation through OpenRouter (the only permitted paid route)

**OpenRouter does offer video generation today (verified).** The endpoints are `POST /api/v1/videos`, which is asynchronous (poll `GET /api/v1/videos/{jobId}`, then download `/content`), and `POST /api/v1/images`. Both are described in the [video docs](https://openrouter.ai/docs/guides/overview/multimodal/video-generation) and the [image docs](https://openrouter.ai/docs/guides/overview/multimodal/image-generation). Video output is not eligible for Zero Data Retention (same video docs). The lists and prices below were pulled live from `https://openrouter.ai/api/v1/videos/models` (29 models) and `https://openrouter.ai/api/v1/images/models` (53 models) on 2026-09-22.

**Video models (29), with price per output second.** "f/l" means first and last frame supported.

| Model | Price | Durations | Res | Frames |
|---|---|---|---|---|
| `bytedance/seedance-2.0-mini` | $0.0000035 / video token | 4–15 s | 480p/720p | f/l |
| `bytedance/seedance-2.0-fast` | $0.0000042 / video token | 4–15 s | 480p/720p | f/l |
| `bytedance/seedance-2.0` | $0.000007 / token (1080p $0.0000077) | 4–15 s | to 4K | f/l |
| `bytedance/seedance-2.5` | $0.0000107 / token | 4–30 s | 480p/720p | f/l |
| `bytedance/seedance-1-5-pro` | $0.0000024 / token ($0.0000012 no audio) | 4–12 s | to 1080p | f/l |
| `kwaivgi/kling-v3.0-std` / `-pro` | $0.084 / $0.112 per s (audio $0.126 / $0.168) | 3–15 s | 720p | f/l |
| `kwaivgi/kling-video-o1` | $0.112/s | 5, 10 s | 720p | f/l |
| `google/veo-3.1-lite` | $0.03–0.08/s | 4/6/8 s | 720p/1080p | f/l |
| `google/veo-3.1-fast` | $0.08–0.30/s | 4/6/8 s | to 4K | f/l |
| `google/veo-3.1` | $0.20–0.60/s | 4/6/8 s | to 4K | f/l |
| `alibaba/wan-3.0` / `wan-3.0-prime` | $0.05 / $0.068 per s at 480p | 2–30 s | to 1080p | first |
| `alibaba/wan-2.7`, `wan-2.6` | $0.10/s; $0.04–0.15/s | 2–10 s | 720p/1080p | varies |
| `minimax/hailuo-3`, `-3-max`, `-2.3` | $0.13/s; $0.05–0.08/s; $0.0817/s | 5–15 s | 480p–2K | f/l or first |
| `x-ai/grok-imagine-video` / `-1.5` | $0.05–0.07/s; $0.08–0.25/s | 1–15 s | 480p–1080p | first |
| `runway/gen-4.5` | $0.12/s | 2–10 s | 720p | first |
| `black-forest-labs/flux-3-video` | $0.17/s at 720p, $0.29/s at 1080p | 5–20 s | 720p/1080p | f/l |
| `openai/sora-2-pro` | $0.30–0.50/s | 4–20 s | 720p/1080p | none |
| `alibaba/happyhorse-1.0` / `-1.1` | $0.0988/s at 720p | 3–15 s | 720p/1080p | first |
| `heygen/avatar-iv` | $0.05/s | n/a | 720p/1080p | n/a |
| **Video editing:** `black-forest-labs/flux-video-edit` | $0.03/s | source video + edit prompt | | |
| **Video editing:** `runway/aleph-2` | $0.28/s (min $0.56) | video-to-video | | |
| **Upscaling:** `black-forest-labs/flux-video-upscale` | $0.075–0.105 per megapixel-second | | | |

The Seedance models are priced per "video token", and I did not find the conversion from tokens to seconds, so their cost per second is unknown. Every model outputs a standard aspect ratio, so 480×406 has to be cropped or letterboxed in composition (inferred).

**Image generation and editing (53 models; the ones relevant here).** Almost all accept reference images, which means they can edit.

| Model | Price |
|---|---|
| `qwen/qwen-image-3` / `-3-pro` (matches the repo's Qwen still pipeline) | $0.03 per image; pro $0.04 (1k) / $0.075 (2k) |
| `black-forest-labs/flux.2-pro` / `flux.2-klein-4b` (also `flux.2-max`, `-flex`) | $0.03 / $0.014 per megapixel |
| `bytedance-seed/seedream-5-0-lite` (also `-pro`, `seedream-4.5`) | $0.035 per image |
| `openai/gpt-image-2` (also `-1`, `-1-mini`, `2.5-*`) | output $30 per million image tokens |
| `google/gemini-3.1-flash-image` (also `-lite`, `3-pro-image`, `2.5-flash-image`) | output $60 per million image tokens |
| `recraft/recraft-v4.1-vector` (SVG; good for UI icons) | $0.08 per image |

Also listed: `meta/muse-image`, `microsoft/mai-image-2.5*/2.6*`, `krea/krea-2-*`, `x-ai/grok-imagine-image-*`, `sourceful/riverflow-*`, and `inclusionai/ming-image-0.1-design`. OpenRouter also lists audio output through `google/lyria-3-*` (music) and `openai/gpt-audio*`, according to `/api/v1/models`.

**Rule conflict: comfy-cloud.** comfy-cloud's `partner_generate` reaches Seedance, Kling, Veo, and Flux through Comfy's own billing, not through OpenRouter. The owner's rule is "Paid actions go through OpenRouter only" (global CLAUDE.md and the repo AGENTS.md), so comfy-cloud paid generation is **not allowed** unless the owner makes an exception. Every model that matters here is available on OpenRouter anyway (Seedance, Kling, Veo, and Flux are all in the lists above), so an exception is not needed. comfy-cloud stays useful for free discovery (search and prompting guides) only. The HyperFrames `/media-use` skill (below) can call its own generation providers, so it must also be routed to OpenRouter or kept offline.

## 3. Composition frameworks compared

| Tool | License (verified) | Agent support | Review UI with timeline | Fit |
|---|---|---|---|---|
| **HyperFrames** ([repo](https://github.com/heygen-com/hyperframes)) | Apache-2.0; CLI 0.8.62; active (pushed 2026-09-22) | Official skills: `npx skills add heygen-com/hyperframes`, 21 skills including `/music-to-video` (beat-synced), `/motion-graphics`, and `/hyperframes-keyframes` ([README](https://github.com/heygen-com/hyperframes#skills)) | Studio via `npx hyperframes preview`: live frame, **timeline**, inspector ([docs/studio](https://github.com/heygen-com/hyperframes/blob/main/docs/studio/index.mdx)). Binds to 127.0.0.1 by default; `HYPERFRAMES_PREVIEW_HOST=0.0.0.0` opts into LAN (`packages/cli/src/server/portUtils.ts:445`). | HTML/CSS plus GSAP/CSS/WAAPI/Lottie/Three animations that must be seekable, so rendering is deterministic. Plain HTML is ideal for recreating DS-style UI. |
| **Remotion** ([repo](https://github.com/remotion-dev/remotion)) | Custom source-available [LICENSE.md](https://github.com/remotion-dev/remotion/blob/main/LICENSE.md): free for individuals, for-profits with **up to 3 employees**, and non-profits. Companies of 4+ need a Company License: "Creators" at $25/mo per seat, or "Automators" at $0.01 per render with a $100/mo minimum ([remotion.pro/license](https://www.remotion.pro/license)). | Official Agent Skills: `npx skills add remotion-dev/skills` (`/remotion-best-practices`, `/remotion-create`, `/remotion-markup`, `/remotion-studio`) ([docs](https://www.remotion.dev/docs/ai/skills)). The **official MCP is deprecated** and shuts down no earlier than 2026-08-31 ([docs](https://www.remotion.dev/docs/ai/mcp)). | Studio via `npx remotion studio` on port 3000 ([docs](https://www.remotion.dev/docs/studio)); can be exported as a static site with `npx remotion bundle` ([docs](https://www.remotion.dev/docs/studio/deploy-static)). `@remotion/player` embeds a video in any React app ([docs](https://www.remotion.dev/docs/player)). | Most mature (v4.0.527, released 2026-09-22). React/TSX; keyframes through `interpolate`/`spring`. |
| **Motion Canvas** ([repo](https://github.com/motion-canvas/motion-canvas)) | MIT; latest release v3.17.2 (2024-12-14) | No official skills found | Has an editor with real-time preview (README) | Generator-based TypeScript animation; strong for vector explainers, weaker for video-heavy edits (inferred). |
| **Revideo** ([repo](https://github.com/midrender/revideo), moved from redotvideo) | MIT; pushed 2026-07 | None found | React player for preview; headless render API (README) | A Motion Canvas fork aimed at rendering from an API. It has no full timeline editor in the README. |
| **Theatre.js** ([repo](https://github.com/theatre-js/theatre)) | Apache-2.0; **last push 2024-08-14** | None | Studio with a keyframe/graph editor | Good keyframe UI, but it only animates the web; it is not a video renderer and looks unmaintained. Skip. |
| **MoviePy v2** ([repo](https://github.com/Zulko/moviepy)) | MIT; v2.2.1 (2025-05-21) | None | None (Python scripts) | Fine for scripted assembly; no motion-graphics layer and no review UI. |
| **Blender bpy** ([PyPI bpy](https://pypi.org/project/bpy/), [API](https://docs.blender.org/api/current/)) | GPL | None official | Blender UI only; nothing browser-reviewable | Overkill for flat 2D UI; its keyframes are not easily diffable. |
| **ffmpeg filters** ([docs](https://ffmpeg.org/ffmpeg-filters.html)) | LGPL/GPL | n/a | n/a | Use it as the footage pre-processor: `setpts=2*PTS` (speed), `minterpolate=fps=60:mi_mode=mci` (optical-flow slow motion), `xfade` (transitions), `scale`/`noise`/`eq` (degradation). Speed ramps need piecewise `setpts` expressions or segments joined with `concat` (inferred). |

**Video-editing MCP servers.** No Adobe MCP server turned up. DaVinci Resolve 21.1 reportedly ships a built-in MCP server ([Y.M.Cinema, 2026-09-17](https://ymcinema.com/2026/09/17/davinci-resolve-21-1-mcp-ai-assistants-control-edit/)); this is secondary reporting and not verified against Blackmagic's documentation. There is also a community one, [samuelgursky/davinci-resolve-mcp](https://github.com/samuelgursky/davinci-resolve-mcp). Both need Resolve Studio running with a GUI, which does not fit a headless WSL agent or produce a diffable source (inferred). Remotion's MCP is deprecated in favour of skills, and HyperFrames ships skills and no MCP. The trend is **skills over MCP** for code-driven video (verified for those two projects only).

Among the MCP servers on this machine: `scrapecreators` covers reference gathering (IG reels and profiles), `chrome-devtools` covers headless capture of UI mockups, and `figma` can export video and motion context (`export_video`, `get_motion_context`), and HyperFrames has a `/figma` import skill. `runpod` could host renders but is not needed. `markitdown` is not relevant.

## 4. Beat detection

| | librosa | aubio |
|---|---|---|
| License | ISC ([repo](https://github.com/librosa/librosa)) | **GPL-3.0** ([repo](https://github.com/aubio/aubio)) |
| API | `beat.beat_track`, `onset.onset_detect` ([docs](https://librosa.org/doc/latest/generated/librosa.beat.beat_track.html)) | `aubio tempo`, `aubio onset` CLI plus Python bindings ([manual](https://aubio.org/manual/latest/)) |
| On this machine | runs via `uv run --with librosa` (verified above) | not installed; not tested |
| Notes | Already the analyzer inside HyperFrames' `/music-to-video` (`scripts/analyze-beatgrid.py` imports librosa, numpy, and soundfile), which also outputs energy, onsets, silences, and phrases into `audiomap.json` | Lower latency and made for real time. That advantage doesn't matter offline, and GPL adds friction. |

Use librosa. The reel shows that the tracker's grid should be a suggestion, not a hard lock, and the HyperFrames skill says the same: "`bpm` and `beats_sec` are reliable only when the music is genuinely rhythmic" (`skills/music-to-video/SKILL.md:20`).

## 5. Recommendation

**Stack:** HyperFrames for HTML compositions and Studio review, ffmpeg for footage speed and degradation, librosa for the beat map, and OpenRouter for generated stills and clips.

Why not Remotion: it is equally capable and more mature, and Reid, working as an individual, is eligible for the free license. But HyperFrames is Apache-2.0 with no licensing trigger if a team or studio forms, its agent skills already include a beat-synced workflow built on librosa, and plain HTML/CSS is the most direct way to rebuild DS-style UI screens. Keep Remotion as the fallback. HyperFrames even ships `/remotion-to-hyperframes`, but not the reverse.

```
scrapecreators (IG reels, profiles) + chrome-devtools (capture UI refs)
        │  refs/*.png, refs/*.mp4, NOTES.md
        ▼
OpenRouter  /api/v1/images (qwen-image-3, flux.2) ─► assets/stills/
            /api/v1/videos (seedance-2.0-fast, kling-v3.0-std, wan-3.0) ─► assets/clips/
        │  ffmpeg: setpts / minterpolate (slow-mo, ramps), scale+noise (2012 look)
        ▼
librosa (analyze-beatgrid.py) ─► audiomap.json  (beats, onsets, phrases)
        │
        ▼
HyperFrames composition: index.html + compositions/*.html, GSAP keyframes,
cut list in data-start/data-duration  (all text, all in git)
        │  npx hyperframes lint / check / render ─► out/promo.mp4 (480×406 crop)
        ▼
npx hyperframes preview (Studio: timeline + scrubber) ─► share.py <port> ─► tailnet URL
```

**Cost (from the OpenRouter prices above).** Per iteration of a 28 s promo: 10–20 stills with `qwen-image-3` cost $0.30–0.60. About 20 s of generated clips cost $1.00 with `wan-3.0` at 480p, $1.68 with `kling-v3.0-std`, or $0.60–1.60 with `veo-3.1-lite`. Total: **about $1.50–2.50 per full regeneration**, under the $5 judgment line. Everything else (HyperFrames, ffmpeg, librosa, rendering) runs locally for free. Remotion as a fallback is free for Reid as an individual and $25/mo per seat or more for a company of 4+.

**Still unknown:**
1. Whether HyperFrames Studio works behind `share.py`'s tailnet proxy. It binds to 127.0.0.1 and checks the Host header for telemetry identity; the `HYPERFRAMES_PREVIEW_HOST` env var may be needed. Not tested.
2. The Seedance token-to-second conversion, so Seedance's real cost per clip.
3. Which providers `/media-use` calls by default, and whether it can be pointed at OpenRouter. It has to be kept from spending outside OpenRouter.
4. What the music in the reel is, and whether its off-grid cuts follow a structure other than beats (phrases or vocals). The data only rules out beat lock.
5. HyperFrames telemetry defaults: there is a `hyperframes telemetry disable` command; the default posture is unverified.

**Next step:** in a worktree, run `npx hyperframes init nohluhn-test`, rebuild one DS "Erase" pad screen plus three cuts from `audiomap.json`, start `npx hyperframes preview`, and publish it with `python3 ~/agentic-workflow/scripts/share.py <port> --label hf-test`. That settles unknown 1 with no spend.
