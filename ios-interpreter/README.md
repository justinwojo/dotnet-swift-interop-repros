# ios-interpreter: Swift calling convention in the CoreCLR interpreter (iOS)

This folder holds one iOS Simulator app that reproduces issues 1 and 2 (see the [top-level README](../README.md)).
The app makes Swift-convention P/Invokes (`CallConvSwift`) into a small Swift framework, and also exposes
`[UnmanagedCallersOnly(CallConvs = [typeof(CallConvSwift)])]` callbacks for native Swift-ABI code to call.

| File | Purpose |
|---|---|
| `Probe.swift` | Swift side: a 40-byte `@frozen struct Five` with `mutating combine(_:_:)` and `total()`, a `throws` function `capture(_:_:_:)`, `@_cdecl` controls, and a native Swift-ABI caller used to drive the reverse callbacks |
| `ProbeCaller.c` | A clang `swiftcall` caller that passes a context value in `swift_context` (x20). It drives the reverse `SwiftSelf` callbacks |
| `Program.cs` | All the managed declarations and checks. The cases are selected through the `REPRO_CASE` environment variable |
| `build-native.sh` | Builds `native-build/InteropProbe.framework` (iOS Simulator arm64) and writes LLVM IR to `artifacts/` |
| `run.py` | Installs and launches one prebuilt app on a booted simulator, then writes `artifacts/<config>-<engine>-<case>.{log,json}` |
| `evidence/` | The reference run, the Swift/C LLVM IR, the exported native symbols, and a disassembly excerpt of the shipped `libcoreclr.dylib` |

## Engine selection

Debug versus Release isn't the relevant variable; what matters is **whether the app's own methods run in the interpreter**.
On .NET 11 iOS CoreCLR the workload's Debug default is `FilterReadyToRunAssemblies=true`. That setting keeps user assemblies out
of the ReadyToRun composite, so they run interpreted. The Release default precompiles them. `ReproEngine` sets that property
explicitly, so all four combinations can be built:

| `-p:ReproEngine=` | `FilterReadyToRunAssemblies` | App methods run in |
|---|---|---|
| `interpreter` (default) | `true` | CoreCLR interpreter |
| `r2r` | `false` | ReadyToRun code |

Each engine builds into its own `bin/<engine>/` and `obj/<engine>/`. `run.py` counts the `Probe` method bodies present in the app's
`*.r2r` image and records the count in every receipt as `probeMethodsPrecompiled`. The count is 0 for `interpreter` and 28 for `r2r`,
so every receipt shows which engine actually ran.

## Running

Requirements: macOS on Apple silicon, Xcode 27.0 with an iOS 27.0 simulator, the .NET SDK `11.0.100-rc.2.26504.105` (pinned in
`global.json`) and the `ios` workload `27.0.12212-net11-rc.2`.

```bash
export DEVELOPER_DIR=/Applications/Xcode-27.0.0.app/Contents/Developer
./build-native.sh
dotnet build -c Debug   -p:ReproEngine=interpreter
dotnet build -c Debug   -p:ReproEngine=r2r
dotnet build -c Release -p:ReproEngine=interpreter
dotnet build -c Release -p:ReproEngine=r2r

SIM=<udid of a booted arm64 iOS simulator>
python3 run.py --simulator $SIM --configuration Debug --engine interpreter --case self
# cases: all, self, self-scalar, self-first, forward-error, reverse-error, reverse-self
```

`run.py` never boots, shuts down or erases a simulator. The only bundle it installs or terminates is `com.swiftinteroprepro.interpreter`.

**Run each case in its own process (`--case <name>`).** Later `SwiftSelf` calls in the same process behave differently once
issue 1 has fired. Our reading of the disassembly (inferred, not observed directly) is that issue 1 leaves the thread's GC mode
wrong (see issue 1 in the [top-level README](../README.md)). The single-case runs are deterministic. The `all` run is kept in
`evidence/` for completeness.

## Cases

| Case | Issue | Declaration under test | Expected |
|---|---|---|---|
| `self` | 1 | `Combine(SwiftIndirectResult, long, long, SwiftSelf)` with a stack receiver and a heap receiver | receiver `11,22,33,14,25` |
| `self-scalar` | 1 | `long Total(SwiftSelf)`, non-mutating | receiver unchanged `1,2,3,4,5` |
| `forward-error` | 2 | `CaptureErrorFirst(SwiftIndirectResult, SwiftError*, long, long, long)`, plus an error-last control | `11,22,33,44,55` |
| `self-first` | 2 | `CombineSelfFirst(SwiftIndirectResult, SwiftSelf, long, long)` | `11,22,33,14,25` |
| `reverse-error` | 2 | callback `(long value, SwiftError* error)`, plus an error-first control | `value=12345` |
| `reverse-self` | 2 | callback `(SwiftSelf self, long value)`, plus a self-last control `(long value, SwiftSelf self)` | `value=12345`, `self=0x5e1fc0de0000` |

Each case also runs a `@_cdecl` control of the same Swift function where one applies. The controls pass everywhere.

## Reference results (11.0.0-rc.2.26504.105, iPhone 18 Pro simulator, iOS 27.0)

Single-case runs, from `evidence/reference-run/`:

| Case | Debug + interpreter | Release + interpreter | Debug + r2r | Release + r2r |
|---|---|---|---|---|
| `self` | **FAIL** receiver `4294967307,22,33,14,25` (stack and heap) | **FAIL** (same) | PASS | PASS |
| `self-scalar` | **FAIL** receiver `4294967297,2,3,4,5` | **FAIL** (same) | PASS | PASS |
| `forward-error` | **FAIL** `<addr>,11,22,44,55` | **FAIL** (same shape) | PASS | PASS |
| `self-first` | **FAIL** `<addr+1>,12,<addr+13>,<addr+4>,15` | **FAIL** (same shape) | PASS | PASS |
| `reverse-error` | **FAIL** `value=<addr> error=0x3039` | **FAIL** (same shape) | PASS | PASS |
| `reverse-self` | **FAIL** `.first`: `value=103490472771584`; `.last` passes | **FAIL** (same) | PASS | PASS |

`4294967307` is `0x1_0000000B`: the original `11` with `1` written into bytes 4–7. `4294967297` is `0x1_00000001`.
`0x3039` is `12345`. `103490472771584` is `0x5E1FC0DE0000`, the context marker: `ProbeCaller.c` deliberately leaves it in x1, so
a callback that reads `value` one register too high sees it instead of a stale copy of `12345`.
