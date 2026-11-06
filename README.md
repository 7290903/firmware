# RunHouse Firmware (public)

Публичное зеркало **готовых прошивок** устройств RunHouse.

- В дереве репозитория — папки устройств с актуальными `.bin` и кратким README.
- Канонический канал для OTA — [GitHub Releases](https://github.com/7290903/firmware/releases) (теги `{DEVICE}-vX.Y.Z`).
- **Исходный код** хранится в отдельных private-репозиториях и сюда не публикуется.
- Шаблоны Wiren Board (`wb-mqtt-serial`) — папка [`wb_template/`](wb_template/).

## Устройства

| Папка | Устройство | Тег релиза | Файлы в папке / OTA |
|-------|------------|------------|---------------------|
| [`RH-DALI_ETH/`](RH-DALI_ETH/) | DALI Ethernet шлюз (Waveshare ESP32-S3-ETH) | [`RH-DALI_ETH-v1.1.0`](https://github.com/7290903/firmware/releases/tag/RH-DALI_ETH-v1.1.0) | `RH-DALI_ETH-firmware.bin`, `RH-DALI_ETH-littlefs.bin` |
| [`curtain/`](curtain/) | Шторы ESP32-WROOM (`RHCURT` / `RHCRT2`) | — (пока только дерево репозитория) | `rh_curtains.bin`, `curtains_fast.bin` (+ SPIFFS `*-fs.bin`) |

### Прямые ссылки (последний релиз RH-DALI_ETH)

- Прошивка: [RH-DALI_ETH-firmware.bin](https://github.com/7290903/firmware/releases/download/RH-DALI_ETH-v1.1.0/RH-DALI_ETH-firmware.bin)
- LittleFS (веб-UI): [RH-DALI_ETH-littlefs.bin](https://github.com/7290903/firmware/releases/download/RH-DALI_ETH-v1.1.0/RH-DALI_ETH-littlefs.bin)
- Папка в репозитории: [`RH-DALI_ETH/`](https://github.com/7290903/firmware/tree/main/RH-DALI_ETH)

### Прямые ссылки (шторы, папка `curtain/`)

- Классика `RHCURT` 9600: [rh_curtains.bin](https://github.com/7290903/firmware/blob/main/curtain/rh_curtains.bin) · [rh_curtains-fs.bin](https://github.com/7290903/firmware/blob/main/curtain/rh_curtains-fs.bin)
- Fast Modbus `RHCRT2` 115200: [curtains_fast.bin](https://github.com/7290903/firmware/blob/main/curtain/curtains_fast.bin) · [curtains_fast-fs.bin](https://github.com/7290903/firmware/blob/main/curtain/curtains_fast-fs.bin)
- Описание: [`curtain/`](https://github.com/7290903/firmware/tree/main/curtain)

## Шаблоны Wiren Board

Папка [`wb_template/`](wb_template/): `config-rh-curt.json` (шторы `RHCURT`, 9600), `config-rh-curt-fast.json` (шторы V2 Fast Modbus `RHCRT2`, 115200), `config-rh-cs-in.json` (датчик `RH-DK`).

На контроллере:

```bash
curl -fsSL https://raw.githubusercontent.com/7290903/firmware/main/wb_template/update-template-from-github.sh | bash
```

## Схема релизов

- Один репозиторий — много устройств.
- Тег: `{DEVICE}-v{SEMVER}` (пример: `RH-DALI_ETH-v1.1.0`).
- Имена файлов в Release всегда с префиксом устройства — OTA ищет «свой» latest по префиксу тега/asset, не мешая другие устройства.
- Общий `/releases/latest` GitHub **не используется** для OTA (там мог бы быть последний релиз любого устройства).

## OTA

Шлюз читает список Releases и выбирает новейший тег с префиксом своего устройства, затем скачивает asset с именем `{DEVICE}-firmware.bin` / `{DEVICE}-littlefs.bin`.