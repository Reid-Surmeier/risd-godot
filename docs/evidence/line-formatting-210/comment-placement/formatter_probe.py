import json,pathlib,subprocess,collections,hashlib
from gdtoolkit.parser import parser
from gdtoolkit.formatter.safety_checks import check_tree_invariant
x=json.load(open(str(pathlib.Path(__file__).parent/'remainder-before.json')));reject=set(json.load(open('docs/evidence/line-formatting-210/manifest.json'))['final_restored_files']);group=collections.defaultdict(list)
for r in x['rows']:
 if r['kind']=='inline-comment' and r['file'] not in reject and len(r['comment'].strip())+len(r['source'])-len(r['source'].lstrip())<=100:group[r['file']].append(r)
root=pathlib.Path('/tmp/risd-210-inline-probe');root.mkdir(exist_ok=True);records=[]
for f,rows in group.items():
 old=subprocess.check_output(['git','show','c47c61e9:'+f],text=True);lines=old.splitlines(keepends=True)
 for r in sorted(rows,key=lambda r:r['line'],reverse=True):
  idx=r['line']-1;line=lines[idx];assert line.rstrip()==r['source'];comment=r['comment'];pos=line.rfind(comment);assert pos>0;indent=line[:len(line)-len(line.lstrip())];lines[idx:idx+1]=[indent+comment+'\n',line[:pos].rstrip()+'\n']
 p=root/f;p.parent.mkdir(parents=True,exist_ok=True);p.write_text(''.join(lines));r=subprocess.run(['/tmp/risd-ci-gdtoolkit-208/bin/gdformat',str(p)],capture_output=True,text=True);after=p.read_text();result={'file':f,'lines':len(rows),'before_sha256':hashlib.sha256(old.encode()).hexdigest(),'after_sha256':hashlib.sha256(after.encode()).hexdigest(),'formatter_exit':r.returncode,'formatter_output':r.stdout+r.stderr}
 try:
  assert r.returncode==0
  check_tree_invariant(old,after,parser.parse(old),parser.parse(after))
  assert [str(t).rstrip() for t in parser.parse_comments(old).children]==[str(t).rstrip() for t in parser.parse_comments(after).children]
  check=subprocess.run(['/tmp/risd-ci-gdtoolkit-208/bin/gdformat','--check',str(p)],capture_output=True,text=True);assert check.returncode==0
  result['equivalence_and_stability']='pass'
 except Exception as e:result['equivalence_and_stability']='fail';result['error']=str(e)
 records.append(result)
(root/'results.json').write_text(json.dumps(records,indent=2)+'\n');print(json.dumps({'files':len(records),'lines':sum(r['lines'] for r in records),'pass':sum(r['equivalence_and_stability']=='pass' for r in records)},indent=2))
