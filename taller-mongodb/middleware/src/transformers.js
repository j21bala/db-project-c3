// Mapeo SQL → MongoDB. Aplica embedding de relaciones relacionadas.
const transformers = {

  // DOMINIO USUARIOS
  usuarios: (p) => ({
    nombre:          p.nombre,
    apellido:        p.apellido,
    nombre_completo: `${p.nombre} ${p.apellido}`,
    email:           p.email,
    telefono:        p.telefono || null,
    activo:          Boolean(p.activo),
    fecha_nacimiento: p.fecha_nacimiento ? new Date(p.fecha_nacimiento) : null,
    creado_at:       p.creado_at ? new Date(p.creado_at) : new Date(),
    // Se enriquece con direcciones y preferencias en bulk migration
    direcciones:     [],
    preferencias:    {},
    _metadata:       { fuente: "mariadb", version: 1 },
  }),

  sesiones: (p) => ({
    usuario_mariadb_id: p.usuario_id,
    token:     p.token,
    ip:        p.ip || null,
    expira_at: p.expira_at ? new Date(p.expira_at) : null,
    creado_at: p.creado_at ? new Date(p.creado_at) : new Date(),
  }),

  // DOMINIO CATÁLOGO
  productos: (p) => ({
    sku:         p.sku,
    nombre:      p.nombre,
    descripcion: p.descripcion || "",
    precio:      parseFloat(p.precio) || 0,
    stock:       parseInt(p.stock) || 0,
    activo:      Boolean(p.activo),
    destacado:   Boolean(p.destacado),
    // Se enriquece en bulk
    categoria:   { mariadb_id: p.categoria_id },
    marca:       { mariadb_id: p.marca_id },
    atributos:   {},
    imagenes:    [],
    variantes:   [],
    resenas:     { promedio: 0, total: 0, items: [] },
    _metadata:   { fuente: "mariadb", version: 1 },
  }),

  // DOMINIO PEDIDOS
  pedidos: (p) => ({
    estado:      p.estado,
    subtotal:    parseFloat(p.subtotal) || 0,
    descuento:   parseFloat(p.descuento) || 0,
    impuestos:   parseFloat(p.impuestos) || 0,
    costo_envio: parseFloat(p.costo_envio) || 0,
    total:       parseFloat(p.total) || 0,
    notas:       p.notas || "",
    creado_at:   p.creado_at ? new Date(p.creado_at) : new Date(),
    usuario_ref: { mariadb_id: p.usuario_id },
    // Se enriquece en bulk
    items:       [],
    pago:        null,
    devolucion:  null,
    _metadata:   { fuente: "mariadb", version: 1 },
  }),

  // DOMINIO LOGÍSTICA
  envios: (p) => ({
    estado:            p.estado,
    numero_guia:       p.numero_guia || null,
    ciudad_destino:    p.ciudad_destino || null,
    direccion_destino: p.direccion_destino || null,
    fecha_estimada:    p.fecha_estimada ? new Date(p.fecha_estimada) : null,
    intentos_entrega:  parseInt(p.intentos_entrega) || 0,
    pedido_ref:        { mariadb_id: p.pedido_id },
    // Se enriquece en bulk
    transportista:     { mariadb_id: p.transportista_id },
    bodega_origen:     { mariadb_id: p.bodega_origen_id },
    tracking:          [],
    _metadata:         { fuente: "mariadb", version: 1 },
  }),

  tracking: (p) => ({
    envio_mariadb_id: p.envio_id,
    estado:           p.estado,
    descripcion:      p.descripcion || "",
    ciudad:           p.ciudad || null,
    latitud:          p.latitud ? parseFloat(p.latitud) : null,
    longitud:         p.longitud ? parseFloat(p.longitud) : null,
    creado_at:        p.creado_at ? new Date(p.creado_at) : new Date(),
  }),
};

module.exports = { transformers };