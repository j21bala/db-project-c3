const { getMariaDB }    = require("./db-mariadb");
const { getMongoDb }    = require("./db-mongo");
const logger            = require("./logger");
const { transformers }  = require("./transformers");

const MAX_BATCH = 50;
const MAX_RETRY = 3;

// Mapa: entidad SQL → colección MongoDB
const COLLECTION_MAP = {
  usuarios:  "usuarios",
  productos: "productos",
  pedidos:   "pedidos",
  envios:    "envios",
  tracking:  "tracking_eventos",
  sesiones:  "sesiones",
};

async function processCDCEvents(broadcast) {
  const db = await getMariaDB();

  const [events] = await db.query(
    `SELECT * FROM outbox_events
     WHERE procesado = 0 AND intentos < ?
     ORDER BY id ASC LIMIT ?`,
    [MAX_RETRY, MAX_BATCH]
  );

  if (events.length === 0) return { processed: 0, errors: 0 };

  let processed = 0, errors = 0;

  for (const event of events) {
    try {
      await applyEvent(event);
      await db.query(
        "UPDATE outbox_events SET procesado=1, procesado_at=NOW() WHERE id=?",
        [event.id]
      );
      processed++;
      if (broadcast) broadcast("cdc_event", {
        id: event.id, dominio: event.dominio,
        entidad: event.entidad, operacion: event.operacion,
        entidad_id: event.entidad_id,
      });
    } catch (err) {
      errors++;
      logger.error(`❌ CDC #${event.id}: ${err.message}`);
      await db.query(
        "UPDATE outbox_events SET intentos=intentos+1 WHERE id=?",
        [event.id]
      );
    }
  }

  return { processed, errors };
}

async function applyEvent(event) {
  const payload = typeof event.payload === "string"
    ? JSON.parse(event.payload) : event.payload;

  const mongoDB   = await getMongoDb(event.dominio);
  const colName   = COLLECTION_MAP[event.entidad] || event.entidad;
  const transform = transformers[event.entidad] || (p => p);
  const doc       = transform(payload);

  switch (event.operacion) {
    case "INSERT":
      await mongoDB.collection(colName).updateOne(
        { mariadb_id: payload.id },
        { $set: { ...doc, mariadb_id: payload.id, _synced_at: new Date() } },
        { upsert: true }
      );
      break;
    case "UPDATE":
      await mongoDB.collection(colName).updateOne(
        { mariadb_id: payload.id },
        { $set: { ...doc, _updated_at: new Date() } }
      );
      break;
    case "DELETE":
      await mongoDB.collection(colName).updateOne(
        { mariadb_id: payload.id },
        { $set: { _deleted: true, _deleted_at: new Date() } }
      );
      break;
  }
}

module.exports = { processCDCEvents };