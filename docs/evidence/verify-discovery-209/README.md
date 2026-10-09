# Verify discovery209

Installed GDScript lint was silently skipped: early-exiting grep closesfind's pipe; pipefail reports141, and the optionallint if-condition treats it as false. The minimal repair uses find-print-quit and checks whether it returned a filename. Lint selection/rules and failure propagation remain unchanged.

`python3 docs/evidence/verify-discovery-209/discovery_check.py scripts/check.sh`

Actualold checkscript RED falsely reports checks passed withoutcallinginstalledlint. Corrected GREEN passesall900filenames and propagateslint exit1 withoutsuccessmessage. No fake runtime/property assertions. No module interface/error/acceptance changes.

Realgdtoolkit4.5.0 workingtree lint FAIL1280 initially, includingfourlonglines in new208privatefixture andthreeexistinguntracked owner/trial findings. Fourprivatefixture lines wrapped; directfixturelintGREEN0 and actual nativeaspect14PASSagain. Tracked current lint nowFAIL1273, identical source findings topre208125927da1273, introduced0. Prior logs retained; finalcomparison is authoritative. No rule disabled, broadrewrites orbaselinePASSclaim. Full lint currentlyfails, ratherthanbeing silentlyskipped.

HostedVerify run36682358949 ondc8555f6 FAIL beforesteps, emptyrunner/no log; prior125927da identical. Check-rollup access403 limitsannotations; causeunverified. No billing/settings/runnerprovisioning or repeatedhostedretry. LocalGodot/seam check passes13existingwarnings whenoptionaltoolabsent; installedlint correctlyfails on known1273trackedfindings. This remains an overall verification/releasegate; no all-CI-pass claim.

PR166 carries14realimageattachments and current completeprivate36cb27af build/picturegallery. Runtime/archive/sourcehashes unchanged by supportscript/evidence formatting. Final149/162/173/174/177 owner approval and208/206/199 verification completion remainopen; automationenabled, original square173 edits preserved. No paidaction/art/generation/bake.
