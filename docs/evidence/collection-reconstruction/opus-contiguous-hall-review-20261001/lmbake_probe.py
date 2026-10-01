"""Read a Godot 4 LightmapGIData (.lmbake) probe field without running Godot, and tap it the
way the engine does for a dynamic object (LightStorage::lightmap_tap_sh_light, 4.7.2-stable).

Run: python3 lmbake_probe.py FILE.lmbake [--offset X Y Z] [--points points.json] [--out out.json]
  --offset  the LightmapGI node's world position; sample points are world, taps are node-local.
  --points  {"name": [x, y, z], ...} world positions (the visitor mesh's AABB centre, about y 0.9).
Prints bounds, probe count, how many probes are black, and L0 (the constant SH term) per point.
"""
import argparse
import json
import struct
import sys


class Reader:
    def __init__(self, data):
        self.d, self.p = data, 0

    def u32(self):
        v = struct.unpack_from("<I", self.d, self.p)[0]
        self.p += 4
        return v

    def u64(self):
        v = struct.unpack_from("<Q", self.d, self.p)[0]
        self.p += 8
        return v

    def f32(self, n=1):
        v = struct.unpack_from("<%df" % n, self.d, self.p)
        self.p += 4 * n
        return v if n > 1 else v[0]

    def string(self):
        n = self.u32()
        s = self.d[self.p:self.p + n].split(b"\0")[0].decode()
        self.p += n
        return s


def variant(r, names):
    t = r.u32()
    if t == 1:
        return None
    if t == 2:
        return bool(r.u32())
    if t == 3:
        return struct.unpack("<i", struct.pack("<I", r.u32()))[0]
    if t == 4:
        return r.f32()
    if t == 5:
        return r.string()
    if t == 12:
        return r.f32(3)
    if t == 15:
        return r.f32(6)
    if t == 24:
        kind = r.u32()
        if kind == 0:
            return None
        if kind in (2, 3):
            return ("resource", kind, r.u32())
        return ("external", r.string(), r.string())
    if t == 26:
        n = r.u32() & 0x7FFFFFFF
        out = {}
        for _ in range(n):
            k = variant(r, names)
            out[str(k)] = variant(r, names)
        return out
    if t == 30:
        return [variant(r, names) for _ in range(r.u32() & 0x7FFFFFFF)]
    if t == 31:
        n = r.u32()
        v = r.d[r.p:r.p + n]
        r.p += n + (-n % 4)
        return v
    if t == 32:
        n = r.u32()
        v = struct.unpack_from("<%di" % n, r.d, r.p)
        r.p += 4 * n
        return v
    if t == 33:
        n = r.u32()
        v = struct.unpack_from("<%df" % n, r.d, r.p)
        r.p += 4 * n
        return v
    if t == 35:
        n = r.u32()
        v = r.f32(3 * n)
        return [v[i:i + 3] for i in range(0, 3 * n, 3)]
    if t == 36:
        n = r.u32()
        v = r.f32(4 * n)
        return [v[i:i + 4] for i in range(0, 4 * n, 4)]
    if t == 22:  # NodePath: u16 names, u16 subnames (high bit = absolute), then string-table ids
        n, m = struct.unpack_from("<2H", r.d, r.p)
        r.p += 4
        absolute = bool(m & 0x8000)
        m &= 0x7FFF
        parts = []
        for _ in range(n + m):
            i = r.u32()
            if i & 0x80000000:
                r.p -= 4
                length = r.u32() & 0x7FFFFFFF
                parts.append(r.d[r.p:r.p + length].split(b"\0")[0].decode())
                r.p += length
            else:
                parts.append(names[i])
        return ("/" if absolute else "") + "/".join(parts[:n]) + (":" + ":".join(parts[n:]) if m else "")
    if t == 44:
        return r.string()
    if t == 40:
        v = struct.unpack_from("<q", r.d, r.p)[0]
        r.p += 8
        return v
    if t == 41:
        v = struct.unpack_from("<d", r.d, r.p)[0]
        r.p += 8
        return v
    if t == 11:
        return r.f32(4)
    if t == 10:
        return r.f32(2)
    raise ValueError("variant type %d at %d" % (t, r.p - 4))


def load(path):
    r = Reader(open(path, "rb").read())
    assert r.d[:4] == b"RSRC", "compressed or not a binary resource"
    r.p = 4
    big, real64 = r.u32(), r.u32()
    assert not big and not real64
    major, minor, fmt = r.u32(), r.u32(), r.u32()
    kind = r.string()
    r.u64()
    flags = r.u32()
    r.u64()
    if flags & 8:
        r.string()
    r.p += 4 * 11
    names = [r.string() for _ in range(r.u32())]
    for _ in range(r.u32()):
        r.string()
        r.string()
        if flags & 2:
            r.u64()
    internal = [(r.string(), r.u64()) for _ in range(r.u32())]
    r.p = internal[-1][1]
    assert r.string() == kind == "LightmapGIData", kind
    props = {}
    for _ in range(r.u32()):
        name = names[r.u32()]
        props[name] = variant(r, names)
    return (major, minor, fmt), props


