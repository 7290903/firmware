# RunHouse Firmware (public)

Публичное зеркало **готовых прошивок** устройств RunHouse.

- Здесь только бинарники, описания устройств и [GitHub Releases](https://github.com/7290903/firmware/releases).
- **Исходный код** хранится в отдельных private-репозиториях и сюда не публикуется.

## Устройства

| Папка | Устройство | Тег релиза | Assets OTA |
|-------|------------|------------|------------|
| [`RH-DALI_ETH/`](RH-DALI_ETH/) | DALI Ethernet шлюз (Waveshare ESP32-S3-ETH) | `RH-DALI_ETH-vX.Y.Z` | `RH-DALI_ETH-firmware.bin`, `RH-DALI_ETH-littlefs.bin` |

## Схема релизов

- Один репозиторий — много устройств.
- Тег: `{DEVICE}-v{SEMVER}` (пример: `RH-DALI_ETH-v1.1.0`).
- Имена файлов в Release всегда с префиксом устройства — шлюз находит «свой» latest по префиксу тега/asset, не путаясь с другими устройствами.
- Общий `/releases/latest` GitHub **не используется** для OTA (там был бы последний релиз любого устройства).

## OTA

Шлюз запрашивает список Releases и выбирает новейший тег с префиксом своего устройства, затем скачивает asset с именем `{DEVICE}-firmware.bin` / `{DEVICE}-littlefs.bin`.
