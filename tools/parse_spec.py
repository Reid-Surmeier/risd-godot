"""Parse docs/icon-set.md into structured icon records."""
import re, io, json, sys

SRC = "/home/reidsurmeier/risd-godot/docs/icon-set.md"

def parse():
    s = io.open(SRC, encoding="utf-8").read()
    blocks = re.split(r"(?=\*\*[A-Z]{2,3}-\d{2} · )", s)
    out = []
    for b in blocks[1:]:
        m = re.match(r"\*\*([A-Z]{2,3}-\d{2}) · ([^*]+?)\*\*(?:\s*\*\(([^)]*)\)\*)?", b)
        if not m:
            continue
        icon_id, name, note = m.group(1), m.group(2).strip(), (m.group(3) or "").strip()
        fn = ""
        fm = re.search(r"\*\*(?:\s*\*\([^)]*\)\*)?\s*—\s*(.+?)(?:\n|$)", b)
        if fm:
            fn = fm.group(1).strip()
        form = re.search(r"- Form: (.+?)(?:\n- |\n\n|\Z)", b, re.S)
        tell = re.search(r"- Tell: (.+?)(?:\n- |\n\n|\Z)", b, re.S)
        if not (form and tell):
            continue
        out.append({
            "id": icon_id,
            "name": name,
            "status": ("rejected" if "not selected" in note.lower()
                       else "unreviewed" if "unreviewed" in note.lower()
                       else "selected"),
            "function": fn,
            "form": " ".join(form.group(1).split()),
            "tell": " ".join(tell.group(1).split()),
        })
    return out

if __name__ == "__main__":
    rows = parse()
    sel = [r for r in rows if r["status"] != "rejected"]
    print(f"parsed {len(rows)} icons | {len(sel)} in the set | rejected {[r['id'] for r in rows if r['status']=='rejected']}")
    by = {}
    for r in sel:
        by.setdefault(r["id"][:3], []).append(r["id"])
    for k, v in sorted(by.items()):
        print(f"  {k}: {len(v):2}  {' '.join(v)}")
    json.dump(rows, open(sys.argv[1] if len(sys.argv) > 1 else "/dev/stdout", "w"), indent=1)
