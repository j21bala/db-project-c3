-- ═══════════════════════════════════════════════════════════════
-- 02-data.sql — Datos completos tienda_monolito
-- Incluye: datos base del taller + ~10,000 registros por dominio
-- ═══════════════════════════════════════════════════════════════
USE tienda_monolito;

SET foreign_key_checks = 0;
SET unique_checks = 0;
SET autocommit = 0;

-- ─────────────────────────────────────────────────────────────
-- DATOS BASE — Catálogo estático
-- ─────────────────────────────────────────────────────────────
INSERT INTO categorias (id, nombre, slug, padre_id) VALUES
(1,'Electrónica','electronica',NULL),
(2,'Smartphones','smartphones',1),
(3,'Laptops','laptops',1),
(4,'Audio','audio',1),
(5,'Ropa','ropa',NULL),
(6,'Ropa Hombre','ropa-hombre',5),
(7,'Ropa Mujer','ropa-mujer',5),
(8,'Deportes','deportes',NULL),
(9,'Suplementos','suplementos',8),
(10,'Equipamiento','equipamiento',8);

INSERT INTO marcas (id, nombre, pais, website) VALUES
(1,'Samsung','Corea del Sur','samsung.com'),
(2,'Apple','Estados Unidos','apple.com'),
(3,'Dell','Estados Unidos','dell.com'),
(4,'Sony','Japón','sony.com'),
(5,'Nike','Estados Unidos','nike.com'),
(6,'Adidas','Alemania','adidas.com'),
(7,'Motorola','Estados Unidos','motorola.com');

-- ─────────────────────────────────────────────────────────────
-- DATOS BASE — Usuarios originales del taller
-- ─────────────────────────────────────────────────────────────
INSERT INTO usuarios (nombre, apellido, email, telefono, fecha_nacimiento) VALUES
('Carlos','Rodríguez','carlos@email.com','+57 300 111 2222','1990-05-14'),
('Ana','Martínez','ana.m@email.com','+57 310 333 4444','1988-11-22'),
('Luis','Herrera','luish@email.com','+57 320 555 6666','1995-03-08'),
('María','González','maria.g@email.com','+57 315 777 8888','1992-07-30'),
('Pedro','Vargas','pedro.v@email.com','+57 325 999 0000','1985-12-01'),
('Sofía','Jiménez','sofia.j@email.com','+57 301 222 3333','1997-09-15'),
('Diego','López','diego.l@email.com','+57 311 444 5555','1993-02-20'),
('Valeria','Castro','valeria.c@email.com','+57 321 666 7777','1991-06-10');

INSERT INTO direcciones (usuario_id, alias, calle, barrio, ciudad, departamento, es_principal) VALUES
(1,'Casa','Calle 100 #15-20','Usaquén','Bogotá','Cundinamarca',1),
(1,'Oficina','Cra 7 #32-16','Centro','Bogotá','Cundinamarca',0),
(2,'Casa','Av. El Poblado #43-50','Laureles','Medellín','Antioquia',1),
(3,'Casa','Cra. 5 #12-34','San Fernando','Cali','Valle del Cauca',1),
(4,'Casa','Calle 72 #8-45','Chapinero','Bogotá','Cundinamarca',1),
(5,'Casa','Av. Santander #25-10','Centro','Manizales','Caldas',1),
(6,'Casa','Calle 5 #35-70','El Prado','Barranquilla','Atlántico',1),
(7,'Casa','Cra 27 #15-80','Cabecera','Bucaramanga','Santander',1),
(8,'Casa','Calle 12 #40-22','La Esmeralda','Ibagué','Tolima',1);

INSERT INTO preferencias_usuario (usuario_id, idioma, moneda, notif_email) VALUES
(1,'es','COP',1),(2,'es','COP',1),(3,'es','COP',0),
(4,'es','COP',1),(5,'es','COP',1),(6,'es','USD',1),
(7,'es','COP',0),(8,'es','COP',1);

INSERT INTO sesiones (usuario_id, token, ip, expira_at) VALUES
(1,'tok_abc123','190.24.1.1',DATE_ADD(NOW(), INTERVAL 7 DAY)),
(2,'tok_def456','181.53.2.2',DATE_ADD(NOW(), INTERVAL 7 DAY)),
(3,'tok_ghi789','200.21.3.3',DATE_ADD(NOW(), INTERVAL 7 DAY));

-- ─────────────────────────────────────────────────────────────
-- DATOS BASE — Productos originales del taller
-- ─────────────────────────────────────────────────────────────
INSERT INTO productos (sku, nombre, descripcion, precio, precio_costo, categoria_id, marca_id, stock, peso_kg, destacado) VALUES
('SMSG-S24-BLK','Samsung Galaxy S24','Smartphone flagship IA integrada 6.2" 8GB/256GB',3200000,1900000,2,1,50,0.167,1),
('SMSG-S24U-TIT','Samsung Galaxy S24 Ultra','S-Pen 12GB/512GB cámara 200MP titanio',6800000,4200000,2,1,25,0.232,1),
('APPL-IP15P-BLK','iPhone 15 Pro','Titanio A17 Pro 6.1" 256GB',4500000,2800000,2,2,30,0.187,1),
('APPL-IP15PM-NAT','iPhone 15 Pro Max','Titanio A17 Pro 6.7" 512GB',5800000,3600000,2,2,15,0.221,1),
('DELL-XPS15-32','Dell XPS 15','Intel i9 32GB RAM 1TB SSD OLED 4K',8900000,5500000,3,3,12,1.860,1),
('DELL-XPS13-16','Dell XPS 13 Plus','Intel i7 16GB 512GB OLED',6200000,3800000,3,3,20,1.235,0),
('SONY-WH1000XM5','Sony WH-1000XM5','Auriculares ANC Premium Bluetooth',1400000,800000,4,4,80,0.250,1),
('SONY-WF1000XM5','Sony WF-1000XM5','Earbuds True Wireless ANC',900000,520000,4,4,60,0.055,0),
('MOTO-G84-AZL','Motorola G84','6.5" pOLED 120Hz 256GB batería 5000mAh',980000,590000,2,7,90,0.167,0),
('NIKE-AM270-42','Nike Air Max 270','Zapatillas Running talla 42',420000,220000,8,5,45,0.680,0),
('ADID-UB22-BLK','Adidas Ultraboost 22','Running Premium amortiguación BOOST',580000,310000,8,6,30,0.720,1);

