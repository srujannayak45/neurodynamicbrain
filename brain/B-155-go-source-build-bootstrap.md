---
id: B-155
tags: [infra, gotcha, config]
scope: building the Go toolchain from source (darwin/arm64)
hook: Building Go from source needs GOROOT_BOOTSTRAP pointing at an existing Go — the default ~/go1.4 does not exist
---

# Building the Go toolchain from source

To build the Go toolchain from a checkout of the Go source tree:

```sh
cd <goroot-src>/src && GOROOT_BOOTSTRAP=/usr/local/go ./make.bash
```

**Why the GOROOT_BOOTSTRAP is required:** `make.bash` needs an existing Go (recent enough to satisfy
the bootstrap floor) to compile the new one, and defaults its bootstrap path to `~/go1.4/bin/go`,
which does NOT exist on a modern machine. Unset → `ERROR: Cannot find .../go1.4/bin/go`. Point it at
the system Go install (e.g. `/usr/local/go`) which satisfies the version floor.

**How to apply:**
- Built toolchain installs to `<goroot>/bin`; host target auto-resolves (all defaults; GOROOT/GOOS/
  GOARCH need nothing set).
- Put `<goroot>/bin` ahead of the system Go on PATH so the dev build wins. Verify with `go version`.
- To cross-compile, use per-build `GOOS`/`GOARCH` (e.g. `GOOS=linux GOARCH=amd64 go build`); no rebuild.
- `GOARM64` (default `v8.0`) is the only env worth overriding on Apple Silicon if a newer baseline is wanted.
