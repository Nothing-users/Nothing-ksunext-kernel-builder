# Nothing Kernel Builder

Nothing kernels built with KernelSU Next, SUSFS and a ready-to-flash AnyKernel3 ZIP via GitHub Actions.

## Devices

| Device | Codename | Model | NothingOSS branch |
|---|---|---|---|
| Nothing Phone (3a) | `asteroids` | A059 | `sm7635/b/mr` |
| Nothing Phone (3a) Pro | `asteroids` | A059P | `sm7635/b/mr` |
| Nothing Phone (4a) | `frogger` | A069 | `sm7635/b/mr_Frogger` |

The 3a and 3a Pro share the same kernel and are described by a single manifest, compiled once and packaged as one ZIP for the series.

## What is used

- [NothingOSS kernel 6.1](https://github.com/NothingOSS/android_kernel_msm-6.1_nothing_sm7635)
- [KernelSU Next](https://github.com/KernelSU-Next/KernelSU-Next) — `dev`, `stable` or a custom ref
- [SUSFS](https://gitlab.com/simonpunk/susfs4ksu), branch `gki-android14-6.1`
- Android Clang `clang-r487747c`
- [Nothing AnyKernel3](https://github.com/weekanya/AnyKernel3)

AK3 and compatibility patch versions are pinned by commit SHA. The NothingOSS, KSUN and SUSFS refs can be overridden at manual dispatch.

## Running a build

Open `Actions → Nothing Kernel Builder → Run workflow`.

`ccache` is stored per codename (`asteroids`, `frogger`). The first build warms the cache; subsequent builds reuse it while Clang and sources match.

| Input | Default | Purpose |
|---|---|---|
| `device` | `all` | 3a series, Phone 4a or all devices |
| `kernel_ref` | manifest default | NothingOSS branch, tag or commit |
| `ksun_ref` | `dev` | `dev`, `stable` or `custom` |
| `ksun_custom_ref` | empty | KSUN branch, tag or commit for `custom` mode |
| `ksun_patchset` | `dev` | Compatibility patch set (`dev` or `stable`) for custom refs |
| `susfs_ref` | auto | SUSFS branch, tag or commit |
| `optimize_level` | `O2` | Compiler optimization: `O1`, `O2` or `O3` |
| `extra_patches` | enabled | Apply the optional BBRv3 backport; KSUN, SUSFS and Nothing kernel fixups are always applied |
| `create_release` | enabled | Publish a GitHub Release or developer prerelease |
| `developer_mode` | disabled | Keep patch logs, diffs, `.rej` and `.orig` files |

Build identity is fixed by the composite action: `wee@mrvoki`.

## Patches

1. `10_enable_susfs_for_ksu.patch` is applied to the upstream KSUN tree.
2. Conflicts against `dev` and `stable` are resolved by pinned [WildKernels fixes](https://github.com/WildKernels/kernel_patches) for SUSFS v2.2.0, including hook-mode and toolkit.
3. For Nothing 6.1.134 the missing `linux/dma-buf.h` include is added.
4. For Nothing 6.1.157 the incompatible `trace/hooks/blk.h` include is removed if present.
5. `50_add_susfs_in_gki-android14-6.1.patch` is applied to the kernel tree.
6. Optional: BBRv3 backport for android14-6.1 (sysctl helpers + main patch), enabled when `extra_patches` is on.

Any unknown or unresolved `.rej` stops the build. In `developer_mode` diagnostic files are uploaded even when the job fails.

## Output

- `<device>-anykernel3` — the flashable `Nothing-<device>-KSUNext-SUSFS-<kernel>-<optimization>.zip`
- `<device>-build-files` — `Image`, config, `System.map`, logs and metadata
- `<target>-developer-diagnostics` — `.rej`, `.orig`, patch logs and diffs when developer mode is on

AK3 checks the codename, detects the active A/B slot and replaces only the kernel in `boot`, keeping the stock ramdisk.

## Notes

The bootloader must be unlocked. Back up the original `boot.img` before flashing.

Do not flash the raw `Image` with `fastboot flash boot Image`. The patch chain and ZIP layout are verified, but no boot test has been done on a physical device yet, so releases should be considered experimental until then.
