db = db.getSiblingDB("pedidos_db");
db.createCollection("pedidos");
db.pedidos.createIndex({ mariadb_id: 1 }, { unique: true, sparse: true });
db.pedidos.createIndex({ "usuario_ref.mariadb_id": 1 });
db.pedidos.createIndex({ estado: 1 });
db.pedidos.createIndex({ creado_at: -1 });
print("✅ pedidos_db listo");