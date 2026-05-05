db = db.getSiblingDB("usuarios_db");
db.createCollection("usuarios");
db.createCollection("sesiones");
db.usuarios.createIndex({ email: 1 }, { unique: true, sparse: true });
db.usuarios.createIndex({ mariadb_id: 1 }, { unique: true, sparse: true });
db.sesiones.createIndex({ mariadb_id: 1 }, { unique: true, sparse: true });
db.sesiones.createIndex({ expira_at: 1 }, { expireAfterSeconds: 0 });
print("✅ usuarios_db listo");