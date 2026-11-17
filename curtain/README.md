# curtain — прошивки штор RunHouse

Плата: **uPesy ESP32-WROOM** (4 МБ flash). RS-485: TX18 / RX5 / DE25.

В папке только **готовые `.bin`**. Исходники сюда не публикуются.

| Файл | Env PlatformIO | Сигнатура WB | RS-485 baud (по умолчанию) | Файловая система |
|------|----------------|--------------|----------------------------|------------------|
| [`rh_curtains.bin`](rh_curtains.bin) | `rh_curtains` | `RHCURT` | **9600** 8N2 | [`rh_curtains-fs.bin`](rh_curtains-fs.bin) (SPIFFS) |
| [`curtains_fast.bin`](curtains_fast.bin) | `curtains_fast` | `RHCRT2` | **115200** 8N2 | [`curtains_fast-fs.bin`](curtains_fast-fs.bin) (SPIFFS) |
| [`rh_curtains_v1_1.bin`](rh_curtains_v1_1.bin) | `rh_curtains_v1_1` | `RHCRV1` | **115200** 8N2 | [`rh_curtains_v1_1-fs.bin`](rh_curtains_v1_1-fs.bin) (SPIFFS) |
| [`rh_curtains_v2.bin`](rh_curtains_v2.bin) | `rh_curtains_v2` | `RHCRV2` | **115200** 8N2 | [`rh_curtains_v2-fs.bin`](rh_curtains_v2-fs.bin) (SPIFFS) |

Веб-UI у обеих сборок общий (SPIFFS из каталога `data`).

## Что выбрать

- **`rh_curtains`** — классические шторы, обычный Modbus RTU. Шаблон [`config-rh-curt.json`](../wb_template/config-rh-curt.json). Порт на Wiren Board: **9600**.
- **`curtains_fast`** — те же шторы + Fast Modbus V2 (скан WB). Шаблон [`config-rh-curt-fast.json`](../wb_template/config-rh-curt-fast.json). Порт: **115200**. На 9600 сканер Fast Modbus устройство не найдёт.

- **`rh_curtains_v2`** — **новый модуль Tuya**: ESP вместо WBR1/K202, UART к MCU CMS32L051. Скорость мотора, угол ламелей, единая команда для Home Assistant, автодобавление в HA (MQTT Discovery). Шаблон [`config-rh-curt-v2.json`](../wb_template/config-rh-curt-v2.json). Порт: **115200**.

- **`rh_curtains_v1_1`** — **моторы TP35 (старый модуль Tuya) + новый UI**. Команды Tuya как в `rh_curtains`, веб-интерфейс, Modbus и HA Discovery как у `rh_curtains_v2`. Шаблон [`config-rh-curt-v11.json`](../wb_template/config-rh-curt-v11.json). Порт: **115200**.

Не смешивать шаблон и прошивку: `RHCURT` ≠ `RHCRT2` ≠ `RHCRV1` ≠ `RHCRV2`.

### `rh_curtains_v1_1` — моторы TP35, новый UI, 115200

Поддерживает **два типа моторов**, тип определяется автоматически по ответу MCU при старте:

| Мотор | Как опознаётся | Команды |
|-------|----------------|---------|
| **TP35D-10/22** | MCU прислал продукт `p=u6vocbgufhjq97ti` | DP 01 + дубль DP 66 (VER `03`), позиция DP 02/03 |
| **TP35-05/26EHU** (старый блок) | любой другой продукт | только DP 01, позиция DP 02 |

- **Новый веб-интерфейс** (как у v2). Угла ламелей и скорости нет — у TP35 этих команд Tuya нет.
- **RS-485 по умолчанию 115200** 8N2 (со старых 9600 переводится автоматически при первом запуске).
- Сигнатура WB `RHCRV1`, id устройства `rh-curt-v11`.
- Регистры — как у `rh_curtains_v2` (таблица ниже), **кроме 75 и 76**: есть единая команда 77 и HA Discovery 78.

### Регистры `rh_curtains_v2` (holding)

| Рег. | Назначение |
|------|------------|
| 64 / 65 | уставка / позиция, 0–100 (0 = открыто) |
| 66 | статус: 0 стоп, 1 открыто, 2 закрыто, 3 открывается, 4 закрывается |
| 67 / 68 / 69 | открыть / стоп / закрыть |
| 75 | угол ламелей 0–100 |
| 76 | скорость: 0 высокая, 1 средняя, 2 низкая |
| 77 | команда: 1 открыть, 2 стоп, 3 закрыть (сбрасывается в 0) |
| 78 | HA Discovery через wb-rules (0/1) |

## Прошивка (esptool)

Смещения для стандартных разделов Arduino ESP32 4 МБ (`min_spiffs`): приложение `0x10000`, SPIFFS `0x290000`. Bootloader `0x1000`, partitions `0x8000`.

```bash
# Классика RHCURT
esptool.py --chip esp32 write_flash 0x10000 rh_curtains.bin 0x290000 rh_curtains-fs.bin

# Fast Modbus RHCRT2
esptool.py --chip esp32 write_flash 0x10000 curtains_fast.bin 0x290000 curtains_fast-fs.bin

# Моторы TP35 + новый UI RHCRV1
esptool.py --chip esp32 write_flash 0x10000 rh_curtains_v1_1.bin 0x290000 rh_curtains_v1_1-fs.bin

# Новый модуль Tuya RHCRV2
esptool.py --chip esp32 write_flash 0x10000 rh_curtains_v2.bin 0x290000 rh_curtains_v2-fs.bin
```

Либо PlatformIO: `pio run -e rh_curtains -t upload` / `-t uploadfs` (и то же для `curtains_fast`).

USB-монитор: 115200 (это не скорость RS-485).

## Wiren Board

Шаблоны: [`wb_template/`](../wb_template/). На контроллере:

```bash
# RHCURT (9600)
curl -fsSL https://raw.githubusercontent.com/7290903/firmware/main/wb_template/update-template-from-github.sh | bash

# RHCRT2 (115200)
TEMPLATE_FILE=config-rh-curt-fast.json bash update-template-from-github.sh

# RHCRV1 — моторы TP35, новый UI (115200)
TEMPLATE_FILE=config-rh-curt-v11.json bash update-template-from-github.sh

# RHCRV2 — новый модуль Tuya (115200)
TEMPLATE_FILE=config-rh-curt-v2.json bash update-template-from-github.sh
```
