# desktop-jit-crash: JIT crash on an unobserved `SwiftError` (osx-arm64)

This folder reproduces issue 3 (see the [top-level README](../README.md)) with a desktop console app. It needs no iOS tooling.

A Swift-convention P/Invoke takes a `SwiftError*` that points at a local, and the local is **never read after the call**:

```csharp
[DllImport("libSwiftErrorProbe.dylib", EntryPoint = "$s15SwiftErrorProbe11plainThrowsys5Int64VADKF")]
[UnmanagedCallConv(CallConvs = [typeof(CallConvSwift)])]
static extern long CallErrorLast(long a, SwiftError* error);

[MethodImpl(MethodImplOptions.NoInlining)]
static long Unobserved()
{
    SwiftError error = default;
    return CallErrorLast(41, &error);   // error is never read afterwards
}
```

The optimizing JIT then crashes with SIGSEGV in `Lowering::LowerNonvirtPinvokeCall`. Tier0 compiles the method without trouble.
If the error local is read after the call (`error.Value == null ? value : -1`), the method passes with default tiering and
with tiering disabled.

| File | Purpose |
|---|---|
| `Probe.swift` | `public func plainThrows(_ a: Int64) throws -> Int64 { a &+ 1 }`, built with library evolution |
| `Program.cs` | Cases: `unobserved`, `unobserved-error-first`, `observed` (control), `unobserved-hot` (default tiering, loops until tier-up) |
| `build-native.sh` | Builds `libSwiftErrorProbe.dylib` and `artifacts/Probe.ll` |
| `run.sh` | Builds everything and runs every case on `net10.0` and `net11.0`, under default tiering and `DOTNET_TieredCompilation=0` |
| `publish.sh` | Publishes each target framework with `PublishReadyToRun=true` and with `PublishAot=true`, and runs the cases from every publish that succeeds |
| `evidence/` | The reference matrix, the publish results and lldb backtraces for .NET 10.0.7 and 11.0 RC2 |

## Running

```bash
# DOTNET must be an SDK that can build net11.0; DOTNET10 is optional and builds the net10.0 target.
export DOTNET=/path/to/net11-rc2/dotnet
export DOTNET10=/usr/local/share/dotnet/dotnet
./build-native.sh
./run.sh       # JIT matrix   -> artifacts/matrix.txt
./publish.sh   # R2R and AOT  -> artifacts/publish.txt (full logs in artifacts/publish-*.log)
```

Exit code 139 is SIGSEGV. To see the native stack:

```bash
cd bin/Release/net11.0
DOTNET_TieredCompilation=0 lldb --batch -o run -k "bt 12" -- "$DOTNET" SwiftErrorJitCrash.dll unobserved
```

## Reference results (macOS 26.6.2, Apple M3 Pro)

From `evidence/matrix.txt`:

| Case | .NET 10.0.7 default | .NET 10.0.7 `TC=0` | .NET 11.0 RC2 default | .NET 11.0 RC2 `TC=0` |
|---|---|---|---|---|
| `observed` (control) | 0 | 0 | 0 | 0 |
| `unobserved` | 0 (Tier0) | **139** | 0 (Tier0) | **139** |
| `unobserved-error-first` | 0 (Tier0) | **139** | 0 (Tier0) | **139** |
| `unobserved-hot` | **139** (after tier-up) | **139** | **139** (after tier-up) | **139** |

Ahead-of-time compilers, same project, `-r osx-arm64` (from `evidence/publish.txt`):

| Publish mode | .NET 10 | .NET 11 RC2 |
|---|---|---|
| `PublishReadyToRun=true` | crossgen2 **exits 139** (NETSDK1096) | crossgen2 **exits 139** (NETSDK1096) |
| `PublishAot=true` | publishes; the three tested cases exit 0 | publishes; the three tested cases exit 0 |

`publish.sh` runs `observed`, `unobserved` and `unobserved-error-first` from each publish; `unobserved-hot` only exercises tier-up.

This pattern was first found in an iOS Release build, where crossgen2 exited the same way: the .NET 11 iOS workload compiles user
assemblies into the ReadyToRun composite in Release.

Top of the native stack on .NET 11 RC2 (`evidence/lldb-net11-unobserved.txt`). On .NET 10.0.7 the fault is the same instruction
sequence in the same function at `+672` (`evidence/lldb-net10-unobserved.txt`):

```
EXC_BAD_ACCESS (code=1, address=0x0)
frame #0: libclrjit.dylib`Lowering::LowerNonvirtPinvokeCall(GenTreeCall*) + 588     ldrb w8, [x21]
frame #1: libclrjit.dylib`Lowering::LowerCall(GenTree*) + 984
frame #2: libclrjit.dylib`Lowering::LowerNode(GenTree*) + 1568
frame #3: libclrjit.dylib`Lowering::DoPhase() + 192
frame #4: libclrjit.dylib`Phase::Run() + 44
frame #5: libclrjit.dylib`Compiler::compCompile(void**, unsigned int*, JitFlags*) + 4996
```
