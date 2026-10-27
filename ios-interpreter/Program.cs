// Copyright (c) 2026 Justin Wojciechowski.
// Licensed under the MIT License.
using System.Reflection;
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;
using System.Runtime.InteropServices.Swift;

namespace InterpreterRepro;

static class Program
{
    static void Main(string[] args)
    {
        Probe.Run(Environment.GetEnvironmentVariable("REPRO_CASE") ?? "all");
        Environment.Exit(Probe.Failures == 0 ? 0 : 1);
    }
}

[StructLayout(LayoutKind.Sequential)]
struct Five
{
    public long A, B, C, D, E;
    public override string ToString() => $"{A},{B},{C},{D},{E}";
}

static unsafe class Probe
{
    const string Lib = "@rpath/InteropProbe.framework/InteropProbe";
    const string CombineSymbol = "$s12InteropProbe4FiveV7combineyACs5Int64V_AFtF";
    const string TotalSymbol = "$s12InteropProbe4FiveV5totals5Int64VyF";
    const string CaptureSymbol = "$s12InteropProbe7captureyAA4FiveVs5Int64V_A2FtKF";

    // Swift: mutating func combine(_ x: Int64, _ y: Int64) -> Five on a 40-byte @frozen struct.
    // IR: swiftcc void(ptr sret %result, i64 %x, i64 %y, ptr swiftself %self)
    [DllImport(Lib, EntryPoint = CombineSymbol)]
    [UnmanagedCallConv(CallConvs = [typeof(CallConvSwift)])]
    static extern void Combine(SwiftIndirectResult result, long x, long y, SwiftSelf receiver);

    // Same native function, SwiftSelf declared before the ordinary arguments.
    [DllImport(Lib, EntryPoint = CombineSymbol)]
    [UnmanagedCallConv(CallConvs = [typeof(CallConvSwift)])]
    static extern void CombineSelfFirst(SwiftIndirectResult result, SwiftSelf receiver, long x, long y);

    // Swift: func total() -> Int64 (non-mutating). IR: swiftcc i64(ptr swiftself %self)
    [DllImport(Lib, EntryPoint = TotalSymbol)]
    [UnmanagedCallConv(CallConvs = [typeof(CallConvSwift)])]
    static extern long Total(SwiftSelf receiver);

    // Swift: func capture(_ a: Int64, _ b: Int64, _ c: Int64) throws -> Five
    // IR: swiftcc void(ptr sret, i64 %a, i64 %b, i64 %c, ptr swiftself (unused), ptr swifterror)
    [DllImport(Lib, EntryPoint = CaptureSymbol)]
    [UnmanagedCallConv(CallConvs = [typeof(CallConvSwift)])]
    static extern void CaptureErrorFirst(SwiftIndirectResult result, SwiftError* error, long a, long b, long c);

    [DllImport(Lib, EntryPoint = CaptureSymbol)]
    [UnmanagedCallConv(CallConvs = [typeof(CallConvSwift)])]
    static extern void CaptureErrorLast(SwiftIndirectResult result, long a, long b, long c, SwiftError* error);

    // Cdecl controls and native callback drivers.
    [DllImport(Lib, EntryPoint = "probe_combine_control")]
    static extern void CombineControl(Five* result, Five* receiver, long x, long y);
    [DllImport(Lib, EntryPoint = "probe_capture_control")]
    static extern void CaptureControl(Five* result, long a, long b, long c);
    [DllImport(Lib, EntryPoint = "probe_invoke_callback")]
    static extern long InvokeCallback(void* callback, long value);
    [DllImport(Lib, EntryPoint = "probe_invoke_self_callback")]
    static extern long InvokeSelfCallback(void* callback, void* context, long value);

    public static int Failures { get; private set; }
    static void Check(string name, bool ok, string detail)
    {
        if (!ok) Failures++;
        Console.WriteLine($"{(ok ? "PASS" : "FAIL")} {name} {detail}");
    }
    static bool Equal(Five value, long a, long b, long c, long d, long e) =>
        value.A == a && value.B == b && value.C == c && value.D == d && value.E == e;
    static Five Initial => new() { A = 1, B = 2, C = 3, D = 4, E = 5 };

