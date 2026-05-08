require("dotenv").config();
const express   = require("express");
const cors      = require("cors");
const http      = require("http");
const WebSocket = require("ws");
const logger    = require("./logger");
const { getMariaDB }      = require("./db-mariadb");
const { getMongoDomains } = require("./db-mongo");
const { processCDCEvents } = require("./cdc-processor");
const { runFullMigration } = require("./migrate-full");
const { checkIntegrity }  = require("./integrity-checker");

const app    = express();
const server = http.createServer(app);
const wss    = new WebSocket.Server({ server });

app.use(cors({ origin: '*', methods: ['GET','POST'] }));
app.use(express.json());

// Broadcast a todos los clientes WebSocket
const broadcast = (type, data) => {
  const msg = JSON.stringify({ type, data, ts: new Date().toISOString() });
  wss.clients.forEach(c => { if (c.readyState === WebSocket.OPEN) c.send(msg); });
};
global.broadcast = broadcast;

// ── RUTAS ────────────────────────────────────────
app.get("/api/status", async (req, res) => {
  try {
    const db      = await getMariaDB();
    const domains = await getMongoDomains();
    const [total]  = await db.query("SELECT COUNT(*) as c FROM outbox_events");
    const [proc]   = await db.query("SELECT COUNT(*) as c FROM outbox_events WHERE procesado=1");
    const [pend]   = await db.query("SELECT COUNT(*) as c FROM outbox_events WHERE procesado=0");

    const mongodb = {};
    for (const [domain, client] of Object.entries(domains)) {
      const dbi = client.db(`${domain}_db`);
      const cols = await dbi.listCollections().toArray();
      mongodb[domain] = {};
      for (const col of cols) {
        mongodb[domain][col.name] = await dbi.collection(col.name).countDocuments();
      }
    }
    res.json({ ok: true, mariadb: { total: total[0].c, procesados: proc[0].c, pendientes: pend[0].c },
               mongodb, uptime: process.uptime() });
  } catch (err) { res.status(500).json({ ok: false, error: err.message }); }
});