INSERT INTO variantes_producto (producto_id, sku_variante, color, stock) VALUES
(1,'SMSG-S24-WHT','Blanco Mármol',20),(1,'SMSG-S24-VLT','Violeta',15),
(3,'APPL-IP15P-WHT','Blanco Natural',12),(3,'APPL-IP15P-BLU','Azul',8),
(10,'NIKE-AM270-41','Talla 41',10),(10,'NIKE-AM270-43','Talla 43',15),(10,'NIKE-AM270-44','Talla 44',8);

INSERT INTO atributos_producto (producto_id, clave, valor) VALUES
(1,'ram','8GB'),(1,'almacenamiento','256GB'),(1,'pantalla','6.2 pulgadas'),(1,'bateria','4000mAh'),
(3,'chip','A17 Pro'),(3,'camara','48MP + 12MP + 12MP'),(3,'video','4K 60fps'),
(5,'procesador','Intel Core i9-13900H'),(5,'pantalla','15.6 OLED 3.5K 60Hz'),(5,'gpu','NVIDIA RTX 4070'),
(7,'autonomia','30 horas'),(7,'anc','Adaptativo'),(7,'conexion','Bluetooth 5.2');

INSERT INTO imagenes_producto (producto_id, url, alt_text, es_principal) VALUES
(1,'https://cdn.tienda.co/smsg-s24-01.jpg','Samsung Galaxy S24 frente',1),
(1,'https://cdn.tienda.co/smsg-s24-02.jpg','Samsung Galaxy S24 trasera',0),
(3,'https://cdn.tienda.co/iphone15p-01.jpg','iPhone 15 Pro titanio',1),
(5,'https://cdn.tienda.co/xps15-01.jpg','Dell XPS 15 abierta',1),
(7,'https://cdn.tienda.co/wh1000xm5-01.jpg','Sony WH-1000XM5',1);

INSERT INTO resenas (producto_id, usuario_id, calificacion, titulo, comentario, verificado) VALUES
(1,2,5,'Increíble teléfono','La cámara con IA es espectacular, batería dura todo el día',1),
(1,4,4,'Muy bueno','Excelente rendimiento, un poco caliente en carga rápida',1),
(3,1,5,'El mejor iPhone','Titanio se siente premium, fotos profesionales desde el bolsillo',1),
(5,3,5,'Laptop de ensueño','La pantalla OLED es impresionante para diseño 3D y video',1),
(7,5,5,'Los mejores audífonos','ANC perfecto para home office, llamadas muy claras',1),
(10,6,4,'Cómodas para correr','Buen soporte, talla un poco grande, pedir media talla menos',0);

INSERT INTO cupones (codigo, tipo, valor, minimo_compra, maximo_usos) VALUES
('BIENVENIDO10','porcentaje',10,100000,500),
('NAVIDAD20','porcentaje',20,300000,200),
('DESCUENTO50K','monto_fijo',50000,200000,100);

INSERT INTO pedidos (usuario_id, estado, subtotal, impuestos, costo_envio, total, creado_at) VALUES
(1,'entregado',3200000,608000,0,3808000,'2024-01-15 10:30:00'),
(2,'entregado',4500000,855000,0,5355000,'2024-01-18 14:00:00'),
(3,'despachado',8900000,1691000,15000,10606000,'2024-01-20 09:15:00'),
(4,'pagado',980000,186200,8000,1174200,'2024-01-21 16:45:00'),
(1,'confirmado',6800000,1292000,0,8092000,'2024-01-22 11:00:00'),
(5,'en_preparacion',1400000,266000,12000,1678000,'2024-01-23 08:00:00'),
(6,'confirmado',900000,171000,8000,1079000,'2024-01-24 15:30:00'),
(7,'pagado',580000,110200,9000,699200,'2024-01-25 12:00:00'),
(8,'borrador',420000,79800,8000,507800,'2024-01-26 09:45:00');

INSERT INTO items_pedido (pedido_id, producto_id, cantidad, precio_unit, sku_snapshot, nombre_snapshot) VALUES
(1,1,1,3200000,'SMSG-S24-BLK','Samsung Galaxy S24'),
(2,3,1,4500000,'APPL-IP15P-BLK','iPhone 15 Pro'),
(3,5,1,8900000,'DELL-XPS15-32','Dell XPS 15'),
(4,9,1,980000,'MOTO-G84-AZL','Motorola G84'),
(5,2,1,6800000,'SMSG-S24U-TIT','Samsung Galaxy S24 Ultra'),
(6,7,1,1400000,'SONY-WH1000XM5','Sony WH-1000XM5'),
(7,8,1,900000,'SONY-WF1000XM5','Sony WF-1000XM5'),
(8,11,1,580000,'ADID-UB22-BLK','Adidas Ultraboost 22'),
(9,10,1,420000,'NIKE-AM270-42','Nike Air Max 270');

INSERT INTO pagos (pedido_id, metodo, estado, monto, moneda, referencia_ext, pasarela) VALUES
(1,'pse','aprobado',3808000,'COP','PSE-001-2024','Redeban'),
(2,'tarjeta_credito','aprobado',5355000,'COP','TC-002-2024','Credibanco'),
(3,'pse','aprobado',10606000,'COP','PSE-003-2024','Redeban'),
(4,'nequi','aprobado',1174200,'COP','NEQ-004-2024','Nequi'),
(5,'tarjeta_credito','aprobado',8092000,'COP','TC-005-2024','Credibanco'),
(6,'daviplata','aprobado',1678000,'COP','DAV-006-2024','Davivienda'),
(7,'pse','aprobado',1079000,'COP','PSE-007-2024','Redeban'),
(8,'tarjeta_debito','aprobado',699200,'COP','TD-008-2024','Bancolombia'),
(9,'efecty','pendiente',507800,'COP','EFE-009-2024','Efecty');

