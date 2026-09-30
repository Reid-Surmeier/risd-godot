# Blender control and bake execution for the character pilot

Research for [Research: Blender MCP control and repeatable texture-bake execution](https://github.com/Reid-Surmeier/risd-godot/issues/229), child of [Map: repeatable Muse character assets with Blender baking and animation](https://github.com/Reid-Surmeier/risd-godot/issues/226). Inspected September 30, 2026. This resolves the control-path question; it does not establish character quality or a connected MCP session.

## Decision

Use the installed **Blender 4.3.2** binary for saved `bpy` stages, running headless on CPU first. Reuse the existing native bake/export recipe. Use the existing pinned Blender MCP definition for GUI inspection and small saved-stage calls after a project-scoped setup change. Do not put long bake jobs inside a synchronous MCP request. This recommendation follows the successful local smoke below and the installed bridge's execution/timeout behavior. [Local smoke](#verification), [installed client and add-on](#local-primary-source-record).

## Live inventory

| Item | Verified state |
| --- | --- |
| `/usr/bin/blender --version` | 4.0.2 |
| `/home/reidsurmeier/.local/opt/blender-4.3.2/blender --version` | 4.3.2, build hash `32f5fdce0a0a` |
| `nvidia-smi` | RTX 4070 SUPER, driver 591.86, 12,282 MiB |
| Blender 4.3.2 Cycles CUDA device discovery | CPU only: AMD Ryzen 9 7950X. GPU Cycles baking is **not verified** despite the visible NVIDIA device. |
| Installed add-on | `~/.config/blender/4.3/scripts/addons/blender_mcp.py`; display version 1.7, protocol 7 |
| Cached client package | `mcp-for-blender==2.0.0`; expected add-on protocol 7 |
| `ss -ltnp '( sport = :9876 )'` | No listener |
| This research session | No callable Blender MCP tools |
| This repository | No `project-sets.json` or project `.codex/config.toml`/ `.mcp.json` found in the working tree |

These are local read-only probes, not guesses from an earlier session. The add-on's displayed 1.7 is not the client package's version number; their inspected protocol values match. [Local primary sources](#local-primary-source-record), [package metadata](https://pypi.org/project/mcp-for-blender/2.0.0/).

## Repeatable native execution

Pin the absolute binary; do not use the host's default `blender`. A saved stage should construct or explicitly load its inputs, then run:

```bash
/home/reidsurmeier/.local/opt/blender-4.3.2/blender \
  --background --factory-startup --threads 1 \
  --python-exit-code 1 --python path/to/saved_stage.py
```

`--factory-startup` skips the user's startup file; it does not promise a completely isolated preference/environment profile. `--python-exit-code 1` turns a command-line Python exception into a failed process. Read saved input files explicitly inside the stage so command argument ordering does not accidentally reset a loaded scene. [Blender 4.3 CLI arguments](https://docs.blender.org/manual/en/4.3/advanced/command_line/arguments.html).

For a color-only bake, select the final UV mesh, make it the view layer's active object, and make a fresh target Image Texture node active in **every** material slot being baked. Keep the source texture connected separately. Use:

```python
scene.render.engine = "CYCLES"
scene.cycles.device = "CPU"
scene.render.bake.margin = 8
bpy.ops.object.bake(type="DIFFUSE", pass_filter={"COLOR"})
```

Or route the authored source color through Emission and use `type="EMIT"`, as the existing trial and this smoke did. A UV map and active image target are required. For the pilot, 8 pixels is a starting margin, not a guaranteed value for every atlas/resolution. Save the image externally, then connect the saved baked image to Principled Base Color for export. Check RGB pixels separately from alpha: `max(image.pixels)` alone can pass a black image with opaque alpha. [Blender 4.3 baking](https://docs.blender.org/manual/en/4.3/render/cycles/baking.html), [existing saved bake source](https://github.com/Reid-Surmeier/risd-godot/blob/0f690ea63245c633b04cb2dbb35ac28ff0bb710e/modules/shell/prototype/gallery_walk4/identity/build.py).

A generated high mesh projected onto a different low mesh needs **Selected to Active**, with the low mesh active and selected high meshes as sources. A ray distance/cage must cover the source without intersecting unrelated body parts. Same-mesh color baking does not need that projection. Both sides should use the same rest pose for transfer; that is the proposed pilot procedure, not a claim that a T-pose image creates a rig. Normal maps for a deforming asset should use tangent space; bake AO separately rather than quietly baking lighting into base color. [Blender 4.3 selected-to-active, cage and tangent-normal documentation](https://docs.blender.org/manual/en/4.3/render/cycles/baking.html).

## Animation export

Export only the intended meshes **and armature**, with UVs, materials, skinning and clips enabled:

```python
bpy.ops.export_scene.gltf(
    filepath=str(output_glb),
    export_format="GLB",
    use_selection=True,
    export_animations=True,
    export_animation_mode="ACTIONS",
    export_skins=True,
)
```

The local 4.3.2 operator exposes `ACTIONS`, `ACTIVE_ACTIONS`, `BROADCAST`, `NLA_TRACKS`, and `SCENE`. In Actions mode, exported actions must be active on an object or stashed on that object's NLA tracks; unrelated actions in the data file are not automatically exported. Use `NLA_TRACKS` deliberately when the intended clip consists of multiple strips or NLA modifiers. Prefer the explicit current mode over copying the old trial's `export_nla_strips=True` argument. [Live RNA probe](#verification), [Blender 4.3 glTF animations](https://docs.blender.org/manual/en/4.3/addons/import_export/scene_gltf2.html#animations).

glTF carries object transforms, pose-bone animation and shape-key values. The 4.3 manual says physics, light and material-property animation are ignored by this export route. Bake simulations/constraints into supported channels when needed and verify the exported clips; keep Godot particles, footstep timing and runtime material effects as separate intended runtime work. This limits what “animation effects” can be assumed to survive a GLB. [Blender 4.3 glTF animation limitations](https://docs.blender.org/manual/en/4.3/addons/import_export/scene_gltf2.html#animations).

Inspect the binary's JSON before claiming transfer: skins/joints, `JOINTS_0` and `WEIGHTS_0`, `TEXCOORD_0`, embedded image buffer views, material `baseColorTexture`, named animation channels and clip count. Then reimport/render in Blender and Godot at the intended camera distance. A count check proves presence, not correct deformation or a readable painted face. [glTF 2.0 specification](https://registry.khronos.org/glTF/specs/2.0/glTF-2.0.html), [existing project transfer recipe](gallery-visitor-uv-bake-sources.md).

## MCP connection and recovery

The reviewed managed definition already exists in `~/agentic-workflow/mcp/blender/project.toml`:

```toml
[mcp_servers.blender]
command = "/home/reidsurmeier/.local/bin/uvx"
args = ["--from", "mcp-for-blender==2.0.0", "mcp-for-blender"]

[mcp_servers.blender.env]
BLENDER_HOST = "localhost"
BLENDER_PORT = "9876"
DISABLE_TELEMETRY = "true"
```

A GUI/event-loop Blender process and the enabled matching add-on are necessary. The installed add-on explicitly refuses `blender -b`; if no physical desktop is available, its source suggests `xvfb-run -a blender`, **without** `-b`. Its default scene flag auto-starts the loopback server; manual start is `bpy.ops.blendermcp.start_server()` or the MCP for Blender sidebar button. Auto-start checks for an existing listener and skips a conflicting port. None of these connection steps was executed by this research ticket. [Managed definition and README](#local-primary-source-record), [installed add-on `start`, auto-start, and operators](#local-primary-source-record), [upstream connection instructions](https://github.com/ahujasid/mcp-for-blender#quickstart).

The installed client serializes send/receive on a connection and waits up to 180 seconds for the response. The add-on queues work, then drains it on Blender's main thread every 0.05 seconds; a synchronous bake blocks that thread. The add-on's 1-second socket read timeout is a poll/recovery interval, **not a bake cancellation deadline**. A client timeout/disconnect does not cancel already executing Python. Do not automatically resend a mutating or generation request. Check the saved output/log and the running scene first; reconnect only after the prior job's state is known. [Installed client `BlenderConnection` and add-on `_drain_command_queue`/`_handle_client`](#local-primary-source-record).

For long jobs, have MCP initiate or inspect a saved external headless stage and return quickly, then inspect its process/output separately. Retain input hashes, stage version, log, output paths, and a success record created only after checks pass. This is the proposed control procedure; no custom job scheduler is needed for the one-character pilot. Small scene inspection and short operations may run directly through the add-on's `execute_code`, which captures Python stdout and errors. [Installed add-on `execute_code`](#local-primary-source-record).

## Minimal setup proposal

1. Make a narrowly scoped setup Issue/PR that enables the **existing** Blender server for `risd-godot` using the managed source. This repo has no project-set renderer yet: either adopt the reviewed `project-sets.json` + renderer together or check in only the existing server table as allowed by ADR 0008; do not introduce the template's unrelated GitNexus, skill or rule changes. If adopting the renderer, inspect its writes first: it writes `.ruler/AGENTS.md` and replaces its managed server files. [ADR 0008](https://github.com/Reid-Surmeier/agentic-workflow/blob/b5f7f1bc0f70f87ff9d003f10d6a8cec8007b1ef/docs/adr/0008-mcp-core-and-project-scope.md), [reviewed renderer source](https://github.com/Reid-Surmeier/agentic-workflow/blob/b5f7f1bc0f70f87ff9d003f10d6a8cec8007b1ef/new-repo/scripts/project_sets.py).
2. Add this repo to the record's Blender project inventory through that record's reviewed source, rather than editing rendered global configuration. The current managed Blender page names only Jax-Solve-Slicer. Leave provider integrations/key storage disabled. [Managed Blender page](#local-primary-source-record).
3. Launch the installed 4.3.2 GUI with the installed add-on enabled, confirm protocol 7 and a loopback 9876 listener, and start a fresh trusted project session so Codex loads the project MCP tools. Run a read-only version/scene query, then one short unpaid saved-stage operation before claiming MCP works. [Managed README and installed protocol source](#local-primary-source-record).

This is a reviewed change proposal only. Research made no global edits, installed no package, started no socket, called no paid provider, and left no smoke assets behind.

## Reuse the earlier bake trial

The source is `modules/shell/prototype/gallery_walk4/identity/build.py` at [commit 0f690ea63245c633b04cb2dbb35ac28ff0bb710e](https://github.com/Reid-Surmeier/risd-godot/blob/0f690ea63245c633b04cb2dbb35ac28ff0bb710e/modules/shell/prototype/gallery_walk4/identity/build.py). It imports the Rogue rig/animation, substitutes authored meshes, bakes a 512×512 Emission albedo and separate AO, connects exporter-recognized AO, joins meshes and exports GLB. Its 4.3 minimum guard reports a prior blank-bake problem on host 4.0; this ticket did **not** reproduce or generalize that older bug. Do not rerun this file in the build worktree because it overwrites its local candidate asset.

The captured trial kept 41 joints and 76 animations and found both maps in Godot. Its matched gameplay views found no clear improvement from the shirt-only texture at the small embedded camera size. Reuse its **procedure and seam checks**, not its selected character/appearance or a presumption that more maps improve the result. [Trial and visual verdict](gallery-visitor-uv-bake-trial.md), [fixed trial evidence](https://github.com/Reid-Surmeier/risd-godot/blob/0f690ea63245c633b04cb2dbb35ac28ff0bb710e/docs/evidence/gallery-visitor-uv-bake/README.md).

## Verification

The read-only headless version/RNA/CUDA probe exited 0. An isolated CPU smoke constructed a UV sphere and emission material, baked a 32×32 image, checked **RGB red** was nonblank, saved the PNG, connected it to Principled Base Color, added a two-frame object-transform action, exported GLB, parsed JSON and asserted one animation and one image. Blender exited 0:

```json
{"blender":"4.3.2","rgb_red_max":0.9058824181556702,"animations":1,"images":1,"bytes":5916,"uv":true}
```

This smoke verifies native color baking and object-animation/image/UV export. It does not verify skinning, a new character, GPU baking, visual fidelity or an MCP connection. The temporary directory was under this research worktree and automatically removed. Reproduce the exact unpaid smoke by writing the following as a temporary `probe.py` and running the pinned command above. The script removes its generated assets:

```python
import bpy, json, struct, tempfile
from pathlib import Path
bpy.ops.wm.read_factory_settings(use_empty=True)
with tempfile.TemporaryDirectory(prefix=".blender-research-smoke-", dir=".") as temp:
 bpy.ops.mesh.primitive_uv_sphere_add(segments=8, ring_count=4)
 obj=bpy.context.object
 mat=bpy.data.materials.new("probe"); mat.use_nodes=True
 nodes=mat.node_tree.nodes; nodes.clear()
 out=nodes.new("ShaderNodeOutputMaterial")
 emit=nodes.new("ShaderNodeEmission"); emit.inputs["Color"].default_value=(0.8,0.2,0.1,1)
 mat.node_tree.links.new(emit.outputs[0], out.inputs["Surface"])
 image=bpy.data.images.new("probe",width=32,height=32)
 target=nodes.new("ShaderNodeTexImage"); target.image=image; nodes.active=target
 obj.data.materials.append(mat)
 bpy.context.scene.render.engine="CYCLES"
 bpy.context.scene.cycles.device="CPU"; bpy.context.scene.cycles.samples=1
 bpy.ops.object.bake(type="EMIT")
 rgb=list(image.pixels)[0::4]
 assert max(rgb)>0.5, "RGB bake blank"
 image.filepath_raw=str(Path(temp)/"probe.png"); image.file_format="PNG"; image.save()
 nodes.clear(); out=nodes.new("ShaderNodeOutputMaterial"); bsdf=nodes.new("ShaderNodeBsdfPrincipled"); tex=nodes.new("ShaderNodeTexImage"); tex.image=image
 mat.node_tree.links.new(tex.outputs["Color"],bsdf.inputs["Base Color"]); mat.node_tree.links.new(bsdf.outputs[0],out.inputs["Surface"])
 obj.location=(0,0,0); obj.keyframe_insert(data_path="location",frame=1)
 obj.location=(0.1,0,0); obj.keyframe_insert(data_path="location",frame=2)
 path=Path(temp)/"probe.glb"
 bpy.ops.export_scene.gltf(filepath=str(path),export_format="GLB",use_selection=True,export_animations=True,export_animation_mode="ACTIONS",export_skins=True)
 raw=path.read_bytes(); length=struct.unpack_from("<I",raw,12)[0]; data=json.loads(raw[20:20+length])
 assert len(data["animations"])==1 and len(data["images"])==1
 print("RESEARCH_SMOKE="+json.dumps({"blender":bpy.app.version_string,"rgb_red_max":max(rgb),"animations":len(data["animations"]),"images":len(data["images"]),"bytes":len(raw),"uv":"TEXCOORD_0" in data["meshes"][0]["primitives"][0]["attributes"]}))

```

## Local primary-source record

All inspected local source paths are provided so another session can repeat the audit. The hashes identify exactly what was read; package metadata identifies client 2.0.0 independently of the mutable public upstream main branch.

- [Installed add-on](/home/reidsurmeier/.config/blender/4.3/scripts/addons/blender_mcp.py): SHA-256 `c836e1e7f9a7177e0101abeb9b34d80103e194dcdec8d086deb0bd9251451767`.
- [Cached client](/home/reidsurmeier/.cache/uv/archive-v0/mybSu209cne7nj1g/blender_mcp/server.py): SHA-256 `277c0ff92d3e96f730220cc38226afce7aab7175dd0d600b5007c0bd6763769a`.
- [Cached protocol manager](/home/reidsurmeier/.cache/uv/archive-v0/mybSu209cne7nj1g/blender_mcp/addon_manager.py), [cached package metadata](/home/reidsurmeier/.cache/uv/archive-v0/mybSu209cne7nj1g/mcp_for_blender-2.0.0.dist-info/METADATA).
- [Managed Blender README](/home/reidsurmeier/agentic-workflow/mcp/blender/README.md), [scope page](/home/reidsurmeier/agentic-workflow/mcp/blender/MCP.md), [definition](/home/reidsurmeier/agentic-workflow/mcp/blender/project.toml), inspected record commit `b5f7f1bc0f70f87ff9d003f10d6a8cec8007b1ef`.
- Blender 4.3 manual pages were fetched directly with `curl --fail --silent --location` and read. The browser fetch returned HTTP 402 for those URLs; the direct fetch succeeded. Upstream/PyPI were also checked with browsing.

