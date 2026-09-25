## The Flowers game on the Web build: window.flowersEmbed(placement | null) keeps one Ruffle player
## (the site's own build, nightly 2024-03-09, self-hosted at <build>/flowers/ruffle/) over the
## window's rect in page px. The canvas shows the view through crt_display.gd's barrel warp
## (window.crtQaState), so both corners are carried through that warp's inverse, as
## playground_page/arena_embed.gd does. The player loads flowers.swf with the SWFs' folder as base,
## so its hstflowers.txt and flowersmain.swf resolve beside it, as on ferryhalim.com.
extends RefCounted

const JS := """
window.flowersEmbed = (() => {
	const BASE = new URL('flowers/', document.baseURI).href;
	let frame = null;
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