INSERT INTO bodegas (nombre, ciudad, direccion) VALUES
('Bodega Bogotá Principal','Bogotá','Calle 13 #68B-10, Zona Industrial'),
('Bodega Medellín','Medellín','Cra 48 #19-100, Guayabal'),
('Bodega Cali','Cali','Av. 3N #54-20, Zona Industrial'),
('Bodega Barranquilla','Barranquilla','Cra 38 #72B-20, Barranquilla');

INSERT INTO stock_bodega (bodega_id, producto_id, cantidad) VALUES
(1,1,25),(1,2,10),(1,3,15),(1,5,8),(1,7,40),
(2,1,15),(2,4,8),(2,7,20),(2,9,45),
(3,8,30),(3,10,25),(3,11,15),
(4,9,45),(4,10,20),(4,7,20);

INSERT INTO transportistas (nombre, codigo, url_tracking) VALUES
('Servientrega','SRVI','servientrega.com.co/tracking'),
('Interrapidísimo','IRPI','interrapidisimo.com.co/track'),
('Coordinadora','CORD','coordinadora.com/rastreo'),
('TCC','TCC_','tcc.com.co/seguimiento');

INSERT INTO envios (pedido_id, transportista_id, bodega_origen_id, numero_guia, estado, direccion_destino, ciudad_destino, fecha_estimada) VALUES
(1,1,1,'SRVI-001-2024','entregado','Calle 100 #15-20','Bogotá','2024-01-17'),
(2,2,2,'IRPI-002-2024','entregado','Av. El Poblado #43-50','Medellín','2024-01-21'),
(3,3,1,'CORD-003-2024','en_transito','Cra. 5 #12-34','Cali','2024-01-24'),
(4,1,1,'SRVI-004-2024','en_reparto','Calle 72 #8-45','Bogotá','2024-01-23'),
(5,4,1,'TCC-005-2024','en_bodega','Calle 100 #15-20','Bogotá','2024-01-26'),
(6,2,2,'IRPI-006-2024','recogido','Av. Santander #25-10','Manizales','2024-01-26');

INSERT INTO tracking_eventos (envio_id, estado, descripcion, ciudad) VALUES
(1,'recibido','Paquete recibido en bodega','Bogotá'),
(1,'en_transito','Paquete en camino','Bogotá'),
(1,'entregado','Entregado al destinatario','Bogotá'),
(2,'recibido','Paquete recibido en bodega','Medellín'),
(2,'entregado','Entregado al destinatario','Medellín'),
(3,'recibido','Recibido en bodega Bogotá','Bogotá'),
(3,'en_transito','Salida hacia Cali','Bogotá'),
(3,'en_ciudad','Llegó a Cali','Cali'),
(4,'recibido','Recibido en bodega','Bogotá'),
(4,'en_reparto','Asignado a mensajero','Bogotá');

COMMIT;

-- ═══════════════════════════════════════════════════════════════
-- TABLAS TEMPORALES DE APOYO
-- ═══════════════════════════════════════════════════════════════
DROP TEMPORARY TABLE IF EXISTS tmp_nombres;
CREATE TEMPORARY TABLE tmp_nombres (id INT AUTO_INCREMENT PRIMARY KEY, val VARCHAR(100));
INSERT INTO tmp_nombres (val) VALUES
('Santiago'),('Valentina'),('Sebastián'),('Camila'),('Mateo'),
('Isabella'),('Samuel'),('Daniela'),('Nicolás'),('Mariana'),
('Alejandro'),('Gabriela'),('Andrés'),('Juliana'),('Felipe'),
('Natalia'),('Juan'),('Paola'),('David'),('Laura'),
('Tomás'),('Luciana'),('Martín'),('Sofía'),('Diego'),
('Valeria'),('Carlos'),('Ana'),('Luis'),('María'),
('Pedro'),('Catalina'),('Jorge'),('Mónica'),('Rafael'),
('Andrea'),('Héctor'),('Patricia'),('Ernesto'),('Gloria'),
('Fernando'),('Claudia'),('Rodrigo'),('Diana'),('Mauricio'),
('Ángela'),('Gustavo'),('Liliana'),('Jaime'),('Esperanza'),
('Cristian'),('Marcela'),('Giovanny'),('Adriana'),('Fabio'),
('Viviana'),('Hernán'),('Sandra'),('Óscar'),('Carolina');

DROP TEMPORARY TABLE IF EXISTS tmp_apellidos;
CREATE TEMPORARY TABLE tmp_apellidos (id INT AUTO_INCREMENT PRIMARY KEY, val VARCHAR(100));
INSERT INTO tmp_apellidos (val) VALUES
('García'),('Rodríguez'),('Martínez'),('López'),('González'),
('Hernández'),('Pérez'),('Sánchez'),('Ramírez'),('Torres'),
('Flores'),('Rivera'),('Gómez'),('Díaz'),('Cruz'),
('Morales'),('Reyes'),('Ortiz'),('Vargas'),('Castillo'),
('Jiménez'),('Moreno'),('Romero'),('Herrera'),('Medina'),
('Aguilar'),('Castro'),('Ramos'),('Rojas'),('Gutiérrez'),
('Mendoza'),('Álvarez'),('Núñez'),('Ruiz'),('Salazar'),
('Suárez'),('Molina'),('Vega'),('Ríos'),('Parra'),
('Guerrero'),('Delgado'),('Muñoz'),('Peña'),('Lozano'),
('Cárdenas'),('Bermúdez'),('Ospina'),('Quintero'),('Escobar'),
('Zapata'),('Giraldo'),('Arango'),('Henao'),('Acosta'),
('Montoya'),('Cifuentes'),('Castaño'),('Velásquez'),('Pineda');

