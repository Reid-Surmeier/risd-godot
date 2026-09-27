## The Flowers game on the Web build: window.flowersEmbed(placement | null) keeps one Ruffle player
## (the site's own build, nightly 2024-03-09, self-hosted at <build>/flowers/ruffle/) over the
## window's rect in page px. The canvas shows the view through crt_display.gd's barrel warp
## (window.crtQaState), so both corners are carried through that warp's inverse, as
## playground_page/arena_embed.gd does. The player loads flowers.swf with the SWFs' folder as base,
## so its hstflowers.txt and flowersmain.swf resolve beside it, as on ferryhalim.com.
##
## The site's two PHP scripts are answered in the page (window.fetch, which Ruffle's loadVariables
## uses), in the site's own reply format (docs/research/flowers-tab.md, from the SWFs' actions):
##   flowersread.php?sample=999  a random sample from web/samples.txt, replies captured from the site
##   flowersmake.php (POST)      stores the bouquet (url_full, "s|se|r|re|bgpt|m|" + six fields per
##                               flower) in localStorage under a new 12-digit number; reply=<number>
##   flowersread.php?code=N      that bouquet (reply=1), or reply=2 for an unknown number
## No e-mail is sent: that needs a mail server.
extends RefCounted

const JS := """
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
			return [box.left + d[0] * box.width, box.top + d[1] * box.height];
		};
		const [x0, y0] = toPage(p.rect[0], p.rect[1]);
		const [x1, y1] = toPage(p.rect[0] + p.rect[2], p.rect[1] + p.rect[3]);
		Object.assign(frame.style, {display: 'block', left: x0 + 'px', top: y0 + 'px', width: (x1 - x0) + 'px', height: (y1 - y0) + 'px'});
	};
})();
"""
