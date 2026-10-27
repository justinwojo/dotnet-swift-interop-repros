// Copyright (c) 2026 Justin Wojciechowski.
// Licensed under the MIT License.

// A throwing Swift function. Its ABI is swiftcc i64(i64, ptr swiftself (unused), ptr swifterror).
@inline(never) public func plainThrows(_ a: Int64) throws -> Int64 { a &+ 1 }
