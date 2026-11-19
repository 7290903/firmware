#!/bin/bash
# Прошивка rh_curtains_v1_1m по Modbus RTU (регистры 0xF000 / команда 0xF080).
# Образ: https://github.com/7290903/firmware ветка main, curtain/modbus/<тег>/rh_curtains_v1_1m.bin
#
# С Wiren Board (сервис опроса шины на время прошивки останавливается):
#   curl -fsSL https://raw.githubusercontent.com/7290903/firmware/main/curtain/modbus/rh-modbus-flash.sh | sudo bash -s -- --slave 1
# Лишний аргумент «.» (bash -s -- .) игнорируется.
#   --port   /dev/ttyRS485-1
#   --baud   115200 (8N2)
#   --tag    v1.1.0 или 1.1.0 (папка в curtain/modbus)
#   --force  прошить даже если релиз не новее устройства
set -euo pipefail

PORT=/dev/ttyRS485-1
SLAVE=
BAUD=115200
TAG=
FORCE=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --port)  PORT=$2; shift 2 ;;
    --slave) SLAVE=$2; shift 2 ;;
    --baud)  BAUD=$2; shift 2 ;;
    --tag)   TAG=$2; shift 2 ;;
    --force) FORCE=1; shift ;;
    .)       shift ;;
    *) echo "Неизвестный аргумент: $1" >&2; exit 2 ;;
  esac
done

if [[ -z "${SLAVE}" ]]; then
  echo "Укажите --slave <адрес Modbus>" >&2
  exit 2
fi

REPO=https://github.com/7290903/firmware
RAW=https://raw.githubusercontent.com/7290903/firmware/main/curtain/modbus
API=https://api.github.com/repos/7290903/firmware/contents/curtain/modbus

TMP=$(mktemp /tmp/rh_curtains_v1_1m.XXXXXX.bin)
cleanup() {
  rm -f "$TMP"
  systemctl start wb-mqtt-serial >/dev/null 2>&1 || true
}
trap cleanup EXIT

