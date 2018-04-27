#!/usr/bin/env bash
set -e
CURL="curl -sSf"
FLANNEL_CNI_ROOT=$(git rev-parse --show-toplevel)
IMAGE_NAME=quay.io/coreos/flannel-cni
VERSION=$($FLANNEL_CNI_ROOT/scripts/git-version)
CNI_VERSION="v0.6.0"
ARCH=amd64

case "$(uname -m)" in
  x86_64*)
    ARCH=amd64
    ;;
  i?86_64*)
    ARCH=amd64
    ;;
  amd64*)
    ARCH=amd64
    ;;
  aarch64*)
    ARCH=arm64
    ;;
  arm64*)
    ARCH=arm64
    ;;
  arm*)
    ARCH=arm
    ;;
  s390x*)
    ARCH=s390x
    ;;
  ppc64le*)
    ARCH=ppc64le
    ;;
  *)
    echo "Unsupported host arch. Must be x86_64, arm, arm64, s390x or ppc64le." >&2
    exit 1
    ;;
esac

mkdir -p dist
$CURL -L --retry 5 https://github.com/containernetworking/cni/releases/download/$CNI_VERSION/cni-$ARCH-$CNI_VERSION.tgz | tar -xz -C dist/
$CURL -L --retry 5 https://github.com/containernetworking/plugins/releases/download/$CNI_VERSION/cni-plugins-$ARCH-$CNI_VERSION.tgz | tar -xz -C dist/

docker build --no-cache -t $IMAGE_NAME:$VERSION-$ARCH .
docker push $IMAGE_NAME:$VERSION-$ARCH
