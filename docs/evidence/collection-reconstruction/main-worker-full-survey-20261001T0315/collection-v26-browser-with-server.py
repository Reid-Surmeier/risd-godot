import subprocess,time,urllib.request
from pathlib import Path
root=Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion/lowpoly-room-v26')
with open('/tmp/collection-v26-browser-server.log','w') as log:
 server=subprocess.Popen(['python3','-m','http.server','18782','--bind','127.0.0.1','--directory',str(root/'web')],stdout=log,stderr=log)
 try:
  for _ in range(40):
   assert server.poll() is None,'Owned preview server exited'
   try:
    with urllib.request.urlopen('http://127.0.0.1:18782/',timeout=1) as response:assert response.status==200
    break
   except OSError:time.sleep(.1)
  else:raise RuntimeError('Preview server did not start')
  with open('/tmp/collection-v26-browser-with-server.log','w') as output:
   result=subprocess.run(['node','modules/shell/prototype/collection_reconstruction/doorway_walk_browser.cjs','http://127.0.0.1:18782/',str(root/'evidence'),'1100','room-front'],stdout=output,stderr=output)
  print('Browser exit:',result.returncode)
  raise SystemExit(result.returncode)
 finally:
  if server.poll() is None:server.terminate();server.wait()
