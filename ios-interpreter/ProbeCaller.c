// Copyright (c) 2026 Justin Wojciechowski.
// Licensed under the MIT License.
//
// Native Swift-convention caller for reverse SwiftSelf tests. Clang's
// swiftcall/swift_context attributes give an exact Swift ABI call (context in
// x20) without needing a Swift closure. It is entered through an ordinary C
// P/Invoke, so no forward managed Swift call is involved.
//
// `context` comes before `value` on purpose. On entry here x1 = context and
// x2 = value; the call moves value to x0 and context to x20, leaving x1 = context.
// A callee that wrongly reads its first ordinary argument from x1 therefore sees
// the context marker, not a leftover copy of `value`.

#include <stdint.h>

typedef int64_t (*SelfCallback)(int64_t value, void *__attribute__((swift_context)) context)
    __attribute__((swiftcall));

int64_t probe_invoke_self_callback(void *callback, void *context, int64_t value)
{
    return ((SelfCallback)callback)(value, context);
}
