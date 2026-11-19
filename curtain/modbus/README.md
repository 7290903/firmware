# Прошивки Modbus OTA

Папка версии: `vMAJOR.MINOR.PATCH` (совпадает с `RH_FW_VER_*` env `rh_curtains_v1_1m`).

| Файл | Раздел |
|---|---|
| `rh_curtains_v1_1m.bin` | приложение |
| `rh_curtains_v1_1m-fs.bin` | SPIFFS, веб-интерфейс |

Скрипт пишет приложение, ждёт перезагрузку и затем SPIFFS (регистр `0xF005` = 1). Это умеет прошивка с `1.1.1`. Образ `v1.1.0` файловую систему по шине не принимает.

```
curl -fsSL https://raw.githubusercontent.com/7290903/firmware/main/curtain/modbus/rh-modbus-flash.sh | sudo bash -s -- --slave 1
```
