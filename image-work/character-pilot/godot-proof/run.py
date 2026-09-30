"""THROWAWAY character230: isolated native proof of unchanged provider clip GLBs."""
from pathlib import Path
import hashlib, json, shutil, subprocess, tempfile

HERE = Path(__file__).resolve().parent
GODOT = shutil.which("godot") or "/home/reidsurmeier/bin/godot"
SOURCES = {"walk": "rig-output-basic_animations-walking_glb.glb", "idle": "rig-output-animations-0-animation_glb.glb"}
with tempfile.TemporaryDirectory(prefix="character230-godot-") as scratch:
    project = Path(scratch)
    for kind, filename in SOURCES.items():
        shutil.copy2(HERE.parent / filename, project / (kind + ".glb"))
    shutil.copy2(HERE / "proof.gd", project / "proof.gd")
    (project / "project.godot").write_text('[application]\nconfig/name="THROWAWAY raw provider proof230"\n[display]\nwindow/size/viewport_width=640\nwindow/size/viewport_height=640\n[rendering]\nrenderer/rendering_method="gl_compatibility"\n')
    for name, args in [("import.log", ["--headless", "--editor", "--import", "--quit"]), ("proof.log", ["--display-driver", "x11", "--rendering-method", "gl_compatibility", "--script", "res://proof.gd"])]:
        with (project / name).open("w") as log:
            subprocess.run([GODOT, "--path", scratch, *args], stdout=log, stderr=subprocess.STDOUT, timeout=60, check=True)
    evidence = json.loads((project / "evidence.json").read_text())
    assert all(c["bones"] == 24 and c["foot_transform_changed"] for c in evidence["clips"].values())
    evidence["source_hashes"] = {filename: hashlib.sha256((HERE.parent / filename).read_bytes()).hexdigest() for filename in SOURCES.values()}
    evidence["bone_rests_identical"] = evidence["clips"]["idle"]["bone_rest"] == evidence["clips"]["walk"]["bone_rest"]
    evidence["clip_scale_gate"] = "FAIL: Idle Hips scale1.176471 versus Walk1.0"
    evidence["walk_review_floor_penetration_m"] = max(-p["min_relative_to_review_floor"] for p in evidence["clips"]["walk"]["skin_bounds_samples"])
    evidence["contact_quality_accepted"] = False
    for name in ["idle.png", "idle-mid.png", "walk-side.png", "import.log", "proof.log"] + [f"walk-{i:02d}.png" for i in range(8)]:
        shutil.copy2(project / name, HERE / name)
    (HERE / "evidence.json").write_text(json.dumps(evidence, indent=2) + "\n")
    subprocess.run(["ffmpeg", "-loglevel", "error", "-y", "-framerate", "7.5", "-i", str(HERE / "walk-%02d.png"), "-vf", "fps=30", "-c:v", "libx264", "-pix_fmt", "yuv420p", str(HERE / "walk-sampled.mp4")], check=True)
    print("RAW PROVIDER IMPORT PROVED; SCALE/CONTACT ACCEPTANCE FAILED; evidence saved")
