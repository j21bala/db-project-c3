const mysql  = require("mysql2/promise");
const logger = require("./logger");
let pool = null;

async function getMariaDB() {
  if (pool) return pool;
  pool = mysql.createPool({
    host:     process.env.MARIADB_HOST || "localhost",
    port:     parseInt(process.env.MARIADB_PORT) || 3306,
    database: process.env.MARIADB_DATABASE || "tienda_monolito",
    user:     process.env.MARIADB_USER || "app_user",
    password: process.env.MARIADB_PASSWORD || "app_pass",
    waitForConnections: true,
    connectionLimit: 10,
  });
  const conn = await pool.getConnection();
  logger.info(`MariaDB conectado`);
  conn.release();
  return pool;
}

module.exports = { getMariaDB };