DROP TEMPORARY TABLE IF EXISTS tmp_ciudades;
CREATE TEMPORARY TABLE tmp_ciudades (id INT AUTO_INCREMENT PRIMARY KEY, ciudad VARCHAR(100), departamento VARCHAR(100));
INSERT INTO tmp_ciudades (ciudad, departamento) VALUES
('Bogotá','Cundinamarca'),('Medellín','Antioquia'),('Cali','Valle del Cauca'),
('Barranquilla','Atlántico'),('Cartagena','Bolívar'),('Bucaramanga','Santander'),
('Pereira','Risaralda'),('Manizales','Caldas'),('Ibagué','Tolima'),
('Santa Marta','Magdalena'),('Cúcuta','Norte de Santander'),('Villavicencio','Meta'),
('Pasto','Nariño'),('Montería','Córdoba'),('Armenia','Quindío'),
('Neiva','Huila'),('Popayán','Cauca'),('Tunja','Boyacá'),
('Valledupar','Cesar'),('Sincelejo','Sucre'),('Riohacha','La Guajira'),
('Florencia','Caquetá'),('Mocoa','Putumayo'),('Arauca','Arauca'),
('Yopal','Casanare'),('Quibdó','Chocó'),('Leticia','Amazonas'),
('Palmira','Valle del Cauca'),('Bello','Antioquia'),('Soledad','Atlántico');

DROP TEMPORARY TABLE IF EXISTS tmp_barrios;
CREATE TEMPORARY TABLE tmp_barrios (id INT AUTO_INCREMENT PRIMARY KEY, val VARCHAR(100));
INSERT INTO tmp_barrios (val) VALUES
('Centro'),('El Poblado'),('Laureles'),('Envigado'),('Sabaneta'),
('Chapinero'),('Usaquén'),('Suba'),('Kennedy'),('Bosa'),
('Fontibón'),('Engativá'),('Teusaquillo'),('Puente Aranda'),('Antonio Nariño'),
('Manga'),('Bocagrande'),('Getsemaní'),('Cabrero'),('Pie de la Popa'),
('El Prado'),('Riomar'),('Villa del Rosario'),('Altos del Prado'),('Ciudad Jardín'),
('San Fernando'),('Granada'),('Santa Mónica'),('Versalles'),('Meléndez'),
('Cabecera'),('La Ciudadela'),('García Rovira'),('Mutis'),('Esmeralda'),
('La Flora'),('Ricaurte'),('Palermo'),('Centenario'),('La Merced'),
('El Restrepo'),('Normandía'),('Quirigua'),('Tintal'),('Castilla'),
('Ciudad Bolívar'),('Usme'),('San Cristóbal'),('Rafael Uribe'),('Tunjuelito');

DROP TEMPORARY TABLE IF EXISTS tmp_calles;
CREATE TEMPORARY TABLE tmp_calles (id INT AUTO_INCREMENT PRIMARY KEY, val VARCHAR(50));
INSERT INTO tmp_calles (val) VALUES
('Calle'),('Carrera'),('Avenida'),('Transversal'),('Diagonal'),
('Autopista'),('Boulevard'),('Pasaje'),('Vía');

DROP TEMPORARY TABLE IF EXISTS tmp_prod_base;
CREATE TEMPORARY TABLE tmp_prod_base (id INT AUTO_INCREMENT PRIMARY KEY, nombre VARCHAR(200), categoria_id INT, marca_id INT, precio_base DECIMAL(14,2));
INSERT INTO tmp_prod_base (nombre, categoria_id, marca_id, precio_base) VALUES
('Smartphone',2,1,2500000),('Tablet',2,2,1800000),
('Laptop Gaming',3,3,4500000),('Laptop Ultrabook',3,3,3200000),
('Audífonos Inalámbricos',4,4,800000),('Parlante Bluetooth',4,4,450000),
('Smartwatch',2,1,1200000),('Cámara Digital',4,4,2800000),
('Monitor',3,3,1600000),('Teclado Mecánico',3,3,380000),
('Mouse Gamer',3,3,220000),('Webcam HD',3,3,280000),
('Disco Duro Externo',3,3,320000),('Memoria USB',3,3,85000),
('Cargador Inalámbrico',2,1,180000),('Funda Protectora',2,2,120000),
('Camiseta Deportiva',6,5,95000),('Pantalón Running',6,5,185000),
('Zapatillas Trail',8,5,380000),('Chaqueta Cortavientos',6,6,290000),
('Medias Compresión',8,5,65000),('Gorra Running',8,5,75000),
('Maletín Deportivo',8,6,220000),('Botella Térmica',8,5,95000),
('Proteína Whey',9,5,280000),('Barra Energética',9,5,12000),
('Cuerda de Saltar',10,6,45000),('Mancuernas Par',10,6,180000),
('Banda Elástica',10,5,55000),('Colchoneta Yoga',10,6,120000),
('Camiseta Básica',7,5,75000),('Vestido Casual',7,6,185000),
('Leggins Deportivos',7,5,130000),('Blusa Estampada',7,6,95000),
('Short Deportivo',6,5,85000),('Sudadera',6,6,210000),
('Mochila Escolar',8,6,180000),('Termo Acero',8,5,75000),
('Creatina',9,5,180000),('BCAA Aminoácidos',9,5,150000);

