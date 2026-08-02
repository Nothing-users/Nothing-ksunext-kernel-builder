English | [Русский](docs/README_RU.md)

---

# Nothing Kernel Builder

> [!WARNING]
> Nothing Phone (3a) and (3a) Pro builds currently do not work: the published NothingOSS source uses the older 6.1.134 kernel, while devices run 6.1.157. This project is experimental; use it at your own risk and keep a backup of your original boot image.

An automated GitHub Actions builder for Nothing kernels with KernelSU Next, SUSFS and custom patch.

## Supported devices

- Nothing Phone (3a) & (3a) Pro (`asteroids`, A059/A059P)
- Nothing Phone (4a) (`frogger`, A069)

## What's included

- [NothingOSS 6.1 kernel source](https://github.com/NothingOSS/android_kernel_msm-6.1_nothing_sm7635)
- [KernelSU Next](https://github.com/KernelSU-Next/KernelSU-Next) (`dev` or `stable`)
- [SUSFS v2.2.0](https://gitlab.com/simonpunk/susfs4ksu/-/tree/gki-android14-6.1)
- [Android Clang `clang-r487747c`](https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+/refs/heads/main-kernel-build-2023/clang-r487747c/)
- [Flashable AnyKernel3 packages](https://github.com/weekanya/AnyKernel3)
- [Baseband Guard](https://github.com/vc-teahouse/Baseband-guard), [BBRv3](https://github.com/WildKernels/kernel_patches/tree/24865a0bc50dfb65b04153cc9ad2879a9c26cc7e/common/bbrv3), FQ, CAKE, TTL Target, MGLRU, ZSTD

## Patches

- Official SUSFS integration patches for KernelSU
- Separate KernelSU Next compatibility fixes for `dev` and `stable`
- Hook mode and KSU toolkit compatibility patches
- BBRv3 backport for Nothing kernel
- Small compatibility fixes for Nothing's modified 6.1 kernel

## Output

- `<device>-anykernel3` — the flashable `Nothing-<device>-KSUNext-SUSFS-<kernel>-<optimization>.zip`
- `<device>-build-files` — `Image`, config, `System.map`, logs and metadata
- `<target>-developer-diagnostics` — `.rej`, `.orig`, patch logs and diffs when developer mode is on
