const { MongoClient } = require("mongodb");
const logger = require("./logger");
const clients = {};

const URIS = {
  usuarios:  process.env.MONGO_USUARIOS_URI,
  catalogo:  process.env.MONGO_CATALOGO_URI,
  pedidos:   process.env.MONGO_PEDIDOS_URI,
  logistica: process.env.MONGO_LOGISTICA_URI,
};

async function getMongoDomains() {
  for (const [domain, uri] of Object.entries(URIS)) {
    if (!clients[domain]) {
      const client = new MongoClient(uri, {
        serverSelectionTimeoutMS: 5000,
        connectTimeoutMS: 5000,
      });
      await client.connect();
      clients[domain] = client;
      logger.info(`✅ MongoDB [${domain}] conectado`);
    }
  }
  return clients;
}

async function getMongoDb(domain) {
  const domains = await getMongoDomains();
  const client  = domains[domain];
  if (!client) throw new Error(`Dominio desconocido: ${domain}`);
  return client.db(`${domain}_db`);
}

module.exports = { getMongoDomains, getMongoDb };