DROP TEMPORARY TABLE IF EXISTS tmp_comentarios;
CREATE TEMPORARY TABLE tmp_comentarios (id INT AUTO_INCREMENT PRIMARY KEY, val TEXT);
INSERT INTO tmp_comentarios (val) VALUES
('El producto llegó en perfectas condiciones y funciona muy bien.'),
('Buena calidad por el precio, lo recomiendo sin dudarlo.'),
('Envío rápido, producto tal como se describe en la ficha.'),
('Superó mis expectativas, muy contento con la compra.'),
('La calidad es aceptable pero podría ser mejor para el precio.'),
('Precio justo para lo que ofrece, cumple su función.'),
('Compra segura, producto original y bien empacado.'),
('Ya es mi segunda compra, siempre quedo muy satisfecho.'),
('El empaque llegó en buen estado, producto funcionando perfecto.'),
('Excelente relación calidad-precio, lo recomiendo.'),
('Llegó antes de lo esperado, muy buen servicio.'),
('El producto es exactamente como se muestra en las fotos.'),
('Muy buen producto, la construcción es sólida y duradera.'),
('Fácil de usar, las instrucciones son claras y completas.'),
('Estoy muy satisfecho con la compra, repetiré sin duda.'),
('El color es idéntico al de las fotos, muy bien.'),
('Funciona perfectamente desde el primer día de uso.'),
('Buena compra, el vendedor respondió rápido mis preguntas.'),
('El tamaño es el indicado, queda perfecto para mi uso.'),
('Recomendado al 100%, no defraudó en nada.');

DROP TEMPORARY TABLE IF EXISTS tmp_titulos_resena;
CREATE TEMPORARY TABLE tmp_titulos_resena (id INT AUTO_INCREMENT PRIMARY KEY, cal TINYINT, val VARCHAR(150));
INSERT INTO tmp_titulos_resena (cal, val) VALUES
(1,'Muy decepcionante, no lo recomiendo'),(1,'Pésima calidad'),(1,'Llegó dañado'),
(2,'Regular, esperaba más'),(2,'Podría mejorar bastante'),(2,'No cumplió expectativas'),
(3,'Cumple lo básico'),(3,'Aceptable para el precio'),(3,'Ni bueno ni malo'),
(4,'Buen producto'),(4,'Muy bueno, lo recomiendo'),(4,'Buena relación calidad-precio'),
(5,'Excelente, lo recomiendo'),(5,'Increíble producto'),(5,'Superó todas mis expectativas');

COMMIT;

-- ═══════════════════════════════════════════════════════════════
-- PROCEDIMIENTO: USUARIOS MASIVOS
-- ═══════════════════════════════════════════════════════════════
DROP PROCEDURE IF EXISTS gen_usuarios;
DELIMITER $$
CREATE PROCEDURE gen_usuarios(IN total INT)
BEGIN
  DECLARE i INT DEFAULT 0;
  DECLARE v_nom VARCHAR(100);
  DECLARE v_ape VARCHAR(100);
  DECLARE v_ciu VARCHAR(100);
  DECLARE v_dep VARCHAR(100);
  DECLARE v_bar VARCHAR(100);
  DECLARE v_cal VARCHAR(50);
  DECLARE v_uid INT;
  DECLARE v_n1 INT;
  DECLARE v_n2 INT;
  DECLARE v_n3 INT;
  DECLARE v_dominio VARCHAR(20);

  WHILE i < total DO
    SELECT val INTO v_nom FROM tmp_nombres ORDER BY RAND() LIMIT 1;
    SELECT val INTO v_ape FROM tmp_apellidos ORDER BY RAND() LIMIT 1;
    SELECT ciudad, departamento INTO v_ciu, v_dep FROM tmp_ciudades ORDER BY RAND() LIMIT 1;
    SELECT val INTO v_bar FROM tmp_barrios ORDER BY RAND() LIMIT 1;
    SELECT val INTO v_cal FROM tmp_calles ORDER BY RAND() LIMIT 1;
    SET v_n1 = FLOOR(RAND()*150)+1;
    SET v_n2 = FLOOR(RAND()*99)+1;
    SET v_n3 = FLOOR(RAND()*99)+1;
    SET v_dominio = ELT(FLOOR(RAND()*5)+1,'gmail.com','hotmail.com','yahoo.com','outlook.com','mail.com');

    INSERT IGNORE INTO usuarios (nombre, apellido, email, telefono, fecha_nacimiento, activo)
    VALUES (
      v_nom,
      v_ape,
      LOWER(CONCAT(
        REGEXP_REPLACE(v_nom, '[^a-zA-Z]', ''), '.',
        REGEXP_REPLACE(v_ape, '[^a-zA-Z]', ''),
        FLOOR(RAND()*90000)+10000, '@', v_dominio
      )),
      CONCAT('+57 3', FLOOR(RAND()*9), FLOOR(RAND()*9), ' ',
             LPAD(FLOOR(RAND()*999),3,'0'), ' ',
             LPAD(FLOOR(RAND()*9999),4,'0')),
      DATE_SUB(CURDATE(), INTERVAL (FLOOR(RAND()*40)+18) YEAR),
      IF(RAND() > 0.05, 1, 0)
    );

    SET v_uid = LAST_INSERT_ID();

    IF v_uid > 0 THEN
      INSERT INTO direcciones (usuario_id, alias, calle, barrio, ciudad, departamento, es_principal)
      VALUES (v_uid, 'Casa',
        CONCAT(v_cal, ' ', v_n1, ' #', v_n2, '-', v_n3),
        v_bar, v_ciu, v_dep, 1);

      IF RAND() < 0.35 THEN
        INSERT INTO direcciones (usuario_id, alias, calle, barrio, ciudad, departamento, es_principal)
        VALUES (v_uid,
          ELT(FLOOR(RAND()*3)+1,'Oficina','Trabajo','Familiar'),
          CONCAT(v_cal, ' ', FLOOR(RAND()*150)+1, ' #', FLOOR(RAND()*99)+1, '-', FLOOR(RAND()*99)+1),
          (SELECT val FROM tmp_barrios ORDER BY RAND() LIMIT 1),
          v_ciu, v_dep, 0);
      END IF;

      INSERT IGNORE INTO preferencias_usuario (usuario_id, idioma, moneda, notif_email, notif_sms)
      VALUES (v_uid, 'es',
        IF(RAND() < 0.94, 'COP', 'USD'),
        IF(RAND() < 0.70, 1, 0),
        IF(RAND() < 0.25, 1, 0));
    END IF;

    SET i = i + 1;
    IF i MOD 500 = 0 THEN COMMIT; END IF;
  END WHILE;
  COMMIT;
