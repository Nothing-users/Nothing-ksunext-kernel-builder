#!/usr/bin/env bash
set -Eeuo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
manifest_path="${1:-}"

if [[ -z "$manifest_path" ]]; then
  printf 'Usage: %s <manifest.json>\n' "$0" >&2
  exit 2
fi

if [[ "$manifest_path" != /* ]]; then
  manifest_path="$repo_root/$manifest_path"
fi

if [[ ! -f "$manifest_path" ]]; then
  printf 'Manifest not found: %s\n' "$manifest_path" >&2
  exit 2
fi

read_json() {
  jq -er "$1" "$manifest_path"
}

clone_branch() {
  local repository="$1"
  local branch="$2"
  local destination="$3"
  local depth="$4"

  if [[ "$depth" == 0 ]]; then
    git clone \
      --filter=blob:none \
      --single-branch \
      --branch "$branch" \
      "$repository" \
      "$destination"
  else
    git clone \
      --filter=blob:none \
      --single-branch \
      --branch "$branch" \
      --depth "$depth" \
      "$repository" \
      "$destination"
  fi
}

checkout_ref_shallow() {
  local repository="$1"
  local ref="$2"
  local destination="$3"

  git init "$destination"
  git -C "$destination" remote add origin "$repository"
  git -C "$destination" -c protocol.version=2 fetch \
    --depth=1 \
    --filter=blob:none \
    origin \
    "$ref"
  git -C "$destination" checkout --detach FETCH_HEAD
}

device="$(read_json '.device')"
device_name="$(read_json '.name')"
codename="$(read_json '.codename')"
model="$(read_json '.model')"
soc="$(read_json '.soc')"
android="$(read_json '.android')"
kernel_repository="$(read_json '.kernel.repository')"
kernel_branch="$(read_json '.kernel.branch')"
kernel_defconfig="$(read_json '.kernel.defconfig')"
kernel_image="$(read_json '.kernel.image')"
toolchain_repository="$(read_json '.toolchain.repository')"
toolchain_branch="$(read_json '.toolchain.branch')"
toolchain_version="$(read_json '.toolchain.version')"
ksu_repository="$(read_json '.kernelsu.repository')"
ksu_branch="$(read_json '.kernelsu.branch')"
ksu_commit="$(read_json '.kernelsu.commit')"
susfs_repository="$(read_json '.susfs.repository')"
susfs_commit="$(read_json '.susfs.commit')"
susfs_patch="$(read_json '.susfs.patch')"
kernel_ref="${KERNEL_REF_OVERRIDE:-$kernel_branch}"
build_root="${BUILD_ROOT:-$repo_root/.work/$device}"
kernel_dir="$build_root/kernel"
toolchain_dir="$build_root/toolchain"
susfs_dir="$build_root/susfs4ksu"
out_dir="$build_root/out"
artifact_dir="$repo_root/artifacts/$device"
config_fragment="$repo_root/config/ksunext-susfs.config"

jq -e '
  .schema == 1 and
  .soc == "sm7635" and
  .android == "android14-6.1" and
  (.kernel.repository | type == "string") and
  (.toolchain.version | type == "string") and
  (.kernelsu.commit | test("^[0-9a-f]{40}$")) and
  (.susfs.commit | test("^[0-9a-f]{40}$"))
' "$manifest_path" >/dev/null

rm -rf "$build_root"
rm -rf "$artifact_dir"
mkdir -p "$build_root" "$artifact_dir"

checkout_ref_shallow "$kernel_repository" "$kernel_ref" "$kernel_dir"
clone_branch "$toolchain_repository" "$toolchain_branch" "$toolchain_dir" 1
clone_branch "$ksu_repository" "$ksu_branch" "$kernel_dir/KernelSU-Next" 0
git -C "$kernel_dir/KernelSU-Next" checkout --detach "$ksu_commit"
checkout_ref_shallow "$susfs_repository" "$susfs_commit" "$susfs_dir"

if [[ ! -x "$toolchain_dir/$toolchain_version/bin/clang" ]]; then
  printf 'Toolchain not found: %s\n' "$toolchain_version" >&2
  exit 1
fi

ln -s ../KernelSU-Next/kernel "$kernel_dir/drivers/kernelsu"

if ! grep -q 'CONFIG_KSU.*kernelsu/' "$kernel_dir/drivers/Makefile"; then
  printf '\nobj-$(CONFIG_KSU) += kernelsu/\n' >> "$kernel_dir/drivers/Makefile"
fi

if ! grep -q 'drivers/kernelsu/Kconfig' "$kernel_dir/drivers/Kconfig"; then
  sed -i '/^endmenu/i source "drivers/kernelsu/Kconfig"' "$kernel_dir/drivers/Kconfig"
fi

sublevel="$(awk '/^SUBLEVEL =/{print $3; exit}' "$kernel_dir/Makefile")"

if (( sublevel <= 141 )) && ! grep -q '^#include <linux/dma-buf.h>$' "$kernel_dir/fs/proc/base.c"; then
  sed -i '/^#include <linux\/cpufreq_times.h>$/a #include <linux/dma-buf.h>' "$kernel_dir/fs/proc/base.c"
fi

if (( sublevel >= 157 )); then
  sed -i '/^#include <trace\/hooks\/blk.h>$/d' "$kernel_dir/fs/namespace.c"
fi

cp -a "$susfs_dir/kernel_patches/fs/." "$kernel_dir/fs/"
cp -a "$susfs_dir/kernel_patches/include/linux/." "$kernel_dir/include/linux/"
patch --directory="$kernel_dir" --batch --forward -p1 < "$susfs_dir/$susfs_patch"

if find "$kernel_dir" -type f -name '*.rej' -print -quit | grep -q .; then
  find "$kernel_dir" -type f -name '*.rej' -print >&2
  exit 1
fi

export PATH="$toolchain_dir/$toolchain_version/bin:$PATH"
export ARCH=arm64
export LLVM=1
export LLVM_IAS=1
export KBUILD_BUILD_USER=github-actions
export KBUILD_BUILD_HOST=github
export KBUILD_BUILD_TIMESTAMP
KBUILD_BUILD_TIMESTAMP="$(git -C "$kernel_dir" show -s --format=%cD HEAD)"
export SOURCE_DATE_EPOCH
SOURCE_DATE_EPOCH="$(git -C "$kernel_dir" show -s --format=%ct HEAD)"
export CCACHE_DIR="${CCACHE_DIR:-$build_root/ccache}"
export CCACHE_COMPILERCHECK=content
export CCACHE_NOHASHDIR=true

mkdir -p "$out_dir" "$CCACHE_DIR"
ccache --max-size=5G
ccache --zero-stats

make \
  -C "$kernel_dir" \
  O="$out_dir" \
  ARCH="$ARCH" \
  LLVM="$LLVM" \
  LLVM_IAS="$LLVM_IAS" \
  CC="ccache clang" \
  HOSTCC="ccache clang" \
  "$kernel_defconfig"

while IFS='=' read -r option value; do
  [[ -z "$option" ]] && continue
  symbol="${option#CONFIG_}"
  case "$value" in
    y)
      "$kernel_dir/scripts/config" --file "$out_dir/.config" -e "$symbol"
      ;;
    n)
      "$kernel_dir/scripts/config" --file "$out_dir/.config" -d "$symbol"
      ;;
    *)
      "$kernel_dir/scripts/config" --file "$out_dir/.config" --set-val "$symbol" "$value"
      ;;
  esac
done < "$config_fragment"

make \
  -C "$kernel_dir" \
  O="$out_dir" \
  ARCH="$ARCH" \
  LLVM="$LLVM" \
  LLVM_IAS="$LLVM_IAS" \
  CC="ccache clang" \
  HOSTCC="ccache clang" \
  olddefconfig

while IFS= read -r expected; do
  [[ -z "$expected" ]] && continue
  if ! grep -qxF "$expected" "$out_dir/.config"; then
    printf 'Required config was not enabled: %s\n' "$expected" >&2
    exit 1
  fi
done < "$config_fragment"

make \
  -C "$kernel_dir" \
  O="$out_dir" \
  ARCH="$ARCH" \
  LLVM="$LLVM" \
  LLVM_IAS="$LLVM_IAS" \
  CC="ccache clang" \
  HOSTCC="ccache clang" \
  -j"$(nproc)" \
  Image

if [[ ! -s "$out_dir/$kernel_image" ]]; then
  printf 'Kernel image was not produced: %s\n' "$out_dir/$kernel_image" >&2
  exit 1
fi

cp "$out_dir/$kernel_image" "$artifact_dir/Image"
cp "$out_dir/.config" "$artifact_dir/kernel.config"

if [[ -f "$out_dir/System.map" ]]; then
  cp "$out_dir/System.map" "$artifact_dir/System.map"
fi

kernel_commit="$(git -C "$kernel_dir" rev-parse HEAD)"
resolved_ksu_commit="$(git -C "$kernel_dir/KernelSU-Next" rev-parse HEAD)"
resolved_susfs_commit="$(git -C "$susfs_dir" rev-parse HEAD)"
clang_version="$("$toolchain_dir/$toolchain_version/bin/clang" --version | head -n 1)"
image_sha256="$(sha256sum "$artifact_dir/Image" | awk '{print $1}')"

jq -n \
  --arg device "$device" \
  --arg name "$device_name" \
  --arg codename "$codename" \
  --arg model "$model" \
  --arg soc "$soc" \
  --arg android "$android" \
  --arg kernel_repository "$kernel_repository" \
  --arg kernel_ref "$kernel_ref" \
  --arg kernel_commit "$kernel_commit" \
  --arg kernel_version "6.1.$sublevel" \
  --arg kernelsu_repository "$ksu_repository" \
  --arg kernelsu_commit "$resolved_ksu_commit" \
  --arg susfs_repository "$susfs_repository" \
  --arg susfs_commit "$resolved_susfs_commit" \
  --arg toolchain "$clang_version" \
  --arg image_sha256 "$image_sha256" \
  '{
    device: $device,
    name: $name,
    codename: $codename,
    model: $model,
    soc: $soc,
    android: $android,
    kernel: {
      repository: $kernel_repository,
      ref: $kernel_ref,
      commit: $kernel_commit,
      version: $kernel_version
    },
    kernelsu: {
      repository: $kernelsu_repository,
      commit: $kernelsu_commit
    },
    susfs: {
      repository: $susfs_repository,
      commit: $susfs_commit
    },
    toolchain: $toolchain,
    image_sha256: $image_sha256
  }' > "$artifact_dir/build.json"

ccache --show-stats
