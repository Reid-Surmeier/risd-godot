"""Asset Pass batch runner, rebuilt after the 2026-08-30 overspend.

Three things it does that the first one did not:

* **Reconciles against the provider, not against run.json.** A call that times out
  client-side is still billed, and writes no run.json, so local sums under-count exactly
  the calls that cost money for nothing. The ceiling is checked against OpenRouter's own
  usage figure.
* **Stops on waste, not only on the ceiling.** If billed-but-undelivered spend passes a
  small threshold, the batch halts rather than grinding through the rest of the set.
* **Runs from a clean worktree with a long read timeout**, both passed in by the caller.
"""
import json, os, subprocess, sys, time, urllib.request

BRIEFS, OUTROOT = sys.argv[1], sys.argv[2]
CEILING  = float(sys.argv[3])        # provider-reported session usage not to exceed
BASELINE = float(sys.argv[4])        # provider usage at session start
REPO     = sys.argv[5]               # clean worktree to run the client from
WASTE_STOP = float(sys.argv[6]) if len(sys.argv) > 6 else 0.35
REF = "/home/reidsurmeier/Qwen-3-pro-Pipeline/artifacts/references/risd-icon-anchors-v001/anchors-all-five.png"
KEY = os.environ["OPENROUTER_API_KEY"]

def provider_usage():
    r = urllib.request.Request("https://openrouter.ai/api/v1/key",
                               headers={"Authorization": f"Bearer {KEY}"})
    with urllib.request.urlopen(r, timeout=30) as resp:
        return float((json.load(resp)["data"].get("usage") or 0.0))

def images_in(d):
    return len([f for f in os.listdir(d)]) if os.path.isdir(d) else 0

def interleaved(names):
    """One icon from each group in turn, rather than all of one group then all of the next.

    The budget may stop the batch part-way, and a half-finished set that covers every
    group is worth far more than one that has finished ACT and not started UI: the
    grammar can be judged across families, and the game has something from each.
    """
    groups: dict[str, list[str]] = {}
    for n in sorted(names):
        groups.setdefault(n.split("-")[0], []).append(n)
    order = []
    longest = max((len(v) for v in groups.values()), default=0)
    for i in range(longest):
        for g in sorted(groups):
            if i < len(groups[g]):
                order.append(groups[g][i])
    return order

paths = [os.path.join(BRIEFS, f)
         for f in interleaved([f for f in os.listdir(BRIEFS) if f.endswith(".json")])]
os.makedirs(OUTROOT, exist_ok=True)
start_usage = provider_usage()
print(f"{len(paths)} briefs | provider usage now ${start_usage:.5f} | ceiling ${CEILING:.2f} | repo {REPO}", flush=True)

delivered, waste, log = 0, 0.0, []
for path in paths:
    slug = os.path.basename(path)[:-5]
    out = os.path.join(OUTROOT, slug)
    if os.path.isdir(out) and any(f.startswith("image-") for f in os.listdir(out)):
        print(f"  skip     {slug}", flush=True); continue

    before = provider_usage()
    if before >= CEILING:
        print(f"  CEILING  reached at ${before:.5f} — stopping before {slug}", flush=True); break
    if waste >= WASTE_STOP:
        print(f"  WASTE    ${waste:.5f} billed-but-undelivered — stopping before {slug}", flush=True); break

    env = dict(os.environ, QWEN_OPENROUTER_TIMEOUT_SECONDS="1200")
    t0 = time.time()
    r = subprocess.run(["python3", "-m", "qwen_ui_pipeline", "generate", path,
                        "--reference", REF, "--output-dir", out],
                       cwd=REPO, capture_output=True, text=True, env=env, timeout=1500)
    elapsed = time.time() - t0
    time.sleep(4)                      # the usage endpoint lags a little
    after = provider_usage()
    billed = after - before
    got = os.path.exists(os.path.join(out, "run.json"))
    if got:
        delivered += 1
        print(f"  ok       {slug:34} {elapsed:5.0f}s  billed ${billed:.5f}  total ${after:.5f}", flush=True)
    else:
        waste += billed
        print(f"  LOST     {slug:34} {elapsed:5.0f}s  billed ${billed:.5f}  NOTHING RETURNED  "
              f"(waste ${waste:.5f})", flush=True)
        err = (r.stderr or r.stdout or "").strip().splitlines()
        if err: print(f"           {err[-1][:150]}", flush=True)
    log.append({"icon": slug, "elapsed_s": round(elapsed, 1), "billed_usd": round(billed, 5),
                "delivered": got})

end_usage = provider_usage()
print(f"\ndelivered {delivered} | billed-but-lost ${waste:.5f}")
print(f"provider usage ${end_usage:.5f} (session ${end_usage-BASELINE:.5f}) | this batch ${end_usage-start_usage:.5f}")
json.dump({"log": log, "delivered": delivered, "waste_usd": round(waste, 5),
           "provider_usage_end": end_usage}, open(os.path.join(OUTROOT, "_batch2-log.json"), "w"), indent=1)