END$$
DELIMITER ;

-- ═══════════════════════════════════════════════════════════════
-- PROCEDIMIENTO: PRODUCTOS MASIVOS
-- ═══════════════════════════════════════════════════════════════
DROP PROCEDURE IF EXISTS gen_productos;
DELIMITER $$
CREATE PROCEDURE gen_productos(IN total INT)
BEGIN
  DECLARE i INT DEFAULT 0;
  DECLARE v_nom VARCHAR(200);
  DECLARE v_cat INT;
  DECLARE v_mrc INT;
  DECLARE v_base DECIMAL(14,2);
  DECLARE v_precio DECIMAL(14,2);
  DECLARE v_sku VARCHAR(60);
  DECLARE v_pid INT;
  DECLARE v_sufijo VARCHAR(20);
  DECLARE v_color VARCHAR(30);
  DECLARE v_garantia VARCHAR(20);
  DECLARE v_origen VARCHAR(30);

  WHILE i < total DO
    SELECT nombre, categoria_id, marca_id, precio_base
    INTO v_nom, v_cat, v_mrc, v_base
    FROM tmp_prod_base ORDER BY RAND() LIMIT 1;

    SET v_precio = ROUND((v_base * (0.6 + RAND() * 0.9)) / 1000) * 1000;
    SET v_sufijo = ELT(FLOOR(RAND()*6)+1,'Pro','Plus','Max','Ultra','Lite','SE');
    SET v_sku = CONCAT('GEN-', LPAD(i+1,6,'0'), '-', LPAD(FLOOR(RAND()*9999),4,'0'));
    SET v_color = ELT(FLOOR(RAND()*8)+1,'Negro','Blanco','Azul','Rojo','Verde','Gris','Plateado','Dorado');
    SET v_garantia = ELT(FLOOR(RAND()*4)+1,'6 meses','1 año','2 años','3 años');
    SET v_origen = ELT(FLOOR(RAND()*5)+1,'China','Corea del Sur','Estados Unidos','Japón','Alemania');

    INSERT IGNORE INTO productos
      (sku, nombre, descripcion, precio, precio_costo, categoria_id, marca_id,
       stock, stock_minimo, peso_kg, activo, destacado)
    VALUES (
      v_sku,
      CONCAT(v_nom, ' ', v_sufijo),
      CONCAT('Producto ', v_nom, ' ', v_sufijo, '. ',
             ELT(FLOOR(RAND()*4)+1,
               'Garantía incluida. Envío a todo Colombia.',
               'Producto original. Stock disponible.',
               'Alta durabilidad y rendimiento.',
               'Diseño ergonómico y materiales premium.')),
      v_precio,
      ROUND((v_precio * 0.52) / 1000) * 1000,
      v_cat, v_mrc,
      FLOOR(RAND()*200) + 5,
      FLOOR(RAND()*10) + 2,
      ROUND(0.05 + RAND() * 4, 3),
      IF(RAND() > 0.07, 1, 0),
      IF(RAND() < 0.12, 1, 0)
    );

    SET v_pid = LAST_INSERT_ID();

    IF v_pid > 0 THEN
      INSERT INTO atributos_producto (producto_id, clave, valor) VALUES
        (v_pid, 'color',    v_color),
        (v_pid, 'garantia', v_garantia),
        (v_pid, 'origen',   v_origen);

      IF RAND() < 0.4 THEN
        INSERT INTO atributos_producto (producto_id, clave, valor) VALUES
          (v_pid, 'material', ELT(FLOOR(RAND()*5)+1,'Plástico ABS','Aluminio','Acero inox','Fibra de carbono','Silicona'));
      END IF;

      INSERT INTO imagenes_producto (producto_id, url, alt_text, es_principal)
      VALUES (v_pid,
        CONCAT('https://cdn.tienda.co/gen/', v_sku, '-01.jpg'),
        CONCAT(v_nom, ' ', v_sufijo, ' imagen principal'), 1);

      IF RAND() < 0.5 THEN
        INSERT INTO imagenes_producto (producto_id, url, alt_text, es_principal)
        VALUES (v_pid,
          CONCAT('https://cdn.tienda.co/gen/', v_sku, '-02.jpg'),
          CONCAT(v_nom, ' ', v_sufijo, ' vista lateral'), 0);
      END IF;
    END IF;

    SET i = i + 1;
    IF i MOD 500 = 0 THEN COMMIT; END IF;
  END WHILE;
  COMMIT;
END$$
DELIMITER ;

-- ═══════════════════════════════════════════════════════════════
-- PROCEDIMIENTO: RESEÑAS MASIVAS
-- ═══════════════════════════════════════════════════════════════
DROP PROCEDURE IF EXISTS gen_resenas;
DELIMITER $$
CREATE PROCEDURE gen_resenas(IN total INT)
BEGIN
  DECLARE i INT DEFAULT 0;
  DECLARE v_pid INT;
  DECLARE v_uid INT;
  DECLARE v_cal TINYINT;
  DECLARE v_titulo VARCHAR(150);
  DECLARE v_comentario TEXT;

  WHILE i < total DO
    SELECT id INTO v_pid FROM productos ORDER BY RAND() LIMIT 1;
    SELECT id INTO v_uid FROM usuarios ORDER BY RAND() LIMIT 1;
    SET v_cal = FLOOR(RAND()*5) + 1;
    SELECT val INTO v_titulo FROM tmp_titulos_resena WHERE cal = v_cal ORDER BY RAND() LIMIT 1;
    SELECT val INTO v_comentario FROM tmp_comentarios ORDER BY RAND() LIMIT 1;

    INSERT IGNORE INTO resenas (producto_id, usuario_id, calificacion, titulo, comentario, verificado)
    VALUES (v_pid, v_uid, v_cal, v_titulo, v_comentario, IF(RAND() < 0.6, 1, 0));

    SET i = i + 1;
    IF i MOD 1000 = 0 THEN COMMIT; END IF;
  END WHILE;
  COMMIT;
