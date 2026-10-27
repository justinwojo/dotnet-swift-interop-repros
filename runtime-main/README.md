# CoreCLR Swift interop bugs on dotnet/runtime `main`: verification and regression tests

This folder re-checks the issues from the [top-level README](../README.md) against dotnet/runtime `main`, using the upstream
`src/tests/Interop/Swift` harness on osx-arm64. The ids map to the top-level numbering like this: A = issue 1, B/B′/C/C′ = issue 2,
D = issue 3.

- **Commit:** [`9f06f271b8aa0cbb073b2bb6f85b16da576e6eaa`](https://github.com/dotnet/runtime/commit/9f06f271b8aa0cbb073b2bb6f85b16da576e6eaa) (main at the time of the clone).
- **Host:** osx-arm64 (Apple Silicon), Darwin 25.6, Xcode Swift toolchain.
- **`tests.patch`:** adds the regression tests to the existing `src/tests/Interop/Swift/SwiftSelfContext` and `SwiftErrorHandling` projects. It applies with `git apply tests.patch` on that commit (checked against a pristine export).
- **`logs/`:** small, trimmed evidence. Each file is described below.

Links in this document are pinned to the commit. `$RT` below is the runtime clone.

## Bugs

| Id | Engine | Summary |
|---|---|---|
| A | Interpreter | The forward call stubs clobber callee-saved `x20` (`Load_SwiftSelf`) and `x21` (`Load_SwiftError`, and then the Swift callee). They never restore them. The C++ caller later dereferences whichever of the two registers holds `Thread*`. |
| B | Interpreter | Forward `SwiftError*` placed before ordinary args shifts every following arg by one register. |
| B′ (sibling) | Interpreter | Forward `SwiftSelf` before ordinary args shifts them the same way. Same root cause as B. |
| C | Interpreter | Reverse (`UnmanagedCallersOnly`) with `SwiftError*` not first swaps the error and the args. |
| C′ (sibling) | Interpreter | Reverse with `SwiftSelf` not last shifts the args. Same mechanism as B on the store side. |
| D | JIT | A Swift P/Invoke whose `SwiftError` is never read: the store of `GT_SWIFT_ERROR` is removed as dead. Lowering then walks off the block (Checked assert, Release SIGSEGV). |

## Build

```sh
git clone https://github.com/dotnet/runtime && cd runtime && git checkout 9f06f271b8aa0cbb073b2bb6f85b16da576e6eaa
git apply /path/to/tests.patch

# Checked runtime + libs (a full build; expect it to take a while). FEATURE_INTERPRETER is on by default for Debug/Checked desktop.
./build.sh -s clr+libs -c checked -lc Release
# Swift interop tests + Core_Root
./src/tests/build.sh checked -tree:Interop/Swift
#  -> artifacts/tests/coreclr/osx.arm64.Checked/Tests/Core_Root
#  -> artifacts/tests/coreclr/osx.arm64.Checked/Interop/Swift/<Name>/<Name>/<Name>.{dll,sh}

# Release runtime with the interpreter (needed for A; see below). A plain `-s clr -c release`
# build has NO interpreter on osx: FEATURE_INTERPRETER defaults on only for Debug/Checked desktop and for iOS/tvOS/MacCatalyst.
./build.sh -s clr.runtime+clr.corelib -c Release /p:FeatureInterpreter=true
# Release Core_Root = copy of the Checked Core_Root, then from artifacts/bin/coreclr/osx.arm64.Release copy over:
#   libcoreclr.dylib libclrjit.dylib libclrinterpreter.dylib corerun  and  IL/System.Private.CoreLib.dll
```

## Running

The upstream way, which is what the `runtime-interpreter` pipeline does:

```sh
export CORE_ROOT=$RT/artifacts/tests/coreclr/osx.arm64.Checked/Tests/Core_Root
cd $RT/artifacts/tests/coreclr/osx.arm64.Checked/Interop/Swift/SwiftSelfContext/SwiftSelfContext
bash SwiftSelfContext.sh                      # JIT
RunInterpreter=1 bash SwiftSelfContext.sh     # the .sh exports DOTNET_Interpreter='SwiftSelfContext!*'
```

- `RunInterpreter=1` is set by [`eng/pipelines/coreclr/interpreter.yml`](https://github.com/dotnet/runtime/blob/9f06f271b8aa0cbb073b2bb6f85b16da576e6eaa/eng/pipelines/coreclr/interpreter.yml) (L98).
- That pipeline runs only **Checked** (linux/windows/osx × x64/arm64).
- `libraries-interpreter.yml` covers library tests only.

The generated xunit wrapper stops at the first failing `[Fact]`. A wrong filter also silently runs nothing and exits 100. For per-test results I therefore used a small reflection driver. It loads the test assembly and runs one named `[Fact]` per `corerun` process, printing `PASS` or `FAIL <exception>` and exiting 100 or 1. A crash shows up as the process exit code.

```csharp
// Driver.cs: corerun Driver.dll <Test.dll>            -> lists [Fact]s
//            corerun Driver.dll <Test.dll> <Type.Method> -> runs one
using System.Reflection;
static class Program {
  static int Main(string[] a) {
    var asm = Assembly.LoadFrom(Path.GetFullPath(a[0]));
    var facts = asm.GetTypes().SelectMany(t => t.GetMethods(BindingFlags.Public|BindingFlags.NonPublic|BindingFlags.Static|BindingFlags.Instance|BindingFlags.DeclaredOnly))
                   .Where(m => m.GetCustomAttributesData().Any(x => x.AttributeType.Name.EndsWith("FactAttribute"))).ToList();
    if (a.Length == 1) { foreach (var m in facts) Console.WriteLine($"{m.DeclaringType.FullName}.{m.Name}"); return 0; }
    var t = facts.Single(m => $"{m.DeclaringType.FullName}.{m.Name}" == a[1]);
    try { t.Invoke(t.IsStatic ? null : Activator.CreateInstance(t.DeclaringType), null); Console.WriteLine($"PASS {a[1]}"); return 100; }
    catch (TargetInvocationException e) { Console.WriteLine($"FAIL {a[1]}: {e.InnerException.GetType().Name}: {e.InnerException.Message.Replace('\n',' ')}"); return 1; }
  }
}
```

The two modes are run like this:
- `jit`: `corerun Driver.dll X.dll Type.Method`
- `interp`: the same, with `DOTNET_Interpreter='<Assembly>!*'`, the exact value `RunInterpreter=1` sets.

## Results

**Controls.** Without the patch, every upstream `Interop/Swift` test passes on Checked under both the JIT and the interpreter:
- 8 assemblies, about 330 `[Fact]`s.
- SwiftAbiStress, SwiftCallbackAbiStress, SwiftRetAbiStress, SwiftErrorHandling, SwiftSelfContext, SwiftIndirectResult, SwiftInlineArray and SwiftInvalidCallConv.

Release was run for **SwiftSelfContext and SwiftErrorHandling only**. Full logs:
- [`logs/results-checked.txt`](logs/results-checked.txt)
- [`logs/A-release-main.txt`](logs/A-release-main.txt)

The table covers the new tests from `tests.patch`, plus the upstream tests that behave differently on Release. In the Release interpreter column, **A** means the crash is bug A's (see below), whatever the test was written for.

| Test (`tests.patch` unless marked) | Bug | Checked JIT | Checked interp | Release JIT | Release interp |
|---|---|---|---|---|---|
| `SelfContextTests.TestSelfIsMutatedFrozenStruct` | A (x20 half) | PASS | PASS (masked) | PASS | PASS (masked) |
| `SelfContextTests.TestSelfIsMutatedFrozenStructOnHeap` | A (x20 half) | PASS | PASS (masked) | PASS | PASS (masked) |
| `SelfContextTests.TestSelfBeforeOtherArguments` | B′ | PASS | **FAIL** 45 → 4549062737 | PASS | **FAIL** 45 → 4417772033 |
| `SelfContextTests.TestReversePInvokeSelfLast` | control for C′ | PASS | PASS | PASS | PASS |
| `SelfContextTests.TestReversePInvokeSelfBeforeOtherArguments` | C′ | PASS | **FAIL** 10020 → 41014021680 | PASS | **FAIL** 10020 → 35668381232 |
| `ErrorHandlingTests.TestUnmanagedCallersOnly` *(upstream)* | — | PASS | PASS | PASS | **CRASH** SIGSEGV (A) |
| `ErrorHandlingTests.TestUnmanagedCallersOnlyWithReturn` *(upstream)* | — | PASS | PASS | PASS | **CRASH** SIGSEGV (A, inferred) |
| `ErrorHandlingTests.TestSwiftErrorLastWithValues` | control for B | PASS | PASS | PASS | **CRASH** SIGSEGV (A) |
| `ErrorHandlingTests.TestSwiftErrorBeforeOtherArguments` | B | PASS | **FAIL** "No Swift error was expected to be thrown." | PASS | **FAIL** (same) |
| `ErrorHandlingTests.TestUnmanagedCallersOnlyWithErrorLast` | C | PASS | **FAIL** 84 → -1 | PASS | **CRASH** SIGSEGV (A, inferred) |
| `ErrorHandlingTests.TestSwiftErrorNotObserved` | D | **CRASH** assert, rc 134 | PASS | **CRASH** SIGSEGV, rc 139 | **CRASH** SIGSEGV (A, inferred) |

All other upstream tests in the two assemblies pass in all four configurations.

"(A)" marks a crash that I stopped in lldb at the A fault site (`TestUnmanagedCallersOnly`, `TestSwiftErrorLastWithValues`). "(A, inferred)" marks a SIGSEGV I did not stop in a debugger; I attribute it to A because it is a forward direct-path `SwiftError*` call that crashes only on Release + interpreter.

The upstream harness itself also catches the failures. With `RunInterpreter=1`, `SwiftSelfContext.sh` reports `END EXECUTION - FAILED`: `TestSelfBeforeOtherArguments` fails, the test process exits 101 instead of the expected 100, and the wrapper script therefore exits 1 ([CLRTest.Execute.Bash.targets](https://github.com/dotnet/runtime/blob/9f06f271b8aa0cbb073b2bb6f85b16da576e6eaa/src/tests/Common/CLRTest.Execute.Bash.targets#L151-L169)) ([`logs/harness-RunInterpreter-SwiftSelfContext.txt`](logs/harness-RunInterpreter-SwiftSelfContext.txt)).

**Test-placement note.** The D test (`TestSwiftErrorNotObserved` and its two `[MethodImpl(NoInlining | AggressiveOptimization)]` helpers) lives in SwiftErrorHandling. Under the JIT it kills the whole merged SwiftErrorHandling test process. Upstream may prefer it in its own project, or marked `ActiveIssue` until D is fixed.

## A: interpreter forward stubs don't preserve x20/x21

**Mechanism** (source and disassembly):

1. `InvokeUnmanagedMethodWithTransition` ([interpexec.cpp L270](https://github.com/dotnet/runtime/blob/9f06f271b8aa0cbb073b2bb6f85b16da576e6eaa/src/coreclr/vm/interpexec.cpp#L270)) does three things:
   - `GCX_PREEMP_NO_DTOR` (L291)
   - `InvokeManagedMethod` (L293), which calls the generated `CallJittedMethod*` stub
   - `GCX_PREEMP_NO_DTOR_END` (L294), which writes `1` to `Thread::m_fPreemptiveGCDisabled`. That field is at offset 4 ([arm64/asmconstants.h L42](https://github.com/dotnet/runtime/blob/9f06f271b8aa0cbb073b2bb6f85b16da576e6eaa/src/coreclr/vm/arm64/asmconstants.h#L42)).
2. The `CallJittedMethod*` stubs ([arm64/asmhelpers.S L2606–2633](https://github.com/dotnet/runtime/blob/9f06f271b8aa0cbb073b2bb6f85b16da576e6eaa/src/coreclr/vm/arm64/asmhelpers.S#L2606-L2633)) save only `fp/lr`.
   - [`Load_SwiftSelf`](https://github.com/dotnet/runtime/blob/9f06f271b8aa0cbb073b2bb6f85b16da576e6eaa/src/coreclr/vm/arm64/asmhelpers.S#L1215-L1219) writes `x20`. `Load_SwiftSelf_ByRef` (L1221) does too.
   - [`Load_SwiftError`](https://github.com/dotnet/runtime/blob/9f06f271b8aa0cbb073b2bb6f85b16da576e6eaa/src/coreclr/vm/arm64/asmhelpers.S#L1229-L1235) does `mov x21, xzr`, and the Swift callee leaves the error, or 0, in `x21`.
   - Neither register is restored before returning to C++. Both are callee-saved under AAPCS64, so the C++ caller may keep any value there across the call.
3. What breaks therefore depends on the C++ compiler's register allocation in the caller:

| Build | Where `Thread*` lives across the stub call | Effect |
|---|---|---|
| main **Checked** | `InvokeManagedMethod` is not inlined. Its own prologue/epilogue saves and restores x19–x28. | Masked: the caller's x20/x21 come back intact. Every A-shaped test passes. |
| main **Release** (`FeatureInterpreter=true`) | Inlined, and **`x21`** = `Thread*`. | A forward Swift call with a `SwiftError*` (blittable, direct path) returns with the error value, or 0, in x21, and the post-call `ldr w8,[x21,#4]` reads through it. In the two crashes I stopped in lldb it faulted:<br>• at address `0x4` when no error was thrown<br>• at the error value + 4 otherwise<br>The tests that crashed this way include two **existing upstream tests** (`TestUnmanagedCallersOnly`, `TestUnmanagedCallersOnlyWithReturn`); the table above lists the rest. Not every such call crashes: `TestSwiftErrorBeforeOtherArguments` FAILs on its assertion instead, and I did not trace why. The x20 half is latent, because x20 holds `pArgs` here and is dead after the call. |
| shipped **11.0.0-rc.2.26504.105** iossimulator-arm64 | Inlined, and **`x20`** = `Thread*`. I disassembled the NuGet runtime-pack `libcoreclr.dylib`. | After a `SwiftSelf` call, `GCX_PREEMP_NO_DTOR_END` does `str 1,[self,#4]`:<br>• For a `@frozen` struct receiver, field `a` gets 1 in its high half (11 → 4294967307), which is the reported symptom.<br>• For a class receiver nothing visible changes (next section).<br>*Inferred, not observed:* the real `Thread` is also left with `m_fPreemptiveGCDisabled == 0` while the interpreter continues in cooperative code, a potential GC hole. |

Evidence for each build is in [`logs/A-release-main.txt`](logs/A-release-main.txt):
- the Release results
- two lldb stops at `InvokeUnmanagedMethodWithTransition+280: ldr w8, [x21, #0x4]`, one with x21=0x15 and one at address 0x4
- the main Release and RC2 disassembly
- the Checked `InvokeManagedMethod` save/restore

**Which tests use the direct path.** The upstream `SwiftErrorHandling` tests that pass on Release use `ref SwiftError`; the ones that crash use `SwiftError*`. I *infer* that `ref SwiftError` goes through the marshalling IL-stub path rather than the direct `InvokeUnmanagedMethodWithTransition` path. I did not trace that path.

**Class-instance offset-4 hypothesis: confirmed.**
- `SelfLibrary.getInstance()`, the receiver of the existing `TestSwiftSelfContext*` tests, already has `u32@4 == 0x00000001`. That is the high half of the isa/metadata pointer `0x0000000103040100`.
- RC2's `GCX_PREEMP_NO_DTOR_END` writes 1 there only if the value is 0 (`ldr; cbnz; mov w8,#1; str`). On a class instance it is a no-op.
- This is why the existing class-receiver tests never caught A.
- Evidence: [`logs/A-class-instance-offset4-probe.txt`](logs/A-class-instance-offset4-probe.txt).

**Could CI catch it?**
- Not as configured. The only CoreCLR `src/tests` interpreter leg (`runtime-interpreter`, `interpreter.yml`) builds **Checked** only, and on Checked the non-inlined `InvokeManagedMethod` masks both halves.
- On main, the existing `TestUnmanagedCallersOnly*` tests would already go red on a Release + interpreter leg (osx-arm64 or iOS, where the interpreter ships in Release).
- The receiver-corruption form (`TestSelfIsMutatedFrozenStruct*` in the patch) reproduces only where the compiler happens to keep `Thread*` in x20, as it does on RC2.
- A managed test cannot pin the register allocation. The defect is the stub's missing x20/x21 save/restore, whichever register the caller uses.

**Fix direction (suggestion only).**
- Save x20/x21 in the `CallJittedMethod*` stubs that may run `Load_SwiftSelf*` or `Load_SwiftError`, and restore them after the error has been stored. The `CallJittedMethodRetVoid` epilogue already reads x21 there.
- Or wrap the Swift call in a dedicated stub that treats them as callee-saved.

## B / B′: forward SwiftError / SwiftSelf placed before ordinary args

- [`RewriteSignatureForSwiftLowering`](https://github.com/dotnet/runtime/blob/9f06f271b8aa0cbb073b2bb6f85b16da576e6eaa/src/coreclr/vm/callstubgenerator.cpp#L2921) keeps three things in the rewritten signature, so `ArgIterator` assigns each a GP register slot:
  - `SwiftSelf` ([L2999](https://github.com/dotnet/runtime/blob/9f06f271b8aa0cbb073b2bb6f85b16da576e6eaa/src/coreclr/vm/callstubgenerator.cpp#L2999), copied at [L3114](https://github.com/dotnet/runtime/blob/9f06f271b8aa0cbb073b2bb6f85b16da576e6eaa/src/coreclr/vm/callstubgenerator.cpp#L3114))
  - `SwiftSelf<T>` (falls through at L3010–3012)
  - the forward `SwiftError*` ([L3024](https://github.com/dotnet/runtime/blob/9f06f271b8aa0cbb073b2bb6f85b16da576e6eaa/src/coreclr/vm/callstubgenerator.cpp#L3024), "Direct P/Invoke")
- The arg loop then calls [`ProcessSwiftSpecialArgument`](https://github.com/dotnet/runtime/blob/9f06f271b8aa0cbb073b2bb6f85b16da576e6eaa/src/coreclr/vm/callstubgenerator.cpp#L3201), which emits `Load_SwiftSelf` / `Load_SwiftError`, and `continue`s ([L2216](https://github.com/dotnet/runtime/blob/9f06f271b8aa0cbb073b2bb6f85b16da576e6eaa/src/coreclr/vm/callstubgenerator.cpp#L2216)).
- It never loads anything into the GP register that `ArgIterator` reserved for the special arg. Every following ordinary arg therefore lands one register later than the callee expects.
- When the special arg is last, there is nothing after it to shift, which is why every upstream test (all special-arg-last) passes.

## C / C′: reverse with SwiftError not first, or SwiftSelf not last

- For the reverse direction:
  - The reverse `SwiftError*` is excluded from the signature ([L3097](https://github.com/dotnet/runtime/blob/9f06f271b8aa0cbb073b2bb6f85b16da576e6eaa/src/coreclr/vm/callstubgenerator.cpp#L3097)).
  - `Store_SwiftError` is emitted **unconditionally before the arg loop** ([L2156–2166](https://github.com/dotnet/runtime/blob/9f06f271b8aa0cbb073b2bb6f85b16da576e6eaa/src/coreclr/vm/callstubgenerator.cpp#L2156-L2166); [asmhelpers.S L1237](https://github.com/dotnet/runtime/blob/9f06f271b8aa0cbb073b2bb6f85b16da576e6eaa/src/coreclr/vm/arm64/asmhelpers.S#L1237-L1242)).
  - The error pointer is therefore stored before every ordinary argument (after any `SwiftIndirectResult`). In the tested `(int, int, SwiftError*)` signature that is slot 0.
  - An `UnmanagedCallersOnly(int value, int setError, SwiftError* error)` receives `(error, value, setError)`. With the test's guard, it returns -1.
- `SwiftSelf` on the reverse side goes through the same keep-in-signature + `continue` path ([`Store_SwiftSelf` L1250](https://github.com/dotnet/runtime/blob/9f06f271b8aa0cbb073b2bb6f85b16da576e6eaa/src/coreclr/vm/arm64/asmhelpers.S#L1250)). `(SwiftSelf, long, long)` is shifted; `(long, long, SwiftSelf)` is fine.

**C′ also reproduces on RC2.** An earlier version of the RC2 repro reported that reverse `SwiftSelf` worked in either position.
- On main, `TestReversePInvokeSelfBeforeOtherArguments` fails **whenever the callback `CombineWithSelfFirst` is interpreted**. Narrowing `DOTNET_Interpreter` to that one method is enough, confirmed with `DOTNET_InterpList=1`.
- Narrowing it to only the self-last callback `CombineWithSelfLast` passes. A filter naming only the caller does not isolate the caller: `DOTNET_InterpList=1` shows the interpreter compiled `CombineWithSelfFirst` as well, and the test fails ([`logs/reverse-swiftself-isolation.txt`](logs/reverse-swiftself-isolation.txt)).
- The RC2 result was wrong because of the test, not the runtime. Its clang trampoline left a copy of `value` in x1, so a callee reading `value` one register too high still saw the right number. The trampoline now passes the context in x1 ([`ProbeCaller.c`](../ios-interpreter/ProbeCaller.c)). On the re-run, `reverse-self.first` fails under the interpreter (`value` = the context marker `0x5e1fc0de0000`) and passes under R2R ([`ios-interpreter/evidence/reference-run`](../ios-interpreter/evidence/reference-run)).

## D: JIT drops the SwiftError store when the error is never read

**Checked assert** (exact; standalone repro, method `PlainUnobserved`):

```
Assertion failed 'swiftErrorNode != nullptr' in 'Program:PlainUnobserved():long' during 'Lowering nodeinfo' (IL size 20; hash 0x1af67085; FullOpts)
    File: src/coreclr/jit/lower.cpp:7337
```

The same assert fires inside the patch's test: `'ErrorHandlingTests:CallIgnoringSwiftError(int):nint' ... (IL size 18; hash 0xe39e1c80; FullOpts)`.

On main Release the same test dies with SIGSEGV (rc 139). I did not capture that frame on main. On shipped RC2, lldb puts the fault in `Lowering::LowerNonvirtPinvokeCall+588`, inside the same `gtNext` walk. With the error read after the call (`error.Value == null ? v : -1`), the recorded observed controls (plain, and `SwiftIndirectResult` with the error last) pass. Evidence: [`logs/D-assert-checked.txt`](logs/D-assert-checked.txt).

**Phase that removes the store: Early liveness** (`Liveness::TryRemoveDeadStoreEarly`). Trimmed JitDump: [`logs/D-jitdump-arm64-trimmed.txt`](logs/D-jitdump-arm64-trimmed.txt).

1. **Importer.** [`impAppendSwiftErrorStore`](https://github.com/dotnet/runtime/blob/9f06f271b8aa0cbb073b2bb6f85b16da576e6eaa/src/coreclr/jit/importercalls.cpp#L2787-L2797) appends `STOREIND(&error, SWIFT_ERROR)`. The `SWIFT_ERROR` node gets `GTF_ORDER_SIDEEFF | GTF_CALL | GTF_GLOB_REF` (L2793–2794).
2. **Local morph.** `error` is a local whose address is taken only for the call, so the `STOREIND` becomes `STORE_LCL_VAR V0x (SWIFT_ERROR)` to the promoted field `SwiftError.Value`.
3. **Early liveness.** The local is never read, so [`TryRemoveDeadStoreEarly`](https://github.com/dotnet/runtime/blob/9f06f271b8aa0cbb073b2bb6f85b16da576e6eaa/src/coreclr/jit/liveness.cpp#L2776-L2790) calls `gtExtractSideEffList(data)` (L2782), with the default `GTF_SIDE_EFFECT` mask.
   - [`gtNodeHasSideEffects`](https://github.com/dotnet/runtime/blob/9f06f271b8aa0cbb073b2bb6f85b16da576e6eaa/src/coreclr/jit/gentree.cpp#L19341-L19368) honours `GTF_CALL` only on an actual `GT_CALL` / `GT_RET_EXPR`.
   - `GTF_ORDER_SIDEEFF` is not part of `GTF_SIDE_EFFECT` ([gentree.h L369, L378](https://github.com/dotnet/runtime/blob/9f06f271b8aa0cbb073b2bb6f85b16da576e6eaa/src/coreclr/jit/gentree.h#L369-L378)).
   - So `SWIFT_ERROR` counts as side-effect-free, and the dump prints `Store [000009] is dead and has no side effects, removing statement`.
4. **Lowering.** The call still has `HasSwiftErrorHandling()`. The loop at [lower.cpp L7326–7343](https://github.com/dotnet/runtime/blob/9f06f271b8aa0cbb073b2bb6f85b16da576e6eaa/src/coreclr/jit/lower.cpp#L7326-L7343) walks `gtNext` looking for `GT_SWIFT_ERROR` and runs off the end of the block. Checked trips the L7337 assert; Release dereferences null.
   - LSRA ([lsrabuild.cpp L4649–4658](https://github.com/dotnet/runtime/blob/9f06f271b8aa0cbb073b2bb6f85b16da576e6eaa/src/coreclr/jit/lsrabuild.cpp#L4649-L4658)) relies on the same invariant: `call->gtNext` is `GT_SWIFT_ERROR`.

Variants that crash identically: plain return, `SwiftIndirectResult` with the error last, and with the error first. Only "error never read" matters.

**x64.**
- The x64 altjit (`libclrjit_unix_x64_arm64.dylib`, `DOTNET_AltJit=PlainUnobserved`) hits the identical assert, also after Early liveness.
- The observed variant passes.
- Evidence: [`logs/D-jitdump-x64-altjit-trimmed.txt`](logs/D-jitdump-x64-altjit-trimmed.txt). This is the altjit cross-compile only; I did not run it on an x64 machine.

**Under the interpreter**, D does not occur (no JIT). It passes on Checked. On Release it crashes with SIGSEGV. That is *inferred* to be A, because the helper is a blittable `SwiftError*` P/Invoke like the other A crashes; I did not take an lldb stop for this one.

**Fix directions (suggestions only).** Either:
- make `GT_SWIFT_ERROR` count as a side effect for `gtNodeHasSideEffects` / `gtExtractSideEffList`, for example by treating the node like a call or honouring `GTF_ORDER_SIDEEFF` for this oper, or
- have Lowering/LSRA tolerate a missing consumer by materialising one, so the error register is still marked busy.

On .NET 10.0.7 and 11 RC2, crossgen2 also exits with SIGSEGV (139) on D, while NativeAOT compiles it ([`desktop-jit-crash/evidence/publish.txt`](../desktop-jit-crash/evidence/publish.txt)). I did not re-run crossgen2 on main.

## Duplicate search

I searched dotnet/runtime issues and PRs, open and closed, read-only, for:
- `SwiftError` + interpreter / `SwiftSelf` + interpreter
- `GT_SWIFT_ERROR`
- `swiftErrorNode`
- `LowerNonvirtPinvokeCall` + Swift
- `Load_SwiftSelf` / `Store_SwiftError`
- `RewriteSignatureForSwiftLowering`
- `CallConvSwift` crash

**No existing issue or PR describes A, B, B′, C, C′ or D.** Related items:

| # | Kind / state | Title (abridged) | Relevance |
|---|---|---|---|
| 99414 | issue, closed 2024-03-08 | [jitstressregs] SwiftErrorHandling fails | Earlier `GT_SWIFT_ERROR` / LSRA invariant fallout. Not the dead-store path. |
| 98586 | PR, merged 2024-02-26 | JIT: Support storing Swift error register value to SwiftError struct | Introduced the importer store and the Lowering move that D trips over. |
| 100692 | PR, merged 2024-04-12 | JIT: Add GT_SWIFT_ERROR_RET | Reverse-side counterpart. |
| 102519 | PR, merged 2024-05-22 | Handle GT_SWIFT_ERROR_RET in getKillSetForNode | Same family. |
| 99236 / 99237 / 99120 | PRs, merged 2024-03 | GT_SWIFT_ERROR in gtCloneExpr / GenTree::Compare / TryGetUse | Same pattern: a node missing from generic utilities. None cover side-effect extraction. |
| 120049 | issue, closed 2026-03-03 | [clr-ios] Implement Swift calling convention in CoreCLR interpreter | Tracking issue for the interpreter Swift support where A, B and C live. |
| 123142 | PR, merged 2026-02-05 | [clr-interp] Swift calling convention support … arm64 | Added the forward stubs and `Load_Swift*` routines. |
| 124927 | PR, merged 2026-03-03 | reverse P/Invoke support for Swift … arm64 | Added `Store_Swift*` and the up-front `Store_SwiftError`. |
| 125177 | PR, merged 2026-03-12 | Fix Swift error handling for marshaled P/Invokes in interpreter | The marshaled (`ref SwiftError`) path. |
| 127897 | issue, closed 2026-05-18 | Known Build Error: SwiftErrorHandling.TestSwiftErrorThrown fails in runtime-interpreter | Fixed by #128257. A different issue (transient-IL detection). |
| 128257 | PR, merged 2026-05-18 | Detect Swift calling convention for transient-IL P/Invokes | — |
| 127940 / 128113 | PRs, closed unmerged | Skip Swift interop tests under interpreter / mark SwiftErrorHandling InterpreterIncompatible | Show the tests are run under the interpreter on purpose. |
| 131634 | PR, merged 2026-08-04 | Fix mono handling of SwiftError | Mono only. |
| 124949 | issue, **open** | [clr-ios] Swift calling convention in CoreCLR interpreter on x64 | x64 interpreter support is not implemented, so A, B and C are arm64-only today. |

## What was run vs inferred

**Run on this machine at the pinned commit:**
- Both builds.
- Every result in the tables.
- The upstream harness with `RunInterpreter=1`.
- The `DOTNET_Interpreter` isolation runs.
- The class-instance probe.
- The Checked and Release lldb stops.
- objdump of the Checked, main-Release and shipped-RC2 (iossimulator-arm64 runtime pack) `InvokeUnmanagedMethodWithTransition`.
- The arm64 JitDump and the x64-altjit JitDump.
- `git apply` of `tests.patch` on a pristine export.

**Not run:**
- Anything on a physical x64 host or iOS device.
- crossgen2 on main.
- RC2 behaviour. The RC2 results come from [`ios-interpreter`](../ios-interpreter) and [`desktop-jit-crash`](../desktop-jit-crash); here the shipped RC2 binary was only disassembled.

**Inferred:**
- That `ref SwiftError` P/Invokes avoid the direct path.
- The GC-mode hazard on RC2.
- That the Release-interpreter SIGSEGVs I did not stop in lldb are the same A site as the two I did stop: `TestUnmanagedCallersOnly` and `TestSwiftErrorLastWithValues`.
- That D on main Release faults in `LowerNonvirtPinvokeCall`, which was observed on RC2.
