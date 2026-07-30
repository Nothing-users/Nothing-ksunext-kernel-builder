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
- Official KernelSU Next `dev`
- Official SUSFS `gki-android14-6.1-dev`
- Android Clang `clang-r487747c`
- GKI `gki_defconfig`
- AnyKernel3 flashable ZIP

KernelSU Next загружается из `KernelSU-Next/KernelSU-Next`, SUSFS — из `simonpunk/susfs4ksu`. Можно указать другую ветку, тег или полный commit SHA. Пустой `susfs_ref` автоматически выбирает ветку SUSFS для Android 14 / kernel 6.1 из манифеста.

## Запуск

1. Открыть `Actions`.
2. Выбрать `Build SM7635 Kernel`.
3. Нажать `Run workflow`.
4. Выбрать устройство или `all`.
5. Настроить параметры сборки:

| Параметр | Значение по умолчанию | Назначение |
|---|---|---|
| `kernel_ref` | ветка из манифеста | Ветка, тег или commit NothingOSS |
| `ksun_ref` | `dev` | Ветка, тег или commit KernelSU Next |
| `susfs_ref` | автоматически | Ветка, тег или commit SUSFS |
| `optimize_level` | `O2` | Оптимизация Clang: `O1`, `O2` или `O3` |
| `create_release` | включено | Создать GitHub Release или developer prerelease |
| `developer_mode` | выключено | Сохранить `.rej`, `.orig`, patch logs и полные diff |

## Результат сборки

Результат всегда сохраняется в GitHub Actions Artifacts. При включённом `create_release` создаётся GitHub Release с готовым AnyKernel3 ZIP и полным архивом файлов каждого выбранного устройства.

В `developer_mode` дополнительно создаётся диагностический artifact для каждого устройства. Если сборка завершилась ошибкой, диагностические архивы публикуются как prerelease. Ожидаемые `.rej` от базового KSUN-патча сохраняются до применения compatibility-fixes; остальные `.rej` означают неразрешённый конфликт.

Перед установкой разблокируйте загрузчик и сохраните оригинальный `boot.img`. AnyKernel3 ZIP пока не проверен на физическом устройстве, поэтому нужно быть готовым восстановить стоковый образ.

- `Nothing-<device>-KSUNext-SUSFS-<kernel>-<optimization>.zip`
- `README.txt`
- `Image`
- `kernel.config`
- `System.map`
- `build.log`
- `build.json`

Устанавливать нужно ZIP через совместимый kernel flasher или custom recovery. `Image` нельзя прошивать командой `fastboot flash boot Image`.

## Патчи

- SUSFS: копируются `kernel_patches/fs` и `kernel_patches/include/linux`, затем применяется `kernel_patches/50_add_susfs_in_gki-android14-6.1.patch`.
- KernelSU Next: применяется официальный `kernel_patches/KernelSU/10_enable_susfs_for_ksu.patch`.
- KSUN compatibility: конфликты официального патча с текущим `dev` закрываются серией `v2.2.0` из закреплённого commit `WildKernels/kernel_patches`.
- Nothing 6.1.134: добавляется отсутствующий include `linux/dma-buf.h`.
- Nothing 6.1.157: удаляется несовместимый include `trace/hooks/blk.h`.

Официальный SUSFS-патч проверяется на обеих ветках Nothing перед сборкой. Для 3a/3a Pro требуется только include compatibility, для 4a патч применяется без конфликтов. После обновлений NothingOSS, KernelSU Next или SUSFS совместимость нужно подтверждать новой сборкой и загрузочным тестом на устройстве.

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
