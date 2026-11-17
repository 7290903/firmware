// RunHouse: автодобавление штор rh-curt-v2 в Home Assistant (MQTT Discovery).
// Положить в /etc/wb-rules/ на Wiren Board. Брокер HA должен видеть топики WB (тот же брокер или мост).
// Устройство находится по топику /devices/rh-curt-v2_<адрес>/...; публикация включается
// каналом «HA Discovery» (Hreg 78). 0 → конфиг удаляется из HA.

var PREFIX = "homeassistant";      // discovery_prefix в HA
// rh-curt-v2 — новый модуль Tuya (угол ламелей, скорость); rh-curt-v11 — TP35, только позиция
var DEV_RE = /^\/devices\/(rh-curt-v(?:2|11)_\d+)\/controls\/HA Discovery$/;
var state = {};                    // deviceId → последнее опубликованное значение флага

function topics(id) {
  var uid = id.replace(/-/g, "_");
  return {
    uid: uid,
    cover: PREFIX + "/cover/" + uid + "/config",
    speed: PREFIX + "/select/" + uid + "_speed/config"
  };
}

function publishDiscovery(id) {
  var t = topics(id);
  var isV2 = id.indexOf("rh-curt-v2_") === 0;
  var base = "/devices/" + id + "/controls/";
  var device = {
    identifiers: [t.uid],
    name: "RunHouse штора " + id.split("_")[1],
    manufacturer: "RunHouse",
    model: isV2 ? "RH Curtain v2 (Modbus)" : "RH Curtain v1.1 (Modbus)",
    via_device: "wirenboard"
  };
  var cover = {
    name: null,                    // имя сущности = имя устройства
    unique_id: t.uid,
    device_class: "blind",
    device: device,
    command_topic: base + "Command/on",
    payload_open: "1",
    payload_stop: "2",
    payload_close: "3",
    state_topic: base + "Status",
    state_stopped: "0",
    state_open: "1",
    state_closed: "2",
    state_opening: "3",
    state_closing: "4",
    position_topic: base + "Position",
    set_position_topic: base + "Set Position/on",
    position_open: 0,              // у мотора 0 % = открыто
    position_closed: 100,
    optimistic: false,
    qos: 1
  };
  publish(t.cover, JSON.stringify(cover), 1, true);
  if (!isV2) {
    publish(t.speed, "", 1, true);  // у v1.1 нет скорости — убрать, если осталась
    log.info("[rh-curt] HA Discovery опубликован: " + id);
    return;
  }
  cover.tilt_status_topic = base + "Tilt";
  cover.tilt_command_topic = base + "Tilt/on";
  cover.tilt_min = 0;
  cover.tilt_max = 100;
  cover.tilt_opened_value = 100;
  cover.tilt_closed_value = 0;

  var speed = {
    name: "Скорость",
    unique_id: t.uid + "_speed",
    device: device,
    state_topic: base + "Speed",
    command_topic: base + "Speed/on",
    options: ["Высокая", "Средняя", "Низкая"],
    value_template: "{{ ['Высокая','Средняя','Низкая'][value | int(1)] }}",
    command_template: "{{ ['Высокая','Средняя','Низкая'].index(value) }}",
    entity_category: "config"
  };

  publish(t.cover, JSON.stringify(cover), 1, true);
  publish(t.speed, JSON.stringify(speed), 1, true);
  log.info("[rh-curt] HA Discovery опубликован: " + id);
}

function removeDiscovery(id) {
  var t = topics(id);
  publish(t.cover, "", 1, true);   // пустой retained = удалить сущность в HA
  publish(t.speed, "", 1, true);
  log.info("[rh-curt] HA Discovery удалён: " + id);
}

trackMqtt("/devices/+/controls/HA Discovery", function (msg) {
  var m = DEV_RE.exec(msg.topic);
  if (!m) return;
  var id = m[1];
  var on = msg.value === "1";
  if (state[id] === on) return;    // WB перепубликует значение — не дёргаем HA
  state[id] = on;
  if (on) publishDiscovery(id); else removeDiscovery(id);
});
