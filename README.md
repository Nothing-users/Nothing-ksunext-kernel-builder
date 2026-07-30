# Nothing KernelSU Next + SUSFS Builder

GitHub Actions builder для GKI-ядер Nothing на платформе SM7635.

## Поддерживаемые устройства

| Устройство | Кодовое имя | Модель | Ветка NothingOSS | Версия ядра |
|---|---|---|---|---|
| Nothing Phone (3a) | asteroids | A059 | `sm7635/b/mr` | 6.1.134 |
| Nothing Phone (3a) Pro | asteroids | A059P | `sm7635/b/mr` | 6.1.134 |
| Nothing Phone (4a) | frogger | A069 | `sm7635/b/mr_Frogger` | 6.1.157 |

Phone (3a) и Phone (3a) Pro используют общую ветку исходников, но имеют отдельные манифесты и артефакты.

## Компоненты

- NothingOSS kernel source
- KernelSU Next `dev-susfs`
- SUSFS для `android14-6.1`
- Android Clang `clang-r487747c`
- GKI `gki_defconfig`

Версии KernelSU Next и SUSFS закреплены по commit SHA в каждом манифесте. Исходники NothingOSS по умолчанию берутся из актуального состояния указанной ветки.

## Запуск

1. Открыть `Actions`.
2. Выбрать `Build SM7635 Kernel`.
3. Нажать `Run workflow`.
4. Выбрать устройство или `all`.
5. При необходимости указать ветку, тег или commit NothingOSS в `kernel_ref`.

Результат сохраняется в GitHub Actions Artifacts:

- `Image`
- `kernel.config`
- `System.map`
- `build.json`

`Image` не является готовым `boot.img`. Его нельзя прошивать командой `fastboot flash boot Image`. Для установки нужен репак стокового `boot.img` либо отдельный совместимый AnyKernel3-пакет.

## Структура

```text
.github/workflows/build-sm7635.yml
.github/actions/build-kernel/action.yml
config/ksunext-susfs.config
manifests/manifest.schema.json
manifests/sm7635/phone-3a.json
manifests/sm7635/phone-3a-pro.json
manifests/sm7635/phone-4a.json
```
