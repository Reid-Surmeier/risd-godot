from pathlib import Path
import subprocess,json,re,hashlib
root=Path('docs/evidence/line-formatting-210');manifest=json.loads((root/'manifest.json').read_text());results=[];logs=root/'parser';logs.mkdir(exist_ok=True)
for record in manifest['records']:
 if not record['changed']:continue
 path=record['file'];current=Path(path).read_bytes()
 if hashlib.sha256(current).hexdigest()!=record['after_sha256']:
  assert hashlib.sha256(current).hexdigest()==record['before_sha256'],path
  results.append({'file':path,'disposition':'rejected/restored','reason':'native Playground multiline lambda indent rejection'});continue
 r=subprocess.run(['godot','--headless','--path','.','--check-only','--script',path],capture_output=True,text=True,timeout=90);output=r.stdout+r.stderr
 bad=r.returncode!=0 or re.search(r'^ERROR|SCRIPT ERROR',output,re.M)
 if bad:
  (logs/(path.replace('/','__')+'.log')).write_text(output)
  Path(path).write_bytes(subprocess.check_output(['git','show','04eb31a9:'+path]))
  base=subprocess.run(['godot','--headless','--path','.','--check-only','--script',path],capture_output=True,text=True,timeout=90);baseline=base.stdout+base.stderr;(logs/(path.replace('/','__')+'-baseline.log')).write_text(baseline)
  results.append({'file':path,'disposition':'rejected/restored','candidate_exit':r.returncode,'baseline_exit':base.returncode,'baseline_has_errors':bool(re.search(r'^ERROR|SCRIPT ERROR',baseline,re.M))})
  print('REJECT/RESTORE',path,flush=True)
 else:results.append({'file':path,'disposition':'native parse PASS','exit':r.returncode})
 (root/'parser-results.json').write_text(json.dumps(results,indent=2)+'\n')
print('native parse accepted',sum(x['disposition']=='native parse PASS' for x in results),'rejected',sum(x['disposition']!='native parse PASS' for x in results),flush=True)
