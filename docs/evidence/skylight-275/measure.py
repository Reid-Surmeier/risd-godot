"""Reproduce #275's two independent planar height checks, using saved frame clicks.

python3 docs/evidence/skylight-275/measure.py
Coordinates refer to the 960 x 1707 tone-mapped, autorotated frames in NOTES.md.
No reference pixels are copied to the game. OpenCV + numpy; no paid service.
"""
import json
import cv2
import numpy as np

observations = [
    dict(frame='IMG_6379 127.0s', accession='69.094', size=[2.21, 2.223],
         corners=[[302,373],[544,392],[532,640],[303,630]], floor=[435,935],
         door_head=None, above_entry=1.64),
    dict(frame='IMG_6379 54.0s', accession='2026.3', size=[1.53, 1.524],
         corners=[[142,113],[564,107],[548,544],[217,534]], floor=[390,1075],
         door_head=[390,769], above_entry=2.00),
]
rng = np.random.default_rng(275)
rows = []
for o in observations:
    w,h = o['size']
    square=np.float32([[0,0],[w,0],[w,h],[0,h]])
    def solve(corners):
        matrix=cv2.getPerspectiveTransform(np.float32(corners),square)
        projected=cv2.perspectiveTransform(np.float32([[o['floor']]]),matrix)[0,0]
        height=float(projected[1]-h/2)
        return height,matrix
    height,matrix=solve(o['corners'])
    trials=[solve(np.array(o['corners'])+rng.uniform(-3,3,(4,2)))[0] for _ in range(2000)]
    row=dict(frame=o['frame'],canvas=o['accession'],canvas_m=o['size'],
             corners_px=o['corners'],floor_px=o['floor'],
             canvas_center_above_lower_m=round(height,3),
             inferred_storey_m=round(height-o['above_entry'],3),
             click_jitter_5_95_m=[round(float(v),3) for v in np.percentile(trials,[5,95])],
             homography=matrix.tolist())
    if o['door_head']:
        head=cv2.perspectiveTransform(np.float32([[o['door_head']]]),matrix)[0,0]
        row['floor_to_cased_door_head_m']=round(height-float(head[1]-h/2),3)
    rows.append(row)
print(json.dumps(dict(method='canvas-plane homography; inherited height relative to entry',
    rows=rows,chosen_storey_m=2.55,estimated_total_error_m=.30,
    caveat='Extrapolated floor and canvas share a wall plane; entry-relative work heights inherited. '
           'Jitter interval excludes lens distortion, canvas/front offset and floor click error.'),indent=2))
