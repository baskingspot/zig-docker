variable "ZIG_VERSION" {}

variable "REGISTRY" {
  default = "ghcr.io/baskingspot/zig"
}

group "default" {
  targets = ["chainguard", "alpine"]
}

target "alpine" {
  context    = "."
  dockerfile = "Dockerfile"
  target     = "final"
  tags = [
    "${REGISTRY}:${ZIG_VERSION}-alpine"
  ]
  args = {
    BASE_IMAGE  = "alpine:3@sha256:be2656061b536c1883c4034790e21d0a09c5aaaf51968b89368a3c0371ea2c9a"
    ZIG_VERSION = "${ZIG_VERSION}"
  }
}

target "chainguard" {
  context    = "."
  dockerfile = "Dockerfile"
  target     = "final"
  tags = [
    "${REGISTRY}:${ZIG_VERSION}",
    "${REGISTRY}:${ZIG_VERSION}-chainguard"
  ]
  args = {
    BASE_IMAGE  = "cgr.dev/chainguard/static:latest@sha256:c12f0107f8afb0bbc1b0eff96ff8675e85a10c6083d039b777c51fef5c27420f"
    ZIG_VERSION = "${ZIG_VERSION}"
  }
}
