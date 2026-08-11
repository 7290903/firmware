# RH-DALI_ETH

Прошивки шлюза **RunHouse DALI ETH** (Waveshare ESP32-S3-ETH + Pico-DALI2).

В этой папке лежат **актуальные бинарники** (копия последнего релиза). Для OTA предпочтительнее скачивать из [GitHub Releases](https://github.com/7290903/firmware/releases/tag/RH-DALI_ETH-v1.1.0) — там же история версий.

## Текущая версия: v1.1.0

| Файл | Назначение | Flash offset |
|------|------------|--------------|
| [`RH-DALI_ETH-firmware.bin`](RH-DALI_ETH-firmware.bin) | приложение | `0x10000` |
| [`RH-DALI_ETH-littlefs.bin`](RH-DALI_ETH-littlefs.bin) | веб-UI (LittleFS) | `0x670000` |
| [`bootloader.bin`](bootloader.bin) | bootloader | `0x0` |
| [`partitions.bin`](partitions.bin) | таблица разделов | `0x8000` |
| [`RH-DALI_ETH-flash-info.txt`](RH-DALI_ETH-flash-info.txt) | адреса и размеры | — |

### Скачать с Release

- [RH-DALI_ETH-firmware.bin](https://github.com/7290903/firmware/releases/download/RH-DALI_ETH-v1.1.0/RH-DALI_ETH-firmware.bin)
- [RH-DALI_ETH-littlefs.bin](https://github.com/7290903/firmware/releases/download/RH-DALI_ETH-v1.1.0/RH-DALI_ETH-littlefs.bin)
- [Страница релиза](https://github.com/7290903/firmware/releases/tag/RH-DALI_ETH-v1.1.0)

## Прошивка

1. Возьмите `.bin` из этой папки или с релиза.
2. Используйте `esptool` / flash-kit из private-репозитория исходников.
3. Либо OTA в веб-UI шлюза: **Настройки → Обновление → GitHub**.

Исходники: private-репозиторий (сюда не публикуются).