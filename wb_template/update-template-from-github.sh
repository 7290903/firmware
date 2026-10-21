#!/bin/bash
# Скачать шаблон штор с GitHub и поставить на Wiren Board.
#
# На контроллере:
#   bash update-template-from-github.sh
#
# С ПК:
#   bash wirenboard/update-template-from-github.sh root@192.168.1.10
#
set -euo pipefail

REPO_RAW="${REPO_RAW:-https://raw.githubusercontent.com/7290903/firmware/main}"
FILE="${TEMPLATE_FILE:-config-rh-curt.json}"
SRC_URL="${REPO_RAW}/wb_template/${FILE}"
DEST_DIRS="/etc/wb-mqtt-serial.conf.d/templates /etc/wb-mqtt-serial.d/templates"
WB_HOST="${1:-}"

install_local() {
  local tmp
  tmp="$(mktemp)"
  echo "Качаю ${SRC_URL}"
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$SRC_URL" -o "$tmp"
  else
    wget -qO "$tmp" "$SRC_URL"
  fi
  python3 -m json.tool "$tmp" >/dev/null
  echo "JSON ок"

  local copied=0
  local d
  for d in $DEST_DIRS; do
    if [[ -d "$d" ]]; then
      echo "Копирую в $d/$FILE"
      cp "$tmp" "$d/$FILE"
      chmod 644 "$d/$FILE"
      copied=1
    fi
  done
  rm -f "$tmp"
  if [[ "$copied" -eq 0 ]]; then
    echo "Нет каталога шаблонов wb-mqtt-serial" >&2
    exit 1
  fi

  echo "Перезапуск драйвера serial..."
  systemctl restart wb-mqtt-serial
  systemctl try-restart wb-mqtt-confed 2>/dev/null || true
  sleep 2
  echo "Журнал:"
  journalctl -u wb-mqtt-serial -n 30 --no-pager | grep -iE 'RHCURT|template|ERROR|Validation' || true
  echo "Готово. UI: Настройки → serial-устройства → Найти и добавить устройства"
}

if [[ -d /etc/wb-mqtt-serial.conf.d || -d /etc/wb-mqtt-serial.d ]]; then
  install_local
  exit 0
fi

if [[ -z "$WB_HOST" ]]; then
  echo "Запуск не на WB. Укажите хост: $0 root@IP_WIRENBOARD" >&2
  exit 1
fi

echo "Ставлю шаблон на ${WB_HOST} с GitHub"
ssh "$WB_HOST" "REPO_RAW='${REPO_RAW}' TEMPLATE_FILE='${FILE}' bash -s" <<'EOS'
set -euo pipefail
FILE="${TEMPLATE_FILE:-config-rh-curt.json}"
SRC_URL="${REPO_RAW}/wb_template/${FILE}"
tmp="$(mktemp)"
curl -fsSL "$SRC_URL" -o "$tmp" || wget -qO "$tmp" "$SRC_URL"
python3 -m json.tool "$tmp" >/dev/null
copied=0
for d in /etc/wb-mqtt-serial.conf.d/templates /etc/wb-mqtt-serial.d/templates; do
  if [[ -d "$d" ]]; then
    cp "$tmp" "$d/$FILE"
    chmod 644 "$d/$FILE"
    echo "Копирую в $d/$FILE"
    copied=1
  fi
done
rm -f "$tmp"
[[ "$copied" -eq 1 ]]
systemctl restart wb-mqtt-serial
systemctl try-restart wb-mqtt-confed 2>/dev/null || true
sleep 2
journalctl -u wb-mqtt-serial -n 30 --no-pager | grep -iE 'RHCURT|template|ERROR|Validation' || true
echo "Готово"
EOS
