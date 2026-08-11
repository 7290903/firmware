# RunHouse Firmware (public)

Публичное зеркало **готовых прошивок** устройств RunHouse.

- В дереве репозитория — папки устройств с актуальными `.bin` и кратким README.
- Канонический канал для OTA — [GitHub Releases](https://github.com/7290903/firmware/releases) (теги `{DEVICE}-vX.Y.Z`).
- **Исходный код** хранится в отдельных private-репозиториях и сюда не публикуется.

## Устройства

| Папка | Устройство | Тег релиза | Файлы в папке / OTA |
|-------|------------|------------|---------------------|
| [`RH-DALI_ETH/`](RH-DALI_ETH/) | DALI Ethernet шлюз (Waveshare ESP32-S3-ETH) | [`RH-DALI_ETH-v1.1.0`](https://github.com/7290903/firmware/releases/tag/RH-DALI_ETH-v1.1.0) | `RH-DALI_ETH-firmware.bin`, `RH-DALI_ETH-littlefs.bin` |

### Прямые ссылки (последний релиз RH-DALI_ETH)

- Прошивка: [RH-DALI_ETH-firmware.bin](https://github.com/7290903/firmware/releases/download/RH-DALI_ETH-v1.1.0/RH-DALI_ETH-firmware.bin)
- LittleFS (веб-UI): [RH-DALI_ETH-littlefs.bin](https://github.com/7290903/firmware/releases/download/RH-DALI_ETH-v1.1.0/RH-DALI_ETH-littlefs.bin)
- Папка в репозитории: [`RH-DALI_ETH/`](https://github.com/7290903/firmware/tree/main/RH-DALI_ETH)

## Схема релизов

- Один репозиторий — много устройств.
- Тег: `{DEVICE}-v{SEMVER}` (пример: `RH-DALI_ETH-v1.1.0`).
- Имена файлов в Release всегда с префиксом устройства — OTA ищет «свой» latest по префиксу тега/asset, не мешая другие устройства.
- Общий `/releases/latest` GitHub **не используется** для OTA (там мог бы быть последний релиз любого устройства).

## OTA

Шлюз читает список Releases и выбирает новейший тег с префиксом своего устройства, затем скачивает asset с именем `{DEVICE}-firmware.bin` / `{DEVICE}-littlefs.bin`.