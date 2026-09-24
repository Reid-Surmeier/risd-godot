## The owner's Are.na profile for the Feng Shui window (web build only), always in Are.na's light
## layout: the real page follows the viewer's system theme and cannot be forced light inside an
## iframe (owner, 2026-09-23), so this draws the profile header, bio and the newest PER blocks from
## the public API, two requests in all, and never loads more. A block opens on are.na in a new tab.
##
## window.playgroundArena(placement | null) places the one element in page px. The canvas shows the
## view through crt_display.gd's barrel warp (published as window.crtQaState), so each corner is
## carried through the inverse of that warp. The profile is laid out at LAYOUT px and scaled down, as
## in the owner's picture. Covered parts are cut out of a clip path made of the uncovered cells of a
## grid on the holes' edges; during a window drag it ignores the pointer.
extends RefCounted

const SLUG := "reid-surmeier"
const PER := 24

const JS := """
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


static func script() -> String:
	return JS.replace("SLUG", SLUG).replace("PER", str(PER))