    static long observedValue;
    static nuint observedError;
    static nuint observedSelf;

    [UnmanagedCallersOnly(CallConvs = [typeof(CallConvSwift)])]
    static long CallbackErrorLast(long value, SwiftError* error)
    {
        observedValue = value;
        observedError = (nuint)error;
        // On the failing interpreter `error` is 12345, not a pointer. Record the
        // mismatch without dereferencing it; a correctly routed callback must
        // initialize its outgoing Swift error.
        if (value == 12345 && (nuint)error != 12345) *error = default;
        return 99;
    }

    [UnmanagedCallersOnly(CallConvs = [typeof(CallConvSwift)])]
    static long CallbackErrorFirst(SwiftError* error, long value)
    {
        *error = default;
        observedValue = value;
        observedError = (nuint)error;
        return 99;
    }

    [UnmanagedCallersOnly(CallConvs = [typeof(CallConvSwift)])]
    static long CallbackSelfLast(long value, SwiftSelf self)
    {
        observedValue = value;
        observedSelf = (nuint)self.Value;
        return 99;
    }

    [UnmanagedCallersOnly(CallConvs = [typeof(CallConvSwift)])]
    static long CallbackSelfFirst(SwiftSelf self, long value)
    {
        observedValue = value;
        observedSelf = (nuint)self.Value;
        return 99;
    }

    public static void Run(string selected)
    {
        string engine = typeof(Probe).Assembly.GetCustomAttributes<AssemblyMetadataAttribute>()
            .FirstOrDefault(a => a.Key == "ReproEngine")?.Value ?? "unknown";
        Console.WriteLine($"ENV runtime={RuntimeInformation.FrameworkDescription} arch={RuntimeInformation.ProcessArchitecture} dynamicSupported={RuntimeFeature.IsDynamicCodeSupported} dynamicCompiled={RuntimeFeature.IsDynamicCodeCompiled}");
#if DEBUG
        Console.WriteLine($"CONFIG Debug engine={engine}");
#else
        Console.WriteLine($"CONFIG Release engine={engine}");
#endif
        if (selected is "all" or "forward-error") ForwardError();
        if (selected is "all" or "reverse-error") ReverseError();
        if (selected is "all" or "reverse-self") ReverseSelf();
        // SwiftSelf cases run last because the failing interpreter writes into
        // the receiver (and leaves the thread's GC mode wrong) after return.
        if (selected is "all" or "self-first") SelfFirst();
        if (selected is "all" or "self-scalar") SelfScalar();
        if (selected is "all" or "self") Self();
        Console.WriteLine($"COMPLETE failures={Failures}");
        Console.Out.Flush();
    }

    // Forward SwiftError declared before ordinary arguments.
    static void ForwardError()
    {
        Five result = default;
        CaptureControl(&result, 11, 22, 33);
        Check("forward-error.cdecl", Equal(result, 11, 22, 33, 44, 55), $"actual={result} expected=11,22,33,44,55");

        SwiftError error = default;
        result = default;
        CaptureErrorLast(new SwiftIndirectResult(&result), 11, 22, 33, &error);
        Check("forward-error.last.error", error.Value == null, $"error=0x{(nuint)error.Value:x}");
        Check("forward-error.last", Equal(result, 11, 22, 33, 44, 55), $"actual={result} expected=11,22,33,44,55");

        error = default;
        result = default;
        CaptureErrorFirst(new SwiftIndirectResult(&result), &error, 11, 22, 33);
        Check("forward-error.first.error", error.Value == null, $"error=0x{(nuint)error.Value:x}");
        Check("forward-error.first", Equal(result, 11, 22, 33, 44, 55), $"actual={result} expected=11,22,33,44,55");
    }

