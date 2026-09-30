import json, subprocess
from pathlib import Path
from lark import Lark
from gdtoolkit.parser.gdscript_indenter import GDScriptIndenter
from gdtoolkit.formatter.safety_checks import check_tree_invariant
baseline, candidate = '04eb31a9', 'ba6b3c05'
grammar = Path('/tmp/risd-ci-gdtoolkit-208/lib/python3.12/site-packages/gdtoolkit/parser')
def parser(name):
    return Lark.open(str(grammar/name), parser='lalr', start='start',
                     postlex=GDScriptIndenter(), maybe_placeholders=False,
                     cache=False, regex=True)
code, comments = parser('gdscript.lark'), parser('comments.lark')
files = subprocess.check_output(
    ['git', 'diff', '--name-only', baseline, candidate, '--', '*.gd'],
    text=True).splitlines()
tree_pass, comment_pass, findings = 0, 0, []
for file in files:
    old, new = [
        subprocess.check_output(['git', 'show', ref+':'+file], text=True)
        for ref in [baseline, candidate]
    ]
    try:
        check_tree_invariant(old, new, code.parse(old+'\n'), code.parse(new+'\n'))
        tree_pass += 1
    except Exception as error:
        findings.append({'file': file, 'check': 'normalized tree', 'error': str(error)})
    before = [str(c).rstrip() for c in comments.parse(old).children]
    after = [str(c).rstrip() for c in comments.parse(new).children]
    if before == after:
        comment_pass += 1
    else:
        findings.append({'file': file, 'check': 'ordered comments'})
result = {'baseline': baseline, 'candidate': candidate, 'changed_gd_files': len(files),
          'normalized_tree_pass': tree_pass, 'ordered_comment_pass': comment_pass,
          'findings': findings}
print(json.dumps(result, indent=2))
assert len(files) == 108 and not findings
