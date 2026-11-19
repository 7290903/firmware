# Прошивки Modbus OTA

Папка версии: `vMAJOR.MINOR.PATCH` (совпадает с `RH_FW_VER_*` env `rh_curtains_v1_1m`).

Файл: `rh_curtains_v1_1m.bin`.

```
https://raw.githubusercontent.com/7290903/firmware/main/curtain/modbus/v1.1.0/rh_curtains_v1_1m.bin
```

Скрипт с Wiren Board (рядом с образами, не в репозитории исходников):

```
curl -fsSL https://raw.githubusercontent.com/7290903/firmware/main/curtain/modbus/rh-modbus-flash.sh | sudo bash -s -- --slave 1
```

`rh_curtains_v1_1m.bin` — только приложение. Раздел SPIFFS (веб-интерфейс) эта сессия не пишет: он остаётся с прошлой прошивки по USB. Отдельного `*-fs.bin` в `modbus/` нет.
