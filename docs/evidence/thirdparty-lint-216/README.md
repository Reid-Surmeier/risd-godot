# Unchanged third-party source —216

The lint command now omits exactly `./modules/sketchbook/mixbox/mixbox.gd`, preserving upstream source instead of rewriting its style. All other authored targets and every lint rule remain present; native compilation and seam discovery are unchanged. Installed gdtoolkit exclusions do not filter explicit file arguments, so the existing find command receives one exact-path filter.

[Specification](spec.md), [focused check](check.py), [preservation](preservation.json), [independent source review](source-review.json). Run: `/tmp/risd-gdtoolkit-211/bin/python docs/evidence/thirdparty-lint-216/check.py`.

The checker compares actual old/new target commands:153→152, only the exact SDK removed. SDK, lookup resource and license bytes match main and recorded provenance; native SDK parse passes. [Actual installed check](check-installed.log) remains FAIL113:110tracked authored findings plus3original untracked findings. [Counts](lint-summary.json) show exactly9upstream style findings excluded, not fixed. Remaining authored findings:85declaration-order,9load-constant-name,8local-variable-name,4duplicated-load,3max-returns and1file-length. No long-line finding remains in authored tracked files.

No runtime source changes follow244be7e2, so its [native/full-Web/private-hash/picture proof](../literal-layout-215/README.md) remains the exact runtime evidence. Protected12assets, museum records and square173 are unchanged. Current runtime is privately shared and directly pictured in PR166. Whole162, final hands-on owner approval and unresolved commercial/attribution rights remain open. Automation stays enabled. No generation/provider/spend/bake/public redistribution/hosted retry/settings/release.
