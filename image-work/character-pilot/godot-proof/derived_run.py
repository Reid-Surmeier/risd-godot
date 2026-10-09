"""THROWAWAY: inspect a combined derived GLB without overwriting raw evidence.

Run: python3 <this file> <path-to-normalized-combined-glb>
"""
from pathlib import Path
import hashlib, json, shutil, subprocess, sys, tempfile

HERE = Path(__file__).resolve().parent
SOURCE = Path(sys.argv[1]).resolve()
DEST = HERE / "normalized"
DEST.mkdir(exist_ok=True)
GODOT = shutil.which("godot") or "/home/reidsurmeier/bin/godot"
# Keep the camera, sampling and skin calculation identical to the raw proof.
proof = (HERE / "proof.gd").read_text().replace(
    'assert(names.size() == 1)\n\t\tvar clip: String = names[0]',
    'assert(names.size() >= 2)\n\t\tvar clip := ""\n\t\tfor name in names:\n\t\t\tif name.to_lower() == kind:\n\t\t\t\tclip = name\n\t\tassert(not clip.is_empty(), "missing derived clip " + kind)',
)
with tempfile.TemporaryDirectory(prefix="character230-derived-") as scratch:
    project = Path(scratch)
    for kind in ("walk", "idle"):
        shutil.copy2(SOURCE, project / (kind + ".glb"))
    (project / "proof.gd").write_text(proof)
    (project / "project.godot").write_text('[application]\nconfig/name="THROWAWAY derived proof230"\n[display]\nwindow/size/viewport_width=640\nwindow/size/viewport_height=640\n[rendering]\nrenderer/rendering_method="gl_compatibility"\n')
    for name, args in [("import.log", ["--headless", "--editor", "--import", "--quit"]), ("proof.log", ["--display-driver", "x11", "--rendering-method", "gl_compatibility", "--script", "res://proof.gd"])]:
        with (project / name).open("w") as log:
            subprocess.run([GODOT, "--path", scratch, *args], stdout=log, stderr=subprocess.STDOUT, timeout=60, check=True)
    evidence = json.loads((project / "evidence.json").read_text())
    assert all(c["bones"] == 24 and c["foot_transform_changed"] for c in evidence["clips"].values())
    scales = {kind: [float(v) for v in c["feet_samples"][0]["hips_local_pose_scale"].strip("()").split(",")] for kind, c in evidence["clips"].items()}
    evidence["source"] = SOURCE.name
    evidence["source_sha256"] = hashlib.sha256(SOURCE.read_bytes()).hexdigest()
    evidence["hips_pose_scales"] = scales
    evidence["clip_scale_gate"] = "PASS" if max(abs(float(v) - 1) for c in evidence["clips"].values() for sample in c["feet_samples"] for v in sample["hips_local_pose_scale"].strip("()").split(",")) < 0.00001 else "FAIL"
    evidence["walk_review_floor_penetration_m"] = max(-p["min_relative_to_review_floor"] for p in evidence["clips"]["walk"]["skin_bounds_samples"])
    evidence["contact_quality_accepted"] = False
    before = json.loads((HERE / "evidence.json").read_text())
    evidence["duration_differences_from_raw_seconds"] = {kind: c["seconds"] - before["clips"][kind]["seconds"] for kind, c in evidence["clips"].items()}
    evidence["duration_gate"] = "PASS" if max(abs(d) for d in evidence["duration_differences_from_raw_seconds"].values()) < 0.00001 else "FAIL"
    for name in ["proof.gd", "idle.png", "idle-mid.png", "walk-side.png", "import.log", "proof.log"] + [f"walk-{i:02d}.png" for i in range(8)]:
        shutil.copy2(project / name, DEST / name)
    (DEST / "evidence.json").write_text(json.dumps(evidence, indent=2) + "\n")
    subprocess.run(["ffmpeg", "-loglevel", "error", "-y", "-framerate", str(8 / evidence["clips"]["walk"]["seconds"]), "-i", str(DEST / "walk-%02d.png"), "-vf", "fps=30", "-c:v", "libx264", "-pix_fmt", "yuv420p", str(DEST / "walk-sampled.mp4")], check=True)
    print(json.dumps({key: evidence[key] for key in ["source", "clip_scale_gate", "hips_pose_scales", "walk_review_floor_penetration_m", "contact_quality_accepted"]}))
