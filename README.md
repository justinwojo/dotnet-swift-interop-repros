# .NET Swift interop reproductions

Minimal, self-contained reproductions of three defects in .NET's Swift calling-convention support (`CallConvSwift`,
`SwiftSelf`, `SwiftError`, `SwiftIndirectResult`) on Apple arm64. We found them while bringing a Swift-to-C# binding generator
([swift-dotnet-bindings](https://github.com/justinwojo/swift-dotnet-bindings)) up on .NET 11 mobile CoreCLR. Every repro below
reduces the problem to one Swift function and one managed declaration, with no generated code involved.

| # | Defect | Component | Versions seen | Repro | Upstream |
|---|---|---|---|---|---|
| 1 | The interpreter's Swift call stubs don't preserve callee-saved x20/x21. On RC2 a `SwiftSelf` P/Invoke corrupts the receiver (the GC-mode restore writes `1` into `receiver+4`); on a Release build of main, `SwiftError*` P/Invokes crash | CoreCLR interpreter (arm64 call stubs) | 11.0 RC2, main | [`ios-interpreter`](ios-interpreter), cases `self`, `self-scalar`; [`runtime-main`](runtime-main) | _not filed yet_ |
| 2 | `SwiftError*` or `SwiftSelf` outside the upstream-tested position displaces the ordinary arguments, both in forward P/Invokes (special argument declared first) and in `[UnmanagedCallersOnly]` callbacks (`SwiftError*` not first, `SwiftSelf` not last) | CoreCLR interpreter (call-stub generator) | 11.0 RC2, main | [`ios-interpreter`](ios-interpreter), cases `forward-error`, `self-first`, `reverse-error`, `reverse-self` | _not filed yet_ |
| 3 | The JIT crashes (SIGSEGV in `Lowering::LowerNonvirtPinvokeCall`) when the `SwiftError` local is never read after the call | RyuJIT (optimized code), crossgen2 | 10.0.7, 11.0 RC2, main | [`desktop-jit-crash`](desktop-jit-crash) | _not filed yet_ |

Issues 1 and 2 occur only when the calling or called managed method **runs in the interpreter**. The same app passes every case
once its methods are precompiled with ReadyToRun, in both Debug and Release ([engine matrix](#engine-isolation-issues-1-and-2)).
Issue 3 is in the optimizing JIT and also affects desktop .NET 10.

All three still reproduce on dotnet/runtime `main`
([`9f06f271`](https://github.com/dotnet/runtime/commit/9f06f271b8aa0cbb073b2bb6f85b16da576e6eaa)), checked with the upstream
`src/tests/Interop/Swift` harness on osx-arm64. [`runtime-main`](runtime-main) has the results, the logs and a `tests.patch` that
adds regression tests to `SwiftSelfContext` and `SwiftErrorHandling`.

## Layout

```
ios-interpreter/        iOS Simulator app for issues 1 and 2 (one app, one case per process)
  Probe.swift             Swift side: @frozen struct Five, mutating combine / total, throwing capture
  ProbeCaller.c           clang swiftcall caller that passes a context in x20 (drives the reverse SwiftSelf case)
  Program.cs              managed declarations and checks
  build-native.sh         builds InteropProbe.framework and the LLVM IR
  run.py                  installs and runs one case and writes a receipt with hashes and the engine that ran
  evidence/               reference run (logs + JSON receipts), LLVM IR, libcoreclr disassembly excerpt
desktop-jit-crash/      osx-arm64 console app for issue 3 (net10.0 + net11.0)
  Probe.swift             func plainThrows(_:) throws -> Int64
  Program.cs              unobserved / observed cases
  run.sh                  builds and runs the full matrix
  publish.sh              ReadyToRun and NativeAOT publishes for both target frameworks
  evidence/               matrix, publish results and lldb backtraces
runtime-main/           the same issues re-checked on dotnet/runtime main with the upstream test harness
  README.md               builds, per-test results (Checked and Release, JIT and interpreter), mechanism notes, duplicate search
  tests.patch             regression tests for src/tests/Interop/Swift (git apply on the pinned commit)
  logs/                   trimmed results, lldb stops, disassembly, JitDumps
environment.txt         captured host, Xcode, simulator and .NET SDK/workload versions
```

## Environment used

Captured output: [`environment.txt`](environment.txt).

| | |
|---|---|
| Host | macOS 26.6.2 (25G83), Apple M3 Pro |
| Xcode | 27.0 (27A266a), Swift 6.4, for the iOS framework. Xcode 26.3 for the desktop dylib |
| Simulator | iPhone 18 Pro, iOS 27.0 (24A434), arm64 |
| .NET SDK | `11.0.100-rc.2.26504.105` (pinned in `ios-interpreter/global.json`), plus `10.0.107` for the .NET 10 runs |
| iOS workload | `Microsoft.iOS.Sdk.net11.0_27.0` `27.0.12212-net11-rc.2`, `UseMonoRuntime=false` (CoreCLR) |
| CoreCLR in the app | `11.0.0-rc.2.26504.105`; `libcoreclr.dylib` sha256 `855293178b5aedc91be5f005e1a844018fbbaf392a9063761b0804485240b4ba` |
| Shipped source | VMR `dotnet/dotnet@820230c3` → [`dotnet/runtime@474ed963`](https://github.com/dotnet/runtime/tree/474ed963699fc29809015392738a15231aaae2de) (`release/11.0-rc2`). Every source link below is pinned to that commit |

## The calling-convention contract we relied on

- The [Swift interop design](https://github.com/dotnet/designs/blob/1b507bda1cff8f86cfe44af3842a54911205ac3d/proposed/swift-interop.md#L60)
  says `SwiftSelf` may be "specified anywhere in the argument list", and `SwiftError` is designed the same way. The XML docs on
  `System.Runtime.InteropServices.Swift` don't impose an order.
- The only ordering rule we found applies to **`SwiftSelf<T>`**, which must be last
  ([#108547](https://github.com/dotnet/runtime/issues/108547), enforced at
  [`importercalls.cpp#L2479`](https://github.com/dotnet/runtime/blob/474ed963699fc29809015392738a15231aaae2de/src/coreclr/jit/importercalls.cpp#L2479)).
  The repros use plain `SwiftSelf`, which isn't covered by that rule.
- With the methods precompiled by ReadyToRun, every ordering used here produces correct results (the `r2r` column below). The
  JIT importer accepts these signatures too.
- As far as we can tell, the upstream tests in `src/tests/Interop/Swift` use only these orderings: `SwiftSelf` last, forward
  `SwiftError` last, and reverse `SwiftError` first. So issue 2's orderings fall outside the shapes that are tested today.

## Engine isolation (issues 1 and 2)

The iOS app's `ReproEngine` property sets `FilterReadyToRunAssemblies`, which decides whether the app assembly runs in the
interpreter (the workload's Debug default) or as ReadyToRun code (the Release default). Every receipt records how many `Probe`
method bodies are present in the R2R image, so the engine that ran can be verified. Results of the single-case runs:

| Case | Debug + interpreter | Release + interpreter | Debug + r2r | Release + r2r |
|---|---|---|---|---|
| `self` (1) | **FAIL** | **FAIL** | PASS | PASS |
| `self-scalar` (1) | **FAIL** | **FAIL** | PASS | PASS |
| `forward-error` (2) | **FAIL** | **FAIL** | PASS | PASS |
| `self-first` (2) | **FAIL** | **FAIL** | PASS | PASS |
| `reverse-error` (2) | **FAIL** | **FAIL** | PASS | PASS |
| `reverse-self` (2) | **FAIL** | **FAIL** | PASS | PASS |
| precompiled `Probe` methods | 0 | 0 | 28 | 28 |

Full logs and receipts: [`ios-interpreter/evidence/reference-run`](ios-interpreter/evidence/reference-run).

## 1. Interpreter: a `SwiftSelf` P/Invoke corrupts the receiver

```csharp
// Swift: @frozen struct Five { var a, b, c, d, e: Int64; mutating func combine(_ x: Int64, _ y: Int64) -> Five }
// IR:    swiftcc void(ptr sret, i64, i64, ptr swiftself)
[DllImport(Lib, EntryPoint = "$s12InteropProbe4FiveV7combineyACs5Int64V_AFtF")]
[UnmanagedCallConv(CallConvs = [typeof(CallConvSwift)])]
static extern void Combine(SwiftIndirectResult result, long x, long y, SwiftSelf receiver);

Five receiver = new() { A = 1, B = 2, C = 3, D = 4, E = 5 }, result = default;
Combine(new SwiftIndirectResult(&result), 10, 20, new SwiftSelf(&receiver));
// expected receiver 11,22,33,14,25   actual 4294967307,22,33,14,25   (0x1_0000000B)
```

The non-mutating, scalar-returning `long Total(SwiftSelf)` shows the same effect: the receiver changes from `1,2,3,4,5` to
`4294967297,2,3,4,5`. So neither an indirect result nor a void return is needed to trigger it.

**Mechanism** (read from the shipped binary, see [`evidence/libcoreclr-disassembly.txt`](ios-interpreter/evidence/libcoreclr-disassembly.txt)):

1. [`Load_SwiftSelf`](https://github.com/dotnet/runtime/blob/474ed963699fc29809015392738a15231aaae2de/src/coreclr/vm/arm64/asmhelpers.S#L1257) loads the receiver into x20.
2. [`CallJittedMethodRetVoid`](https://github.com/dotnet/runtime/blob/474ed963699fc29809015392738a15231aaae2de/src/coreclr/vm/arm64/asmhelpers.S#L2648) and the other `CallJittedMethodRet*` routines save only fp/lr, never x19–x28.
3. x20 is callee-saved (AAPCS64), and Swift preserves it, so the stub returns to its C++ caller with x20 still holding the
   receiver address.
4. That caller, [`InvokeUnmanagedMethodWithTransition`](https://github.com/dotnet/runtime/blob/474ed963699fc29809015392738a15231aaae2de/src/coreclr/vm/interpexec.cpp#L267),
   keeps `Thread*` in x20 across the call. The GC-mode restore at
   [L291](https://github.com/dotnet/runtime/blob/474ed963699fc29809015392738a15231aaae2de/src/coreclr/vm/interpexec.cpp#L291)
   then stores `1` to `[x20 + 4]` (`m_fPreemptiveGCDisabled`, offset
   [`0x04`](https://github.com/dotnet/runtime/blob/474ed963699fc29809015392738a15231aaae2de/src/coreclr/vm/arm64/asmconstants.h#L42)).
   That turns `11` into exactly `0x1_0000000B`.

What follows from the disassembly (we inferred this; we haven't observed it directly): the real `Thread` never gets its
cooperative mode back, so interpreted managed code keeps running while the runtime considers the thread preemptive. That fits
the order dependence we see. In the combined `all` run, the first corrupting call leaves the thread "preemptive", and later
`SwiftSelf` calls take the other branch of the restore, which only clears `[x20 + 4]` when it is non-zero. Some of those calls
then appear to pass.

[`Load_SwiftError`](https://github.com/dotnet/runtime/blob/474ed963699fc29809015392738a15231aaae2de/src/coreclr/vm/arm64/asmhelpers.S#L1271)
does the same to x21 (zeroes it, and the Swift callee leaves the error there), which is also callee-saved. Which half bites
depends on where the C++ compiler keeps `Thread*` in the caller ([details](runtime-main/README.md#a-interpreter-forward-stubs-dont-preserve-x20x21)):

| Build | `Thread*` in | Effect |
|---|---|---|
| shipped RC2, `iossimulator-arm64` | x20 | the receiver corruption above |
| main, Release + `/p:FeatureInterpreter=true`, osx-arm64 | x21 | `SwiftError*` P/Invokes crash with SIGSEGV, including the **existing** upstream `TestUnmanagedCallersOnly` and `TestUnmanagedCallersOnlyWithReturn` |
| main, Checked | (call not inlined; x19–x28 saved) | masked |

The upstream interpreter test leg builds Checked only, which hides both forms. The existing `SwiftSelf` tests also pass a class
instance, where `receiver+4` already holds `1` (the upper half of its metadata pointer), so the restore changes nothing there.

## 2. Interpreter: `SwiftError*` / `SwiftSelf` outside the tested position displaces the arguments

| Direction | Declaration | Case | Result |
|---|---|---|---|
| Forward P/Invoke | `SwiftError*` before ordinary arguments | `forward-error` | arguments one register too high |
| Forward P/Invoke | `SwiftSelf` before ordinary arguments | `self-first` | arguments one register too high |
| Reverse `[UnmanagedCallersOnly]` | `SwiftError*` after an ordinary parameter | `reverse-error` | error pointer delivered first, others move down one |
| Reverse `[UnmanagedCallersOnly]` | `SwiftSelf` before an ordinary parameter | `reverse-self` | ordinary parameter read one register too high |

Forward special arguments declared last, reverse `SwiftError*` first and reverse `SwiftSelf` last all work. Three of the four
come from one mechanism: a register is reserved for the special argument and then skipped. The reverse `SwiftError*` case has
its own mechanism: the error pointer is always stored first.

### Forward

```csharp
// Swift: func capture(_ a: Int64, _ b: Int64, _ c: Int64) throws -> Five   // returns (a, b, c, 44, 55)
[DllImport(Lib, EntryPoint = "$s12InteropProbe7captureyAA4FiveVs5Int64V_A2FtKF")]
[UnmanagedCallConv(CallConvs = [typeof(CallConvSwift)])]
static extern void CaptureErrorFirst(SwiftIndirectResult result, SwiftError* error, long a, long b, long c);

CaptureErrorFirst(new SwiftIndirectResult(&result), &error, 11, 22, 33);
// expected 11,22,33,44,55   actual <address>,11,22,44,55
```

In the interpreter's forward path, `SwiftError*` stays in the native signature
([callstubgenerator.cpp#L3024](https://github.com/dotnet/runtime/blob/474ed963699fc29809015392738a15231aaae2de/src/coreclr/vm/callstubgenerator.cpp#L3024);
the removal at [#L3080-L3098](https://github.com/dotnet/runtime/blob/474ed963699fc29809015392738a15231aaae2de/src/coreclr/vm/callstubgenerator.cpp#L3080-L3098)
applies only to reverse stubs). The argument iterator therefore assigns it x0. `ProcessSwiftSpecialArgument` then emits
`Load_SwiftError` and skips the slot ([#L2216](https://github.com/dotnet/runtime/blob/474ed963699fc29809015392738a15231aaae2de/src/coreclr/vm/callstubgenerator.cpp#L2216)),
so x0 is never loaded (it still holds the routine-table pointer) and `a, b, c` land in x1–x3. Declaring the error last works,
because the slot it consumes is then trailing.

The same thing happens with plain `SwiftSelf` placed before ordinary arguments (`self-first`):
`CombineSelfFirst(result, receiver, 10, 20)` gives `x = <address-like value>`, `y = 10`.

### Reverse

```csharp
[UnmanagedCallersOnly(CallConvs = [typeof(CallConvSwift)])]
static long CallbackErrorLast(long value, SwiftError* error) { ... }

// Called from native Swift as  @convention(thin) (Int64) throws -> Int64  with value 12345.
// expected value=12345   actual value=<address of error slot>, error=0x3039 (12345)
```

In the reverse path, `SwiftError*` is removed from the rewritten signature
([#L3096](https://github.com/dotnet/runtime/blob/474ed963699fc29809015392738a15231aaae2de/src/coreclr/vm/callstubgenerator.cpp#L3096)),
but `Store_SwiftError` is emitted unconditionally before the argument loop
([#L2156](https://github.com/dotnet/runtime/blob/474ed963699fc29809015392738a15231aaae2de/src/coreclr/vm/callstubgenerator.cpp#L2156)).
For the tested `(long value, SwiftError* error)` callback, the error pointer lands in interpreter slot 0 (read as `value`) and
`x0` in slot 1 (read as `error`). More generally, the error pointer is stored before every ordinary argument (after any
`SwiftIndirectResult`), and the ordinary arguments after it shift down by one slot.

Reverse `SwiftSelf` (`reverse-self`) is the store-side form of the forward case. `SwiftSelf` stays in the rewritten signature
and is given an argument register, but the stub stores it from x20 and skips that register. So in a `(SwiftSelf self, long value)`
callback, `self` is right and `value` is read from x1 instead of x0:

```csharp
[UnmanagedCallersOnly(CallConvs = [typeof(CallConvSwift)])]
static long CallbackSelfFirst(SwiftSelf self, long value) { ... }

// Called from a clang swiftcall function with value 12345 in x0, context 0x5E1FC0DE0000 in x20 (and left in x1).
// expected value=12345   actual value=103490472771584 (0x5E1FC0DE0000, the context)
```

`(long value, SwiftSelf self)` works.

## 3. JIT: SIGSEGV in `LowerNonvirtPinvokeCall` when the `SwiftError` local is never read

```csharp
[MethodImpl(MethodImplOptions.NoInlining)]
static long Unobserved()
{
    SwiftError error = default;
    return CallErrorLast(41, &error);   // (long, SwiftError*) -> plainThrows(_:) throws -> Int64
}
```

With `DOTNET_TieredCompilation=0`, or after tier-up under default settings, the JIT faults on .NET 10.0.7 and on 11.0 RC2.
crossgen2 exits with SIGSEGV too, so `PublishReadyToRun` fails. NativeAOT compiles and runs it. Reading `error.Value` after the
call avoids the crash. The faulting instruction is in the loop that moves the `GT_SWIFT_ERROR` node after the call
([lower.cpp#L7367-L7380](https://github.com/dotnet/runtime/blob/474ed963699fc29809015392738a15231aaae2de/src/coreclr/jit/lower.cpp#L7367-L7380)).
The loop walks `gtNext` until it finds `GT_SWIFT_ERROR`, guarded only by `assert`. A JitDump on main shows why the node is
missing: **Early liveness** (`TryRemoveDeadStoreEarly`) removes the store of `GT_SWIFT_ERROR` into the dead local, because
`gtNodeHasSideEffects` doesn't count the node as a side effect. The walk then runs off the end and dereferences null. A Checked
build of main asserts `'swiftErrorNode != nullptr' ... during 'Lowering nodeinfo'`, and so does the x64 altjit. Details, matrix,
publish results and backtraces: [`desktop-jit-crash`](desktop-jit-crash); the analysis on main:
[`runtime-main`](runtime-main/README.md#d-jit-drops-the-swifterror-store-when-the-error-is-never-read).

## Related upstream items

None of these looks like a duplicate.

- [#120049](https://github.com/dotnet/runtime/issues/120049): interpreter Swift support tracking (closed).
  [#123142](https://github.com/dotnet/runtime/pull/123142) and [#124927](https://github.com/dotnet/runtime/pull/124927) added
  the forward and reverse paths that issues 1 and 2 are in.
- [#127897](https://github.com/dotnet/runtime/issues/127897) / [#128257](https://github.com/dotnet/runtime/pull/128257): an
  earlier, different interpreter `SwiftError` loss, now fixed.
- [#131634](https://github.com/dotnet/runtime/pull/131634): Mono `SwiftError` argument-location fixes. Same family, Mono only.
- [#124949](https://github.com/dotnet/runtime/issues/124949): x64 interpreter Swift support (open).
- [#108547](https://github.com/dotnet/runtime/issues/108547): the `SwiftSelf<T>`-must-be-last rule.
- [#98586](https://github.com/dotnet/runtime/pull/98586) added the importer store and the Lowering move that issue 3 trips over.
  [#99414](https://github.com/dotnet/runtime/issues/99414) and [#99120](https://github.com/dotnet/runtime/pull/99120) /
  [#99236](https://github.com/dotnet/runtime/pull/99236) / [#99237](https://github.com/dotnet/runtime/pull/99237) are earlier
  cases of `GT_SWIFT_ERROR` missing from a generic JIT utility.

## Not covered

- Physical iOS devices. The interpreter call stubs are shared by `ios-arm64` and `iossimulator-arm64`, but we only ran on the
  simulator.
- x64 hardware, Mac Catalyst and tvOS. Issue 3 was checked with the x64 altjit only. Issues 1 and 2 are arm64-only today, since the
  interpreter's x64 Swift support isn't implemented ([#124949](https://github.com/dotnet/runtime/issues/124949)).
- crossgen2 on main.

## License

MIT. See [LICENSE](LICENSE).
