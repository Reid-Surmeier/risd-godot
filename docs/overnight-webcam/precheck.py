"""Fallback only: skip live leases, finished goals and runs after morning cutoff."""
import datetime
import json
import pathlib
import sys


def should_run(checkpoint, now):
    timestamp = lambda value: datetime.datetime.fromisoformat(value.replace('Z', '+00:00'))
    return (checkpoint['status'] != 'complete'
            and now < timestamp(checkpoint['deadline_utc'])
            and now >= timestamp(checkpoint['lease_until_utc']))


if __name__ == '__main__':
    if '--check' in sys.argv:
        checkpoint = {'status': 'active', 'lease_until_utc': '2026-09-30T05:00:00Z',
                      'deadline_utc': '2026-09-30T12:00:00Z'}
        instant = lambda h: datetime.datetime(2026, 9, 30, h, tzinfo=datetime.timezone.utc)
        assert not should_run(checkpoint, instant(4))
        assert should_run(checkpoint, instant(6))
        assert not should_run(checkpoint, instant(12))
        checkpoint['status'] = 'complete'
        assert not should_run(checkpoint, instant(6))
        print('fallback precheck passed')
    else:
        checkpoint = json.loads(pathlib.Path(__file__).with_name('checkpoint.json').read_text())
        sys.exit(0 if should_run(checkpoint, datetime.datetime.now(datetime.timezone.utc)) else 20)
