#!/usr/bin/env python3
"""Install and run one prebuilt repro app on an already-booted iOS simulator.

Saves the console output and a JSON receipt (source/binary hashes, and whether the
Probe methods were precompiled into the ReadyToRun image) under artifacts/.
It never boots, shuts down, or erases a simulator, and only installs/terminates
this repro's own bundle id.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys

CASES = ["all", "self", "self-scalar", "self-first", "forward-error", "reverse-error", "reverse-self"]
BUNDLE = "com.swiftinteroprepro.interpreter"

parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
parser.add_argument("--simulator", required=True, help="UDID of a booted arm64 iOS simulator")
parser.add_argument("--configuration", choices=["Debug", "Release"], required=True)
parser.add_argument("--engine", choices=["interpreter", "r2r"], required=True)
parser.add_argument("--case", choices=CASES, default="all")
args = parser.parse_args()

root = Path(__file__).resolve().parent
app = root / "bin" / args.engine / args.configuration / "net11.0-ios/iossimulator-arm64/InterpreterRepro.app"
if not app.is_dir():
    parser.error(f"{app} not found; build it with -c {args.configuration} -p:ReproEngine={args.engine}")
if not os.environ.get("DEVELOPER_DIR"):
    parser.error("Set DEVELOPER_DIR to the selected Xcode Contents/Developer directory.")

# Count Probe methods with native bodies in the app's ReadyToRun image: 0 means
# they run in the interpreter; >0 means they were precompiled.
r2r_symbols = 0
for image in app.glob("Frameworks/*.r2r.framework/*.r2r"):
    nm = subprocess.run(["xcrun", "nm", str(image)], stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True)
    r2r_symbols += len(re.findall(r"^[0-9a-f]+ [sStT] _InterpreterRepro_InterpreterRepro_Probe__\w+$", nm.stdout, re.MULTILINE))

artifacts = root / "artifacts"
artifacts.mkdir(exist_ok=True)
prefix = f"{args.configuration.lower()}-{args.engine}-{args.case}"
env = dict(os.environ, SIMCTL_CHILD_REPRO_CASE=args.case)
subprocess.run(["xcrun", "simctl", "install", args.simulator, str(app)], env=env, check=True, timeout=60)
command = ["xcrun", "simctl", "launch", "--console", "--terminate-running-process", args.simulator, BUNDLE]
timed_out = False
try:
    run = subprocess.run(command, env=env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, timeout=45)
    output, launcher_exit = run.stdout, run.returncode
except subprocess.TimeoutExpired as exc:
    output = (exc.stdout or b"").decode(errors="replace") if isinstance(exc.stdout, bytes) else (exc.stdout or "")
    launcher_exit, timed_out = None, True
    subprocess.run(["xcrun", "simctl", "terminate", args.simulator, BUNDLE], env=env, timeout=15, check=False)

(artifacts / f"{prefix}.log").write_text(output)
# simctl's exit status alone does not report managed assertion failures.
passed = not timed_out and launcher_exit == 0 and "COMPLETE failures=0" in output
receipt = {
    "configuration": args.configuration, "engine": args.engine, "case": args.case,
    "probeMethodsPrecompiled": r2r_symbols, "simulator": args.simulator,
    "launcherExit": launcher_exit, "timedOut": timed_out, "passed": passed,
    "completed": "COMPLETE failures=" in output, "sha256": {},
}
paths = [root / name for name in ("Program.cs", "Probe.swift", "ProbeCaller.c", "InterpreterRepro.csproj", "global.json")]
paths += [app / "libcoreclr.dylib", app / "Frameworks/InteropProbe.framework/InteropProbe"]
paths += list(app.rglob("InterpreterRepro.dll"))
for path in paths:
    if path.is_file():
        receipt["sha256"][str(path.relative_to(root))] = hashlib.sha256(path.read_bytes()).hexdigest()
(artifacts / f"{prefix}.json").write_text(json.dumps(receipt, indent=2) + "\n")

print(output)
print(f"precompiled Probe methods: {r2r_symbols}")
print("PASS" if passed else "FAIL (see artifacts/%s.log)" % prefix)
sys.exit(0 if passed else 1)
