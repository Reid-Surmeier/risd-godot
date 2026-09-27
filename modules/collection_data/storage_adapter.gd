extends RefCounted
## Browser IndexedDB adapter. Native runs keep one in-memory document for playtests.

const DB_SCRIPT := """
(() => {
  const DB = 'risd-collection-browser', STORE = 'collection', KEY = 'saved', VERSION = 1;
  const blank = () => ({schema_version: 1, revision: 0, items: []});
  const envelope = (ok, value, error) => JSON.stringify({ok, value, error});
  const fail = (code, detail) => envelope(false, null, {code, detail});
  const code = error => {
    const name = error?.name || '';
    if (name === 'VersionError') return 'collection_data.storage_version';
    if (name === 'QuotaExceededError') return 'collection_data.storage_write_failed';
    return 'collection_data.storage_unavailable';
  };
  const text = (value, limit = 4096) => typeof value === 'string'
    && new TextEncoder().encode(value).length <= limit
    && ![...value].some(char => { const n = char.charCodeAt(0); return n < 32 && ![9,10,13].includes(n) || n === 127; });
  const url = (value, media = false) => text(value, 2048) && new RegExp(media
    ? '^https://risdmuseum[.]cdn[.]picturepark[.]com/v/[a-zA-Z0-9_-]+/$'
    : '^https://risdmuseum[.]org/art-design/collection/[a-zA-Z0-9_-]+$').test(value);
  const time = value => typeof value === 'string'
    && /^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}([.][0-9]{3})?Z$/.test(value);
  const rights = value => value && typeof value === 'object'
    && ['public_domain','licensed','unknown'].includes(value.status)
    && Object.hasOwn(value, 'evidence_url') && Object.hasOwn(value, 'observed_at')
    && (value.evidence_url === null || url(value.evidence_url))
    && (value.observed_at === null || time(value.observed_at))
    && (value.status === 'unknown' || value.evidence_url !== null && value.observed_at !== null);
  const artwork = a => a && typeof a === 'object' && text(a.web_id, 128) && a.web_id.length > 0
    && ![...a.web_id].some(char => char.trim() === '' || '/?#'.includes(char) || char.charCodeAt(0) === 92)
    && a.id === `risd:${a.web_id}`
    && ['title','dating','accession','category','materials','credit'].every(k => text(a[k]))
    && Array.isArray(a.makers) && a.makers.length <= 32 && a.makers.every(value => text(value))
    && Object.hasOwn(a, 'year_from') && (a.year_from === null || Number.isSafeInteger(a.year_from))
    && url(a.source_url) && rights(a.rights) && time(a.upstream_checked_at)
    && ['available','unavailable','unknown'].includes(a.availability) && Object.hasOwn(a, 'image')
    && (a.image === null || (a.image && typeof a.image === 'object' && text(a.image.id) && a.image.id.length > 0
      && url(a.image.source_url, true) && a.image.evidence_url === a.source_url
      && /^[a-f0-9]{64}$/.test(a.image.sha256) && ['image/jpeg','image/png','image/webp'].includes(a.image.mime)
      && Number.isSafeInteger(a.image.width) && a.image.width > 0 && Number.isSafeInteger(a.image.height) && a.image.height > 0
      && time(a.image.verified_at) && rights(a.image.rights) && a.image.rights.status !== 'unknown'))
    && new TextEncoder().encode(JSON.stringify(a)).length <= 65536;
  const validate = doc => {
    if (!doc || typeof doc !== 'object') return 'corrupt';
    if (doc.schema_version !== VERSION) return Number.isSafeInteger(doc.schema_version) && doc.schema_version > VERSION ? 'version' : 'corrupt';
    if (!Number.isSafeInteger(doc.revision) || doc.revision < 0 || !Array.isArray(doc.items) || doc.items.length > 1000) return 'corrupt';
    const ids = new Set();
    for (const item of doc.items) {
      if (!item || !artwork(item.artwork) || !Number.isSafeInteger(item.saved_at_ms) || item.saved_at_ms < 0 || ids.has(item.artwork.id)) return 'corrupt';
      ids.add(item.artwork.id);
    }
    return new TextEncoder().encode(JSON.stringify(doc)).length <= 4 * 1024 * 1024 ? '' : 'corrupt';
  };
  const open = () => new Promise((resolve, reject) => {
    const request = indexedDB.open(DB, VERSION);
    request.onupgradeneeded = () => { if (!request.result.objectStoreNames.contains(STORE)) request.result.createObjectStore(STORE); };
    request.onsuccess = () => resolve(request.result);
    request.onerror = () => reject(request.error);
    request.onblocked = () => reject(new DOMException('Database upgrade blocked', 'InvalidStateError'));
  });
  const once = done => { let sent = false; return value => { if (!sent) { sent = true; done(value); } }; };
  window.risdCollectionStorage = {
    loadSaves(done) {
      const send = once(done);
      open().then(db => new Promise((resolve, reject) => {
        const tx = db.transaction(STORE, 'readonly'), request = tx.objectStore(STORE).get(KEY);
        let doc = blank();
        request.onsuccess = () => { if (request.result !== undefined) doc = request.result; };
        request.onerror = () => reject(request.error);
        tx.oncomplete = () => resolve(doc);
        tx.onerror = () => reject(tx.error);
        tx.onabort = () => reject(tx.error || new DOMException('Read aborted', 'AbortError'));
      })).then(doc => {
        const invalid = validate(doc);
        send(invalid === 'version' ? fail('collection_data.storage_version', 'Saved data uses a newer version')
          : invalid ? fail('collection_data.storage_corrupt', 'Saved data is corrupt') : envelope(true, doc, null));
      }).catch(error => send(fail(code(error), 'Saved data is unavailable')));
    },
    saveIfAbsent(artworkJson, savedAt, done) {
      const send = once(done); let incoming;
      try { incoming = JSON.parse(artworkJson); } catch (_) { send(fail('collection_data.storage_write_failed', 'Artwork could not be stored')); return; }
      if (!artwork(incoming) || !Number.isSafeInteger(savedAt) || savedAt < 0) {
        send(fail('collection_data.storage_write_failed', 'Artwork could not be stored')); return;
      }
      open().then(db => new Promise((resolve, reject) => {
        let tx;
        try { tx = db.transaction(STORE, 'readwrite', {durability: 'strict'}); }
        catch (_) { tx = db.transaction(STORE, 'readwrite'); }
        const request = tx.objectStore(STORE).get(KEY); let outcome = null;
        request.onsuccess = () => {
          const doc = request.result === undefined ? blank() : request.result;
          const invalid = validate(doc);
          if (invalid) { tx.abort(); reject({storage: invalid}); return; }
          const existing = doc.items.find(item => item.artwork.id === incoming.id);
          if (existing) { outcome = {record: existing, inserted: false, revision: doc.revision}; return; }
          const next = JSON.parse(JSON.stringify(doc));
          next.items.push({artwork: incoming, saved_at_ms: savedAt});
          next.items.sort((a, b) => b.saved_at_ms - a.saved_at_ms || a.artwork.id.localeCompare(b.artwork.id));
          next.revision += 1;
          if (next.items.length > 1000 || new TextEncoder().encode(JSON.stringify(next)).length > 4 * 1024 * 1024) {
            tx.abort(); reject({storage: 'write'}); return;
          }
          tx.objectStore(STORE).put(next, KEY);
          outcome = {record: next.items.find(item => item.artwork.id === incoming.id), inserted: true, revision: next.revision};
        };
        request.onerror = () => reject(request.error);
        tx.oncomplete = () => resolve(outcome);
        tx.onerror = () => reject(tx.error);
        tx.onabort = () => { if (!outcome) reject(tx.error || new DOMException('Write aborted', 'AbortError')); };
      })).then(value => send(envelope(true, value, null))).catch(error => {
        if (error?.storage === 'version') send(fail('collection_data.storage_version', 'Saved data uses a newer version'));
        else if (error?.storage === 'corrupt') send(fail('collection_data.storage_corrupt', 'Saved data is corrupt'));
        else send(fail(error?.storage === 'write' ? 'collection_data.storage_write_failed' : code(error), 'Artwork was not saved'));
      });
    }
  };
})()
"""

