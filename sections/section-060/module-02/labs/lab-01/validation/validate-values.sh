#!/usr/bin/env bash
# Check: the user-supplied values recorded in revisions 1 and 2.
set -uo pipefail

PYCODE=$(cat <<'PY'
import sys, json, base64, gzip

def load_releases(raw_json):
    try:
        data = json.loads(raw_json)
    except ValueError:
        return []
    out = []
    for item in data.get("items", []):
        if item.get("type") != "helm.sh/release.v1":
            continue
        try:
            raw = base64.b64decode(item["data"]["release"])
            raw = base64.b64decode(raw)
            if raw[:3] == b"\x1f\x8b\x08":
                raw = gzip.decompress(raw)
            out.append(json.loads(raw))
        except Exception:
            continue
    out.sort(key=lambda rel: rel.get("version", 0))
    return out

failed = False

def check(ok, good, bad):
    global failed
    if ok:
        print("PASS: " + good)
    else:
        print("FAIL: " + bad)
        failed = True

def as_int(value):
    try:
        return int(str(value))
    except ValueError:
        return None

releases = load_releases(sys.stdin.read())
by_version = {rel.get("version"): rel for rel in releases}
first = by_version.get(1, {}).get("config", {}) or {}
second = by_version.get(2, {}).get("config", {}) or {}
check(as_int(first.get("replicaCount")) == 2, "revision 1 recorded replicaCount 2", "revision 1 recorded replicaCount %s, expected 2" % first.get("replicaCount"))
check(as_int(second.get("replicaCount")) == 3, "revision 2 recorded replicaCount 3", "revision 2 recorded replicaCount %s, expected 3" % second.get("replicaCount"))
check(second.get("logLevel") == "debug", "revision 2 recorded logLevel debug", "revision 2 recorded logLevel %s, expected debug" % second.get("logLevel"))

sys.exit(1 if failed else 0)
PY
)

kubectl -n starfleet get secrets -l owner=helm,name=scout -o json 2>/dev/null | python3 -c "$PYCODE"
exit $?
