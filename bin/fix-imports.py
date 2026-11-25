#!/usr/bin/env python3
"""Adds missing `import qs`, `import qs.services`, `import qs.components` lines to every QML file
that uses Theme / a service / a shared component without importing it. Idempotent.
Usage:  python3 fix-imports.py /path/to/rice/quickshell   [--dry]"""
import os, re, sys
root = sys.argv[1]; dry = "--dry" in sys.argv
names = lambda d: {f[:-4] for f in os.listdir(os.path.join(root, d)) if f.endswith(".qml")}
SERV, COMP = names("services"), names("components")

def code_only(t):
    t = re.sub(r"/\*.*?\*/", "", t, flags=re.S); t = re.sub(r'"(\\.|[^"\\])*"', '""', t)
    return re.sub(r"//[^\n]*", "", t)

changed = 0
for dp, _, files in os.walk(root):
    for fn in files:
        if not fn.endswith(".qml"): continue
        p = os.path.join(dp, fn); rel = os.path.relpath(dp, root); text = open(p).read(); body = code_only(text)
        used = lambda s: any(re.search(r"(?<![\w.])%s\b" % n, body) for n in s if n != fn[:-4])
        need = []
        if fn != "Theme.qml" and re.search(r"(?<![\w.])Theme\b", body): need.append("import qs")
        if rel != "services" and used(SERV): need.append("import qs.services")
        if rel != "components" and used(COMP): need.append("import qs.components")
        if fn == "Theme.qml" and used(SERV): need.append("import qs.services")
        need = list(dict.fromkeys(need))
        need = [i for i in need if not re.search(r"^%s\s*$" % re.escape(i), text, flags=re.M)]
        if not need: continue
        lines = text.split("\n"); last = max([i for i, l in enumerate(lines) if l.startswith("import ")], default=-1)
        lines[last + 1:last + 1] = need
        print(("would fix " if dry else "fixed     ") + os.path.relpath(p, root) + "  +" + ", ".join(i[7:] for i in need))
        if not dry: open(p, "w").write("\n".join(lines))
        changed += 1
print("files needing changes:" if dry else "files changed:", changed)
