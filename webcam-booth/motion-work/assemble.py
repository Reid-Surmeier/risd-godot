"""Mechanical timing/codec assembly; preserves the failed source Run unchanged."""
from pathlib import Path
import subprocess,json,hashlib,numpy as np
root=Path(__file__).resolve().parents[1]
source=root/'motion-work/source.mp4'
raw=subprocess.check_output(['ffmpeg','-v','error','-i',str(source),'-vf','fps=24,scale=160:90','-pix_fmt','rgb24','-f','rawvideo','pipe:1'])
frames=np.frombuffer(raw,dtype=np.uint8).reshape(-1,90,160,3)
# Detect first changed pixels in the previously empty upper canvas; preserve all fuse frames before it.
first=None
for i,f in enumerate(frames):
 a=f[:55].astype(float);green=(a[:,:,1]-np.maximum(a[:,:,0],a[:,:,2])>50)
 if np.mean(~green)>.015:first=i;break
assert first is not None and first>24*5
cut=first/24
# Hold the first burst frame until the wall-clock ten-second mark; use the actual burst thereafter.
filter=f'[0:v]split[a][b];[a]trim=start=0:end={cut},setpts=PTS-STARTPTS,setpts=PTS*{10/cut}[fuse];[b]trim=start={cut}:end=11,setpts=PTS-STARTPTS,setpts=PTS*{1/(11-cut)}[burst];[fuse][burst]concat=n=2:v=1:a=0,fps=24,scale=1024:576,trim=duration=11,setpts=PTS-STARTPTS[out]'
output=root/'assets/fuse-explosion.ogv'
subprocess.run(['ffmpeg','-v','error','-i',str(source),'-filter_complex',filter,'-map','[out]','-an','-c:v','libtheora','-q:v','8','-frames:v','264','-y',str(output)],check=True)
probe=json.loads(subprocess.check_output(['ffprobe','-v','error','-count_frames','-show_entries','stream=width,height,nb_read_frames,duration,codec_name','-show_entries','format=duration','-of','json',str(output)]))
v=probe['streams'][0];assert v['codec_name']=='theora' and v['width']==1024 and v['height']==576
assert abs(float(probe['format']['duration'])-11)<.001
# Theora elides duplicate packets; acceptance counts displayed CFR frames after decode.
decoded=subprocess.check_output(['ffmpeg','-v','error','-i',str(output),'-vf','fps=24,scale=160:90','-pix_fmt','rgb24','-f','rawvideo','pipe:1'])
display=np.frombuffer(decoded,dtype=np.uint8).reshape(-1,90,160,3);assert len(display)==264
burst_frames=[]
for i,f in enumerate(display):
 a=f[:55].astype(float);green=(a[:,:,1]-np.maximum(a[:,:,0],a[:,:,2])>50)
 if np.mean(~green)>.015:burst_frames.append(i)
assert burst_frames and burst_frames[0]>=240 and burst_frames[0]<=243
assert any(np.mean(f[:,:,1].astype(float)-np.maximum(f[:,:,0],f[:,:,2])<50)>.95 for f in display[240:])
record={'sourceRun':'run-16c6dd84b5c249fa0282d930','sourceToolVerdict':'failed: VIDEO_MEDIA_INVALID, preserve unchanged','sourceSha256':hashlib.sha256(source.read_bytes()).hexdigest(),'sourceDuration':11.041667,'detectedBurstSourceSeconds':cut,'timingAssembly':filter,'outputSha256':hashlib.sha256(output.read_bytes()).hexdigest(),'probe':probe,'displayFrames':len(display),'firstBurstFrame':burst_frames[0],'visualAcceptance':'pending in-booth inspection','historicalFidelity':False,'actualCostUsd':'2.55195','reservedLedgerCents':256}
(root/'motion-work/assembly.json').write_text(json.dumps(record,indent=2)+'\n')
print({'burst_source_seconds':cut,'output':str(output),'frames':264})
