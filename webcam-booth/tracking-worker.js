// On-device inference. No frame is sent to an external service.
let tracker;
const clamp=n=>Math.max(0,Math.min(1,Number.isFinite(n)?n:0));
self.onmessage=async({data})=>{
 try{
  if(data.type==='portrait'){
   if(!tracker){importScripts(new URL('vision_bundle.js',data.base).href);tracker=await Vision.FaceLandmarker.createFromOptions(await Vision.FilesetResolver.forVisionTasks(new URL('wasm/',data.base).href),{baseOptions:{modelAssetPath:new URL('face_landmarker.task',data.base).href,delegate:'CPU'},runningMode:'IMAGE',numFaces:1,outputFaceBlendshapes:true,outputFacialTransformationMatrixes:true});}
   else await tracker.setOptions({runningMode:'IMAGE'});
   const bitmap=await createImageBitmap(await (await fetch(data.image)).blob());let result;
   try{result=tracker.detect(bitmap)}finally{bitmap.close()}
   const points=result.faceLandmarks[0];
   if(!points){postMessage({type:'unavailable',token:data.token,error:'No face anchors found on this portrait.'});return;}
   const center=(a,b)=>[(points[a].x+points[b].x)/2,(points[a].y+points[b].y)/2];
   const anchors={left:center(33,133),right:center(362,263),mouth:center(61,291),mouthWidth:Math.abs(points[291].x-points[61].x)};
   await tracker.setOptions({runningMode:'VIDEO'});postMessage({type:'ready',token:data.token,anchors});
  }else if(data.type==='frame'){
   let result;try{result=tracker.detectForVideo(data.bitmap,data.timestamp)}finally{data.bitmap.close()}
   const points=result.faceLandmarks[0];
   if(!points){postMessage({type:'frame',token:data.token,face:false,timestamp:data.timestamp});return;}
   const values=Object.fromEntries((result.faceBlendshapes[0]?.categories??[]).map(x=>[x.categoryName,clamp(x.score)]));
   const l=points[33],r=points[263];
   postMessage({type:'frame',token:data.token,face:true,timestamp:data.timestamp,values:{blinkL:values.eyeBlinkRight??0,blinkR:values.eyeBlinkLeft??0,smile:((values.mouthSmileLeft??0)+(values.mouthSmileRight??0))/2,jaw:values.jawOpen??0},pose:{x:(l.x+r.x)/2,y:(l.y+r.y)/2,angle:Math.atan2(r.y-l.y,r.x-l.x)},landmarks:points.length});
  }
 }catch{data.bitmap?.close();postMessage({type:'unavailable',token:data.token,error:'Expression tracking unavailable; portrait stays neutral.'})}
};
