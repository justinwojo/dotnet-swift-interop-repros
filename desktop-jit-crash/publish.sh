#!/bin/bash
# Publishes the probe ahead of time (ReadyToRun via crossgen2, and NativeAOT) for each
# target framework and records the outcome. Run ./build-native.sh first.
#
#   DOTNET    dotnet whose SDK publishes net11.0 (and net10.0 unless DOTNET10 is set)
#   DOTNET10  dotnet whose SDK publishes net10.0 (defaults to $DOTNET)
set -uo pipefail
cd "$(dirname "$0")"
DOTNET=${DOTNET:-dotnet}
DOTNET10=${DOTNET10:-$DOTNET}
mkdir -p artifacts

{
  for tfm in net10.0 net11.0; do
    host=$DOTNET; [ "$tfm" = net10.0 ] && host=$DOTNET10
    for mode in PublishReadyToRun PublishAot; do
      out=artifacts/publish-$tfm-$mode
      log=$out.log
      rm -rf bin obj "$out"
      "$host" publish -c Release -p:TargetFrameworks=$tfm -f $tfm -r osx-arm64 -p:$mode=true -o "$out" > "$log" 2>&1
      e=$?
      detail=$(grep -oE 'exited with code [0-9-]+|error NETSDK[0-9]+' "$log" | sort -u | tr '\n' ' ')
      printf '%-8s %-18s publish exit=%-3s %s\n' "$tfm" "$mode" "$e" "$detail"
      if [ $e -eq 0 ]; then
        for c in observed unobserved unobserved-error-first; do
          (cd "$out" && ./SwiftErrorJitCrash "$c" > /dev/null 2>&1); echo "    run $c exit=$?"
        done
      fi
    done
  done
} | tee artifacts/publish.txt
