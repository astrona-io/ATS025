#!/usr/bin/env bash
# Check: release scout exists in starfleet, comes from scout-chart 0.1.0 and its latest revision is deployed.
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
check(len(releases) > 0, "release scout has records in starfleet", "no Helm release named scout in starfleet (helm install scout <chart> -n starfleet)")
if releases:
    latest = releases[-1]
    meta = latest.get("chart", {}).get("metadata", {})
    check(meta.get("name") == "scout-chart" and meta.get("version") == "0.1.0",
          "the release was installed from chart scout-chart 0.1.0",
          "the release chart is %s %s, expected scout-chart 0.1.0" % (meta.get("name"), meta.get("version")))
    status = latest.get("info", {}).get("status")
    check(status == "deployed", "the latest revision is deployed", "the latest revision has status '%s', expected deployed" % status)

sys.exit(1 if failed else 0)
PY
)

kubectl -n starfleet get secrets -l owner=helm,name=scout -o json 2>/dev/null | python3 -c "$PYCODE"
exit $?
