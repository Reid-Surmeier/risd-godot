# Jev for gameplay-fidelity triage

Research for [issue #105](https://github.com/Reid-Surmeier/risd-godot/issues/105), checked 2026-09-20. Primary sources are TypeSafe's current documentation; the prior Jev note in the agentic-workflow context was used as comparison.

## Findings

### Verified: typed primitives and outputs

- **Noul** asks a yes/no question and returns `noul`, the probability that yes is correct. It has no separate confidence field.
- **Choice** selects one key from a declared map, up to 255 options, and returns `choice`, the full `probabilities` distribution, and `confidence`.
- **Score** rates an ordered rubric of 2–10 levels and returns a probability-weighted `score`, `legend`, per-level `probabilities`, and `confidence`.
- Requests contain `state`, `model`, and a keyed `questions` map. Question IDs are for the caller; they are not sent to the model. Answers are constrained to the declared answer space.

Sources: [primitives](https://docs.typesafe.ai/primitives), [Choice](https://docs.typesafe.ai/primitives/choice), [Score](https://docs.typesafe.ai/primitives/score), [Noul](https://docs.typesafe.ai/primitives/noul), [API](https://docs.typesafe.ai/api).

### Verified: input modality and limits

- `state` may be text, a JSON object, or an array of text values. `instructions` and criteria may also be structured.
- Jev 1.13 accepts **text only**. It does not accept images, audio, video, or binary game captures. Screenshots must first be converted into deterministic measurements/metadata or judged by a separate vision-capable generative model.
- The current limit is 64k tokens per request, with 32k for `state` plus the longest question. Filter state before sending it.

Source: [models](https://docs.typesafe.ai/models).

### Verified: confidence and probability semantics

- Choice probabilities cover all declared options and sum to 1. Score probabilities cover all levels. Confidence is a TypeSafe-derived summary of how concentrated the distribution is; the full distribution remains available.
- Noul's value itself is the yes probability; `0.5` means equally uncertain, not “medium severity.”
- TypeSafe recommends confidence bands: act automatically at high confidence, confirm/review at medium confidence, and do not act at low confidence. Thresholds must be tuned to the cost of a wrong decision.
- The prior research correctly warns: calibration is population-level behavior, not a guarantee for one answer, and semantically equivalent questions should not be assumed to have identical results. Enforce invariants and arithmetic in code.

Sources: [confidence](https://docs.typesafe.ai/confidence), [Noul](https://docs.typesafe.ai/primitives/noul), [Jev 1.13 jaggedness](https://docs.typesafe.ai/model-jaggedness/jev-1.13).

### Verified: batching, fan-out, and dependent calls

- Multiple questions over the same state are evaluated independently and in parallel in one request. Mixing Noul, Choice, and Score is supported.
- TypeSafe recommends speculative fan-out: ask questions the code might need, then ignore irrelevant answers. Extra questions add input tokens but little latency; a cited cookbook reports 13 questions in one call as 11.5x cheaper and 9.6x faster than 13 calls.
- Use a second request only when the first answer changes what data/options must be fetched or supplied. Hierarchical classification chains Choice calls for larger taxonomies.

Source: [primitives / ask multiple questions](https://docs.typesafe.ai/primitives).

### Verified: live/offline testing

- The official [system-one-adapter-python](https://github.com/typesafe-ai/system-one-adapter-python) is a drop-in `TypeSafeClient` replacement backed by another LLM, not a local Jev model. It supports structured or prompted outputs, probability/discrete modes, retries, attempt diagnostics, and replay of recorded provider attempts.
- Therefore it is useful for contract/integration tests and workflow comparison, but it is **not** an offline Jev-fidelity oracle. A truly offline test must use recorded Jev responses or deterministic fixtures and must not claim Jev accuracy.
- Production/live validation should run a small labelled fixture set against a pinned Jev version, record the returned model ID, probabilities, confidence, latency, token usage, and route outcome, then tune thresholds from observed errors.

Source: [TypeSafe adapter README](https://github.com/typesafe-ai/system-one-adapter-python).

### Verified: cost, rate, and version constraints

- TypeSafe currently lists `jev-1.13.0` at `$0.042` per million input tokens (`$42` per billion); output tokens are free.
- Listed limits are 250,000 tokens/second and 1,200 requests/minute, and TypeSafe says limits may change dynamically. Direct API `429` responses should honor retry/backoff behavior.
- `jev-latest` currently points to `jev-1.13.0`, but aliases can move. Pin the version while tuning gameplay thresholds.
- The repository’s no-credentials rule still applies: no API key, live call, or credential setup is needed for this research.

Source: [models](https://docs.typesafe.ai/models), [API](https://docs.typesafe.ai/api).

## Decision for gameplay fidelity triage

**Verified fit:** use Jev after deterministic extraction to classify a bounded finding (`interaction_missing`, `interaction_broken`, `style_drift`, `asset_mismatch`, `unknown`), score severity on an explicit rubric, and choose `repair`, `retest`, or `human_review`—each with a confidence gate and an `other/unknown` escape hatch.

**Inferred design:** send compact structured state such as control ID, declared action, observed event trace, error codes, reference-style tokens, and deterministic visual measurements. Ask independent questions in one batch. Let ordinary code enforce click coverage, pixel/grid measurements, hashes, retries, repair scope, and pass/fail. A low-confidence or contradictory result escalates; it never directly edits scenes or generated pixels.

**Not Jev’s job:** reading screenshots directly, discovering every control from pixels, generating GDScript, generating/reassembling art, exact counting/arithmetic, or deciding whether a deterministic test passed. A generative/vision model may propose a bounded repair or produce pixels, but code must validate and assemble the result.

## Smallest useful test seam

1. Run the Godot/Playtest-Godot harness and emit a compact JSON finding per declared control plus reference/current visual measurements.
2. Run Jev live only in an opt-in triage stage; batch classification, severity, and route questions in one request.
3. Store the exact request, pinned model ID, response, thresholds, cost, and route decision as evidence.
4. Replay the same fixtures offline with recorded responses or adapter outputs for contract tests; never substitute those results for live Jev calibration.
5. Permit only bounded repair tickets; rerun deterministic interaction and visual checks before accepting or escalating.