END$$
DELIMITER ;

-- ═══════════════════════════════════════════════════════════════
-- PROCEDIMIENTO: PEDIDOS MASIVOS
-- ═══════════════════════════════════════════════════════════════
DROP PROCEDURE IF EXISTS gen_pedidos;
DELIMITER $$
CREATE PROCEDURE gen_pedidos(IN total INT)
BEGIN
  DECLARE i INT DEFAULT 0;
  DECLARE v_uid INT;
  DECLARE v_pid INT;
  DECLARE v_precio DECIMAL(14,2);
  DECLARE v_sku VARCHAR(80);
  DECLARE v_pnom VARCHAR(200);
  DECLARE v_ped_id INT;
  DECLARE v_cant INT;
  DECLARE v_subtot DECIMAL(14,2);
  DECLARE v_imp DECIMAL(14,2);
  DECLARE v_envio_costo DECIMAL(10,2);
  DECLARE v_tot DECIMAL(14,2);
  DECLARE v_estado_ped VARCHAR(30);
  DECLARE v_metodo VARCHAR(30);
  DECLARE v_estado_pago VARCHAR(20);
  DECLARE v_fecha DATETIME;
  DECLARE v_trans_id INT;
  DECLARE v_bod_id INT;
  DECLARE v_guia VARCHAR(100);
  DECLARE v_estado_env VARCHAR(30);
  DECLARE v_envio_id INT;
  DECLARE v_dias_offset INT;

  WHILE i < total DO
    SELECT id INTO v_uid FROM usuarios ORDER BY RAND() LIMIT 1;
    SELECT id INTO v_pid FROM productos WHERE activo = 1 ORDER BY RAND() LIMIT 1;
    SELECT precio, sku, nombre INTO v_precio, v_sku, v_pnom FROM productos WHERE id = v_pid LIMIT 1;

    SET v_cant = FLOOR(RAND()*3) + 1;
    SET v_subtot = v_precio * v_cant;
    SET v_imp = ROUND(v_subtot * 0.19);
    SET v_envio_costo = IF(v_subtot > 400000, 0, (FLOOR(RAND()*4)+1) * 5000);
    SET v_tot = v_subtot + v_imp + v_envio_costo;
    SET v_dias_offset = FLOOR(RAND()*730) + 1;
    SET v_fecha = DATE_SUB(NOW(), INTERVAL v_dias_offset DAY);

    SET v_estado_ped = ELT(FLOOR(RAND()*8)+1,
      'borrador','confirmado','pagado','en_preparacion',
      'despachado','entregado','cancelado','devuelto');

    INSERT INTO pedidos (usuario_id, estado, subtotal, impuestos, costo_envio, total, creado_at)
    VALUES (v_uid, v_estado_ped, v_subtot, v_imp, v_envio_costo, v_tot, v_fecha);

    SET v_ped_id = LAST_INSERT_ID();

    INSERT INTO items_pedido (pedido_id, producto_id, cantidad, precio_unit, sku_snapshot, nombre_snapshot)
    VALUES (v_ped_id, v_pid, v_cant, v_precio, v_sku, v_pnom);

    -- Segundo item en 20% de pedidos
    IF RAND() < 0.2 THEN
      SELECT id INTO v_pid FROM productos WHERE activo=1 ORDER BY RAND() LIMIT 1;
      SELECT precio, sku, nombre INTO v_precio, v_sku, v_pnom FROM productos WHERE id=v_pid LIMIT 1;
      INSERT INTO items_pedido (pedido_id, producto_id, cantidad, precio_unit, sku_snapshot, nombre_snapshot)
      VALUES (v_ped_id, v_pid, 1, v_precio, v_sku, v_pnom);
    END IF;

    -- Pago
    IF v_estado_ped NOT IN ('borrador','cancelado') THEN
      SET v_metodo = ELT(FLOOR(RAND()*8)+1,
        'tarjeta_credito','tarjeta_debito','pse','nequi',
        'daviplata','efecty','contraentrega','crypto');
      SET v_estado_pago = CASE
        WHEN v_estado_ped IN ('pagado','en_preparacion','despachado','entregado') THEN 'aprobado'
        WHEN v_estado_ped = 'devuelto' THEN 'reembolsado'
        ELSE 'pendiente'
      END;
      INSERT INTO pagos (pedido_id, metodo, estado, monto, moneda, referencia_ext, pasarela, creado_at)
      VALUES (v_ped_id, v_metodo, v_estado_pago, v_tot, 'COP',
        CONCAT(UPPER(LEFT(v_metodo,3)), '-', LPAD(v_ped_id,7,'0')),
        ELT(FLOOR(RAND()*5)+1,'Redeban','Credibanco','Nequi','Bancolombia','Davivienda'),
        DATE_ADD(v_fecha, INTERVAL (FLOOR(RAND()*60)+1) MINUTE));
    END IF;

    -- Envío
    IF v_estado_ped IN ('en_preparacion','despachado','entregado') THEN
      SET v_trans_id = FLOOR(RAND()*4) + 1;
      SET v_bod_id   = FLOOR(RAND()*4) + 1;
      SET v_guia = CONCAT(
        ELT(v_trans_id,'SRVI','IRPI','CORD','TCC_'), '-',
        LPAD(v_ped_id, 8, '0'));
      SET v_estado_env = CASE v_estado_ped
        WHEN 'entregado'     THEN 'entregado'
        WHEN 'despachado'    THEN ELT(FLOOR(RAND()*3)+1,'en_transito','en_ciudad','en_reparto')
        ELSE 'en_bodega'
      END;

      INSERT IGNORE INTO envios
        (pedido_id, transportista_id, bodega_origen_id, numero_guia, estado,
         direccion_destino, ciudad_destino, fecha_estimada, creado_at)
      VALUES (
        v_ped_id, v_trans_id, v_bod_id, v_guia, v_estado_env,
        COALESCE(
          (SELECT CONCAT(d.calle, ', ', d.barrio)
           FROM direcciones d WHERE d.usuario_id = v_uid AND d.es_principal = 1 LIMIT 1),
          'Dirección no registrada'
        ),
        (SELECT ciudad FROM tmp_ciudades ORDER BY RAND() LIMIT 1),
        DATE_ADD(v_fecha, INTERVAL (FLOOR(RAND()*5)+2) DAY),
        DATE_ADD(v_fecha, INTERVAL (FLOOR(RAND()*12)+1) HOUR)
      );

      SET v_envio_id = LAST_INSERT_ID();

      IF v_envio_id > 0 THEN
        -- Evento 1: siempre recibido
        INSERT INTO tracking_eventos (envio_id, estado, descripcion, ciudad, creado_at)
        VALUES (v_envio_id, 'recibido', 'Paquete recibido en bodega origen',
          (SELECT nombre FROM bodegas WHERE id = v_bod_id LIMIT 1),
          DATE_ADD(v_fecha, INTERVAL 4 HOUR));

        -- Evento 2: en tránsito si aplica
        IF v_estado_env IN ('en_transito','en_ciudad','en_reparto','entregado') THEN
          INSERT INTO tracking_eventos (envio_id, estado, descripcion, ciudad, creado_at)
          VALUES (v_envio_id, 'en_transito',
            ELT(FLOOR(RAND()*3)+1,
              'En camino al destino',
              'Paquete en ruta de entrega',
              'Saliendo de la ciudad de origen'),
            (SELECT ciudad FROM tmp_ciudades ORDER BY RAND() LIMIT 1),
            DATE_ADD(v_fecha, INTERVAL 1 DAY));
        END IF;

        -- Evento 3: en ciudad si aplica
        IF v_estado_env IN ('en_ciudad','en_reparto','entregado') THEN
          INSERT INTO tracking_eventos (envio_id, estado, descripcion, ciudad, creado_at)
          VALUES (v_envio_id, 'en_ciudad', 'Paquete llegó a la ciudad destino',
            (SELECT ciudad FROM tmp_ciudades ORDER BY RAND() LIMIT 1),
            DATE_ADD(v_fecha, INTERVAL 2 DAY));
        END IF;

        -- Evento 4: entregado
        IF v_estado_env = 'entregado' THEN
          INSERT INTO tracking_eventos (envio_id, estado, descripcion, ciudad, creado_at)
          VALUES (v_envio_id, 'entregado', 'Entregado al destinatario',
            (SELECT ciudad FROM tmp_ciudades ORDER BY RAND() LIMIT 1),
            DATE_ADD(v_fecha, INTERVAL (FLOOR(RAND()*3)+3) DAY));
        END IF;
      END IF;
    END IF;

    SET i = i + 1;
    IF i MOD 500 = 0 THEN COMMIT; END IF;
  END WHILE;
  COMMIT;
