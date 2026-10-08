"""Place a finished mesh through the room generator's own inventory (the route the Apostles use). Free.
usage: place_inventory.py ASSET ACCESSION ROOM_FOLDER GLB_NAME [DRAFT_EXTENSION_DIR]
Run from the repository root. Copies the record GLB to image-work/collection-room-remodel/additions/ROOM_FOLDER/GLB_NAME
with the lean import settings, adds "mesh" to the asset's volume_instances row in video-inventory.json, re-keys the
work in representation.json (as a mesh, off the shortfalls) and its caption row in objects.json to the accession,
because a placed mesh reports its accession. With a draft room project, gives its generated row the same key and
copies the GLB there, so the placement can be checked without a rebuild. Text edits only: no file is rewritten whole."""
import sys, json, shutil, os
asset, acc, folder, glb = sys.argv[1:5]; draft = sys.argv[5] if len(sys.argv) > 5 else None
A = "image-work/collection-room-remodel/"; rec = f"modules/shell/prototype/mesh_pilot/meshes/{acc}/{acc.replace('.', '-')}.glb"
dst = f"{A}additions/{folder}/{glb}"; shutil.copy(rec, dst); shutil.copy(f"{A}additions/medieval/apostle-41045.glb.import", dst + ".import")
p = A + "video-inventory.json"; t = open(p).read(); old = f'      "asset": "{asset}",\n      "accession": "{acc}",\n'
assert t.count(old) == 1, f"row of {asset} not found once"
t = t.replace(old, f'      "asset": "{asset}",\n      "mesh": "additions/{folder}/{glb}",\n      "accession": "{acc}",\n', 1); json.loads(t); open(p, "w").write(t)
p = "modules/shell/collection_rooms/representation.json"; t = open(p).read(); d = json.loads(t); o = d.get("objects", d); room = o[asset]["room"]; form = o[asset]["form"]
old = [l for l in t.split("\n") if l.startswith(f'  "{asset}": {{')]; assert len(old) == 1
t = t.replace(old[0], f'  "{acc}": {{"room": "{room}", "form": "{form}", "as": "mesh"}},', 1)
assert t.count(f'  "{asset}",\n') == 1; t = t.replace(f'  "{asset}",\n', "", 1); d = json.loads(t); open(p, "w").write(t)
p = "modules/shell/collection_rooms/objects.json"; t = open(p).read(); assert t.count(f'  "{asset}": {{\n') == 1
t = t.replace(f'  "{asset}": {{\n', f'  "{acc}": {{\n', 1); assert json.loads(t)[acc]["accession"] == acc; open(p, "w").write(t)
if draft:
    os.makedirs(f"{draft}/assets/additions/{folder}", exist_ok=True); shutil.copy(dst, f"{draft}/assets/additions/{folder}/{glb}"); shutil.copy(dst + ".import", f"{draft}/assets/additions/{folder}/{glb}.import")
    q = draft + "/assets/catalogue-objects.json"; g = json.load(open(q)); n = 0
    for r in g["instances"]:
        if r.get("asset") == asset: r["mesh"] = f"additions/{folder}/{glb}"; n += 1
    assert n == 1; json.dump(g, open(q, "w"), indent=2)
print(f"placed {acc} ({asset}) in {room}: shortfalls {len(d['shortfalls'])}")
