#!/usr/bin/env bash
# Check: three or more revisions, revision 2 is an upgrade, the latest revision is a rollback to revision 1.
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
versions = [rel.get("version") for rel in releases]
check(len(releases) >= 3, "the release has %d revisions" % len(releases), "the release has %d revisions, expected at least 3" % len(releases))
by_version = {rel.get("version"): rel for rel in releases}
second = by_version.get(2, {}).get("info", {}).get("description", "")
check(second.startswith("Upgrade"), "revision 2 is an upgrade", "revision 2 description is '%s', expected an upgrade" % second)
if releases:
    latest = releases[-1]
    description = latest.get("info", {}).get("description", "")
    check(description.startswith("Rollback to 1"), "the latest revision (%s) is a rollback to revision 1" % latest.get("version"),
          "the latest revision description is '%s', expected 'Rollback to 1'" % description)

sys.exit(1 if failed else 0)
PY
)

kubectl -n starfleet get secrets -l owner=helm,name=scout -o json 2>/dev/null | python3 -c "$PYCODE"
exit $?