def tap(probe, p):
    """lightmap_tap_sh_light: walk the BSP, then clamped barycentric blend of four probes."""
    bsp, tets, points, sh = probe["bsp"], probe["tetrahedra"], probe["points"], probe["sh"]
    if not points or not bsp or not tets:
        return None, "no probe data"
    raw = struct.pack("<%di" % len(bsp), *bsp)
    node = 0
    while node >= 0:
        a, b, c, d = struct.unpack_from("<4f", raw, node * 24)
        over, under = struct.unpack_from("<2i", raw, node * 24 + 16)
        node = over if a * p[0] + b * p[1] + c * p[2] - d > 1e-5 else under
    if node == -(2 ** 31) or node == -2147483648:
        return None, "empty leaf"
    if abs(node) - 1 >= len(tets) // 4:
        return None, "empty leaf"
    index = abs(node) - 1
    ids = tets[index * 4:index * 4 + 4]
    v = [points[i] for i in ids]
    # Geometry3D::tetrahedron_get_barycentric_coords
    def sub(x, y):
        return [x[0] - y[0], x[1] - y[1], x[2] - y[2]]
    def det(x, y, z):
        return (x[0] * (y[1] * z[2] - y[2] * z[1]) - x[1] * (y[0] * z[2] - y[2] * z[0])
                + x[2] * (y[0] * z[1] - y[1] * z[0]))
    vap, vbp = sub(p, v[0]), sub(p, v[1])
    vab, vac, vad = sub(v[1], v[0]), sub(v[2], v[0]), sub(v[3], v[0])
    vbc, vbd = sub(v[2], v[1]), sub(v[3], v[1])
    va6, vb6 = det(vbp, vbd, vbc), det(vap, vac, vad)
    vc6, vd6 = det(vap, vad, vab), det(vap, vab, vac)
    total = det(vab, vac, vad)
    if abs(total) < 1e-12:
        return None, "degenerate tetrahedron"
    w = [min(1.0, max(0.0, x / total)) for x in (va6, vb6, vc6, vd6)]
    l0 = [sum(sh[ids[i] * 9][c] * w[i] for i in range(4)) for c in range(3)]
    return l0, "tetrahedron %d weights %s" % (index, [round(x, 2) for x in w])


def weight(bounds, p):
    """_update_instance_lightmap_captures blend weight when two or more lightmaps are paired."""
    inner = [((p[i] - bounds[i]) / bounds[3 + i]) * 2.0 - 1.0 for i in range(3)]
    blend = max(abs(x) for x in inner)
    length = sum(x * x for x in inner) ** 0.5
    blend = length + (blend - length) * blend
    return max(0.0, 1.0 - blend * blend), all(abs(x) <= 1.0 for x in inner)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("lmbake")
    parser.add_argument("--offset", type=float, nargs=3, default=[0, 0, 0])
    parser.add_argument("--points")
    parser.add_argument("--out")
    args = parser.parse_args()
    version, props = load(args.lmbake)
    probe = props["probe_data"]
    points, sh = probe["points"], probe["sh"]
    assert len(sh) == len(points) * 9, (len(sh), len(points))
    black = [i for i in range(len(points)) if max(sh[i * 9][:3]) < 0.02]
    report = {
        "file": args.lmbake, "format": version, "bounds": [round(x, 3) for x in probe["bounds"]],
        "interior": probe.get("interior"), "probes": len(points),
        "tetrahedra": len(probe["tetrahedra"]) // 4, "bsp_nodes": len(probe["bsp"]) // 6,
        "black_probes_l0_below_0.02": len(black), "users": len(props.get("user_data", [])) // 4,
        "node_offset": args.offset, "taps": {},
    }
    if args.points:
        for name, world in json.load(open(args.points)).items():
            local = [world[i] - args.offset[i] for i in range(3)]
            l0, how = tap(probe, local)
            w, inside = weight(probe["bounds"], local)
            report["taps"][name] = {
                "world": world, "l0": None if l0 is None else [round(x, 4) for x in l0],
                "how": how, "blend_weight_if_paired_with_another": round(w, 3),
                "inside_bounds": inside,
            }
    report["probe_list"] = [
        {"p": [round(x, 3) for x in points[i]], "l0": [round(x, 4) for x in sh[i * 9][:3]]}
        for i in range(len(points))
    ]
    text = json.dumps(report, indent=1)
    if args.out:
        open(args.out, "w").write(text + "\n")
    summary = {k: v for k, v in report.items() if k != "probe_list"}
    print(json.dumps(summary, indent=1))


if __name__ == "__main__":
    sys.exit(main())