    // Reverse SwiftError declared after ordinary arguments.
    static void ReverseError()
    {
        observedValue = 0; observedError = 0;
        long result = InvokeCallback((delegate* unmanaged[Swift]<SwiftError*, long, long>)&CallbackErrorFirst, 12345);
        Check("reverse-error.first", observedValue == 12345 && result == 99,
            $"value={observedValue} expected=12345 error=0x{observedError:x} returned={result} expectedReturn=99");

        observedValue = 0; observedError = 0;
        result = InvokeCallback((delegate* unmanaged[Swift]<long, SwiftError*, long>)&CallbackErrorLast, 12345);
        Check("reverse-error.last", observedValue == 12345 && result == 99,
            $"value={observedValue} expected=12345 error=0x{observedError:x} returned={result} expectedReturn=99");
    }

    // Reverse SwiftSelf declared before ordinary arguments. The context is an opaque
    // marker value; neither side dereferences it.
    static void ReverseSelf()
    {
        void* context = (void*)0x5E1F_C0DE_0000;
        observedValue = 0; observedSelf = 0;
        long result = InvokeSelfCallback((delegate* unmanaged[Swift]<long, SwiftSelf, long>)&CallbackSelfLast, context, 12345);
        Check("reverse-self.last", observedValue == 12345 && observedSelf == (nuint)context && result == 99,
            $"value={observedValue} expected=12345 self=0x{observedSelf:x} expectedSelf=0x{(nuint)context:x} returned={result}");

        observedValue = 0; observedSelf = 0;
        result = InvokeSelfCallback((delegate* unmanaged[Swift]<SwiftSelf, long, long>)&CallbackSelfFirst, context, 12345);
        Check("reverse-self.first", observedValue == 12345 && observedSelf == (nuint)context && result == 99,
            $"value={observedValue} expected=12345 self=0x{observedSelf:x} expectedSelf=0x{(nuint)context:x} returned={result}");
    }

    // Forward SwiftSelf declared before ordinary arguments.
    static void SelfFirst()
    {
        Five receiver = Initial;
        Five result = default;
        CombineSelfFirst(new SwiftIndirectResult(&result), new SwiftSelf(&receiver), 10, 20);
        Check("self-first.result", Equal(result, 11, 22, 33, 14, 25), $"actual={result} expected=11,22,33,14,25");
    }

    // SwiftSelf receiver overwritten, with a scalar return and no indirect result.
    static void SelfScalar()
    {
        Five receiver = Initial;
        long total = Total(new SwiftSelf(&receiver));
        Check("self-scalar.result", total == 15, $"actual={total} expected=15");
        Check("self-scalar.receiver", Equal(receiver, 1, 2, 3, 4, 5), $"actual={receiver} expected=1,2,3,4,5 (non-mutating method)");
    }

    // SwiftSelf receiver overwritten after the call returns.
    static void Self()
    {
        Five receiver = Initial;
        Five result = default;
        CombineControl(&result, &receiver, 10, 20);
        Check("self.cdecl", Equal(receiver, 11, 22, 33, 14, 25) && Equal(result, 11, 22, 33, 14, 25),
            $"receiver={receiver} result={result} expected=11,22,33,14,25");

        receiver = Initial;
        result = default;
        Combine(new SwiftIndirectResult(&result), 10, 20, new SwiftSelf(&receiver));
        Check("self.stack.result", Equal(result, 11, 22, 33, 14, 25), $"actual={result}");
        Check("self.stack.receiver", Equal(receiver, 11, 22, 33, 14, 25), $"actual={receiver} expected=11,22,33,14,25");

        Five* heapReceiver = (Five*)NativeMemory.Alloc((nuint)sizeof(Five));
        Five* heapResult = (Five*)NativeMemory.Alloc((nuint)sizeof(Five));
        try
        {
            *heapReceiver = Initial;
            *heapResult = default;
            Combine(new SwiftIndirectResult(heapResult), 10, 20, new SwiftSelf(heapReceiver));
            Check("self.heap.result", Equal(*heapResult, 11, 22, 33, 14, 25), $"actual={*heapResult}");
            Check("self.heap.receiver", Equal(*heapReceiver, 11, 22, 33, 14, 25), $"actual={*heapReceiver} expected=11,22,33,14,25");
        }
        finally { NativeMemory.Free(heapReceiver); NativeMemory.Free(heapResult); }
    }
}
