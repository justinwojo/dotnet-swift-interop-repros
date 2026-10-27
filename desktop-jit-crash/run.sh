#!/bin/bash
# Builds the Swift dylib and the managed probe, then runs every case under default
# tiering and with DOTNET_TieredCompilation=0. Exit 139 is SIGSEGV in the JIT.
#
#   DOTNET    dotnet used to build (needs an SDK that knows net11.0) and to run net11.0
#   DOTNET10  dotnet used to run net10.0 (defaults to $DOTNET)
set -uo pipefail
cd "$(dirname "$0")"
DOTNET=${DOTNET:-dotnet}
DOTNET10=${DOTNET10:-$DOTNET}

./build-native.sh > /dev/null || exit 1
"$DOTNET" build -c Release > artifacts/build.log 2>&1 || { tail -20 artifacts/build.log; exit 1; }

{
  for tfm in net10.0 net11.0; do
    host=$DOTNET; [ "$tfm" = net10.0 ] && host=$DOTNET10
    dll=bin/Release/$tfm/SwiftErrorJitCrash.dll
    for c in observed unobserved unobserved-error-first unobserved-hot; do
      for tc in default 0; do
        if [ "$tc" = default ]; then
          out=$("$host" "$dll" "$c" 2>&1); e=$?
        else
          out=$(DOTNET_TieredCompilation=0 "$host" "$dll" "$c" 2>&1); e=$?
        fi
        runtime=$(printf '%s\n' "$out" | sed -n 's/^runtime=\([^ ]* [^ ]*\).*/\1/p' | head -1)
        printf '%-8s %-24s TieredCompilation=%-8s exit=%-4s %s\n' "$tfm" "$c" "$tc" "$e" "$runtime"
      done
    done
  done
} | tee artifacts/matrix.txt