app.get("/api/monolito/:tabla", async (req, res) => {
  const allowed = ["usuarios","productos","pedidos","envios","pagos",
                   "resenas","outbox_events","tracking_eventos","transportistas","bodegas"];
  if (!allowed.includes(req.params.tabla)) return res.status(400).json({ error: "No permitida" });
  try {
    const db = await getMariaDB();
    const [rows] = await db.query(`SELECT * FROM ${req.params.tabla} LIMIT ?`,
                                  [parseInt(req.query.limit) || 20]);
    res.json({ tabla: req.params.tabla, total: rows.length, data: rows });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

app.get("/api/mongo/:dominio/:coleccion", async (req, res) => {
  try {
    const domains = await getMongoDomains();
    const client  = domains[req.params.dominio];
    if (!client) return res.status(404).json({ error: "Dominio no encontrado" });
    const docs = await client.db(`${req.params.dominio}_db`)
      .collection(req.params.coleccion).find({}).limit(20).toArray();
    res.json({ dominio: req.params.dominio, coleccion: req.params.coleccion, total: docs.length, data: docs });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

app.post("/api/migrate/full", async (req, res) => {
  try {
    broadcast("migration_started", { mode: "full" });
    const result = await runFullMigration(broadcast);
    broadcast("migration_completed", result);
    res.json({ ok: true, result });
  } catch (err) {
    broadcast("migration_error", { error: err.message });
    res.status(500).json({ ok: false, error: err.message });
  }
});

app.post("/api/migrate/cdc", async (req, res) => {
  try {
    const result = await processCDCEvents(broadcast);
    res.json({ ok: true, result });
  } catch (err) { res.status(500).json({ ok: false, error: err.message }); }
});
// Crear un nuevo usuario en el monolito vía API
// ── Agregar múltiples USUARIOS ──
app.post("/api/usuarios", async (req, res) => {
  try {
    // Convertimos a Array por si nos envían solo uno o varios
    const usuarios = Array.isArray(req.body) ? req.body : [req.body];
    const db = await getMariaDB();
    let insertados = 0;

    for (const u of usuarios) {
      if (!u.nombre || !u.apellido || !u.email) continue;
      await db.query(
        "INSERT INTO usuarios (nombre, apellido, email, telefono) VALUES (?, ?, ?, ?)",
        [u.nombre, u.apellido, u.email, u.telefono || null]
      );
      insertados++;
    }
    res.json({ ok: true, mensaje: `${insertados} usuarios guardados exitosamente` });
  } catch (err) { 
    res.status(500).json({ error: err.message }); 
  }
});
// ── Agregar múltiples PRODUCTOS (Catálogo) ──
app.post("/api/productos", async (req, res) => {
  try {
    const productos = Array.isArray(req.body) ? req.body : [req.body];
    const db = await getMariaDB();
    let insertados = 0;

    for (const p of productos) {
      // Ahora validamos que también traiga un 'sku'
      if (!p.sku || !p.nombre || !p.precio || !p.categoria_id) continue; 
      
      await db.query(
        "INSERT INTO productos (sku, nombre, precio, stock, categoria_id) VALUES (?, ?, ?, ?, ?)",
        [p.sku, p.nombre, p.precio, p.stock || 0, p.categoria_id]
      );
      insertados++;
    }
    res.json({ ok: true, mensaje: `${insertados} productos guardados exitosamente` });
  } catch (err) { 
    res.status(500).json({ error: err.message }); 
  }
});

// ── Agregar múltiples PEDIDOS ──
app.post("/api/pedidos", async (req, res) => {
  try {
    const pedidos = Array.isArray(req.body) ? req.body : [req.body];
    const db = await getMariaDB();
    let insertados = 0;

    for (const p of pedidos) {
      if (!p.usuario_id || !p.total) continue;
      
      // Si nos envía un estado que es válido, lo usamos. Si no, lo dejamos nulo
      // para que MariaDB use su valor DEFAULT ('borrador')
      await db.query(
        "INSERT INTO pedidos (usuario_id, total, estado) VALUES (?, ?, ?)",
        [p.usuario_id, p.total, p.estado || null]
      );
      insertados++;
    }
    res.json({ ok: true, mensaje: `${insertados} pedidos guardados exitosamente` });
  } catch (err) { 
    res.status(500).json({ error: err.message }); 
  }
});
// ── MODO BERSERKER: Stress Test (Generar miles de registros) ──
app.post("/api/stress", async (req, res) => {
  try {
    // Si no le mandamos cantidad, por defecto hará 10,000
    const cantidad = req.query.cantidad || 10000; 
    const db = await getMariaDB();
    
    // Le respondemos a Postman de inmediato para que no se quede cargando
    res.json({ ok: true, mensaje: `Iniciando bombardeo de ${cantidad} pedidos en segundo plano... Mira tu Dashboard!` });

    // Empezamos a inyectar directamente a MariaDB en segundo plano
    setTimeout(async () => {
      let insertados = 0;
      for(let i = 0; i < cantidad; i++) {
        // Inventamos totales aleatorios para variar
        const totalRandom = (Math.random() * 500).toFixed(2);
        await db.query(
          "INSERT INTO pedidos (usuario_id, total, estado) VALUES (1, ?, 'borrador')",
          [totalRandom]
        );
        insertados++;
      }
      console.log(` Stress test finalizado: Se inyectaron ${insertados} registros de golpe.`);
    }, 100); // Inicia casi inmediatamente

  } catch (err) { 
    console.error("Error en stress test:", err);
  }
});

app.get("/api/integrity", async (req, res) => {
  try {
    const report = await checkIntegrity();
    broadcast("integrity_report", report);
    res.json(report);
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// ── CDC LOOP ─────────────────────────────────────
const CDC_INTERVAL = parseInt(process.env.CDC_INTERVAL_MS) || 4000;

setInterval(async () => {
  try {
    const r = await processCDCEvents(broadcast);
    if (r.processed > 0) logger.info(`CDC: ${r.processed} eventos`);
  } catch (err) { logger.error(`CDC: ${err.message}`); }
}, CDC_INTERVAL);

// ── INICIO ───────────────────────────────────────
const PORT = process.env.PORT || 3000;

async function main() {
  let retries = 0;
  while (retries < 20) {
    try {
      await getMariaDB();
      await getMongoDomains();
      logger.info("Todas las conexiones establecidas");
      break;
    } catch (err) {
      retries++;
      logger.warn(`Esperando DBs (${retries}/20): ${err.message}`);
      await new Promise(r => setTimeout(r, 3000));
    }
  }
  server.listen(PORT, () => {
    logger.info(`🌐 API → http://0.0.0.0:${PORT}`);
    logger.info(`📡 WS  → ws://0.0.0.0:${PORT}`);
    logger.info(`⚙️  CDC loop cada ${CDC_INTERVAL}ms`);
  });
}

main();