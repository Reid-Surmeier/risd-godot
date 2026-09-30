"""Throwaway single-pilot queue client. Resume polls the same request, never retries POST.

Run through stored_bws.sh; credentials remain in process memory. --check is unpaid.
"""
import base64
import hashlib
import json
import os
from pathlib import Path
import sys
import urllib.error
import urllib.parse
import urllib.request

HERE = Path(__file__).resolve().parent
PRIVATE = Path('/tmp/risd-character-pilot-receipts')

def read(path):
    return json.loads(path.read_text())

def write(path, value):
    temporary = path.with_suffix('.tmp')
    with temporary.open('w') as f:
        json.dump(value, f, indent=2)
        f.write('\n')
        f.flush()
        os.fsync(f.fileno())
    temporary.replace(path)

def api(url, payload=None):
    parsed = urllib.parse.urlparse(url)
    assert parsed.scheme == 'https' and parsed.netloc == 'queue.fal.run'
    data = None if payload is None else json.dumps(payload).encode()
    req = urllib.request.Request(url, data=data, headers={
        'Authorization': 'Key ' + os.environ['FAL_KEY'], 'Content-Type': 'application/json'})
    with urllib.request.urlopen(req, timeout=60) as response:
        return json.load(response)

def reserve(ledger, kind, endpoint, amount):
    assert not any(e.get('kind') == kind for e in ledger['entries']), 'Never resubmit an existing reservation'
    assert sum(e['liability_usd'] for e in ledger['entries']) + amount <= ledger['ceiling_usd']
    ledger['entries'].append({'kind': kind, 'provider': 'fal', 'model': endpoint,
        'count': 1, 'liability_usd': amount, 'actual_cost_usd': None,
        'state': 'submission-may-have-started; never-resubmit'})

def main(mode, kind='mesh'):
    if mode == '--check':
        test = {'ceiling_usd': 4, 'entries': [{'liability_usd': .01}]}
        reserve(test, 'mesh', 'test', 1.2)
        for k, cost in [('mesh', .1), ('rig', 4)]:
            try:
                reserve(test, k, 'test', cost)
            except AssertionError:
                continue
            raise AssertionError('duplicate or over-budget reservation accepted')
        print('PASS: duplicate submission and over-budget reservations refused')
        return
    assert kind in ('mesh', 'rig')
    assert os.environ.get('FAL_KEY'), 'Missing credential; no reservation'
    PRIVATE.mkdir(mode=0o700, exist_ok=True)
    state_path = HERE / (kind + '-queue.json')
    if mode == '--submit':
        assert not state_path.exists(), 'Existing request must be polled, never submitted again'
        if kind == 'mesh':
            endpoint, amount = 'meshy/v7.1/image-to-3d', 1.2
            payload = read(HERE / 'mesh-input.json')
            payload['image_url'] = 'data:image/png;base64,' + base64.b64encode((HERE / 'front.png').read_bytes()).decode()
        else:
            endpoint, amount = 'fal-ai/meshy/rigging/multi-animation', .32
            payload = read(HERE / 'rig-input.json')
            payload['model_url'] = read(PRIVATE / 'mesh-result.json')['model_glb']['url']
        ledger = read(HERE / 'spend.json')
        reserve(ledger, kind, endpoint, amount)
        write(HERE / 'spend.json', ledger)
        result = api('https://queue.fal.run/' + endpoint, payload)
        write(state_path, {key: result[key] for key in ('request_id', 'status_url', 'response_url')})
        print(kind, 'submitted; reservation USD', amount, 'request_id', result['request_id'])
    elif mode == '--poll':
        state = read(state_path)
        result = api(state['status_url'])
        status = result['status']
        print(kind, status)
        if status != 'COMPLETED':
            return
        result = api(state['response_url'])
        write(PRIVATE / (kind + '-result.json'), result)
        os.chmod(PRIVATE / (kind + '-result.json'), 0o600)
        outputs = []
        def download(value, name):
            if isinstance(value, dict) and isinstance(value.get('url'), str):
                url = value['url']; parsed = urllib.parse.urlparse(url)
                assert parsed.scheme == 'https' and (parsed.hostname.endswith('.fal.media') or parsed.hostname.endswith('.meshy.ai'))
                suffix = Path(parsed.path).suffix.lower()
                if suffix not in ('.glb', '.png', '.jpg', '.jpeg', '.webp'):
                    return
                target = HERE / (kind + '-' + name + suffix)
                if not target.exists():
                    with urllib.request.urlopen(url, timeout=60) as response:
                        target.write_bytes(response.read())
                outputs.append({'path': target.name, 'sha256': hashlib.sha256(target.read_bytes()).hexdigest(), 'bytes': target.stat().st_size})
            elif isinstance(value, dict):
                for key, child in value.items():
                    download(child, name + '-' + key)
            elif isinstance(value, list):
                for index, child in enumerate(value):
                    download(child, name + '-' + str(index))
        download(result, 'output')
        write(HERE / (kind + '-outputs.json'), {'request_id': state['request_id'], 'outputs': outputs,
            'seed': result.get('seed'), 'actual_cost_usd': None, 'price_basis': 'Listed selected-option rate retained as liability'})
        ledger = read(HERE / 'spend.json')
        entry = next(e for e in ledger['entries'] if e.get('kind') == kind)
        entry['state'] = 'completed; billed cost unverified'
        entry['request_id'] = state['request_id']
        write(HERE / 'spend.json', ledger)
        print('Downloaded', len(outputs), 'artifacts; URLs and credentials omitted')
    else:
        raise AssertionError('Use --submit, --poll, or --check')

if __name__ == '__main__':
    try:
        main(*sys.argv[1:])
    except urllib.error.HTTPError as error:
        print('HTTP', error.code, '; reservation retained; no automatic resubmission')
        sys.exit(1)
    except Exception as error:
        print(type(error).__name__, '; no automatic resubmission')
        sys.exit(1)
