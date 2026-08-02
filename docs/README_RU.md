[English](../README.md) | Русский

---

# Nothing Stock Kernel Builder

> [!WARNING]
> Сборки для Nothing Phone (3a) и (3a) Pro сейчас не работают: опубликованные исходники NothingOSS используют старое ядро 6.1.134, а на устройствах установлено 6.1.157. Перед прошивкой сохраните оригинальный образ boot.

GitHub Actions билдер неизменённого ядра NothingOSS 6.1. В этой ветке нет KernelSU, SUSFS, Baseband Guard, BBRv3 и других пользовательских патчей.

## Поддерживаемые устройства

- Nothing Phone (3a) & (3a) Pro (`asteroids`, A059/A059P)
- Nothing Phone (4a) (`frogger`, A069)

## Исходники сборки

- [Ядро NothingOSS 6.1](https://github.com/NothingOSS/android_kernel_msm-6.1_nothing_sm7635)
- [Android Clang `clang-r487747c`](https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+/refs/heads/main-kernel-build-2023/clang-r487747c/)
- [AnyKernel3](https://github.com/weekanya/AnyKernel3)

## Результаты

- `<device>-stock-anykernel3` — прошиваемый ZIP со стоковым ядром
- `<device>-stock-build-files` — `Image`, конфигурация, `System.map`, логи и метаданные
- `<codename>-stock-developer-diagnostics` — диагностика ошибки при включённом developer mode
