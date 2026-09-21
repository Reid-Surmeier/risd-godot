"""One bounded Jev call; existing receipt prevents retries after ambiguous spend.

Run through stored_bws.sh run OPENROUTER_API_KEY OPENROUTER_API_KEY -- python3 ...
API contract: https://openrouter.ai/docs/api/api-reference/alphadecisions/submit-a-decisions-questions-and-answers-request
"""
import json
import os
from pathlib import Path
import sys
import urllib.request
import urllib.error

report = json.loads(Path(sys.argv[1]).read_text())
out = Path(sys.argv[2])
out.mkdir(parents=True, exist_ok=True)
findings = next(event['checks'] for event in report['log'] if event['event'] == 'checks')
payload = {'model': 'typesafe/jev-1.13', 'state': {
    'context': 'Godot Playground: observed input tests against real page with synthetic saves. Existing artwork frames must remain unchanged.',
    'findings': findings,
}, 'questions': {'route': {'type': 'choice', 'instructions': 'Choose the appropriate next repair operation for the observed failures.', 'criteria': {
    'repair_code': 'Missing interactive behavior requires native controls and event handlers.',
    'regenerate_art': 'Interactive behavior works, but the image asset violates the reference style.',
    'no_change': 'All observed tests pass.',
    'unknown': 'The evidence does not establish a repair direction.'}}}}
receipt = out / 'jev-receipt.json'
with receipt.open('x') as file:
    json.dump({'state': 'reserved_or_unknown', 'provider': 'OpenRouter', 'model': payload['model'],
               'count': 1, 'budget_usd': 0.01, 'retry': 'never_resubmit_automatically'}, file, indent=2)
(out / 'jev-request.json').write_text(json.dumps(payload, indent=2))
request = urllib.request.Request('https://openrouter.ai/api/alpha/decisions',
    data=json.dumps(payload).encode(), headers={'Authorization': 'Bearer ' + os.environ['OPENROUTER_API_KEY'],
                                              'Content-Type': 'application/json'}, method='POST')
try:
    with urllib.request.urlopen(request, timeout=45) as response:
        result = json.load(response)
except (urllib.error.URLError, TimeoutError):
    print('Jev request failed or ambiguous; reservation retained, no retry.')
    sys.exit(1)
(out / 'jev-response.json').write_text(json.dumps(result, indent=2))
receipt.write_text(json.dumps({'state': 'response_received', 'provider': 'OpenRouter',
    'model': payload['model'], 'count': 1, 'usage': result.get('usage'), 'retry': 'never_resubmit_automatically'}, indent=2))
print(json.dumps({'answers': result.get('answers'), 'usage': result.get('usage')}))
