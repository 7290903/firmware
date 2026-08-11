# RH-DALI_ETH

Прошивки шлюза **RunHouse DALI ETH** (Waveshare ESP32-S3-ETH + Pico-DALI2).

В этой папке — только описание. Бинарники публикуются в **GitHub Releases** этого репозитория.

## Релизы

- Теги: `RH-DALI_ETH-vX.Y.Z`
- Assets:
  - `RH-DALI_ETH-firmware.bin` — приложение (flash @ `0x10000`)
  - `RH-DALI_ETH-littlefs.bin` — веб-UI LittleFS (@ `0x670000`)
  - `RH-DALI_ETH-flash-info.txt` — адреса и размеры
  - опционально: `bootloader.bin`, `partitions.bin`, `boot_app0.bin`

## Прошивка

1. Скачайте assets нужного релиза.
2. Используйте `esptool` / flash-kit из private-репозитория исходников.
3. Либо OTA из веб-UI шлюза: **Настройки → Обновление → GitHub**.

Исходники: private-репозиторий `RH-DALI_ETH` (не публикуются сюда).