END$$
DELIMITER ;

-- ═══════════════════════════════════════════════════════════════
-- EJECUTAR GENERADORES
-- ═══════════════════════════════════════════════════════════════
SELECT 'Generando 10,000 usuarios...' AS log_status;
CALL gen_usuarios(10000);

SELECT 'Generando 5,000 productos...' AS log_status;
CALL gen_productos(5000);

SELECT 'Generando 10,000 reseñas...' AS log_status;
CALL gen_resenas(10000);

SELECT 'Generando 10,000 pedidos...' AS log_status;
CALL gen_pedidos(10000);

-- ═══════════════════════════════════════════════════════════════
-- LIMPIEZA
-- ═══════════════════════════════════════════════════════════════
DROP PROCEDURE IF EXISTS gen_usuarios;
DROP PROCEDURE IF EXISTS gen_productos;
DROP PROCEDURE IF EXISTS gen_resenas;
DROP PROCEDURE IF EXISTS gen_pedidos;

DROP TEMPORARY TABLE IF EXISTS tmp_nombres;
DROP TEMPORARY TABLE IF EXISTS tmp_apellidos;
DROP TEMPORARY TABLE IF EXISTS tmp_ciudades;
DROP TEMPORARY TABLE IF EXISTS tmp_barrios;
DROP TEMPORARY TABLE IF EXISTS tmp_calles;
DROP TEMPORARY TABLE IF EXISTS tmp_prod_base;
DROP TEMPORARY TABLE IF EXISTS tmp_comentarios;
DROP TEMPORARY TABLE IF EXISTS tmp_titulos_resena;

SET foreign_key_checks = 1;
SET unique_checks = 1;

-- ═══════════════════════════════════════════════════════════════
-- RESUMEN
-- ═══════════════════════════════════════════════════════════════
SELECT tabla, total FROM (
  SELECT 'usuarios'         AS tabla, COUNT(*) AS total FROM usuarios         UNION ALL
  SELECT 'direcciones',              COUNT(*) FROM direcciones                UNION ALL
  SELECT 'preferencias',             COUNT(*) FROM preferencias_usuario       UNION ALL
  SELECT 'productos',                COUNT(*) FROM productos                  UNION ALL
  SELECT 'atributos',                COUNT(*) FROM atributos_producto         UNION ALL
  SELECT 'imagenes',                 COUNT(*) FROM imagenes_producto          UNION ALL
  SELECT 'resenas',                  COUNT(*) FROM resenas                    UNION ALL
  SELECT 'pedidos',                  COUNT(*) FROM pedidos                    UNION ALL
  SELECT 'items_pedido',             COUNT(*) FROM items_pedido               UNION ALL
  SELECT 'pagos',                    COUNT(*) FROM pagos                      UNION ALL
  SELECT 'envios',                   COUNT(*) FROM envios                     UNION ALL
  SELECT 'tracking_eventos',         COUNT(*) FROM tracking_eventos           UNION ALL
  SELECT 'outbox_events',            COUNT(*) FROM outbox_events
) t;