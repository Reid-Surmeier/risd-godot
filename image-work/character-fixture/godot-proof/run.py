"""THROWAWAY fixture230: run the native proof in a temporary Godot project."""
from pathlib import Path
import hashlib, json, shutil, subprocess, tempfile

HERE = Path(__file__).resolve().parent
GODOT = shutil.which("godot") or "/home/reidsurmeier/bin/godot"
fixture = HERE.parent / "fixture.glb"
with tempfile.TemporaryDirectory(prefix="fixture230-godot-") as scratch:
    project = Path(scratch)
    shutil.copy2(fixture, project / "fixture.glb")
    shutil.copy2(HERE / "proof.gd", project / "proof.gd")
    (project / "project.godot").write_text('[application]\nconfig/name="THROWAWAY fixture230"\n[display]\nwindow/size/viewport_width=512\nwindow/size/viewport_height=512\n[rendering]\nrenderer/rendering_method="gl_compatibility"\n')
    for name, args in [("import.log", ["--headless", "--editor", "--import", "--quit"]), ("proof.log", ["--display-driver", "x11", "--rendering-method", "gl_compatibility", "--script", "res://proof.gd"])]:
        with (project / name).open("w") as log:
            subprocess.run([GODOT, "--path", scratch, *args], stdout=log, stderr=subprocess.STDOUT, timeout=60, check=True)
    evidence = json.loads((project / "evidence.json").read_text())
    assert evidence["bones"] == 41 and evidence["imported_animations"] == 76
    assert evidence["walk_changes_foot"] and evidence["idle_to_walk_changes_foot"]
    assert evidence["effect_event_calls"] == evidence["effect_idle_control_calls"] == 1
    evidence["fixture_sha256"] = hashlib.sha256(fixture.read_bytes()).hexdigest()
    for name in ["idle.png", "walk.png", "dust.png", "dust-control.png", "import.log", "proof.log"]:
        shutil.copy2(project / name, HERE / name)
    (HERE / "evidence.json").write_text(json.dumps(evidence, indent=2) + "\n")
    print(json.dumps(evidence))
