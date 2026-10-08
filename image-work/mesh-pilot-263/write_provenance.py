"""Write modules/shell/collection_rooms/assets/meshes/<accession>/PROVENANCE.md from batch/objects.json and the
mesh's own record. usage: write_provenance.py ACCESSION [NOTE]   (run from the repository root)"""
import sys, json, hashlib, os
acc = sys.argv[1]; note = sys.argv[2] if len(sys.argv) > 2 else ""
here = os.path.dirname(os.path.abspath(__file__)); o = json.load(open(f"{here}/batch/objects.json"))[acc]
d = f"modules/shell/collection_rooms/assets/meshes/{acc}"; name = acc.replace(".", "-"); r = json.load(open(f"{d}/{name}.json"))
sha = lambda p: hashlib.sha256(open(p, "rb").read()).hexdigest()
out, imp, run = r["out"], r["imported"], o["run"]; w, h, dep = out["size_m_width_height_depth"]
rows = [("Source", f"the museum's catalogue photograph, `{o['source']}` (see the `SOURCES.md` beside it)", "—", "—"),
        ("Cut-out", f"`cut_photo.py`, {o['cut']}: `image-work/mesh-pilot-263/batch/{acc}/cut.png`", "free", f"`{sha(f'{here}/batch/{acc}/cut.png')[:16]}…`"),
        ("Mesh", f"Flora, RISD EDU Workspace, {run.get('model', 'Tripo H3.1 (`i3d-tripo-h3-1-i3d`)')}, {run['params']}; run `{run['id']}`", f"quoted {run['quote']:.2f} USD, charged {run['charged']:.2f} USD", f"`{run['sha256'][:16]}…`")]
if "refused" in o: rows.insert(2, ("Refused", f"Flora, RISD EDU Workspace, {o['refused']['model']}, {o['refused']['params']}; run `{o['refused']['id']}`: {o['refused']['error']}", f"quoted {o['refused']['quote']:.2f} USD, charged {o['refused']['charged']:.2f} USD", "—"))
if o["photo"]: rows.append(("Photograph over the front", f"`project_photo.py`: {run['view']}", "free", "—"))
rows.append(("Clean-up", "`prepare_mesh.py`: " + "; ".join(json.dumps(s) for s in r["steps"] if not any(k in s for k in ("islands", "boundary_edges"))).replace('"', "") or "`prepare_mesh.py`", "free", f"`{out['sha256']}`"))
text = f"# {acc} {o['title'].split('*')[1]}\n\n{o['title']} RISD Museum {acc}.\n\n| Step | What | Cost | sha256 |\n| --- | --- | --- | --- |\n"
text += "".join(f"| {a} | {b} | {c} | {e} |\n" for a, b, c, e in rows)
text += f"\n{out['triangles']:,} triangles, one {out['texture']['px'][-1][0]} px texture. Size {w} × {h} × {dep} m (width × height × depth). In the pack: {imp['total_bytes'] // 1024} KB (mesh {imp['mesh_bytes'] // 1024}, texture {imp['texture_bytes'] // 1024}).\n"
if note: text += f"\n{note}\n"
open(f"{d}/PROVENANCE.md", "w").write(text); print("wrote", f"{d}/PROVENANCE.md")
