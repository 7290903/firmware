# curtain — прошивки штор RunHouse

Плата: **uPesy ESP32-WROOM** (4 МБ flash). RS-485: TX18 / RX5 / DE25.

В папке только **готовые `.bin`**. Исходники сюда не публикуются.

| Файл | Env PlatformIO | Сигнатура WB | RS-485 baud (по умолчанию) | Файловая система |
|------|----------------|--------------|----------------------------|------------------|
| [`rh_curtains.bin`](rh_curtains.bin) | `rh_curtains` | `RHCURT` | **9600** 8N2 | [`rh_curtains-fs.bin`](rh_curtains-fs.bin) (SPIFFS) |
| [`curtains_fast.bin`](curtains_fast.bin) | `curtains_fast` | `RHCRT2` | **115200** 8N2 | [`curtains_fast-fs.bin`](curtains_fast-fs.bin) (SPIFFS) |

Веб-UI у обеих сборок общий (SPIFFS из каталога `data`).

## Что выбрать

- **`rh_curtains`** — классические шторы, обычный Modbus RTU. Шаблон [`config-rh-curt.json`](../wb_template/config-rh-curt.json). Порт на Wiren Board: **9600**.
- **`curtains_fast`** — те же шторы + Fast Modbus V2 (скан WB). Шаблон [`config-rh-curt-fast.json`](../wb_template/config-rh-curt-fast.json). Порт: **115200**. На 9600 сканер Fast Modbus устройство не найдёт.

Не смешивать шаблон и прошивку: `RHCURT` ≠ `RHCRT2`.

## Прошивка (esptool)

Смещения для стандартных разделов Arduino ESP32 4 МБ (`min_spiffs`): приложение `0x10000`, SPIFFS `0x290000`. Bootloader `0x1000`, partitions `0x8000`.

```bash
# Классика RHCURT
esptool.py --chip esp32 write_flash 0x10000 rh_curtains.bin 0x290000 rh_curtains-fs.bin

# Fast Modbus RHCRT2
esptool.py --chip esp32 write_flash 0x10000 curtains_fast.bin 0x290000 curtains_fast-fs.bin
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
```
