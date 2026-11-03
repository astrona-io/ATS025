#!/usr/bin/env bash
# Check: release relay is deployed from relay-chart 0.1.0 and records replicaCount 2 and logLevel debug.
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
check(len(releases) > 0, "release relay has records in starfleet", "no Helm release named relay in starfleet")
if releases:
    latest = releases[-1]
    meta = latest.get("chart", {}).get("metadata", {})
    check(meta.get("name") == "relay-chart" and meta.get("version") == "0.1.0",
          "the release comes from chart relay-chart 0.1.0", "the release chart is %s %s, expected relay-chart 0.1.0" % (meta.get("name"), meta.get("version")))
    check(latest.get("info", {}).get("status") == "deployed", "the latest revision is deployed", "the latest revision is not deployed")
    config = latest.get("config", {}) or {}
    check(as_int(config.get("replicaCount")) == 2, "recorded replicaCount is 2", "recorded replicaCount is %s, expected 2" % config.get("replicaCount"))
    check(config.get("logLevel") == "debug", "recorded logLevel is debug", "recorded logLevel is %s, expected debug" % config.get("logLevel"))

sys.exit(1 if failed else 0)
PY
)

kubectl -n starfleet get secrets -l owner=helm,name=relay -o json 2>/dev/null | python3 -c "$PYCODE"
exit $?
