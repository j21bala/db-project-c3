const { getMariaDB } = require("./db-mariadb");
const { getMongoDb } = require("./db-mongo");
const logger         = require("./logger");

async function checkIntegrity() {
  const db = await getMariaDB();
  const report = { timestamp: new Date().toISOString(), ok: true, dominios: {}, divergencias: [] };

  const checks = [
    { dominio: "usuarios",  table: "usuarios",  mongoCol: "usuarios"  },
    { dominio: "catalogo",  table: "productos", mongoCol: "productos" },
    { dominio: "pedidos",   table: "pedidos",   mongoCol: "pedidos"   },
    { dominio: "logistica", table: "envios",    mongoCol: "envios"    },
  ];

  for (const { dominio, table, mongoCol } of checks) {
    try {
      const [rows]   = await db.query(`SELECT COUNT(*) as c FROM ${table}`);
      const mongoDB  = await getMongoDb(dominio);
      const mongoC   = await mongoDB.collection(mongoCol).countDocuments({ _deleted: { $ne: true } });
      const mariaC   = rows[0].c;
      const match    = mariaC === mongoC;
      report.dominios[dominio] = { mariadb: mariaC, mongodb: mongoC, match, tabla: table };
      if (!match) {
        report.ok = false;
        report.divergencias.push({ dominio, mensaje: `Δ ${Math.abs(mariaC - mongoC)} registros`, mariaC, mongoC });
      }
    } catch (err) {
      report.dominios[dominio] = { error: err.message };
      report.ok = false;
    }
  }

  const [pend] = await db.query("SELECT COUNT(*) as c FROM outbox_events WHERE procesado=0");
  report.pendientes_cdc = pend[0].c;
  logger.info(`🔍 Integridad: ${report.ok ? "OK" : " DIVERGENCIAS"} | CDC pendientes: ${report.pendientes_cdc}`);
  return report;
}

module.exports = { checkIntegrity };