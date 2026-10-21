# Шаблоны Wiren Board (`wb-mqtt-serial`)

JSON для **Настройки → serial-устройства**.

| Файл | Устройство | Сигнатура |
|------|------------|-----------|
| `config-rh-curt.json` | RunHouse шторы | `RHCURT` |
| `config-rh-cs-in.json` | Датчик климата | `RH-DK` |

## Установка на контроллер

На Wiren Board:

```bash
curl -fsSL https://raw.githubusercontent.com/7290903/firmware/main/wb_template/update-template-from-github.sh | bash
```

Только шторы (по умолчанию). Датчик:

```bash
TEMPLATE_FILE=config-rh-cs-in.json bash update-template-from-github.sh
```

С ПК:

```bash
bash update-template-from-github.sh root@IP_WIRENBOARD
```

Скрипт кладёт файл в `/etc/wb-mqtt-serial.conf.d/templates/` и перезапускает `wb-mqtt-serial`.
