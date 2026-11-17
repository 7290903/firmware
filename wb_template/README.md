# Шаблоны Wiren Board (`wb-mqtt-serial`)

JSON для **Настройки → serial-устройства**.

| Файл | Устройство | Сигнатура |
|------|------------|-----------|
| `config-rh-curt.json` | RunHouse шторы | `RHCURT` |
| `config-rh-curt-fast.json` | RH-Шторы V2 (Fast Modbus) | `RHCRT2` |
| `config-rh-curt-v2.json` | RunHouse шторы (новый модуль Tuya) | `RHCRV2` |
| `config-rh-cs-in.json` | Датчик климата | `RH-DK` |
| `rh-curt-ha-discovery.js` | wb-rules: автодобавление штор RHCRV2 в Home Assistant | — |

## Установка на контроллер

На Wiren Board:

```bash
curl -fsSL https://raw.githubusercontent.com/7290903/firmware/main/wb_template/update-template-from-github.sh | bash
```

Только шторы V1 (по умолчанию). Шторы V2 / Fast Modbus:

```bash
TEMPLATE_FILE=config-rh-curt-fast.json bash update-template-from-github.sh
```

Шторы, новый модуль Tuya (RHCRV2) + автодобавление в Home Assistant:

```bash
TEMPLATE_FILE=config-rh-curt-v2.json bash update-template-from-github.sh
curl -fsSL https://raw.githubusercontent.com/7290903/firmware/main/wb_template/rh-curt-ha-discovery.js \
  -o /etc/wb-rules/rh-curt-ha-discovery.js
```

В карточке устройства переключатель «Home Assistant Discovery» (рег. 78) включает/убирает штору в HA.

Датчик:

```bash
TEMPLATE_FILE=config-rh-cs-in.json bash update-template-from-github.sh
```

С ПК:

```bash
bash update-template-from-github.sh root@IP_WIRENBOARD
```

Скрипт кладёт файл в `/etc/wb-mqtt-serial.conf.d/templates/` и перезапускает `wb-mqtt-serial`.
