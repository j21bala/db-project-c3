const { getMariaDB } = require("./db-mariadb");
const { getMongoDb } = require("./db-mongo");
const logger         = require("./logger");

async function runFullMigration(broadcast) {
  const db    = await getMariaDB();
  const stats = { usuarios:0, catalogo:0, pedidos:0, logistica:0, errors:[] };

  // ══ FASE 1: USUARIOS ════════════════════════════════
  logger.info("Fase 1: Usuarios...");
  try {
    const uDb = await getMongoDb("usuarios");
    const col  = uDb.collection("usuarios");
    await col.createIndex({ mariadb_id: 1 }, { unique: true, sparse: true });
    await col.createIndex({ email: 1 }, { unique: true, sparse: true });

    const [usuarios]   = await db.query("SELECT * FROM usuarios");
    const [dirs]       = await db.query("SELECT * FROM direcciones");
    const [prefs]      = await db.query("SELECT * FROM preferencias_usuario");
    const [sesiones]   = await db.query("SELECT * FROM sesiones");

    // Mapas por usuario_id
    const dirMap  = {};
    const prefMap = {};
    for (const d of dirs) {
      if (!dirMap[d.usuario_id]) dirMap[d.usuario_id] = [];
      dirMap[d.usuario_id].push({
        alias: d.alias, calle: d.calle, barrio: d.barrio,
        ciudad: d.ciudad, departamento: d.departamento,
        pais: d.pais, codigo_postal: d.codigo_postal,
        es_principal: Boolean(d.es_principal),
      });
    }
    for (const p of prefs) {
      prefMap[p.usuario_id] = {
        idioma: p.idioma, moneda: p.moneda,
        notif_email: Boolean(p.notif_email), notif_sms: Boolean(p.notif_sms),
      };
    }

    for (const u of usuarios) {
      await col.updateOne({ mariadb_id: u.id }, { $set: {
        mariadb_id:      u.id,
        nombre:          u.nombre,
        apellido:        u.apellido,
        nombre_completo: `${u.nombre} ${u.apellido}`,
        email:           u.email,
        telefono:        u.telefono,
        activo:          Boolean(u.activo),
        fecha_nacimiento: u.fecha_nacimiento ? new Date(u.fecha_nacimiento) : null,
        creado_at:       new Date(u.creado_at),
        // EMBEDDING — relaciones incrustadas
        direcciones:     dirMap[u.id]  || [],
        preferencias:    prefMap[u.id] || {},
        _migrado_at:     new Date(),
      }}, { upsert: true });
      stats.usuarios++;
    }

    // Sesiones en colección separada
    const sesCol = uDb.collection("sesiones");
    for (const s of sesiones) {
      await sesCol.updateOne({ mariadb_id: s.id }, { $set: {
        mariadb_id:         s.id,
        usuario_mariadb_id: s.usuario_id,
        token:     s.token,
        ip:        s.ip,
        expira_at: s.expira_at ? new Date(s.expira_at) : null,
        creado_at: new Date(s.creado_at),
      }}, { upsert: true });
    }

    if (broadcast) broadcast("phase_complete", { fase: "usuarios", count: stats.usuarios });
    logger.info(`  ${stats.usuarios} usuarios + ${sesiones.length} sesiones`);
  } catch (err) {
    logger.error(`  Usuarios: ${err.message}`);
    stats.errors.push({ fase: "usuarios", error: err.message });
  }

  // ══ FASE 2: CATÁLOGO ════════════════════════════════
  logger.info("Fase 2: Catálogo...");
  try {
    const cDb   = await getMongoDb("catalogo");
    const pCol  = cDb.collection("productos");
    const catCol = cDb.collection("categorias");
    const mrcCol = cDb.collection("marcas");
    await pCol.createIndex({ sku: 1 }, { unique: true, sparse: true });
    await pCol.createIndex({ mariadb_id: 1 }, { unique: true, sparse: true });

    const [categorias] = await db.query("SELECT * FROM categorias");
    const [marcas]     = await db.query("SELECT * FROM marcas");
    const [productos]  = await db.query("SELECT * FROM productos");
    const [atributos]  = await db.query("SELECT * FROM atributos_producto");
    const [variantes]  = await db.query("SELECT * FROM variantes_producto");
    const [imagenes]   = await db.query("SELECT * FROM imagenes_producto");
    const [resenas]    = await db.query("SELECT * FROM resenas");

    // Poblar categorías y marcas en MongoDB
    const catMap = {};
    for (const c of categorias) {
      catMap[c.id] = { mariadb_id: c.id, nombre: c.nombre, slug: c.slug };
      await catCol.updateOne({ mariadb_id: c.id },
        { $set: { mariadb_id: c.id, nombre: c.nombre, slug: c.slug, padre_id: c.padre_id } },
        { upsert: true });
    }
    const mrcMap = {};
    for (const m of marcas) {
      mrcMap[m.id] = { mariadb_id: m.id, nombre: m.nombre, pais: m.pais };
      await mrcCol.updateOne({ mariadb_id: m.id },
        { $set: { mariadb_id: m.id, nombre: m.nombre, pais: m.pais, website: m.website } },
        { upsert: true });
    }

    // Construir mapas de relaciones 1:N
    const attrMap = {}, varMap = {}, imgMap = {}, resMap = {};
    for (const a of atributos) {
      if (!attrMap[a.producto_id]) attrMap[a.producto_id] = {};
      attrMap[a.producto_id][a.clave] = a.valor;
    }
    for (const v of variantes) {
      if (!varMap[v.producto_id]) varMap[v.producto_id] = [];
      varMap[v.producto_id].push({
        sku_variante: v.sku_variante, color: v.color,
        talla: v.talla, stock: v.stock, precio_extra: parseFloat(v.precio_extra) || 0,
      });
    }
    for (const i of imagenes) {
      if (!imgMap[i.producto_id]) imgMap[i.producto_id] = [];
      imgMap[i.producto_id].push({
        url: i.url, alt_text: i.alt_text,
        orden: i.orden, es_principal: Boolean(i.es_principal),
      });
    }
    for (const r of resenas) {
      if (!resMap[r.producto_id]) resMap[r.producto_id] = { total: 0, suma: 0, items: [] };
      resMap[r.producto_id].total++;
      resMap[r.producto_id].suma += r.calificacion;
      resMap[r.producto_id].items.push({
        usuario_mariadb_id: r.usuario_id,
        calificacion: r.calificacion,
        titulo: r.titulo, comentario: r.comentario,
        verificado: Boolean(r.verificado),
        creado_at: new Date(r.creado_at),
      });
    }

    for (const p of productos) {
      const res = resMap[p.id];
      await pCol.updateOne({ mariadb_id: p.id }, { $set: {
        mariadb_id:   p.id,
        sku:          p.sku,
        nombre:       p.nombre,
        descripcion:  p.descripcion || "",
        precio:       parseFloat(p.precio),
        precio_costo: parseFloat(p.precio_costo) || null,
        stock:        p.stock,
        stock_minimo: p.stock_minimo,
        peso_kg:      parseFloat(p.peso_kg) || null,
        activo:       Boolean(p.activo),
        destacado:    Boolean(p.destacado),
        creado_at:    new Date(p.creado_at),
        // EMBEDDING COMPLETO
        categoria:    catMap[p.categoria_id] || null,
        marca:        mrcMap[p.marca_id]     || null,
        atributos:    attrMap[p.id]          || {},
        variantes:    varMap[p.id]           || [],
        imagenes:     imgMap[p.id]           || [],
        resenas: res ? {
          promedio: parseFloat((res.suma / res.total).toFixed(2)),
          total:    res.total,
          items:    res.items,
        } : { promedio: 0, total: 0, items: [] },
        _migrado_at: new Date(),
      }}, { upsert: true });
      stats.catalogo++;
    }

    if (broadcast) broadcast("phase_complete", { fase: "catalogo", count: stats.catalogo });
    logger.info(` ${stats.catalogo} productos`);
  } catch (err) {
    logger.error(` Catálogo: ${err.message}`);
    stats.errors.push({ fase: "catalogo", error: err.message });
  }

  // ══ FASE 3: PEDIDOS ════════════════════════════════
  logger.info("Fase 3: Pedidos...");
  try {
    const pedDb = await getMongoDb("pedidos");
    const pedCol = pedDb.collection("pedidos");
    await pedCol.createIndex({ mariadb_id: 1 }, { unique: true, sparse: true });

    const [pedidos]    = await db.query("SELECT * FROM pedidos");
    const [items]      = await db.query(`
      SELECT i.*, p.sku, p.nombre AS prod_nombre
      FROM items_pedido i
      JOIN productos p ON i.producto_id = p.id`);
    const [pagos]      = await db.query("SELECT * FROM pagos");
    const [devoluciones] = await db.query("SELECT * FROM devoluciones");
    const [cupones]    = await db.query("SELECT * FROM cupones");

    const itemMap = {}, pagoMap = {}, devMap = {}, cupMap = {};
    for (const i of items) {
      if (!itemMap[i.pedido_id]) itemMap[i.pedido_id] = [];
      itemMap[i.pedido_id].push({
        producto_mariadb_id: i.producto_id,
        variante_id: i.variante_id || null,
        sku: i.sku_snapshot || i.sku,
        nombre: i.nombre_snapshot || i.prod_nombre,
        cantidad: i.cantidad,
        precio_unit: parseFloat(i.precio_unit),
        descuento_item: parseFloat(i.descuento_item) || 0,
        subtotal: parseFloat(i.precio_unit) * i.cantidad,
      });
    }
    for (const pg of pagos) {
      pagoMap[pg.pedido_id] = {
        mariadb_id: pg.id, metodo: pg.metodo, estado: pg.estado,
        monto: parseFloat(pg.monto), moneda: pg.moneda,
        referencia_ext: pg.referencia_ext, pasarela: pg.pasarela,
        creado_at: new Date(pg.creado_at),
      };
    }
    for (const d of devoluciones) {
      devMap[d.pedido_id] = {
        mariadb_id: d.id, motivo: d.motivo, descripcion: d.descripcion,
        estado: d.estado, monto_reemb: parseFloat(d.monto_reemb) || 0,
        creado_at: new Date(d.creado_at),
      };
    }
    for (const c of cupones) cupMap[c.id] = { codigo: c.codigo, tipo: c.tipo, valor: parseFloat(c.valor) };

    for (const ped of pedidos) {
      await pedCol.updateOne({ mariadb_id: ped.id }, { $set: {
        mariadb_id:   ped.id,
        estado:       ped.estado,
        subtotal:     parseFloat(ped.subtotal)    || 0,
        descuento:    parseFloat(ped.descuento)   || 0,
        impuestos:    parseFloat(ped.impuestos)   || 0,
        costo_envio:  parseFloat(ped.costo_envio) || 0,
        total:        parseFloat(ped.total)       || 0,
        notas:        ped.notas || "",
        creado_at:    new Date(ped.creado_at),
        usuario_ref:  { mariadb_id: ped.usuario_id },
        // EMBEDDING COMPLETO
        cupon:        ped.cupon_id ? cupMap[ped.cupon_id] || null : null,
        items:        itemMap[ped.id]   || [],
        pago:         pagoMap[ped.id]   || null,
        devolucion:   devMap[ped.id]    || null,
        _migrado_at:  new Date(),
      }}, { upsert: true });
      stats.pedidos++;
    }

    if (broadcast) broadcast("phase_complete", { fase: "pedidos", count: stats.pedidos });
    logger.info(` ${stats.pedidos} pedidos`);
  } catch (err) {
    logger.error(` Pedidos: ${err.message}`);
    stats.errors.push({ fase: "pedidos", error: err.message });
  }

  // ══ FASE 4: LOGÍSTICA ═══════════════════════════════
  logger.info("Fase 4: Logística...");
  try {
    const logDb  = await getMongoDb("logistica");
    const envCol = logDb.collection("envios");
    const bodCol = logDb.collection("bodegas");
    const traCol = logDb.collection("transportistas");
    await envCol.createIndex({ mariadb_id: 1 }, { unique: true, sparse: true });

    const [bodegas]       = await db.query("SELECT * FROM bodegas");
    const [transportistas] = await db.query("SELECT * FROM transportistas");
    const [envios]        = await db.query("SELECT * FROM envios");
    const [tracking]      = await db.query("SELECT * FROM tracking_eventos");
    const [stockBod]      = await db.query(`
      SELECT sb.*, p.sku, p.nombre
      FROM stock_bodega sb JOIN productos p ON sb.producto_id = p.id`);

    const bodMap = {}, traMap = {};
    for (const b of bodegas) {
      bodMap[b.id] = { mariadb_id: b.id, nombre: b.nombre, ciudad: b.ciudad };
      const stockItems = stockBod.filter(s => s.bodega_id === b.id).map(s => ({
        producto_mariadb_id: s.producto_id, sku: s.sku,
        nombre: s.nombre, cantidad: s.cantidad,
      }));
      await bodCol.updateOne({ mariadb_id: b.id }, { $set: {
        mariadb_id: b.id, nombre: b.nombre, ciudad: b.ciudad,
        direccion: b.direccion, activa: Boolean(b.activa),
        stock_items: stockItems,  // EMBEDDING
      }}, { upsert: true });
    }
    for (const t of transportistas) {
      traMap[t.id] = { mariadb_id: t.id, nombre: t.nombre, codigo: t.codigo };
      await traCol.updateOne({ mariadb_id: t.id }, { $set: {
        mariadb_id: t.id, nombre: t.nombre, codigo: t.codigo,
        url_tracking: t.url_tracking, activo: Boolean(t.activo),
      }}, { upsert: true });
    }

    const trkMap = {};
    for (const t of tracking) {
      if (!trkMap[t.envio_id]) trkMap[t.envio_id] = [];
      trkMap[t.envio_id].push({
        estado: t.estado, descripcion: t.descripcion,
        ciudad: t.ciudad,
        latitud:  t.latitud  ? parseFloat(t.latitud)  : null,
        longitud: t.longitud ? parseFloat(t.longitud) : null,
        creado_at: new Date(t.creado_at),
      });
    }

    for (const e of envios) {
      await envCol.updateOne({ mariadb_id: e.id }, { $set: {
        mariadb_id:        e.id,
        estado:            e.estado,
        numero_guia:       e.numero_guia || null,
        ciudad_destino:    e.ciudad_destino,
        direccion_destino: e.direccion_destino,
        fecha_estimada:    e.fecha_estimada ? new Date(e.fecha_estimada) : null,
        fecha_entregado:   e.fecha_entregado ? new Date(e.fecha_entregado) : null,
        intentos_entrega:  e.intentos_entrega,
        creado_at:         new Date(e.creado_at),
        pedido_ref:        { mariadb_id: e.pedido_id },
        // EMBEDDING COMPLETO
        transportista:     traMap[e.transportista_id]  || null,
        bodega_origen:     bodMap[e.bodega_origen_id]  || null,
        tracking:          trkMap[e.id]                || [],
        _migrado_at:       new Date(),
      }}, { upsert: true });
      stats.logistica++;
    }

    if (broadcast) broadcast("phase_complete", { fase: "logistica", count: stats.logistica });
    logger.info(` ${stats.logistica} envíos`);
  } catch (err) {
    logger.error(` Logística: ${err.message}`);
    stats.errors.push({ fase: "logistica", error: err.message });
  }

  logger.info(`MIGRACIÓN COMPLETA: ${JSON.stringify(stats)}`);
  return stats;
}

module.exports = { runFullMigration };