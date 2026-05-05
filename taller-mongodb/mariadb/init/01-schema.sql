-- ═══════════════════════════════════════════════════════
-- MONOLITO TIENDA_MONOLITO — Base relacional completa
-- Dominio 1: Usuarios y autenticación
-- Dominio 2: Catálogo de productos
-- Dominio 3: Pedidos y pagos
-- Dominio 4: Logística y envíos
-- ═══════════════════════════════════════════════════════
USE tienda_monolito;

-- ─────────────────────────────────────────
-- DOMINIO USUARIOS
-- ─────────────────────────────────────────
CREATE TABLE usuarios (
  id              INT AUTO_INCREMENT PRIMARY KEY,
  nombre          VARCHAR(100) NOT NULL,
  apellido        VARCHAR(100) NOT NULL,
  email           VARCHAR(150) UNIQUE NOT NULL,
  telefono        VARCHAR(20),
  fecha_nacimiento DATE,
  activo          TINYINT(1) DEFAULT 1,
  creado_at       DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE direcciones (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  usuario_id    INT NOT NULL,
  alias         VARCHAR(60) DEFAULT 'Casa',
  calle         VARCHAR(200),
  barrio        VARCHAR(100),
  ciudad        VARCHAR(100),
  departamento  VARCHAR(100),
  pais          VARCHAR(60) DEFAULT 'Colombia',
  codigo_postal VARCHAR(20),
  es_principal  TINYINT(1) DEFAULT 0,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

CREATE TABLE sesiones (
  id          BIGINT AUTO_INCREMENT PRIMARY KEY,
  usuario_id  INT NOT NULL,
  token       VARCHAR(255) UNIQUE NOT NULL,
  ip          VARCHAR(45),
  user_agent  TEXT,
  expira_at   DATETIME,
  creado_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

CREATE TABLE preferencias_usuario (
  usuario_id          INT PRIMARY KEY,
  idioma              VARCHAR(10) DEFAULT 'es',
  moneda              VARCHAR(10) DEFAULT 'COP',
  notif_email         TINYINT(1) DEFAULT 1,
  notif_sms           TINYINT(1) DEFAULT 0,
  categorias_favoritas TEXT,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

-- ─────────────────────────────────────────
-- DOMINIO CATÁLOGO
-- ─────────────────────────────────────────
CREATE TABLE categorias (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  nombre      VARCHAR(100) NOT NULL,
  slug        VARCHAR(120) UNIQUE,
  descripcion TEXT,
  padre_id    INT,
  activo      TINYINT(1) DEFAULT 1,
  FOREIGN KEY (padre_id) REFERENCES categorias(id)
);

CREATE TABLE marcas (
  id      INT AUTO_INCREMENT PRIMARY KEY,
  nombre  VARCHAR(100) NOT NULL,
  pais    VARCHAR(60),
  website VARCHAR(200)
);

CREATE TABLE productos (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  sku           VARCHAR(60) UNIQUE NOT NULL,
  nombre        VARCHAR(200) NOT NULL,
  descripcion   TEXT,
  precio        DECIMAL(14,2) NOT NULL,
  precio_costo  DECIMAL(14,2),
  categoria_id  INT,
  marca_id      INT,
  stock         INT DEFAULT 0,
  stock_minimo  INT DEFAULT 5,
  peso_kg       DECIMAL(6,3),
  activo        TINYINT(1) DEFAULT 1,
  destacado     TINYINT(1) DEFAULT 0,
  creado_at     DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (categoria_id) REFERENCES categorias(id),
  FOREIGN KEY (marca_id)     REFERENCES marcas(id)
);

CREATE TABLE variantes_producto (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  producto_id INT NOT NULL,
  sku_variante VARCHAR(80) UNIQUE,
  color       VARCHAR(60),
  talla       VARCHAR(30),
  stock       INT DEFAULT 0,
  precio_extra DECIMAL(10,2) DEFAULT 0,
  FOREIGN KEY (producto_id) REFERENCES productos(id)
);

CREATE TABLE atributos_producto (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  producto_id INT NOT NULL,
  clave       VARCHAR(80),
  valor       VARCHAR(255),
  FOREIGN KEY (producto_id) REFERENCES productos(id)
);

CREATE TABLE imagenes_producto (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  producto_id INT NOT NULL,
  url         VARCHAR(500),
  alt_text    VARCHAR(200),
  orden       INT DEFAULT 0,
  es_principal TINYINT(1) DEFAULT 0,
  FOREIGN KEY (producto_id) REFERENCES productos(id)
);

CREATE TABLE resenas (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  producto_id  INT NOT NULL,
  usuario_id   INT NOT NULL,
  calificacion TINYINT NOT NULL CHECK (calificacion BETWEEN 1 AND 5),
  titulo       VARCHAR(150),
  comentario   TEXT,
  verificado   TINYINT(1) DEFAULT 0,
  creado_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (producto_id) REFERENCES productos(id),
  FOREIGN KEY (usuario_id)  REFERENCES usuarios(id)
);

-- ─────────────────────────────────────────
-- DOMINIO PEDIDOS
-- ─────────────────────────────────────────
CREATE TABLE cupones (
  id               INT AUTO_INCREMENT PRIMARY KEY,
  codigo           VARCHAR(30) UNIQUE NOT NULL,
  tipo             ENUM('porcentaje','monto_fijo') DEFAULT 'porcentaje',
  valor            DECIMAL(10,2),
  minimo_compra    DECIMAL(12,2) DEFAULT 0,
  maximo_usos      INT DEFAULT 100,
  usos_actuales    INT DEFAULT 0,
  activo           TINYINT(1) DEFAULT 1,
  expira_at        DATETIME
);

CREATE TABLE pedidos (
  id               INT AUTO_INCREMENT PRIMARY KEY,
  usuario_id       INT NOT NULL,
  estado           ENUM('borrador','confirmado','pagado','en_preparacion',
                        'despachado','entregado','cancelado','devuelto') DEFAULT 'borrador',
  subtotal         DECIMAL(14,2),
  descuento        DECIMAL(14,2) DEFAULT 0,
  impuestos        DECIMAL(14,2) DEFAULT 0,
  costo_envio      DECIMAL(10,2) DEFAULT 0,
  total            DECIMAL(14,2),
  cupon_id         INT,
  notas            TEXT,
  creado_at        DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at       DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
  FOREIGN KEY (cupon_id)   REFERENCES cupones(id)
);

CREATE TABLE items_pedido (
  id              INT AUTO_INCREMENT PRIMARY KEY,
  pedido_id       INT NOT NULL,
  producto_id     INT NOT NULL,
  variante_id     INT,
  cantidad        INT NOT NULL,
  precio_unit     DECIMAL(14,2) NOT NULL,
  descuento_item  DECIMAL(10,2) DEFAULT 0,
  sku_snapshot    VARCHAR(80),
  nombre_snapshot VARCHAR(200),
  FOREIGN KEY (pedido_id)   REFERENCES pedidos(id),
  FOREIGN KEY (producto_id) REFERENCES productos(id),
  FOREIGN KEY (variante_id) REFERENCES variantes_producto(id)
);

CREATE TABLE pagos (
  id              INT AUTO_INCREMENT PRIMARY KEY,
  pedido_id       INT NOT NULL,
  metodo          ENUM('tarjeta_credito','tarjeta_debito','pse','nequi',
                       'daviplata','efecty','contraentrega','crypto') DEFAULT 'pse',
  estado          ENUM('pendiente','procesando','aprobado',
                       'rechazado','reembolsado') DEFAULT 'pendiente',
  monto           DECIMAL(14,2),
  moneda          VARCHAR(5) DEFAULT 'COP',
  referencia_ext  VARCHAR(150),
  pasarela        VARCHAR(80),
  respuesta_raw   TEXT,
  creado_at       DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (pedido_id) REFERENCES pedidos(id)
);

CREATE TABLE devoluciones (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  pedido_id   INT NOT NULL,
  motivo      ENUM('producto_defectuoso','no_corresponde','arrepentimiento','otro'),
  descripcion TEXT,
  estado      ENUM('solicitada','aprobada','rechazada','completada') DEFAULT 'solicitada',
  monto_reemb DECIMAL(14,2),
  creado_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (pedido_id) REFERENCES pedidos(id)
);

-- ─────────────────────────────────────────
-- DOMINIO LOGÍSTICA
-- ─────────────────────────────────────────
CREATE TABLE bodegas (
  id        INT AUTO_INCREMENT PRIMARY KEY,
  nombre    VARCHAR(100) NOT NULL,
  ciudad    VARCHAR(100),
  direccion VARCHAR(200),
  activa    TINYINT(1) DEFAULT 1
);

CREATE TABLE stock_bodega (
  bodega_id   INT NOT NULL,
  producto_id INT NOT NULL,
  cantidad    INT DEFAULT 0,
  PRIMARY KEY (bodega_id, producto_id),
  FOREIGN KEY (bodega_id)   REFERENCES bodegas(id),
  FOREIGN KEY (producto_id) REFERENCES productos(id)
);

CREATE TABLE transportistas (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  nombre      VARCHAR(100) NOT NULL,
  codigo      VARCHAR(30) UNIQUE,
  url_tracking VARCHAR(300),
  activo      TINYINT(1) DEFAULT 1
);

CREATE TABLE envios (
  id                INT AUTO_INCREMENT PRIMARY KEY,
  pedido_id         INT UNIQUE NOT NULL,
  transportista_id  INT,
  bodega_origen_id  INT,
  numero_guia       VARCHAR(100),
  estado            ENUM('pendiente','en_bodega','recogido','en_transito',
                         'en_ciudad','en_reparto','entregado','fallido') DEFAULT 'pendiente',
  direccion_destino VARCHAR(300),
  ciudad_destino    VARCHAR(100),
  fecha_estimada    DATE,
  fecha_entregado   DATETIME,
  intentos_entrega  INT DEFAULT 0,
  creado_at         DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at        DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (pedido_id)        REFERENCES pedidos(id),
  FOREIGN KEY (transportista_id) REFERENCES transportistas(id),
  FOREIGN KEY (bodega_origen_id) REFERENCES bodegas(id)
);

CREATE TABLE tracking_eventos (
  id          BIGINT AUTO_INCREMENT PRIMARY KEY,
  envio_id    INT NOT NULL,
  estado      VARCHAR(80),
  descripcion TEXT,
  ciudad      VARCHAR(100),
  latitud     DECIMAL(10,7),
  longitud    DECIMAL(10,7),
  creado_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (envio_id) REFERENCES envios(id)
);

-- ─────────────────────────────────────────
-- OUTBOX — Captura de cambios (CDC)
-- ─────────────────────────────────────────
CREATE TABLE outbox_events (
  id          BIGINT AUTO_INCREMENT PRIMARY KEY,
  dominio     ENUM('usuarios','catalogo','pedidos','logistica') NOT NULL,
  entidad     VARCHAR(80) NOT NULL,
  entidad_id  INT NOT NULL,
  operacion   ENUM('INSERT','UPDATE','DELETE') NOT NULL,
  payload     JSON,
  procesado   TINYINT(1) DEFAULT 0,
  intentos    INT DEFAULT 0,
  creado_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
  procesado_at DATETIME,
  INDEX idx_pendientes (procesado, dominio),
  INDEX idx_entidad    (entidad, entidad_id)
);

-- ─────────────────────────────────────────
-- TRIGGERS CDC — cada tabla escribe al outbox
-- ─────────────────────────────────────────
DELIMITER $$

-- usuarios
CREATE TRIGGER trg_usu_ins AFTER INSERT ON usuarios FOR EACH ROW
BEGIN INSERT INTO outbox_events(dominio,entidad,entidad_id,operacion,payload) VALUES('usuarios','usuarios',NEW.id,'INSERT',
  JSON_OBJECT('id',NEW.id,'nombre',NEW.nombre,'apellido',NEW.apellido,'email',NEW.email,'telefono',NEW.telefono,'activo',NEW.activo,'creado_at',NEW.creado_at)); END$$

CREATE TRIGGER trg_usu_upd AFTER UPDATE ON usuarios FOR EACH ROW
BEGIN INSERT INTO outbox_events(dominio,entidad,entidad_id,operacion,payload) VALUES('usuarios','usuarios',NEW.id,'UPDATE',
  JSON_OBJECT('id',NEW.id,'nombre',NEW.nombre,'apellido',NEW.apellido,'email',NEW.email,'activo',NEW.activo)); END$$

-- productos
CREATE TRIGGER trg_prod_ins AFTER INSERT ON productos FOR EACH ROW
BEGIN INSERT INTO outbox_events(dominio,entidad,entidad_id,operacion,payload) VALUES('catalogo','productos',NEW.id,'INSERT',
  JSON_OBJECT('id',NEW.id,'sku',NEW.sku,'nombre',NEW.nombre,'precio',NEW.precio,'stock',NEW.stock,'categoria_id',NEW.categoria_id,'marca_id',NEW.marca_id,'activo',NEW.activo,'destacado',NEW.destacado)); END$$

CREATE TRIGGER trg_prod_upd AFTER UPDATE ON productos FOR EACH ROW
BEGIN INSERT INTO outbox_events(dominio,entidad,entidad_id,operacion,payload) VALUES('catalogo','productos',NEW.id,'UPDATE',
  JSON_OBJECT('id',NEW.id,'precio',NEW.precio,'stock',NEW.stock,'activo',NEW.activo,'destacado',NEW.destacado)); END$$

-- pedidos
CREATE TRIGGER trg_ped_ins AFTER INSERT ON pedidos FOR EACH ROW
BEGIN INSERT INTO outbox_events(dominio,entidad,entidad_id,operacion,payload) VALUES('pedidos','pedidos',NEW.id,'INSERT',
  JSON_OBJECT('id',NEW.id,'usuario_id',NEW.usuario_id,'estado',NEW.estado,'total',NEW.total,'creado_at',NEW.creado_at)); END$$

CREATE TRIGGER trg_ped_upd AFTER UPDATE ON pedidos FOR EACH ROW
BEGIN INSERT INTO outbox_events(dominio,entidad,entidad_id,operacion,payload) VALUES('pedidos','pedidos',NEW.id,'UPDATE',
  JSON_OBJECT('id',NEW.id,'estado',NEW.estado,'total',NEW.total)); END$$

-- envios
CREATE TRIGGER trg_env_ins AFTER INSERT ON envios FOR EACH ROW
BEGIN INSERT INTO outbox_events(dominio,entidad,entidad_id,operacion,payload) VALUES('logistica','envios',NEW.id,'INSERT',
  JSON_OBJECT('id',NEW.id,'pedido_id',NEW.pedido_id,'estado',NEW.estado,'numero_guia',NEW.numero_guia,'ciudad_destino',NEW.ciudad_destino)); END$$

CREATE TRIGGER trg_env_upd AFTER UPDATE ON envios FOR EACH ROW
BEGIN INSERT INTO outbox_events(dominio,entidad,entidad_id,operacion,payload) VALUES('logistica','envios',NEW.id,'UPDATE',
  JSON_OBJECT('id',NEW.id,'estado',NEW.estado,'numero_guia',NEW.numero_guia,'fecha_entregado',NEW.fecha_entregado,'intentos_entrega',NEW.intentos_entrega)); END$$

-- tracking
CREATE TRIGGER trg_trk_ins AFTER INSERT ON tracking_eventos FOR EACH ROW
BEGIN INSERT INTO outbox_events(dominio,entidad,entidad_id,operacion,payload) VALUES('logistica','tracking',NEW.envio_id,'INSERT',
  JSON_OBJECT('id',NEW.id,'envio_id',NEW.envio_id,'estado',NEW.estado,'descripcion',NEW.descripcion,'ciudad',NEW.ciudad,'creado_at',NEW.creado_at)); END$$

DELIMITER ;