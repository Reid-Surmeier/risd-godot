"""Saved native stage for the selected reference-comparison profile; usable through MCP."""
from pathlib import Path
import runpy, sys

HERE = Path(__file__).resolve().parent
profile = Path(sys.argv[sys.argv.index('--profile') + 1]).resolve() if '--profile' in sys.argv else HERE / 'authored-walk-v5.json'
assert profile.is_relative_to(HERE) and profile.is_file()
sys.argv = [str(HERE.parent / 'motion-diagnosis/correct.py'), '--profile', str(profile)]
runpy.run_path(sys.argv[0], run_name='__main__')
