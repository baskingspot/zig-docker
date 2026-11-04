ARG BASE_IMAGE

# Shared stage: download Zig from the org's mirror, which picks a random
# community mirror and caches the answer at the edge.
FROM alpine:3@sha256:be2656061b536c1883c4034790e21d0a09c5aaaf51968b89368a3c0371ea2c9a AS downloader

ARG ZIG_VERSION

RUN apk add --no-cache curl minisign xz

# The Zig Software Foundation's minisign public key, from ziglang.org/download.
ENV ZIG_PUBKEY=RWSGOq2NVecA2UPNdBUZykf1CCb147pkmdtYxgb3Ti+JO/wCYvhbAb/U

RUN set -eux; \
    case "$(uname -m)" in \
        x86_64) ZIG_ARCH=x86_64 ;; \
        aarch64) ZIG_ARCH=aarch64 ;; \
        armv7l) ZIG_ARCH=arm ;; \
        *) echo "unsupported machine: $(uname -m)" >&2; exit 1 ;; \
    esac; \
    ZIG_TARBALL="zig-${ZIG_ARCH}-linux-${ZIG_VERSION}.tar.xz"; \
    ZIG_URL="https://zig.baskingspot.dev/${ZIG_TARBALL}"; \
    \
    curl -fSL "${ZIG_URL}" -o "/tmp/${ZIG_TARBALL}"; \
    curl -fSL "${ZIG_URL}.minisig" -o "/tmp/${ZIG_TARBALL}.minisig"; \
    \
    # The trusted comment names the tarball, so a mirror cannot swap in a build. \
    VERIFIED="$(minisign -V -P "${ZIG_PUBKEY}" -x "/tmp/${ZIG_TARBALL}.minisig" -m "/tmp/${ZIG_TARBALL}" 2>&1)"; \
    echo "${VERIFIED}"; \
    echo "${VERIFIED}" | grep -Fq "file:${ZIG_TARBALL}"; \
    \
    mkdir -p /usr/local/zig; \
    tar -xJf "/tmp/${ZIG_TARBALL}" -C /usr/local/zig --strip-components=1; \
    /usr/local/zig/zig version; \
    rm -rf /tmp/*

# Final stage - parameterized by base image
FROM ${BASE_IMAGE} AS final

LABEL org.opencontainers.image.source="https://github.com/baskingspot/zig-docker"
COPY --from=downloader /usr/local/zig /usr/local/zig
ENV PATH="/usr/local/zig:${PATH}"
CMD ["zig", "version"]
