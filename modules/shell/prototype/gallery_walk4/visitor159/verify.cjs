const fs=require('node:fs'), assert=require('node:assert/strict');
for(const path of process.argv.slice(2)){
  const data=JSON.parse(fs.readFileSync(path,'utf8'));
  const d=data.report||data;
  assert.equal(d.paintings,23);assert.equal(d.bones,42);assert.equal(d.detail_seen,true);
  assert(d.demo_seconds>=32&&d.demo_seconds<32.5);
  assert(d.max_penetration<.01,`floor penetration ${d.max_penetration}`);
  assert(d.max_planted_vertex_drift<.02,`planted drift ${d.max_planted_vertex_drift}`);
  for(const stage of ['front idle','profile turn','back turn','straight walk','diagonal walk','stop','reverse','reverse stop','look','artwork approach / gesture'])assert(d.stages[stage]>0,stage);
  for(const gesture of ['look','wave'])assert(d.records.some(r=>r.gesture===gesture),`missing ${gesture}`);
  for(const r of d.records.filter(r=>r.stationary))assert(r.left_x>.08&&r.right_x<-.08,`crossed/narrow neutral stance at ${r.time}: ${r.left_x}, ${r.right_x}`);
  const pointing=d.records.filter(r=>r.pointing_dot>=0);
  assert(pointing.length>=5,'missing held artwork-directed pointing');
  for(const r of pointing)assert(r.pointing_dot>.98,`arm not aimed at artwork at ${r.time}: ${r.pointing_dot}`);
  for(const gesture of ['look','wave']){
    const framed=d.records.filter(r=>r.gesture===gesture&&r.target_in_frame!==null);
    assert(framed.length>=3,`missing held target framing: ${gesture}`);
    for(const r of framed)assert(r.target_in_frame&&r.camera_clearance>=1.79,`target framing/clearance at ${r.time}`);
  }
  if(data.samples){
    const wall=(data.end-data.start)/1000;
    assert(Math.abs(d.demo_seconds/wall-1)<.05,`wall-clock ratio ${d.demo_seconds/wall}`);
  }
  console.log(`PASS ${path}: 23 works, actual 42-bone target, all controller stages, look/wave/detail, planted contacts`);
}
