extends SceneTree
func _init() -> void:
	var before_0 := "FLOOR186 selected mesh/material restored, shared edges conformed, world-space lightmap UVs verified"
	var after_0 := (
			"FLOOR186 selected mesh/material restored, shared edges conformed, world-space " +
			"lightmap UVs verified"
		)
	assert(before_0.to_utf8_buffer() == after_0.to_utf8_buffer())
	print("STRING0 PASS ", before_0.sha256_text())
	var before_1 := "PASSAGE_ONLY repaired shared edges, interpolated UV/color/UV2; original material/lightmap retained"
	var after_1 := (
			"PASSAGE_ONLY repaired shared edges, interpolated UV/color/UV2; original " +
			"material/lightmap retained"
		)
	assert(before_1.to_utf8_buffer() == after_1.to_utf8_buffer())
	print("STRING1 PASS ", before_1.sha256_text())
	var before_2 := """
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
	var after_2 := (
	"""
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
    && ![...value].some(char => { const n = char.charCodeAt(0); return n < 32 """ +
	"""&& ![9,10,13].includes(n) || n === 127; });
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
    && ![...a.web_id].some(char => char.trim() === '' || '/?#'.includes(char) """ +
	"""|| char.charCodeAt(0) === 92)
    && a.id === `risd:${a.web_id}`
    && ['title','dating','accession','category','materials','credit'].every(k => text(a[k]))
    && Array.isArray(a.makers) && a.makers.length <= 32 && a.makers.every(value => text(value))
    && Object.hasOwn(a, 'year_from') && (a.year_from === null || Number.isSafeInteger(a.year_from))
    && url(a.source_url) && rights(a.rights) && time(a.upstream_checked_at)
    && ['available','unavailable','unknown'].includes(a.availability) && Object.hasOwn(a, 'image')
    && (a.image === null || (a.image && typeof a.image === 'object' && """ +
	"""text(a.image.id) && a.image.id.length > 0
      && url(a.image.source_url, true) && a.image.evidence_url === a.source_url
      && /^[a-f0-9]{64}$/.test(a.image.sha256) && """ +
	"""['image/jpeg','image/png','image/webp'].includes(a.image.mime)
      && Number.isSafeInteger(a.image.width) && a.image.width > 0 && """ +
	"""Number.isSafeInteger(a.image.height) && a.image.height > 0
      && time(a.image.verified_at) && rights(a.image.rights) && """ +
	"""a.image.rights.status !== 'unknown'))
    && new TextEncoder().encode(JSON.stringify(a)).length <= 65536;
  const validate = doc => {
    if (!doc || typeof doc !== 'object') return 'corrupt';
    if (doc.schema_version !== VERSION) return """ +
	"""Number.isSafeInteger(doc.schema_version) && doc.schema_version > VERSION ? """ +
	"""'version' : 'corrupt';
    if (!Number.isSafeInteger(doc.revision) || doc.revision < 0 || """ +
	"""!Array.isArray(doc.items) || doc.items.length > 1000) return 'corrupt';
    const ids = new Set();
    for (const item of doc.items) {
      if (!item || !artwork(item.artwork) || """ +
	"""!Number.isSafeInteger(item.saved_at_ms) || item.saved_at_ms < 0 || """ +
	"""ids.has(item.artwork.id)) return 'corrupt';
      ids.add(item.artwork.id);
    }
    return new TextEncoder().encode(JSON.stringify(doc)).length <= 4 * 1024 * 1024 ? '' : 'corrupt';
  };
  const open = () => new Promise((resolve, reject) => {
    const request = indexedDB.open(DB, VERSION);
    request.onupgradeneeded = () => { if """ +
	"""(!request.result.objectStoreNames.contains(STORE)) """ +
	"""request.result.createObjectStore(STORE); };
    request.onsuccess = () => resolve(request.result);
    request.onerror = () => reject(request.error);
    request.onblocked = () => reject(new DOMException('Database upgrade """ +
	"""blocked', 'InvalidStateError'));
  });
  const once = done => { let sent = false; return value => { if (!sent) { """ +
	"""sent = true; done(value); } }; };
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
        send(invalid === 'version' ? fail('collection_data.storage_version', """ +
	"""'Saved data uses a newer version')
          : invalid ? fail('collection_data.storage_corrupt', 'Saved data is """ +
	"""corrupt') : envelope(true, doc, null));
      }).catch(error => send(fail(code(error), 'Saved data is unavailable')));
    },
    saveIfAbsent(artworkJson, savedAt, done) {
      const send = once(done); let incoming;
      try { incoming = JSON.parse(artworkJson); } catch (_) { """ +
	"""send(fail('collection_data.storage_write_failed', 'Artwork could not be """ +
	"""stored')); return; }
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
          if (existing) { outcome = {record: existing, inserted: false, """ +
	"""revision: doc.revision}; return; }
          const next = JSON.parse(JSON.stringify(doc));
          next.items.push({artwork: incoming, saved_at_ms: savedAt});
          next.items.sort((a, b) => b.saved_at_ms - a.saved_at_ms || """ +
	"""a.artwork.id.localeCompare(b.artwork.id));
          next.revision += 1;
          if (next.items.length > 1000 || new """ +
	"""TextEncoder().encode(JSON.stringify(next)).length > 4 * 1024 * 1024) {
            tx.abort(); reject({storage: 'write'}); return;
          }
          tx.objectStore(STORE).put(next, KEY);
          outcome = {record: next.items.find(item => item.artwork.id === """ +
	"""incoming.id), inserted: true, revision: next.revision};
        };
        request.onerror = () => reject(request.error);
        tx.oncomplete = () => resolve(outcome);
        tx.onerror = () => reject(tx.error);
        tx.onabort = () => { if (!outcome) reject(tx.error || new """ +
	"""DOMException('Write aborted', 'AbortError')); };
      })).then(value => send(envelope(true, value, null))).catch(error => {
        if (error?.storage === 'version') """ +
	"""send(fail('collection_data.storage_version', 'Saved data uses a newer """ +
	"""version'));
        else if (error?.storage === 'corrupt') """ +
	"""send(fail('collection_data.storage_corrupt', 'Saved data is corrupt'));
        else send(fail(error?.storage === 'write' ? """ +
	"""'collection_data.storage_write_failed' : code(error), 'Artwork was not """ +
	"""saved'));
      });
    }
  };
})()
"""
)
	assert(before_2.to_utf8_buffer() == after_2.to_utf8_buffer())
	print("STRING2 PASS ", before_2.sha256_text())
	var before_3 := """
window.flowersEmbed = (() => {
	const BASE = new URL('flowers/', document.baseURI).href;
	let frame = null;
	const KEY = 'orisinal-flowers:';
	const memory = {};  // when localStorage is unavailable
	const store = {
		get: (k) => { try { return localStorage.getItem(KEY + k); } catch (e) { return memory[k] || null; } },
		set: (k, v) => { try { localStorage.setItem(KEY + k, v); } catch (e) { memory[k] = v; } },
	};
	let samples = null;
	window.flowersLog = [];  // what the stand-in answered, for the playtest
	const reply = (text) => { window.flowersLog.push(text.slice(-40)); return new Response(text, {status: 200, headers: {'Content-Type': 'text/html'}}); };
	const bouquet = (data) => {  // url_full -> the reply flowersread.php gives for a number
		const f = data.split('|');
		if (f.length < 6) return null;
		const out = ['s=' + f[0], 'se=' + f[1], 'r=' + f[2], 're=' + f[3], 'bgc=' + f[4], 'm=' + f[5]];
		let n = 0;
		for (let i = 6; i + 5 < f.length; i += 6) {
			n += 1;
			['ft', 'fx', 'fy', 'fxs', 'fys', 'fr'].forEach((name, j) => out.push(name + n + '=' + f[i + j]));
		}
		return '&' + out.join('&') + '&total=' + n + '&reply=1';
	};
	const answer = async (url, init) => {
		if (url.pathname.endsWith('/flowersread.php')) {
			if (url.searchParams.get('sample') !== null) {
				if (!samples) samples = (await (await window.flowersFetch(BASE + 'samples.txt')).text()).split(String.fromCharCode(10)).filter((l) => l);
				return reply(samples[Math.floor(Math.random() * samples.length)]);
			}
			return reply(store.get(url.searchParams.get('code') || '') || '&reply=2');
		}
		const body = init && init.body != null ? await new Response(init.body).text() : '';
		const vars = new URLSearchParams(body || url.search);
		const saved = bouquet(vars.get('data') || '');
		if (!saved) return reply('&reply=');
		let number = '';
		do { number = String(1e11 + Math.floor(Math.random() * 9e11)); } while (store.get(number));
		store.set(number, saved);
		return reply('&reply=' + number);
	};
	if (!window.flowersFetch) {
		window.flowersFetch = window.fetch.bind(window);
		window.fetch = (input, init) => {
			const url = new URL(input instanceof Request ? input.url : String(input), document.baseURI);
			if (url.href.startsWith(BASE) && (url.pathname.endsWith('/flowersread.php') || url.pathname.endsWith('/flowersmake.php'))) {
				if (input instanceof Request && !init) return input.text().then((text) => answer(url, {body: text}));
				return answer(url, init);
			}
			return window.flowersFetch(input, init);
		};
	}
	const build = () => {
		frame = document.createElement('div');
		frame.id = 'flowers-game';
		frame.style.cssText = 'position:fixed;z-index:1;display:none;background:#fff';
		document.body.append(frame);
		const start = () => {
			window.RufflePlayer.config = {autoplay: 'on', splashScreen: false, unmuteOverlay: 'hidden'};
			const player = window.RufflePlayer.newest().createPlayer();
			player.style.cssText = 'width:100%;height:100%;display:block';
			frame.append(player);
			player.load({url: BASE + 'flowers.swf', base: BASE, backgroundColor: '#FFFFFF', quality: 'high'});
		};
		if (window.RufflePlayer && window.RufflePlayer.newest) return start();
		const s = document.createElement('script');
		s.src = BASE + 'ruffle/ruffle.js';
		s.onload = start;
		document.head.append(s);
	};
	return (p) => {
		if (!p) { if (frame) frame.style.display = 'none'; return; }
		if (!frame) build();
		const box = document.getElementById('canvas').getBoundingClientRect();
		const crt = window.crtQaState, [vw, vh] = p.view;
		const warp = (x, y) => {
			if (!crt || !crt.enabled) return [x, y];
			const a = vh / vw;
			const u = (x - 0.5) / crt.screen_scale / a, v = (y - 0.5) / crt.screen_scale;
			const k = 1 - (u * u + v * v - 0.25) * crt.curve;
			return [u / k * a + 0.5, v / k + 0.5];
		};
		const toPage = (x, y) => {
			const t = [x / vw, y / vh], d = [t[0], t[1]];
			for (let i = 0; i < 8; i++) { const s = warp(d[0], d[1]); d[0] += t[0] - s[0]; d[1] += t[1] - s[1]; }
			const side = Math.min(box.width, box.height);
			return [box.left + (box.width - side) / 2 + d[0] * side, box.top + (box.height - side) / 2 + d[1] * side];
		};
		const [x0, y0] = toPage(p.rect[0], p.rect[1]);
		const [x1, y1] = toPage(p.rect[0] + p.rect[2], p.rect[1] + p.rect[3]);
		Object.assign(frame.style, {display: 'block', left: x0 + 'px', top: y0 + 'px', width: (x1 - x0) + 'px', height: (y1 - y0) + 'px'});
	};
})();
"""
	var after_3 := (
	"""
window.flowersEmbed = (() => {
	const BASE = new URL('flowers/', document.baseURI).href;
	let frame = null;
	const KEY = 'orisinal-flowers:';
	const memory = {};  // when localStorage is unavailable
	const store = {
		get: (k) => { try { return localStorage.getItem(KEY + k); } catch (e) { """ +
	"""return memory[k] || null; } },
		set: (k, v) => { try { localStorage.setItem(KEY + k, v); } catch (e) { memory[k] = v; } },
	};
	let samples = null;
	window.flowersLog = [];  // what the stand-in answered, for the playtest
	const reply = (text) => { window.flowersLog.push(text.slice(-40)); return """ +
	"""new Response(text, {status: 200, headers: {'Content-Type': 'text/html'}}); };
	const bouquet = (data) => {  // url_full -> the reply flowersread.php gives for a number
		const f = data.split('|');
		if (f.length < 6) return null;
		const out = ['s=' + f[0], 'se=' + f[1], 'r=' + f[2], 're=' + f[3], 'bgc=' + f[4], 'm=' + f[5]];
		let n = 0;
		for (let i = 6; i + 5 < f.length; i += 6) {
			n += 1;
			['ft', 'fx', 'fy', 'fxs', 'fys', 'fr'].forEach((name, j) => out.push(name + n + '=' + f[i + j]));
		}
		return '&' + out.join('&') + '&total=' + n + '&reply=1';
	};
	const answer = async (url, init) => {
		if (url.pathname.endsWith('/flowersread.php')) {
			if (url.searchParams.get('sample') !== null) {
				if (!samples) samples = (await (await window.flowersFetch(BASE + """ +
	"""'samples.txt')).text()).split(String.fromCharCode(10)).filter((l) => l);
				return reply(samples[Math.floor(Math.random() * samples.length)]);
			}
			return reply(store.get(url.searchParams.get('code') || '') || '&reply=2');
		}
		const body = init && init.body != null ? await new Response(init.body).text() : '';
		const vars = new URLSearchParams(body || url.search);
		const saved = bouquet(vars.get('data') || '');
		if (!saved) return reply('&reply=');
		let number = '';
		do { number = String(1e11 + Math.floor(Math.random() * 9e11)); } while (store.get(number));
		store.set(number, saved);
		return reply('&reply=' + number);
	};
	if (!window.flowersFetch) {
		window.flowersFetch = window.fetch.bind(window);
		window.fetch = (input, init) => {
			const url = new URL(input instanceof Request ? input.url : String(input), document.baseURI);
			if (url.href.startsWith(BASE) && """ +
	"""(url.pathname.endsWith('/flowersread.php') || """ +
	"""url.pathname.endsWith('/flowersmake.php'))) {
				if (input instanceof Request && !init) return input.text().then((text) => """ +
	"""answer(url, {body: text}));
				return answer(url, init);
			}
			return window.flowersFetch(input, init);
		};
	}
	const build = () => {
		frame = document.createElement('div');
		frame.id = 'flowers-game';
		frame.style.cssText = 'position:fixed;z-index:1;display:none;background:#fff';
		document.body.append(frame);
		const start = () => {
			window.RufflePlayer.config = {autoplay: 'on', splashScreen: false, unmuteOverlay: 'hidden'};
			const player = window.RufflePlayer.newest().createPlayer();
			player.style.cssText = 'width:100%;height:100%;display:block';
			frame.append(player);
			player.load({url: BASE + 'flowers.swf', base: BASE, backgroundColor: """ +
	"""'#FFFFFF', quality: 'high'});
		};
		if (window.RufflePlayer && window.RufflePlayer.newest) return start();
		const s = document.createElement('script');
		s.src = BASE + 'ruffle/ruffle.js';
		s.onload = start;
		document.head.append(s);
	};
	return (p) => {
		if (!p) { if (frame) frame.style.display = 'none'; return; }
		if (!frame) build();
		const box = document.getElementById('canvas').getBoundingClientRect();
		const crt = window.crtQaState, [vw, vh] = p.view;
		const warp = (x, y) => {
			if (!crt || !crt.enabled) return [x, y];
			const a = vh / vw;
			const u = (x - 0.5) / crt.screen_scale / a, v = (y - 0.5) / crt.screen_scale;
			const k = 1 - (u * u + v * v - 0.25) * crt.curve;
			return [u / k * a + 0.5, v / k + 0.5];
		};
		const toPage = (x, y) => {
			const t = [x / vw, y / vh], d = [t[0], t[1]];
			for (let i = 0; i < 8; i++) { const s = warp(d[0], d[1]); d[0] += t[0] - """ +
	"""s[0]; d[1] += t[1] - s[1]; }
			const side = Math.min(box.width, box.height);
			return [box.left + (box.width - side) / 2 + d[0] * side, box.top + """ +
	"""(box.height - side) / 2 + d[1] * side];
		};
		const [x0, y0] = toPage(p.rect[0], p.rect[1]);
		const [x1, y1] = toPage(p.rect[0] + p.rect[2], p.rect[1] + p.rect[3]);
		Object.assign(frame.style, {display: 'block', left: x0 + 'px', top: y0 + """ +
	"""'px', width: (x1 - x0) + 'px', height: (y1 - y0) + 'px'});
	};
})();
"""
)
	assert(before_3.to_utf8_buffer() == after_3.to_utf8_buffer())
	print("STRING3 PASS ", before_3.sha256_text())
	var before_4 := """
window.playgroundArena = (() => {
	const API = 'https://api.are.na/v3/users/SLUG', LAYOUT = 1200;
	let frame = null;
	const el = (tag, css, text) => {
		const e = document.createElement(tag);
		if (css) e.style.cssText = css;
		if (text != null) e.textContent = text;
		return e;
	};
	const list = (label, items, chosen) => {
		const col = el('div', 'flex:1');
		col.append(el('div', 'color:#999;font-size:13px;padding-bottom:8px;margin-bottom:12px;border-bottom:1px solid #e6e6e6', label));
		for (const item of items) col.append(el('div', 'font-size:13px;line-height:21px;font-weight:bold;color:' + (item === chosen ? '#000' : '#666'), (item === chosen ? '• ' : '') + item));
		return col;
	};
	// the bio's html from the API, keeping only paragraphs, breaks, emphasis and http(s) links
	const bioNode = (html) => {
		const out = el('div', 'font-size:13px;line-height:19px');
		const copy = (from, to) => {
			for (const n of from.childNodes) {
				if (n.nodeType === 3) { to.append(n.textContent); continue; }
				const tag = n.nodeName.toLowerCase();
				if (tag === 'br') { to.append(el('br')); continue; }
				let next = to;
				if (tag === 'p') next = el('p', 'margin:0 0 12px');
				else if (tag === 'em') next = el('em');
				else if (tag === 'a' && /^https?:/.test(n.getAttribute('href') || '')) {
					next = el('a', 'color:#000;font-weight:bold;text-decoration:none');
					next.href = n.getAttribute('href'); next.target = '_blank'; next.rel = 'noopener';
				}
				if (next !== to) to.append(next);
				copy(n, next);
			}
		};
		copy(new DOMParser().parseFromString(html || '', 'text/html').body, out);
		return out;
	};
	const block = (b) => {
		const a = el('a', 'display:block;color:#000;text-decoration:none;min-width:0');
		a.href = b.type === 'Channel' ? 'https://www.are.na/' + (b.owner && b.owner.slug || 'SLUG') + '/' + b.slug : 'https://www.are.na/block/' + b.id;
		a.target = '_blank'; a.rel = 'noopener';
		const box = el('div', 'height:320px;display:flex;align-items:center;justify-content:center;overflow:hidden;box-sizing:border-box');
		const image = b.image && (b.image.medium || b.image.large || b.image.small);
		if (image) {
			const img = el('img', 'max-width:100%;max-height:100%;object-fit:contain;display:block');
			img.src = image.src; img.alt = b.title || ''; img.loading = 'lazy';
			box.append(img);
		} else if (b.type === 'Text') {
			box.style.cssText += ';border:1px solid #e6e6e6;align-items:flex-start;justify-content:flex-start;padding:16px;font-size:13px;line-height:19px;white-space:pre-line';
			box.textContent = String(b.content && (b.content.plain || b.content.markdown) || '').slice(0, 700);
		} else {
			box.style.cssText += ';border:1px solid #e6e6e6;flex-direction:column;font-size:15px;font-weight:bold;text-align:center;padding:16px';
			box.append(el('div', '', b.title || b.type));
			if (b.counts) box.append(el('div', 'color:#999;font-size:12px;font-weight:normal;margin-top:6px', (b.counts.contents || 0) + ' blocks'));
		}
		a.append(box, el('div', 'margin-top:10px;font-size:12px;color:#999;text-align:center;white-space:nowrap;overflow:hidden;text-overflow:ellipsis', b.type === 'Channel' ? '' : (b.title || '')));
		return a;
	};
	const build = () => {
		frame = el('div', 'position:fixed;z-index:1;box-sizing:border-box;padding:40px 64px 64px;background:#fff;color:#000;color-scheme:light;' +
			'font-family:Arial,Helvetica,sans-serif;overflow-x:hidden;overflow-y:auto;scrollbar-width:none;transform-origin:0 0');
		frame.id = 'playground-arena';
		const name = el('span', '', 'Reid Surmeier');
		const head = el('div', 'font-size:30px;font-weight:bold;margin-bottom:48px');
		head.append(el('span', 'color:#999', 'Are.na'), el('span', 'color:#ccc;margin:0 12px', '/'), name);
		const info = el('div', 'flex:1');
		info.append(el('div', 'color:#999;font-size:13px;padding-bottom:8px;margin-bottom:12px;border-bottom:1px solid #e6e6e6', 'Info'));
		const columns = el('div', 'display:flex;gap:32px;margin-bottom:64px');
		columns.append(info, list('View', ['Channels', 'Blocks', 'Table', 'Index', 'All'], 'Blocks'),
			list('Order', ['Relevance', 'Updated recently', 'Newest first', 'Oldest first', 'Alphabetical by title', 'No. of connections', 'Random'], 'Newest first'));
		const grid = el('div', 'display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:56px 40px');
		const more = el('a', 'display:block;margin:56px 0 0;text-align:center;font-size:13px;font-weight:bold;color:#000;text-decoration:none', 'More on Are.na →');
		more.href = 'https://www.are.na/SLUG/blocks'; more.target = '_blank'; more.rel = 'noopener';
		frame.append(head, columns, grid, more);
		document.body.append(frame);
		fetch(API).then((r) => r.json()).then((u) => {
			name.textContent = u.name;
			info.append(bioNode(u.bio && u.bio.html));
		}).catch(() => {});
		fetch(API + '/contents?per=PER&sort=created_at_desc').then((r) => r.json()).then((d) => {
			for (const b of d.data || []) grid.append(block(b));
		}).catch(() => grid.append(el('div', 'color:#999;font-size:13px', 'Are.na is unavailable right now.')));
	};
	return (p) => {
		if (!p) { if (frame) frame.style.display = 'none'; return; }
		if (!frame) build();
		const box = document.getElementById('canvas').getBoundingClientRect();
		const crt = window.crtQaState, [vw, vh] = p.view;
		const warp = (x, y) => {
			if (!crt || !crt.enabled) return [x, y];
			const a = vh / vw;
			const u = (x - 0.5) / crt.screen_scale / a, v = (y - 0.5) / crt.screen_scale;
			const k = 1 - (u * u + v * v - 0.25) * crt.curve;
			return [u / k * a + 0.5, v / k + 0.5];
		};
		const toPage = (x, y) => {
			const t = [x / vw, y / vh], d = [t[0], t[1]];
			for (let i = 0; i < 8; i++) { const s = warp(d[0], d[1]); d[0] += t[0] - s[0]; d[1] += t[1] - s[1]; }
			return [box.left + d[0] * box.width, box.top + d[1] * box.height];
		};
		const [x0, y0] = toPage(p.rect[0], p.rect[1]);
		const [x1, y1] = toPage(p.rect[0] + p.rect[2], p.rect[1] + p.rect[3]);
		const z = (x1 - x0) / LAYOUT, w = LAYOUT, h = (y1 - y0) / z;
		const holes = p.holes.map((r) => {
			const [a, b] = toPage(r[0], r[1]), [c, d] = toPage(r[0] + r[2], r[1] + r[3]);
			return [Math.max(0, (a - x0) / z), Math.max(0, (b - y0) / z), Math.min(w, (c - x0) / z), Math.min(h, (d - y0) / z)];
		}).filter((r) => r[0] < r[2] && r[1] < r[3]);
		const xs = [...new Set([0, w, ...holes.flatMap((r) => [r[0], r[2]])])].sort((a, b) => a - b);
		const ys = [...new Set([0, h, ...holes.flatMap((r) => [r[1], r[3]])])].sort((a, b) => a - b);
		let path = '';
		for (let i = 0; i + 1 < xs.length; i++) for (let j = 0; j + 1 < ys.length; j++) {
			const cx = (xs[i] + xs[i + 1]) / 2, cy = (ys[j] + ys[j + 1]) / 2;
			if (!holes.some((r) => cx > r[0] && cx < r[2] && cy > r[1] && cy < r[3]))
				path += `M${xs[i]} ${ys[j]}H${xs[i + 1]}V${ys[j + 1]}H${xs[i]}Z`;
		}
		Object.assign(frame.style, {display: 'block', left: x0 + 'px', top: y0 + 'px', width: w + 'px', height: h + 'px',
			transform: `scale(${z})`, clipPath: holes.length ? `path('${path || 'M0 0'}')` : '', pointerEvents: p.drag ? 'none' : 'auto'});
	};
})();
"""
	var after_4 := (
	"""
window.playgroundArena = (() => {
	const API = 'https://api.are.na/v3/users/SLUG', LAYOUT = 1200;
	let frame = null;
	const el = (tag, css, text) => {
		const e = document.createElement(tag);
		if (css) e.style.cssText = css;
		if (text != null) e.textContent = text;
		return e;
	};
	const list = (label, items, chosen) => {
		const col = el('div', 'flex:1');
		col.append(el('div', 'color:#999;font-size:13px;padding-bottom:8px;margin-b""" +
	"""ottom:12px;border-bottom:1px solid #e6e6e6', label));
		for (const item of items) col.append(el('div', """ +
	"""'font-size:13px;line-height:21px;font-weight:bold;color:' + (item === chosen """ +
	"""? '#000' : '#666'), (item === chosen ? '• ' : '') + item));
		return col;
	};
	// the bio's html from the API, keeping only paragraphs, breaks, emphasis and http(s) links
	const bioNode = (html) => {
		const out = el('div', 'font-size:13px;line-height:19px');
		const copy = (from, to) => {
			for (const n of from.childNodes) {
				if (n.nodeType === 3) { to.append(n.textContent); continue; }
				const tag = n.nodeName.toLowerCase();
				if (tag === 'br') { to.append(el('br')); continue; }
				let next = to;
				if (tag === 'p') next = el('p', 'margin:0 0 12px');
				else if (tag === 'em') next = el('em');
				else if (tag === 'a' && /^https?:/.test(n.getAttribute('href') || '')) {
					next = el('a', 'color:#000;font-weight:bold;text-decoration:none');
					next.href = n.getAttribute('href'); next.target = '_blank'; next.rel = 'noopener';
				}
				if (next !== to) to.append(next);
				copy(n, next);
			}
		};
		copy(new DOMParser().parseFromString(html || '', 'text/html').body, out);
		return out;
	};
	const block = (b) => {
		const a = el('a', 'display:block;color:#000;text-decoration:none;min-width:0');
		a.href = b.type === 'Channel' ? 'https://www.are.na/' + (b.owner && """ +
	"""b.owner.slug || 'SLUG') + '/' + b.slug : 'https://www.are.na/block/' + b.id;
		a.target = '_blank'; a.rel = 'noopener';
		const box = el('div', 'height:320px;display:flex;align-items:center;justify""" +
	"""-content:center;overflow:hidden;box-sizing:border-box');
		const image = b.image && (b.image.medium || b.image.large || b.image.small);
		if (image) {
			const img = el('img', 'max-width:100%;max-height:100%;object-fit:contain;display:block');
			img.src = image.src; img.alt = b.title || ''; img.loading = 'lazy';
			box.append(img);
		} else if (b.type === 'Text') {
			box.style.cssText += ';border:1px solid """ +
	"""#e6e6e6;align-items:flex-start;justify-content:flex-start;padding:16px;font-s""" +
	"""ize:13px;line-height:19px;white-space:pre-line';
			box.textContent = String(b.content && (b.content.plain || """ +
	"""b.content.markdown) || '').slice(0, 700);
		} else {
			box.style.cssText += ';border:1px solid """ +
	"""#e6e6e6;flex-direction:column;font-size:15px;font-weight:bold;text-align:cent""" +
	"""er;padding:16px';
			box.append(el('div', '', b.title || b.type));
			if (b.counts) box.append(el('div', """ +
	"""'color:#999;font-size:12px;font-weight:normal;margin-top:6px', """ +
	"""(b.counts.contents || 0) + ' blocks'));
		}
		a.append(box, el('div', 'margin-top:10px;font-size:12px;color:#999;text-ali""" +
	"""gn:center;white-space:nowrap;overflow:hidden;text-overflow:ellipsis', b.type """ +
	"""=== 'Channel' ? '' : (b.title || '')));
		return a;
	};
	const build = () => {
		frame = el('div', 'position:fixed;z-index:1;box-sizing:border-box;padding:4""" +
	"""0px 64px 64px;background:#fff;color:#000;color-scheme:light;' +
			'font-family:Arial,Helvetica,sans-serif;overflow-x:hidden;overflow-y:auto;""" +
	"""scrollbar-width:none;transform-origin:0 0');
		frame.id = 'playground-arena';
		const name = el('span', '', 'Reid Surmeier');
		const head = el('div', 'font-size:30px;font-weight:bold;margin-bottom:48px');
		head.append(el('span', 'color:#999', 'Are.na'), el('span', """ +
	"""'color:#ccc;margin:0 12px', '/'), name);
		const info = el('div', 'flex:1');
		info.append(el('div', 'color:#999;font-size:13px;padding-bottom:8px;margin-""" +
	"""bottom:12px;border-bottom:1px solid #e6e6e6', 'Info'));
		const columns = el('div', 'display:flex;gap:32px;margin-bottom:64px');
		columns.append(info, list('View', ['Channels', 'Blocks', 'Table', 'Index', 'All'], 'Blocks'),
			list('Order', ['Relevance', 'Updated recently', 'Newest first', 'Oldest """ +
	"""first', 'Alphabetical by title', 'No. of connections', 'Random'], 'Newest """ +
	"""first'));
		const grid = el('div', 'display:grid;grid-template-columns:repeat(3,minmax(""" +
	"""0,1fr));gap:56px 40px');
		const more = el('a', 'display:block;margin:56px 0 """ +
	"""0;text-align:center;font-size:13px;font-weight:bold;color:#000;text-decoratio""" +
	"""n:none', 'More on Are.na →');
		more.href = 'https://www.are.na/SLUG/blocks'; more.target = '_blank'; more.rel = 'noopener';
		frame.append(head, columns, grid, more);
		document.body.append(frame);
		fetch(API).then((r) => r.json()).then((u) => {
			name.textContent = u.name;
			info.append(bioNode(u.bio && u.bio.html));
		}).catch(() => {});
		fetch(API + '/contents?per=PER&sort=created_at_desc').then((r) => r.json()).then((d) => {
			for (const b of d.data || []) grid.append(block(b));
		}).catch(() => grid.append(el('div', 'color:#999;font-size:13px', 'Are.na """ +
	"""is unavailable right now.')));
	};
	return (p) => {
		if (!p) { if (frame) frame.style.display = 'none'; return; }
		if (!frame) build();
		const box = document.getElementById('canvas').getBoundingClientRect();
		const crt = window.crtQaState, [vw, vh] = p.view;
		const warp = (x, y) => {
			if (!crt || !crt.enabled) return [x, y];
			const a = vh / vw;
			const u = (x - 0.5) / crt.screen_scale / a, v = (y - 0.5) / crt.screen_scale;
			const k = 1 - (u * u + v * v - 0.25) * crt.curve;
			return [u / k * a + 0.5, v / k + 0.5];
		};
		const toPage = (x, y) => {
			const t = [x / vw, y / vh], d = [t[0], t[1]];
			for (let i = 0; i < 8; i++) { const s = warp(d[0], d[1]); d[0] += t[0] - """ +
	"""s[0]; d[1] += t[1] - s[1]; }
			return [box.left + d[0] * box.width, box.top + d[1] * box.height];
		};
		const [x0, y0] = toPage(p.rect[0], p.rect[1]);
		const [x1, y1] = toPage(p.rect[0] + p.rect[2], p.rect[1] + p.rect[3]);
		const z = (x1 - x0) / LAYOUT, w = LAYOUT, h = (y1 - y0) / z;
		const holes = p.holes.map((r) => {
			const [a, b] = toPage(r[0], r[1]), [c, d] = toPage(r[0] + r[2], r[1] + r[3]);
			return [Math.max(0, (a - x0) / z), Math.max(0, (b - y0) / z), Math.min(w, """ +
	"""(c - x0) / z), Math.min(h, (d - y0) / z)];
		}).filter((r) => r[0] < r[2] && r[1] < r[3]);
		const xs = [...new Set([0, w, ...holes.flatMap((r) => [r[0], r[2]])])].sort((a, b) => a - b);
		const ys = [...new Set([0, h, ...holes.flatMap((r) => [r[1], r[3]])])].sort((a, b) => a - b);
		let path = '';
		for (let i = 0; i + 1 < xs.length; i++) for (let j = 0; j + 1 < ys.length; j++) {
			const cx = (xs[i] + xs[i + 1]) / 2, cy = (ys[j] + ys[j + 1]) / 2;
			if (!holes.some((r) => cx > r[0] && cx < r[2] && cy > r[1] && cy < r[3]))
				path += `M${xs[i]} ${ys[j]}H${xs[i + 1]}V${ys[j + 1]}H${xs[i]}Z`;
		}
		Object.assign(frame.style, {display: 'block', left: x0 + 'px', top: y0 + """ +
	"""'px', width: w + 'px', height: h + 'px',
			transform: `scale(${z})`, clipPath: holes.length ? `path('${path || 'M0 """ +
	"""0'}')` : '', pointerEvents: p.drag ? 'none' : 'auto'});
	};
})();
"""
)
	assert(before_4.to_utf8_buffer() == after_4.to_utf8_buffer())
	print("STRING4 PASS ", before_4.sha256_text())
	var before_5 := "DEAR DIARY !! I LOOOVE THIS THING HAHAHAHAHAHAHA!! i decorated my room and and and my ROOMIE IS JUST SO CUTE !!!!!!!!!!\n\ni dont think my dad knew how much i would use this thing but nextrooms with my friends is like hanging with them 24/7 lol"
	var after_5 := (
	"DEAR DIARY !! I LOOOVE THIS THING HAHAHAHAHAHAHA!! i decorated my room and " +
	"and and my ROOMIE IS JUST SO CUTE !!!!!!!!!!\n\ni dont think my dad knew how " +
	"much i would use this thing but nextrooms with my friends is like hanging " +
	"with them 24/7 lol"
)
	assert(before_5.to_utf8_buffer() == after_5.to_utf8_buffer())
	print("STRING5 PASS ", before_5.sha256_text())
	var before_6 := """
shader_type canvas_item;
render_mode unshaded;
uniform float scroll_progress = 0.0;
uniform vec4 content_rect = vec4(58.0, 685.0, 1425.0, 720.0);
uniform vec4 scroll_rect = vec4(1548.0, 278.0, 58.0, 1149.0);
uniform float content_scroll = 240.0;
uniform vec4 pressed_rect = vec4(0.0);
uniform float press_offset = 0.0;
void fragment() {
	vec2 source_size = 1.0 / TEXTURE_PIXEL_SIZE;
	vec2 pixel = UV * source_size;
	vec2 sample_pixel = pixel;
	if (press_offset > 0.0 && pixel.x >= pressed_rect.x && pixel.x < pressed_rect.x + pressed_rect.z && pixel.y >= pressed_rect.y && pixel.y < pressed_rect.y + pressed_rect.w) {
		sample_pixel.y = clamp(pixel.y - press_offset, pressed_rect.y, pressed_rect.y + pressed_rect.w - 1.0);
	}
	if (scroll_progress > 0.0001 && pixel.x >= content_rect.x && pixel.x < content_rect.x + content_rect.z && pixel.y >= content_rect.y && pixel.y < content_rect.y + content_rect.w) {
		float shifted_y = pixel.y + scroll_progress * content_scroll;
		sample_pixel = shifted_y < content_rect.y + content_rect.w ? vec2(pixel.x, shifted_y) : vec2(1400.0, 700.0);
	}
	if (scroll_progress > 0.0001 && pixel.x >= scroll_rect.x && pixel.x < scroll_rect.x + scroll_rect.z && pixel.y >= scroll_rect.y && pixel.y < scroll_rect.y + scroll_rect.w) {
		float thumb_height = 710.0;
		float new_top = scroll_rect.y + scroll_progress * (scroll_rect.w - thumb_height);
		sample_pixel.y = pixel.y >= new_top && pixel.y < new_top + thumb_height ? scroll_rect.y + pixel.y - new_top : 1100.0;
	}
	COLOR = texture(TEXTURE, sample_pixel / source_size);
}
"""
	var after_6 := (
		"""
shader_type canvas_item;
render_mode unshaded;
uniform float scroll_progress = 0.0;
uniform vec4 content_rect = vec4(58.0, 685.0, 1425.0, 720.0);
uniform vec4 scroll_rect = vec4(1548.0, 278.0, 58.0, 1149.0);
uniform float content_scroll = 240.0;
uniform vec4 pressed_rect = vec4(0.0);
uniform float press_offset = 0.0;
void fragment() {
	vec2 source_size = 1.0 / TEXTURE_PIXEL_SIZE;
	vec2 pixel = UV * source_size;
	vec2 sample_pixel = pixel;
	if (press_offset > 0.0 && pixel.x >= pressed_rect.x && pixel.x < """ +
		"""pressed_rect.x + pressed_rect.z && pixel.y >= pressed_rect.y && pixel.y < """ +
		"""pressed_rect.y + pressed_rect.w) {
		sample_pixel.y = clamp(pixel.y - press_offset, pressed_rect.y, """ +
		"""pressed_rect.y + pressed_rect.w - 1.0);
	}
	if (scroll_progress > 0.0001 && pixel.x >= content_rect.x && pixel.x < """ +
		"""content_rect.x + content_rect.z && pixel.y >= content_rect.y && pixel.y < """ +
		"""content_rect.y + content_rect.w) {
		float shifted_y = pixel.y + scroll_progress * content_scroll;
		sample_pixel = shifted_y < content_rect.y + content_rect.w ? vec2(pixel.x, """ +
		"""shifted_y) : vec2(1400.0, 700.0);
	}
	if (scroll_progress > 0.0001 && pixel.x >= scroll_rect.x && pixel.x < """ +
		"""scroll_rect.x + scroll_rect.z && pixel.y >= scroll_rect.y && pixel.y < """ +
		"""scroll_rect.y + scroll_rect.w) {
		float thumb_height = 710.0;
		float new_top = scroll_rect.y + scroll_progress * (scroll_rect.w - thumb_height);
		sample_pixel.y = pixel.y >= new_top && pixel.y < new_top + thumb_height ? """ +
		"""scroll_rect.y + pixel.y - new_top : 1100.0;
	}
	COLOR = texture(TEXTURE, sample_pixel / source_size);
}
"""
	)
	assert(before_6.to_utf8_buffer() == after_6.to_utf8_buffer())
	print("STRING6 PASS ", before_6.sha256_text())
	var before_7 := "Roman marble portrait head, made around 130 CE for insertion into a separate bust. Its damaged portions remain unrestored."
	var after_7 := (
			"Roman marble portrait head, made around 130 CE for insertion into a separate " +
			"bust. Its damaged portions remain unrestored."
		)
	assert(before_7.to_utf8_buffer() == after_7.to_utf8_buffer())
	print("STRING7 PASS ", before_7.sha256_text())
	var before_8 := "Roman marble portrait head, made around 130 CE for insertion into a separate bust. Its damaged portions remain unrestored."
	var after_8 := (
			"Roman marble portrait head, made around 130 CE for insertion into a separate " +
			"bust. Its damaged portions remain unrestored."
		)
	assert(before_8.to_utf8_buffer() == after_8.to_utf8_buffer())
	print("STRING8 PASS ", before_8.sha256_text())
	var before_9 := "PASS: 20 native selections; exact displayed metadata; 16 explicit unknowns; 5x4 order; four live scans"
	var after_9 := (
			"PASS: 20 native selections; exact displayed metadata; 16 explicit unknowns; " +
			"5x4 order; four live scans"
		)
	assert(before_9.to_utf8_buffer() == after_9.to_utf8_buffer())
	print("STRING9 PASS ", before_9.sha256_text())
	var before_10 := "WINDOW192 four windows drag/raise, shrink/grow, uniform aspect, selection, orbit and retained placement PASS"
	var after_10 := (
			"WINDOW192 four windows drag/raise, shrink/grow, uniform aspect, selection, " +
			"orbit and retained placement PASS"
		)
	assert(before_10.to_utf8_buffer() == after_10.to_utf8_buffer())
	print("STRING10 PASS ", before_10.sha256_text())
	var before_11 := "new URLSearchParams(location.search).get('crt') === '0' || new URLSearchParams(location.search).has('qa-viewer')"
	var after_11 := (
					"new URLSearchParams(location.search).get('crt') === '0' || new " +
					"URLSearchParams(location.search).has('qa-viewer')"
				)
	assert(before_11.to_utf8_buffer() == after_11.to_utf8_buffer())
	print("STRING11 PASS ", before_11.sha256_text())
	var before_12 := "PASS #174 captures: Collection front/profile/back, straight/diagonal walk, stop, 23 paintings, gestures disabled"
	var after_12 := (
			"PASS #174 captures: Collection front/profile/back, straight/diagonal walk, " +
			"stop, 23 paintings, gestures disabled"
		)
	assert(before_12.to_utf8_buffer() == after_12.to_utf8_buffer())
	print("STRING12 PASS ", before_12.sha256_text())
	var before_13 := "PASS #174: Hair36 body, 42-bone rig, 23 paintings, start/walk/stop/reversal, 90/180-degree turns, planted feet/floor, gestures disabled"
	var after_13 := (
			"PASS #174: Hair36 body, 42-bone rig, 23 paintings, start/walk/stop/reversal, " +
			"90/180-degree turns, planted feet/floor, gestures disabled"
		)
	assert(before_13.to_utf8_buffer() == after_13.to_utf8_buffer())
	print("STRING13 PASS ", before_13.sha256_text())
	var before_14 := "var u=new URL(location.href);u.searchParams.set('lighting','%s');history.replaceState(null,'',u)"
	var after_14 := (
						"var u=new URL(location.href);u.searchParams.set('lighting','%s');history.repl" +
						"aceState(null,'',u)"
					)
	assert(before_14.to_utf8_buffer() == after_14.to_utf8_buffer())
	print("STRING14 PASS ", before_14.sha256_text())
	var before_15 := "var u=new URL(location.href);u.searchParams.set('variant','%s');history.replaceState(null,'',u)"
	var after_15 := (
						"var u=new URL(location.href);u.searchParams.set('variant','%s');history.repla" +
						"ceState(null,'',u)"
					)
	assert(before_15.to_utf8_buffer() == after_15.to_utf8_buffer())
	print("STRING15 PASS ", before_15.sha256_text())
	var before_16 := "window.risdFullscreenError = false; (document.fullscreenElement ? document.exitFullscreen() : document.documentElement.requestFullscreen()).catch(() => { window.risdFullscreenError = true; document.dispatchEvent(new Event('fullscreenchange')); })"
	var after_16 := (
					"window.risdFullscreenError = false; (document.fullscreenElement ? " +
					"document.exitFullscreen() : document.documentElement.requestFullscreen()).cat" +
					"ch(() => { window.risdFullscreenError = true; document.dispatchEvent(new " +
					"Event('fullscreenchange')); })"
				)
	assert(before_16.to_utf8_buffer() == after_16.to_utf8_buffer())
	print("STRING16 PASS ", before_16.sha256_text())
	var before_17 := """(() => {
		const old = document.getElementById(%s);
		if (old) old.remove();
		const input = document.createElement('input');
		input.id = %s;
		input.type = 'file';
		input.accept = 'image/png,image/jpeg,image/webp';
		input.setAttribute('aria-label', 'Post an image');
		input.title = 'Post an image';
		Object.assign(input.style, { position: 'fixed', opacity: '0', zIndex: '2147483647', cursor: 'pointer' });
		input.onchange = () => {
			const file = input.files && input.files[0];
			if (!file) return;
			if (file.size > %d) { window[%s]('', 'Image is over 8 MiB'); input.value = ''; return; }
			const reader = new FileReader();
			reader.onload = () => { window[%s](String(reader.result), ''); input.value = ''; };
			reader.onerror = () => { window[%s]('', 'Could not read image'); input.value = ''; };
			reader.readAsDataURL(file);
		};
		document.body.appendChild(input);
	})()"""
	var after_17 := (
					"""(() => {
		const old = document.getElementById(%s);
		if (old) old.remove();
		const input = document.createElement('input');
		input.id = %s;
		input.type = 'file';
		input.accept = 'image/png,image/jpeg,image/webp';
		input.setAttribute('aria-label', 'Post an image');
		input.title = 'Post an image';
		Object.assign(input.style, { position: 'fixed', opacity: '0', zIndex: """ +
					"""'2147483647', cursor: 'pointer' });
		input.onchange = () => {
			const file = input.files && input.files[0];
			if (!file) return;
			if (file.size > %d) { window[%s]('', 'Image is over 8 MiB'); input.value = ''; return; }
			const reader = new FileReader();
			reader.onload = () => { window[%s](String(reader.result), ''); input.value = ''; };
			reader.onerror = () => { window[%s]('', 'Could not read image'); input.value = ''; };
			reader.readAsDataURL(file);
		};
		document.body.appendChild(input);
	})()"""
				)
	assert(before_17.to_utf8_buffer() == after_17.to_utf8_buffer())
	print("STRING17 PASS ", before_17.sha256_text())
	var before_18 := "shader_type canvas_item; void fragment(){if(COLOR.r>0.5 && COLOR.b>0.5 && COLOR.g<0.4){COLOR.a=0.0;}}"
	var after_18 := (
		"shader_type canvas_item; void fragment(){if(COLOR.r>0.5 && COLOR.b>0.5 && " +
		"COLOR.g<0.4){COLOR.a=0.0;}}"
	)
	assert(before_18.to_utf8_buffer() == after_18.to_utf8_buffer())
	print("STRING18 PASS ", before_18.sha256_text())
	quit(0)
