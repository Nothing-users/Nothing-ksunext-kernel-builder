# Nothing Kernel Builder

Сборка ядер Nothing с KernelSU Next, SUSFS и готовым AnyKernel3 ZIP через GitHub Actions.

## Устройства

| Устройство | Codename | Модель | Ветка NothingOSS |
|---|---|---|---|
| Nothing Phone (3a) | `asteroids` | A059 | `sm7635/b/mr` |
| Nothing Phone (3a) Pro | `asteroids` | A059P | `sm7635/b/mr` |
| Nothing Phone (4a) | `frogger` | A069 | `sm7635/b/mr_Frogger` |

3a и 3a Pro описаны одним манифестом, компилируются один раз, затем упаковываются в отдельные ZIP и артефакты.

## Что используется

- [NothingOSS kernel 6.1](https://github.com/NothingOSS/android_kernel_msm-6.1_nothing_sm7635)
- [KernelSU Next](https://github.com/KernelSU-Next/KernelSU-Next), ветка `dev` или `stable`
- [SUSFS](https://gitlab.com/simonpunk/susfs4ksu), ветка `gki-android14-6.1-dev`
- Android Clang `clang-r487747c`
- [Nothing AnyKernel3](https://github.com/weekanya/AnyKernel3)

Версии AK3 и compatibility-патчей закреплены по commit SHA. Ветки NothingOSS, KSUN и SUSFS можно заменить при ручном запуске.

## Запуск

Открой `Actions → Build SM7635 Kernel → Run workflow`.

`ccache` сохраняется отдельно для `asteroids` и `frogger`. Первая сборка заполняет кэш, следующие переиспользуют его при совпадающем Clang и исходниках.

| Параметр | По умолчанию | Назначение |
|---|---|---|
| `device` | `all` | Линейка 3a, Phone 4a или все устройства |
| `kernel_ref` | из манифеста | Ветка, тег или commit NothingOSS |
| `ksun_ref` | `dev` | Ветка KSUN: `dev` или `stable` |
| `susfs_ref` | автоматически | Ветка, тег или commit SUSFS |
| `optimize_level` | `O2` | Оптимизация `O1`, `O2` или `O3` |
| `create_release` | включено | Создать Release или developer prerelease |
| `developer_mode` | выключено | Сохранить patch-логи, diff, `.rej` и `.orig` |

Build identity неизменно задаётся composite action: `wee@mrvoki`.

## Патчи

1. На официальный KSUN применяется `10_enable_susfs_for_ksu.patch`.
2. Конфликты с `dev` и `stable` закрываются отдельными закреплёнными [WildKernels fixes](https://github.com/WildKernels/kernel_patches) для SUSFS v2.2.0, включая hook-mode и toolkit.
3. Для Nothing 6.1.134 добавляется отсутствующий `linux/dma-buf.h`.
4. Для Nothing 6.1.157 удаляется несовместимый `trace/hooks/blk.h`, если он присутствует.
5. К ядру применяется `50_add_susfs_in_gki-android14-6.1.patch`.

Неизвестный или неразрешённый `.rej` останавливает сборку. В `developer_mode` диагностические файлы сохраняются даже при падении job.

## Результат

- `<device>-anykernel3` — только прошиваемый `Nothing-<device>-KSUNext-SUSFS-<kernel>-<optimization>.zip`
- `<device>-build-files` — `Image`, config, `System.map`, логи и metadata
- `<target>-developer-diagnostics` — `.rej`, `.orig`, patch-логи и diff при включённом developer mode

AK3 проверяет codename, определяет активный A/B-слот и заменяет только kernel в `boot`, сохраняя штатный ramdisk. Для каждого устройства создаётся отдельный ZIP.

## Важно

Загрузчик должен быть разблокирован. Перед установкой сохрани оригинальный `boot.img`.

Не прошивай сырой `Image` командой `fastboot flash boot Image`. Цепочка патчей и структура ZIP проверены, но загрузочного теста на физическом устройстве пока не было. До него релизы следует считать тестовыми.