if [[ -z "${TAG}" ]]; then
  echo "Ищу последнюю версию в ${REPO} curtain/modbus …"
  META=$(curl -fsSL -A rh-modbus-flash -H "Accept: application/vnd.github+json" "$API")
  TAG=$(printf '%s' "$META" | python3 -c '
import json, sys
items = json.load(sys.stdin)
best = None
best_name = None
for it in items:
    if it.get("type") != "dir":
        continue
    name = it.get("name") or ""
    core = name[1:] if name[:1] in ("v", "V") else name
    parts = core.split(".")
    if len(parts) != 3:
        continue
    try:
        key = tuple(int(x) for x in parts)
    except ValueError:
        continue
    if best is None or key > best:
        best = key
        best_name = name
if not best_name:
    sys.exit("В curtain/modbus нет папок версий vMAJOR.MINOR.PATCH")
print(best_name)
')
fi

URL="${RAW}/${TAG}/rh_curtains_v1_1m.bin"
echo "Качаю ${URL}"
curl -fsSL -A rh-modbus-flash -o "$TMP" "$URL"

echo "Останавливаю wb-mqtt-serial"
systemctl stop wb-mqtt-serial

export RH_PORT="$PORT" RH_SLAVE="$SLAVE" RH_BAUD="$BAUD" RH_TAG="$TAG" RH_FORCE="$FORCE" RH_BIN="$TMP"
python3 - <<'PY'
# -*- coding: utf-8 -*-
"""Мастер Modbus RTU на termios: версия, куски, commit. Без pyserial."""
import os, sys, select, termios, binascii, time

PORT = os.environ["RH_PORT"]
SLAVE = int(os.environ["RH_SLAVE"]) & 0xFF
BAUD = int(os.environ["RH_BAUD"])
TAG = os.environ["RH_TAG"]
FORCE = os.environ.get("RH_FORCE") == "1"
BIN = os.environ["RH_BIN"]

BASE = 0xF000
CMD = 0xF080
BAUD_MAP = {
    9600: termios.B9600,
    19200: termios.B19200,
    38400: termios.B38400,
    57600: termios.B57600,
    115200: termios.B115200,
}

def die(msg, code=1):
    print(msg, file=sys.stderr)
    sys.exit(code)

def parse_ver(text):
    s = text.strip()
    if s[:1] in ("v", "V"):
        s = s[1:]
    parts = s.split(".")
    if len(parts) != 3:
        die("Тег версии должен быть vMAJOR.MINOR.PATCH или MAJOR.MINOR.PATCH: %s" % text)
    try:
        return tuple(int(x) for x in parts)
    except ValueError:
        die("Не разобрал версию: %s" % text)

def crc16(data):
    crc = 0xFFFF
    for b in data:
        crc ^= b
        for _ in range(8):
            crc = (crc >> 1) ^ 0xA001 if (crc & 1) else (crc >> 1)
    return crc

def u16be(n):
    return bytes(((n >> 8) & 0xFF, n & 0xFF))

class Bus:
    def __init__(self, path, baud):
        if baud not in BAUD_MAP:
            die("Скорость %s не поддержана" % baud)
        self.fd = os.open(path, os.O_RDWR | os.O_NOCTTY)
        attr = termios.tcgetattr(self.fd)
        # 8N2, без программного управления потоком
        attr[0] = 0
        attr[1] = 0
        attr[2] = termios.CS8 | termios.CSTOPB | termios.CREAD | termios.CLOCAL
        attr[3] = 0
        attr[4] = attr[5] = BAUD_MAP[baud]
        attr[6][termios.VMIN] = 0
        attr[6][termios.VTIME] = 0
        termios.tcsetattr(self.fd, termios.TCSANOW, attr)
        termios.tcflush(self.fd, termios.TCIOFLUSH)

    def close(self):
        os.close(self.fd)

    def xfer(self, pdu, timeout):
        frame = pdu + crc16(pdu).to_bytes(2, "little")
        termios.tcflush(self.fd, termios.TCIFLUSH)
        time.sleep(0.005)
        os.write(self.fd, frame)
        termios.tcdrain(self.fd)
        deadline = time.monotonic() + timeout
        buf = b""
        while time.monotonic() < deadline:
            left = deadline - time.monotonic()
            r, _, _ = select.select([self.fd], [], [], left)
            if not r:
                break
            buf += os.read(self.fd, 256)
            if len(buf) >= 5:
                # Ждём тишину 4 мс, чтобы добрать хвост кадра
                r2, _, _ = select.select([self.fd], [], [], 0.004)
                if not r2 and len(buf) >= 5:
                    break
        if len(buf) < 5:
            die("Нет ответа Modbus (slave %u)" % pdu[0])
        body, recv = buf[:-2], int.from_bytes(buf[-2:], "little")
        if crc16(body) != recv:
            die("CRC ответа Modbus")
        if body[0] != pdu[0]:
            die("Чужой адрес в ответе: %u" % body[0])
        if body[1] & 0x80:
            die("Исключение Modbus fc=0x%02X code=%u" % (body[1], body[2] if len(body) > 2 else 0))
        return body

    def read_h(self, addr, count, timeout=1.0):
        pdu = bytes((SLAVE, 0x03)) + u16be(addr) + u16be(count)
        body = self.xfer(pdu, timeout)
        if body[1] != 0x03 or body[2] != count * 2:
            die("Короткий FC03")
        raw = body[3:3 + count * 2]
        return [int.from_bytes(raw[i:i+2], "big") for i in range(0, len(raw), 2)]

    def write_one(self, addr, value, timeout=1.0):
        pdu = bytes((SLAVE, 0x06)) + u16be(addr) + u16be(value & 0xFFFF)
        body = self.xfer(pdu, timeout)
        if body[1] != 0x06:
            die("Нет эха FC06")

    def write_many(self, addr, values, timeout=2.0):
        n = len(values)
        payload = b"".join(u16be(v & 0xFFFF) for v in values)
        pdu = bytes((SLAVE, 0x10)) + u16be(addr) + u16be(n) + bytes((n * 2,)) + payload
        body = self.xfer(pdu, timeout)
        if body[1] != 0x10:
            die("Нет эха FC16")

def cmd(bus, code, timeout):
    bus.write_one(CMD, code, timeout)
    st, err = bus.read_h(BASE + 3, 2, timeout=1.0)
    return st, err

def main():
    rel = parse_ver(TAG)
    data = open(BIN, "rb").read()
    if not data:
        die("Пустой bin")
    crc = binascii.crc32(data) & 0xFFFFFFFF
    size = len(data)
    print("Релиз %s, %u байт, crc32 %08X" % (".".join(str(x) for x in rel), size, crc))

    bus = Bus(PORT, BAUD)
    try:
        major, minor, patch = bus.read_h(BASE, 3)
        dev = (major, minor, patch)
        print("На шине %u.%u.%u (slave %u)" % (major, minor, patch, SLAVE))
        if rel > dev:
            print("Релиз новее — прошиваю")
        else:
            if not FORCE:
                try:
                    tty = open("/dev/tty", "r+", encoding="utf-8", errors="replace")
                except OSError:
                    die("Релиз не новее устройства, /dev/tty недоступен. Добавьте --force")
                tty.write("На устройстве %u.%u.%u, релиз %u.%u.%u. Прошить? [y/N] " % (dev + rel))
                tty.flush()
                ans = tty.readline().strip().lower()
                if ans not in ("y", "yes", "д", "да"):
                    print("Отмена")
                    return
            else:
                print("--force: прошиваю несмотря на версию")

        # size и crc, затем begin отдельным регистром (стирание раздела может занять несколько секунд)
        bus.write_many(BASE + 6, [size & 0xFFFF, (size >> 16) & 0xFFFF,
                                   crc & 0xFFFF, (crc >> 16) & 0xFFFF], timeout=2.0)
        st, err = cmd(bus, 1, timeout=20.0)
        if st == 3 or err:
            die("begin: status=%u err=%u" % (st, err))

        off = 0
        while off < size:
            chunk = data[off:off + 200]
            n = len(chunk)
            if n % 2:
                chunk = chunk + b"\x00"
            regs = [int.from_bytes(chunk[i:i+2], "big") for i in range(0, len(chunk), 2)]
            bus.write_many(BASE + 10, [off & 0xFFFF, (off >> 16) & 0xFFFF, n], timeout=2.0)
            bus.write_many(BASE + 16, regs, timeout=2.0)
            st, err = cmd(bus, 4, timeout=5.0)
            if err or st == 3:
                die("кусок off=%u: status=%u err=%u" % (off, st, err))
            off += n
            if (off // 200) % 10 == 0 or off == size:
                print("  %u / %u" % (off, size))

        st, err = cmd(bus, 2, timeout=20.0)
        if err or st != 2:
            die("commit: status=%u err=%u" % (st, err))
        print("Commit принят, контроллер перезагрузится")
    finally:
        bus.close()

if __name__ == "__main__":
    main()
PY
echo "Готово. wb-mqtt-serial будет запущен при выходе."
