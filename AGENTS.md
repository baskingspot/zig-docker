# AGENTS.md

Working notes for AI coding agents in zig-docker.

## What this is

Docker images for the Zig compiler. `Dockerfile` downloads Zig from `zig.baskingspot.dev`, the org's mirror, and verifies the tarball with minisign against the Zig Software Foundation's public key. `docker-bake.hcl` defines two targets, `chainguard` and `alpine`, over that one Dockerfile. `.github/workflows/build.yml` builds both for `linux/amd64` and `linux/arm64` and publishes them to `ghcr.io/baskingspot/zig`.

## Environment

The flake is the tool contract. `nix develop` provides docker, hadolint, actionlint, zizmor, oxfmt, yq, and the base tools. The justfile is the command interface:

```
just test
just lint
just ci
```

`just test` builds the newest Zig version for the host architecture, loads both base images into the local docker daemon, and checks `zig version` inside each image. It never pushes. `just ci` runs what CI runs. A docker daemon must be running.

## Conventions

- Images are published only by `build.yml` in CI. Do not `docker push`, and do not run the publishing workflow by hand.
- The Zig version list lives in the `build.yml` matrix, the README's images and usage, and the justfile's `test` default. Edit all three. `just check-versions` fails when the matrix and the README Images section disagree, or when the `test` default is not the newest matrix entry; it runs in `just lint`.
- The tag scheme lives in `docker-bake.hcl`: `${REGISTRY}:${ZIG_VERSION}` plus the `-chainguard` and `-alpine` suffixes. `REGISTRY` changes only when the registry moves.
- Commits are one line, `area: summary`, and signed.
