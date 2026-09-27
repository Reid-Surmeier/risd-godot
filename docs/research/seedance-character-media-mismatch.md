# Seedance character media mismatch

Read-only diagnosis, 2026-09-26. No provider request, paid retry, asset edit, Run Record mutation or tool edit was performed. The only new file is this report.

**Confirmed immediate cause:** the provider's MP4 stores `moov` after `mdat`. The maintained verifier supplies the original bytes to a non-seekable FFmpeg stdin pipe, which cannot return to the media data after discovering the trailing index. It fails before comparing expected resolution. Two separate latent contract violations remain: output dimensions are larger than requested, and output is one frame longer. The Run must remain failed.

## Reproduced evidence

| Evidence | New character | Previous kid |
|---|---|---|
| Application / Run | `gallery-character-motion/run-b987214702e0dedab7819356` | `grand-gallery-v2-motion-b/run-b5aa2b802a994e89b3cf1dab` |
| Immutable expected media | 720 × 720, 8 s, no audio | 480 × 480, 4 s, no audio |
| FFprobe and complete seekable-file decode | **960 × 960, 193 frames at 24 fps, 8.041667 s**, no audio | **640 × 640, 97 frames at 24 fps, 4.041667 s**, no audio |
| Exact verifier pipe invocation | exit 183, `partial file`, demuxing invalid data | exit 183, same error |
| Seekable file invocation, same decoder/framehash output | exit 0, all 193 frames, empty stderr | exit 0, all 97 frames, empty stderr |
| MP4 top-level index location | `mdat` offset 21,722; `moov` offset 4,999,959 | `mdat` offset 21,722; `moov` offset 1,214,169 |
| Provider receipt cost | $0.60795 | $0.1358 |

The new raw output SHA-256 is `3f792dfdc2d3a99ce38f8976a5daebbfa50e058f4bef29ba36a108dd36cb9852`. Evidence is in the original application's `artifacts/image-generation/runs/<Run>/failure.json`, `request.json`, provider receipts and `outputs/output.mp4`. The earlier `grand-gallery-v2-motion/run-ca92b5b2fdc3275ab54aae8c` is a separate HTTP 520/unreconciled submission, not the completed old clip above.

The exact failing decoder arguments are implemented in [`video-verification.ts`](/home/reidsurmeier/Image-generation-pipline/modules/video-verification/video-verification.ts): `/usr/bin/ffmpeg -nostdin -hide_banner -loglevel error -xerror -threads 1 -protocol_whitelist pipe -i pipe:0 -map 0:v:0 -map 0:a? -f framehash -`. System FFmpeg is 6.1.1, satisfying the required major. The file is not proven corrupt by this failure: complete file-based decoding succeeded. The limitation is the non-seekable ingest path.

The actual failure code is `VIDEO_MEDIA_INVALID`. An expected-size or expected-duration disagreement would instead throw `VIDEO_CHECK_FAILED` after inspection. This distinction is important: merely adjusting expected dimensions would not repair the original failure.

## Wire format and provider sizing

The maintained public Python adapter [`_wire_request`](/home/reidsurmeier/Image-generation-pipline/seedance/src/seedance_icons/adapter_host.py) derives:

```json
{"model":"bytedance/seedance-2.0-mini","duration":8,"size":"720x720","generate_audio":false}
```

It additionally sends the prompt and image-only references as `frame_images` with first/last frame roles. This shape is consistent with current [OpenRouter documentation](https://openrouter.ai/docs/guides/overview/multimodal/video-generation): `size` is exact `WIDTHxHEIGHT`, documented as interchangeable with `resolution` plus `aspect_ratio`; duration is integer seconds. The adapter does not send `resolution` or `aspect_ratio` along with size. There is no basis to call the local field misspelled or missing.

Both observed square outputs are **4/3 larger per axis** than the size request, and include one additional 24-fps frame. A provider mapping of nominal 480p/720p to 640²/960² square canvases is a plausible explanation, **not a proven provider implementation detail**. No exact provider wire echo or backend settings are preserved by these receipts. Future correction should obtain/document that mapping rather than guess a new paid request.

The free capabilities profile lists 720×720 for Mini but does not list 960×960. The retained `capabilities.validate_request()` rejects an unsupported exact size; the public `adapter_host.py` does not call that helper. A new application plan claiming 960×960 to match an already-returned file would neither prove provider compliance nor reconcile the failed immutable Run. Do not do this.

## Why the cost exceeded the plan

The local estimate assumed 720² × 8 × 24 pixels/frames, divided by 1024, at $0.0000035/video-token: **$0.3402**. The returned media computes exactly:

`960 × 960 × 193 / 1024 × $0.0000035 = $0.60795`.

This matches the receipt, including both canvas growth and the extra frame. The application's $0.35 ceiling was exceeded by $0.25795, about 73.7%. Its failure record still reports `spendState: unknown` while containing provider actual-cost evidence; preserve both facts and reconcile the ledger explicitly. Do not report a refund, zero cost, or a successful within-budget run. The earlier kid receipt also matches actual 640² × 97 frames at that rate ($0.1358).

## Recovery without falsifying acceptance

1. **Keep the original Run, raw MP4, hashes and failure immutable.** No retry is warranted by this diagnosis. Independently inspect the usable first four seconds as failed-run evidence, with `humanReviewed:false` and `certified:false`; record visually rejected gesture segments separately.
2. **Container-only repair is technically available**, as a separately named derivative: FFmpeg `-c copy -movflags +faststart` relocates the index without re-encoding video. [FFmpeg's primary documentation](https://ffmpeg.org/ffmpeg-formats.html#mov_002c-mp4_002c-ismv) describes the operation. Verify derivative provenance plus full decoded frame hashes against the raw seekable source. This was **not executed** in this diagnosis. It repairs streaming compatibility, not resolution/duration/cost deviations or motion defects.
3. **A study derivative is not a tool-certified output.** The maintained verifier's [ADR 0007](/home/reidsurmeier/Image-generation-pipline/docs/adr/0007-decode-seedance-evidence-locally.md) requires exact original-byte pipe decoding. The local application `AUTHORITY.md` says failed segments are not imported. No public recovery command accepting altered expected media or amended bytes was established in this inspection. Independent checks cannot silently impersonate that gate.
4. **Practical application adoption needs explicit scoped authority for the deviation** (or a reviewed tool recovery feature): accept a specifically identified usable walking segment from the failed source as an experimental application asset, retain failed tool status and pending human fields, disclose actual spend and reject the bad gesture segment. Existing approval to generate inferred motion is not itself evidence that changed media/cost and an uncertified failed output were reviewed. Prepare the derivative, checks and visual proof before requesting any final decision; do not ask for another generation merely to avoid the issue.
5. **Fix the maintained tool under its own issue before more paid work.** Add a safe seekable decoder strategy or recorded container-normalization stage, tested against trailing-index MP4 and malformed fixtures; preserve original bytes and hashes. Separately model nominal provider sizing and one-frame duration semantics, with explicit tolerances decided before execution. Do not relax all deterministic checks or rewrite this application's immutable expectation after the fact.

No new generation is necessary to establish these defects. The existing paid media is sufficient to test the container fix, sizing calculation, independent visual review, and any explicitly authorized application-only recovery.
