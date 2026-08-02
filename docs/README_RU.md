[English](../README.md) | Русский

---

# Nothing Kernel Builder

> [!WARNING]
> Сборки для Nothing Phone (3a) и (3a) Pro сейчас не работают: опубликованные исходники NothingOSS используют старое ядро 6.1.134, а на устройствах установлено 6.1.157. Проект экспериментальный — используйте его на свой страх и риск и сохраните оригинальный boot.img.

Автоматизированная сборка ядер Nothing с KernelSU Next, SUSFS и пользовательским патчем с помощью GitHub Actions.

## Поддерживаемые устройства

- Nothing Phone (3a) & (3a) Pro (`asteroids`, A059/A059P)
- Nothing Phone (4a) (`frogger`, A069)

## Что входит в сборку

- [Исходный код ядра NothingOSS 6.1](https://github.com/NothingOSS/android_kernel_msm-6.1_nothing_sm7635)
- [KernelSU Next](https://github.com/KernelSU-Next/KernelSU-Next) (`dev` или `stable`)
- [SUSFS v2.2.0](https://gitlab.com/simonpunk/susfs4ksu/-/tree/gki-android14-6.1)
- [Android Clang `clang-r487747c`](https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+/refs/heads/main-kernel-build-2023/clang-r487747c/)
- [Прошиваемые пакеты AnyKernel3](https://github.com/weekanya/AnyKernel3)
- [Baseband Guard](https://github.com/vc-teahouse/Baseband-guard), [BBRv3](https://github.com/WildKernels/kernel_patches/tree/24865a0bc50dfb65b04153cc9ad2879a9c26cc7e/common/bbrv3), FQ, CAKE, TTL Target, MGLRU, ZSTD

## Патчи

- Официальные патчи интеграции SUSFS для KernelSU
- Отдельные исправления совместимости KernelSU Next для `dev` и `stable`
- Патчи совместимости с режимом хуков и инструментарием KSU
- Бэкпорт BBRv3 для ядра Nothing
- Небольшие исправления совместимости для ядра Nothing версии 6.1

## Результаты сборки

- `<device>-anykernel3` — прошиваемый архив `Nothing-<device>-KSUNext-SUSFS-<kernel>-<optimization>.zip`
- `<device>-build-files` — `Image`, конфигурация, `System.map`, журналы и метаданные
- `<target>-developer-diagnostics` — файлы `.rej` и `.orig`, журналы применения патчей и различия при включённом режиме разработчика
