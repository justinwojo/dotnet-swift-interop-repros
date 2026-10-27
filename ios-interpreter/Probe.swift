// Copyright (c) 2026 Justin Wojciechowski.
// Licensed under the MIT License.

@frozen public struct Five {
    public var a, b, c, d, e: Int64
    @inline(never) public mutating func combine(_ x: Int64, _ y: Int64) -> Five {
        a &+= x; b &+= y; c &+= x &+ y; d &+= x; e &+= y
        return self
    }
}

// The throws ABI uses swifterror even though this function never throws.
@inline(never) public func capture(_ a: Int64, _ b: Int64, _ c: Int64) throws -> Five {
    Five(a: a, b: b, c: c, d: 44, e: 55)
}

@_cdecl("probe_combine_control")
public func combineControl(_ result: UnsafeMutableRawPointer, _ receiver: UnsafeMutableRawPointer,
                           _ x: Int64, _ y: Int64) {
    let value = receiver.assumingMemoryBound(to: Five.self).pointee.combine(x, y)
    result.assumingMemoryBound(to: Five.self).pointee = value
}

@_cdecl("probe_capture_control")
public func captureControl(_ result: UnsafeMutableRawPointer, _ a: Int64, _ b: Int64, _ c: Int64) {
    result.assumingMemoryBound(to: Five.self).pointee = try! capture(a, b, c)
}

// A native Swift caller, entered through an ordinary C P/Invoke, isolates the
// reverse calling convention from any managed forward Swift call.
@_cdecl("probe_invoke_callback")
public func invokeCallback(_ address: UnsafeRawPointer, _ value: Int64) -> Int64 {
    let callback = unsafeBitCast(address, to: (@convention(thin) (Int64) throws -> Int64).self)
    return (try? callback(value)) ?? -1
}

extension Five {
    // Non-mutating, scalar return: the receiver is still passed by address in swiftself.
    @inline(never) public func total() -> Int64 { a &+ b &+ c &+ d &+ e }
}
