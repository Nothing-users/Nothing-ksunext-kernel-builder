English | [Русский](docs/README_RU.md)

---

# Nothing Stock Kernel Builder

> [!WARNING]
> Builds are not tested on physical devices yet. Keep a backup of the original boot image before flashing.

GitHub Actions builder for unmodified NothingOSS 6.1 kernels. This branch does not include KernelSU, SUSFS, Baseband Guard, BBRv3 or other custom patches.

## Supported devices

- Nothing Phone (3a) & (3a) Pro (`asteroids`, A059/A059P)
- Nothing Phone (4a) (`frogger`, A069)

## Build sources

- [NothingOSS 6.1 kernel source](https://github.com/NothingOSS/android_kernel_msm-6.1_nothing_sm7635)
- [Android Clang `clang-r487747c`](https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+/refs/heads/main-kernel-build-2023/clang-r487747c/)
- [AnyKernel3](https://github.com/weekanya/AnyKernel3)

## Output

- `<device>-stock-anykernel3` — flashable stock kernel ZIP
- `<device>-stock-build-files` — `Image`, config, `System.map`, logs and metadata
- `<codename>-stock-developer-diagnostics` — failure diagnostics when developer mode is enabled
