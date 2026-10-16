# zig-docker: Docker images for the Zig compiler, verified against the Zig
# Software Foundation's signing key. README.md says what the images are.
# AGENTS.md holds the working conventions.

[private]
default:
    @just --list

[doc("Build ZIG_VERSION for the host architecture, load both base images into the local docker daemon, and check `zig version` inside each image")]
[group("test")]
test ZIG_VERSION="0.17.0":
    #!/usr/bin/env bash
    set -euo pipefail
    case "$(uname -m)" in
        x86_64|amd64) platform=linux/amd64 ;;
        aarch64|arm64) platform=linux/arm64 ;;
        *) echo "unsupported host architecture: $(uname -m)" >&2; exit 1 ;;
    esac
    ZIG_VERSION="{{ ZIG_VERSION }}" docker buildx bake --set "*.platform=${platform}" --load
    for image in \
        "ghcr.io/baskingspot/zig:{{ ZIG_VERSION }}" \
        "ghcr.io/baskingspot/zig:{{ ZIG_VERSION }}-chainguard" \
        "ghcr.io/baskingspot/zig:{{ ZIG_VERSION }}-alpine"
    do
        got=$(docker run --rm "${image}" zig version)
        if [ "${got}" != "{{ ZIG_VERSION }}" ]; then
            echo "${image}: expected {{ ZIG_VERSION }}, got ${got}" >&2
            exit 1
        fi
        echo "${image}: ${got}"
    done

[doc("Lint the Dockerfile, the bake file, Nix, Markdown, the workflows, and the justfile")]
[group("lint")]
lint:
    hadolint Dockerfile
    docker buildx bake --print >/dev/null
    nix fmt -- --ci
    oxfmt --check README.md AGENTS.md .github
    actionlint
    zizmor .
    just --fmt --check

[doc("Format everything lint checks")]
[group("lint")]
fmt:
    nix fmt
    oxfmt README.md AGENTS.md .github
    just --fmt

[doc("Everything CI runs: the image check and lint")]
[group("ci")]
ci: test lint
