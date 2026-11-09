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
    BASE_IMAGE  = "alpine:3@sha256:f59abe656b692d901e184be3445e084786602108599d2a51d229c0f5a48c71bf"
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
