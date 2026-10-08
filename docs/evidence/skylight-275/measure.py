"""Reproduce #275's two independent planar height checks, using saved frame clicks.

python3 docs/evidence/skylight-275/measure.py
Coordinates refer to the 960 x 1707 tone-mapped, autorotated frames in NOTES.md.
No reference pixels are copied to the game. OpenCV + numpy; no paid service.
"""
import json
import cv2
import numpy as np

shape = np.array([[.2426,.0014],[.0013,.2972],[.0039,.6942],[.2407,.9935],
                  [.6952,.9993],[.9993,.4989],[.6965,.0007]], dtype=np.float32)

observations = [
    dict(frame='IMG_6379 127.0s', accession='69.094', size=[2.21, 2.223],
         corners=[[302,373],[544,392],[532,640],[303,630]], floor=[435,935],
         door_head=None, above_entry=1.64, ceiling=[435,230], cornice_foot=[435,272]),
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
    if o.get('ceiling'):
        high=cv2.perspectiveTransform(np.float32([[o['ceiling'],o['cornice_foot']]]),matrix)[0]
        row['ceiling_px']=o['ceiling']
        row['cornice_foot_px']=o['cornice_foot']
        row['lower_floor_to_ceiling_m']=round(height-float(high[0,1]-h/2),3)
        row['entry_to_ceiling_m']=round(row['lower_floor_to_ceiling_m']-2.55,3)
        row['entry_to_cornice_foot_m']=round(height-float(high[1,1]-h/2)-2.55,3)
    rows.append(row)
label_observations = [
    dict(frame='IMG_6379 127.0s', accession='69.094', size=[2.21,2.223],
         corners=observations[0]['corners'], label=[514,820], above_lower=4.11, error=.20),
    dict(frame='IMG_6379 127.0s', accession='73.018', size=[2.242,2.038],
         corners=[[720,375],[689,464],[689,560],[717,628],[771,628],[836,479],[785,337]],
         label=[783,907], above_lower=4.30, error=.35, shape=shape,
         corner_line=[[680,300],[642,870]]),
    dict(frame='IMG_6379 154.5s', accession='73.018', size=[2.242,2.038],
         corners=[[497,405],[452,511],[457,626],[496,708],[590,736],[689,574],[601,379]],
         label=[632,1050], above_lower=4.30, error=.35, shape=shape,
         corner_line=[[409,294],[410,930]]),
    dict(frame='IMG_6379 54.0s', accession='2026.3', size=[1.53,1.524],
         corners=observations[1]['corners'], label=[383,644], above_lower=4.53, error=.20),
    dict(frame='IMG_6379 6.5s', accession='2000.17', size=[1.88,2.21],
         corners=[[219,564],[289,662],[264,855],[190,808]], label=[263,955],
         above_lower=4.30, error=.40),
    dict(frame='IMG_6379 159.5s', accession='2025.19', size=[1.524,1.524],
         corners=[[370,67],[783,75],[731,535],[390,514]], label=[880,650],
         above_lower=4.45, error=.30),
]
labels = []
spacing = []
for o in label_observations:
    w,h = o['size']
    target = o.get('shape',np.float32([[0,0],[1,0],[1,1],[0,1]]))*np.float32([w,h])
    matrix,_ = cv2.findHomography(np.float32(o['corners']),target)
    projected = cv2.perspectiveTransform(np.float32([[o['label']]]),matrix)[0,0]
    labels.append(dict(frame=o['frame'],canvas=o['accession'],corners_px=o['corners'],
                       label_center_px=o['label'],
                       horizontal_from_canvas_center_m=round(float(projected[0]-w/2),3),
                       above_lower_m=round(o['above_lower']+h/2-float(projected[1]),3),
                       estimated_error_m=o['error'],
                       inherited_canvas_center_above_lower_m=o['above_lower'],
                       method='canvas-plane homography; seven outline points for Mangold'))
    if o.get('corner_line'):
        # Intersect the observed room corner with the canvas-centre level;
        # extrapolating to the cornice magnifies lens / outline click error.
        line=matrix[1]-h/2*matrix[2]
        a=np.array([*o['corner_line'][0],1.])
        delta=np.array([*(np.array(o['corner_line'][1])-o['corner_line'][0]),0.])
        point=a-delta*np.dot(line,a)/np.dot(line,delta)
        corner=cv2.perspectiveTransform(np.float32([[[point[0],point[1]]]]),matrix)[0,0]
        spacing.append(dict(frame=o['frame'],canvas=o['accession'],corner_line_px=o['corner_line'],
                            center_from_northwest_corner_m=round(w/2-float(corner[0]),3),
                            estimated_error_m=.30))
    if o['accession']=='2025.19':
        samples=np.float32([[[18,0],[78,380],[110,575],[162,767]]])
        corner=cv2.perspectiveTransform(samples,matrix)[0]
        spacing.append(dict(frame=o['frame'],canvas=o['accession'],corner_samples_px=samples[0].tolist(),
                            center_from_northeast_corner_m=[round(w/2-float(p[0]),3) for p in corner],
                            chosen_along_m=2.10,estimated_error_m=.30))
print(json.dumps(dict(method='canvas-plane homography; inherited height relative to entry',
    rows=rows,chosen_storey_m=2.55,estimated_total_error_m=.30,
    label_positions=labels,
    spacing_checks=spacing,
    caveat='Extrapolated floor and canvas share a wall plane; entry-relative work heights inherited. '
           'Jitter interval excludes lens distortion, canvas/front offset and floor click error.'),indent=2))
