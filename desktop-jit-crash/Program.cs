// Copyright (c) 2026 Justin Wojciechowski.
// Licensed under the MIT License.
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;
using System.Runtime.InteropServices.Swift;

static unsafe class Program
{
    const string Lib = "libSwiftErrorProbe.dylib";
    const string PlainThrows = "$s15SwiftErrorProbe11plainThrowsys5Int64VADKF";

    // Swift: func plainThrows(_ a: Int64) throws -> Int64
    [DllImport(Lib, EntryPoint = PlainThrows)]
    [UnmanagedCallConv(CallConvs = [typeof(CallConvSwift)])]
    static extern long CallErrorLast(long a, SwiftError* error);

    [DllImport(Lib, EntryPoint = PlainThrows)]
    [UnmanagedCallConv(CallConvs = [typeof(CallConvSwift)])]
    static extern long CallErrorFirst(SwiftError* error, long a);

    // Crashes the optimizing JIT: the SwiftError local is never read after the call.
    [MethodImpl(MethodImplOptions.NoInlining)]
    static long Unobserved()
    {
        SwiftError error = default;
        return CallErrorLast(41, &error);
    }

    [MethodImpl(MethodImplOptions.NoInlining)]
    static long UnobservedErrorFirst()
    {
        SwiftError error = default;
        return CallErrorFirst(&error, 41);
    }

    // Control: identical call, but the error is read afterwards. Compiles and runs.
    [MethodImpl(MethodImplOptions.NoInlining)]
    static long Observed()
    {
        SwiftError error = default;
        long value = CallErrorLast(41, &error);
        return error.Value == null ? value : -1;
    }

    // Default runtime settings: Tier0 code works, and the crash happens once the
    // method is hot enough to be recompiled at Tier1.
    static long Hot()
    {
        long value = 0;
        for (int i = 0; i < 200; i++)
        {
            for (int j = 0; j < 100; j++) value = Unobserved();
            Thread.Sleep(10);
        }
        return value;
    }

    static int Main(string[] args)
    {
        string which = args.Length > 0 ? args[0] : "unobserved";
        Console.WriteLine($"runtime={RuntimeInformation.FrameworkDescription} arch={RuntimeInformation.ProcessArchitecture} case={which}");
        Console.Out.Flush();
        long value = which switch
        {
            "unobserved" => Unobserved(),
            "unobserved-error-first" => UnobservedErrorFirst(),
            "observed" => Observed(),
            "unobserved-hot" => Hot(),
            _ => throw new ArgumentException($"unknown case '{which}'"),
        };
        Console.WriteLine($"result={value} expected=42");
        return value == 42 ? 0 : 1;
    }
}
