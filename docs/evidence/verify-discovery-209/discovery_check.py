"""Exercise actual check.sh with many scripts and an installed lint recorder."""
from pathlib import Path
import json,os,shutil,subprocess,tempfile,sys
script=Path(sys.argv[1]).resolve()
with tempfile.TemporaryDirectory(prefix='risd-verify-209-') as temp:
    root=Path(temp);(root/'scripts').mkdir();(root/'bin').mkdir();(root/'src').mkdir()
    shutil.copy2(script,root/'scripts/check.sh');(root/'MODULES.md').write_text('')
    for name in ['dirname','find','grep','cut']:(root/'bin'/name).symlink_to(shutil.which(name))
    for i in range(900):(root/'src'/(f'sample-{i:04d}-'+'x'*180+'.gd')).write_text('# fixture\n')
    lint=root/'bin/gdlint';lint.write_text('#!/bin/sh\nprintf "%s\\n" "$#" > "$RISD_LINT_MARKER"\nexit "${RISD_LINT_EXIT:-0}"\n');lint.chmod(0o755)
    marker=root/'called';env={**os.environ,'PATH':str(root/'bin'),'RISD_LINT_MARKER':str(marker)}
    r=subprocess.run(['/bin/bash',str(root/'scripts/check.sh')],env=env,capture_output=True,text=True,timeout=120)
    result={'check_exit':r.returncode,'lint_called':marker.exists(),'lint_argument_count':int(marker.read_text()) if marker.exists() else 0,'stdout':r.stdout,'stderr':r.stderr}
    print(json.dumps(result,indent=2));assert marker.exists() and int(marker.read_text())==900,'Installed GDScript lint was silently skipped'
    env['RISD_LINT_EXIT']='1'
    failed=subprocess.run(['/bin/bash',str(root/'scripts/check.sh')],env=env,capture_output=True,text=True,timeout=120)
    assert failed.returncode==1 and 'checks passed' not in failed.stdout,'Lint failure was hidden'
    print('lint invocation and error propagation PASS')