var _bridge: Variant
var _callbacks := {}
var _next_callback := 0
var _memory := {"schema_version": 1, "revision": 0, "items": []}


func initialize() -> Dictionary:
	if OS.has_feature("web"):
		JavaScriptBridge.eval(DB_SCRIPT, true)
		_bridge = JavaScriptBridge.get_interface("risdCollectionStorage")
		if _bridge == null:
			return _err("collection_data.storage_unavailable", "IndexedDB bridge could not start")
	return _ok(self)


func load_saves(done: Callable) -> Dictionary:
	if not done.is_valid():
		return _err("collection_data.invalid_dependency", "A completion callback is required")
	if not OS.has_feature("web"):
		done.call(_ok(_memory.duplicate(true)))
		return _ok()
	_bridge.loadSaves(_callback(done))
	return _ok()


func save_if_absent(artwork: Dictionary, saved_at_ms: int, done: Callable) -> Dictionary:
	if not done.is_valid():
		return _err("collection_data.invalid_dependency", "A completion callback is required")
	if not OS.has_feature("web"):
		for item in _memory.items:
			if item.artwork.id == artwork.id:
				done.call(_ok({"record": item.duplicate(true), "inserted": false, "revision": _memory.revision}))
				return _ok()
		var record := {"artwork": artwork.duplicate(true), "saved_at_ms": saved_at_ms}
		_memory.items.append(record)
		_memory.items.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
			return a.saved_at_ms > b.saved_at_ms or (a.saved_at_ms == b.saved_at_ms and a.artwork.id < b.artwork.id))
		_memory.revision += 1
		done.call(_ok({"record": record.duplicate(true), "inserted": true, "revision": _memory.revision}))
		return _ok()
	_bridge.saveIfAbsent(JSON.stringify(artwork), saved_at_ms, _callback(done))
	return _ok()


func _callback(done: Callable) -> Variant:
	var id := _next_callback
	_next_callback += 1
	var callback = JavaScriptBridge.create_callback(func(args: Array) -> void:
		_callbacks.erase(id)
		var parsed: Variant = JSON.parse_string(str(args[0])) if not args.is_empty() else null
		done.call(parsed if parsed is Dictionary else _err("collection_data.storage_corrupt", "Storage returned invalid data")))
	_callbacks[id] = callback
	return callback


func _ok(value: Variant = null) -> Dictionary:
	return {"ok": true, "value": value, "error": null}


func _err(code: String, detail: String) -> Dictionary:
	return {"ok": false, "value": null, "error": {"code": code, "detail": detail}}
