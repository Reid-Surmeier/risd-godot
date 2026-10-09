"""Exercise the bake command's failure recovery in an isolated project."""
from pathlib import Path
import os
import subprocess
import sys
import tempfile

source = Path(__file__).with_name('run.py')
for variant, existing_plugin, saved in ((name, plugin, saved) for name in ("room", "white") for plugin in (False, True) for saved in (False, True)):
    with tempfile.TemporaryDirectory() as temporary:
        root = Path(temporary)
        runner = root / 'modules/shell/prototype/gallery_walk4/bake/run.py'
        runner.parent.mkdir(parents=True)
        runner.write_bytes(source.read_bytes())
        project = root / 'project.godot'
        project.write_text('[application]\n' + ('[editor_plugins]\n' if existing_plugin else ''))
        baked = runner.parent.parent / 'baked'
        baked.mkdir()
        for name in (variant + extension for extension in ('.tscn', '.lmbake', '.exr', '.exr.import')):
            (baked / name).write_bytes(b'previous valid bake')
        before = {path: path.read_bytes() for path in [project, *baked.iterdir()]}
        # The child process modifies outputs, then the editor fails. This models
        # the external tool's failure, not the restoration logic under test.
        godot = root / 'godot'
        godot.write_text('#!' + sys.executable + '\n'
                         'from pathlib import Path\nimport sys\n'
                         'root=Path(sys.argv[sys.argv.index("--path")+1])\n'
                         'for p in (root/"modules/shell/prototype/gallery_walk4/baked").iterdir():\n'
                         '    p.write_bytes(b"unfinished bake")\n'
                         + ('print("BAKE_OK users=137") if "--editor" in sys.argv else None\n' if saved else '') +
                         'sys.exit(2 if "--editor" in sys.argv else 0)\n')
        godot.chmod(0o755)
        result = subprocess.run([sys.executable, str(runner)] + (["--white"] if variant == "white" else []),
                                env={**os.environ, 'PATH': str(root) + os.pathsep + os.environ['PATH']},
                                capture_output=True, timeout=10)
        assert project.read_bytes() == before[project], 'project settings not restored'
        if saved and not existing_plugin:
            assert result.returncode == 0, 'saved bake discarded after editor shutdown failure'
            assert all(path.read_bytes() == b'unfinished bake' for path in baked.iterdir()), 'completed outputs not retained'
        else:
            assert result.returncode != 0, 'failed bake reported success'
            assert all(path.read_bytes() == content for path, content in before.items()), 'failed bake changed working assets/settings'
print('BAKE_RECOVERY failed/preflight runs restore files; saved runs survive editor shutdown failure')
