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
    BASE_IMAGE  = "alpine:3@sha256:294b683cb724975bec92580e1e685676bd4b50bda910ddb8c51d4cabeaec77e6"
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
    BASE_IMAGE  = "cgr.dev/chainguard/static:latest@sha256:fe55470f22d3259488d9d3739168d8f04da67755f0b69382bc26eda4a7d3d327"
    ZIG_VERSION = "${ZIG_VERSION}"
  }
}
