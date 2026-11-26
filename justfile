# zig-docker: Docker images for the Zig compiler, verified against the Zig
# Software Foundation's signing key. README.md says what the images are.
# AGENTS.md holds the working conventions.

[private]
default:
    @just --list

[doc("Build ZIG_VERSION for the host architecture, load both base images into the local docker daemon, and check `zig version` inside each image")]
[group("test")]
test ZIG_VERSION="0.17.1":
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

[doc("Check that the Zig version list in build.yml, README.md, and the justfile agree")]
[group("lint")]
check-versions:
    #!/usr/bin/env bash
    set -euo pipefail
    matrix_line=$(yq -r '.jobs.build.strategy.matrix.zig_version[]' .github/workflows/build.yml)
    if [ -z "${matrix_line}" ]; then
        echo "check-versions: .github/workflows/build.yml: no jobs.build.strategy.matrix.zig_version found" >&2
        exit 1
    fi
    matrix=$(printf '%s\n' "${matrix_line}" | sort -u)
    readme=$(sed -n '/^## Images$/,/^## /p' README.md | awk '{while (match($0, /[0-9]+\.[0-9]+\.[0-9]+/)) {print substr($0, RSTART, RLENGTH); $0=substr($0, RSTART+RLENGTH)}}' | sort -u)
    if [ -z "${readme}" ]; then
        echo "check-versions: README.md: no Zig versions found in the Images section" >&2
        exit 1
    fi
    status=0
    for version in ${matrix}; do
        if ! grep -qxF "${version}" <<<"${readme}"; then
            echo "check-versions: README.md: Zig ${version} is built by .github/workflows/build.yml but missing from the Images section" >&2
            status=1
        fi
    done
    for version in ${readme}; do
        if ! grep -qxF "${version}" <<<"${matrix}"; then
            echo "check-versions: README.md: Zig ${version} is in the Images section but .github/workflows/build.yml does not build it" >&2
            status=1
        fi
    done
    newest=$(printf '%s\n' "${matrix}" | sort -t. -k1,1n -k2,2n -k3,3n | tail -n 1)
    default=$(sed -n 's/^test ZIG_VERSION="\([^"]*\)".*/\1/p' justfile)
    if [ -z "${default}" ]; then
        echo "check-versions: justfile: no test ZIG_VERSION default found" >&2
        status=1
    elif [ "${default}" != "${newest}" ]; then
        echo "check-versions: justfile: test default is ${default}, but the newest in .github/workflows/build.yml is ${newest}" >&2
        status=1
    fi
    if [ "${status}" -eq 0 ]; then
        echo "check-versions: build.yml, README.md, and the justfile agree; newest is ${newest}"
    fi
    exit "${status}"

[doc("Lint the Dockerfile, the bake file, Nix, Markdown, the workflows, and the justfile")]
[group("lint")]
lint:
    just check-versions
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
