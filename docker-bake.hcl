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
    BASE_IMAGE  = "cgr.dev/chainguard/static:latest@sha256:fc42af33e643f20d08baf03cddcc1c02ba57052dfb02edb0d79f3fc47bcea8d9"
    ZIG_VERSION = "${ZIG_VERSION}"
  }
}
