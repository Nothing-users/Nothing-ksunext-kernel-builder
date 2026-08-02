[English](../README.md) | Русский

---

# Nothing Kernel Builder

> [!WARNING]
> Этот проект является экспериментальным и ещё не тестировался на физических устройствах. Используйте его на свой страх и риск и обязательно сохраните свою резервную копию оригинального boot.img .

Автоматизированная сборка ядер Nothing с KernelSU Next, SUSFS и пользовательским патчем с помощью GitHub Actions.

## Поддерживаемые устройства

- Nothing Phone (3a) & (3a) Pro (`asteroids`, A059/A059P)
- Nothing Phone (4a) (`frogger`, A069)

## Что входит в сборку

- Исходный код ядра NothingOSS 6.1
- KernelSU Next (`dev` или `stable`)
- SUSFS v2.2.0
- Android Clang `clang-r487747c`
- Прошиваемые пакеты AnyKernel3
- Baseband Guard, BBRv3, FQ, CAKE, TTL Target, MGLRU, ZSTD

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
