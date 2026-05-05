db = db.getSiblingDB("logistica_db");
db.createCollection("envios");
db.createCollection("bodegas");
db.createCollection("transportistas");
db.envios.createIndex({ mariadb_id: 1 }, { unique: true, sparse: true });
db.envios.createIndex({ "pedido_ref.mariadb_id": 1 });
db.envios.createIndex({ numero_guia: 1 }, { sparse: true });
db.envios.createIndex({ estado: 1 });
print("✅ logistica_db listo");