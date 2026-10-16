<h1>
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/static/logo-dark.svg">
    <img src="docs/static/logo.svg" alt="zig-docker" height="48">
  </picture>
</h1>

Docker images for the Zig compiler, verified against the Zig Software Foundation's signing key.

Unofficial images, published to `ghcr.io/baskingspot/zig` for `linux/amd64` and `linux/arm64`. The build runs weekly and on changes to `Dockerfile`, `docker-bake.hcl`, or `build.yml`.

## Images

- `ghcr.io/baskingspot/zig:0.17.0` and `ghcr.io/baskingspot/zig:0.17.0-chainguard`: built on `cgr.dev/chainguard/static:latest`.
- `ghcr.io/baskingspot/zig:0.17.0-alpine`: built on `alpine:3`.

Zig `0.15.2` and `0.16.0` are published with the same tag suffixes.

## Usage

```dockerfile
FROM ghcr.io/baskingspot/zig:0.17.0 AS builder
WORKDIR /app
COPY . .
RUN zig build -Doptimize=ReleaseFast

FROM debian:bookworm-slim
COPY --from=builder /app/zig-out/bin/myapp /usr/local/bin/myapp
ENTRYPOINT ["myapp"]
```

## Security

The `downloader` stage fetches Zig from the [community mirrors](https://ziglang.org/download/community-mirrors/) and falls back to ziglang.org. The tarball is verified with minisign against the Zig Software Foundation's public key before it is copied into the image.

## Work on it

```sh
just ci
```

`nix develop` provides the toolchain. `just test` builds the images for the host architecture, loads them into the local docker daemon, and runs `zig version` inside each one. `just` lists the recipes.

## License

MIT. See `LICENSE`. The logo files in `docs/static/` are baskingspot marks and are not covered by it. See `docs/static/LICENSE`.

## How it's made

Built with LLM assistance. [How, in detail](https://github.com/baskingspot/.github/blob/main/docs/AI.md).

<a href="https://github.com/baskingspot"><img src="https://raw.githubusercontent.com/baskingspot/.github/main/brand/assets/badge.svg" alt="baskingspot" height="24"></a>
