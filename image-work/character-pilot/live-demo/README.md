# Character walk-around playtest — prototype #231

Question: how do the selected character's pose, turning and idle/WALK/DASH transitions feel when a person drives them?

Keyboard: WASD or arrows move, Shift sprints, R resets. Touch: hold a direction and Sprint together. Change view cycles the game-angle, profile and lower camera. Trees and the outer fence collide. The ground stays flat.

This standalone Godot4.7.2 project reuses selected WALKv5 and Fastv6. It creates no runtime dependency and uses no paid provider. Fast motion is imported from the fast GLB's `walk` slot into a separate `dash` clip. Actual Animation method keys emit dash puffs; WALK/idle suppress them. Puffs retain their world birth position. Animation import uses240fps with optimization disabled, matching the native receipts.

```bash
python3 image-work/character-pilot/live-demo/build.py
```

The command prints the generated site folder under ignored `build/character-playtest/<content-hash>/site`. The neighbouring project and build logs are disposable. The saved sources regenerate them. Publish the printed folder using the share skill and retain it for the owner's review:

```bash
python3 ~/agentic-workflow/scripts/share.py <printed-site-folder> --label character-walk --reason 'Owner-requested live character playtest, issue231' --keep 3d
node image-work/character-pilot/live-demo/browser_check.cjs <published-url> image-work/character-pilot/live-demo/evidence
```

The browser check actually holds keys and sends two simultaneous touch contacts. It verifies movement, turning, sprint, stop, no new dust after stopping, reset and the camera button, at960×720 and390×844. Screenshots are inspected; `evidence/browser.json` records the observed state. It uses the host's installed Puppeteer/Chrome rather than adding a dependency. `evidence/provenance.json` binds the tested build and assets.

Limits: this exposes the current rig rather than certifying exact Animal Crossing likeness. The source WALK boot/contact-order difference remains. A short blend-floor lift prevents obvious transition sinking on this flat test floor; it does not plant feet during turns/blends. Travel speeds1.05m/s WALK and1.8m/s DASH are playtest choices, not recovered source speeds. Foot sliding, terrain, speed matching and collision-aware locomotion require further work. The trees/fence are simple test geometry, not generated assets.

The web export uses Compatibility/WebGL2 and a single-thread template, following [Godot's web export documentation](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html). A browser with WebGL2 enabled is required. No export binary is committed; only the small source and review evidence are captured on the prototype branch.
