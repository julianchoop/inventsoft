-- ============================================================
-- MÓDULO – PEDIDOS
-- Empresa de Carrocerías · Normalización 3FN
-- Basado en página 11 del documento de normalización
-- ============================================================

-- ------------------------------------------------------------
-- TABLA: CATEGORIAS_PRODUCTO
-- Catálogo de categorías de materiales (Láminas, Tubos, Perfiles)
-- 3FN: extraída de PRODUCTO para eliminar dependencia transitiva
-- ------------------------------------------------------------
CREATE TABLE CATEGORIAS_PRODUCTO (
    id_categoria        INT AUTO_INCREMENT PRIMARY KEY,
    nombre_categoria    VARCHAR(50)  NOT NULL UNIQUE,
    descripcion         VARCHAR(100),
    activo              TINYINT(1)   NOT NULL DEFAULT 1,
    fecha_creacion      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ------------------------------------------------------------
-- TABLA: ESTADO_PEDIDO
-- Catálogo de estados posibles para un pedido
-- 3FN: extraída de PEDIDOS para eliminar dependencia transitiva
-- ------------------------------------------------------------
CREATE TABLE ESTADO_PEDIDO (
    id_estado           INT AUTO_INCREMENT PRIMARY KEY,
    nombre_estado       VARCHAR(30)  NOT NULL UNIQUE,
    descripcion         VARCHAR(100),
    activo              TINYINT(1)   NOT NULL DEFAULT 1,
    fecha_creacion      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ------------------------------------------------------------
-- TABLA: TIPO_PEDIDO
-- Catálogo de tipos de pedido (Normal, Urgente, Exportación)
-- 3FN: tabla independiente sin dependencias transitivas
-- ------------------------------------------------------------
CREATE TABLE TIPO_PEDIDO (
    id_tipo             INT AUTO_INCREMENT PRIMARY KEY,
    nombre_tipo         VARCHAR(30)  NOT NULL UNIQUE,
    descripcion         VARCHAR(100),
    activo              TINYINT(1)   NOT NULL DEFAULT 1,
    fecha_creacion      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ------------------------------------------------------------
-- TABLA: CLIENTES
-- Datos del cliente separados del pedido
-- 2FN → 3FN: evita repetición de datos en cada fila de PEDIDOS
-- ------------------------------------------------------------
CREATE TABLE CLIENTES (
    id_cliente          INT AUTO_INCREMENT PRIMARY KEY,
    nombre              VARCHAR(80)  NOT NULL,
    correo              VARCHAR(100) NOT NULL UNIQUE,
    telefono            VARCHAR(20),
    direccion           VARCHAR(120),
    ciudad              VARCHAR(50),
    activo              TINYINT(1)   NOT NULL DEFAULT 1,
    fecha_registro      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ------------------------------------------------------------
-- TABLA: PRODUCTO
-- Catálogo de productos disponibles para pedir
-- 3FN: id_categoria como FK elimina dependencia transitiva
--      (nombre_categoria dependía de id_categoria, no de id_producto)
-- ------------------------------------------------------------
CREATE TABLE PRODUCTO (
    id_producto         VARCHAR(10)  PRIMARY KEY,
    nombre_producto     VARCHAR(80)  NOT NULL,
    id_categoria        INT          NOT NULL,
    precio_base         DECIMAL(10,2) NOT NULL,
    unidad              VARCHAR(20),
    stock               INT          NOT NULL DEFAULT 0,
    activo              TINYINT(1)   NOT NULL DEFAULT 1,
    fecha_registro      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_prod_cat FOREIGN KEY (id_categoria)
        REFERENCES CATEGORIAS_PRODUCTO (id_categoria)
);

-- ------------------------------------------------------------
-- TABLA: PEDIDOS
-- Encabezado del pedido (sin datos de cliente ni transitivos)
-- 3FN: solo claves foráneas a CLIENTES, ESTADO_PEDIDO y TIPO_PEDIDO
-- ------------------------------------------------------------
CREATE TABLE PEDIDOS (
    id_pedido           INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente          INT          NOT NULL,
    id_estado           INT          NOT NULL,
    id_tipo             INT          NOT NULL DEFAULT 1,
    fecha_pedido        DATE         NOT NULL,
    ciudad_entrega      VARCHAR(50),
    total               DECIMAL(12,2) NOT NULL DEFAULT 0,
    observaciones       TEXT,
    activo              TINYINT(1)   NOT NULL DEFAULT 1,
    fecha_registro      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_ped_cliente FOREIGN KEY (id_cliente)
        REFERENCES CLIENTES (id_cliente),
    CONSTRAINT fk_ped_estado  FOREIGN KEY (id_estado)
        REFERENCES ESTADO_PEDIDO (id_estado),
    CONSTRAINT fk_ped_tipo    FOREIGN KEY (id_tipo)
        REFERENCES TIPO_PEDIDO (id_tipo)
);

-- ------------------------------------------------------------
-- TABLA: DETALLE_PEDIDO
-- Líneas de producto dentro de cada pedido (tabla asociativa)
-- Clave primaria simple + restricción única (id_pedido, id_producto)
-- ------------------------------------------------------------
CREATE TABLE DETALLE_PEDIDO (
    id_detalle          INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido           INT          NOT NULL,
    id_producto         VARCHAR(10)  NOT NULL,
    cantidad            INT          NOT NULL,
    precio_unit         DECIMAL(10,2) NOT NULL,
    subtotal            DECIMAL(12,2) GENERATED ALWAYS AS (cantidad * precio_unit) STORED,
    activo              TINYINT(1)   NOT NULL DEFAULT 1,
    fecha_registro      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_det_pedido  FOREIGN KEY (id_pedido)
        REFERENCES PEDIDOS (id_pedido),
    CONSTRAINT fk_det_prod    FOREIGN KEY (id_producto)
        REFERENCES PRODUCTO (id_producto),
    UNIQUE (id_pedido, id_producto)
);


-- ============================================================
-- DATOS DE PRUEBA
-- ============================================================

-- CATEGORIAS_PRODUCTO
INSERT INTO CATEGORIAS_PRODUCTO (nombre_categoria, descripcion) VALUES
    ('Láminas',  'Productos planos de acero'),
    ('Tubos',    'Perfiles tubulares metálicos'),
    ('Perfiles', 'Ángulos y canales metálicos');

-- ESTADO_PEDIDO
INSERT INTO ESTADO_PEDIDO (nombre_estado, descripcion) VALUES
    ('En proceso', 'Pedido recibido y en preparación'),
    ('Pendiente',  'En espera de aprobación'),
    ('Entregado',  'Entregado al cliente');

-- TIPO_PEDIDO
INSERT INTO TIPO_PEDIDO (nombre_tipo, descripcion) VALUES
    ('Normal',      'Sin urgencia'),
    ('Urgente',     'Entrega prioritaria'),
    ('Exportación', 'Para cliente exterior');

-- CLIENTES
INSERT INTO CLIENTES (nombre, correo, telefono, direccion, ciudad) VALUES
    ('Luis Torres', 'lta@mail.com', '310-111-0000', 'Cra 5 #12-30', 'Bogotá'),
    ('Ana Ruiz',    'ar@mail.com',  '315-222-0000', 'Cl 30 #8-15',  'Medellín');

-- PRODUCTO
INSERT INTO PRODUCTO (id_producto, nombre_producto, id_categoria, precio_base, unidad, stock) VALUES
    ('P-001', 'Platina 2m',       1, 80000.00, 'Unidad', 150),
    ('P-002', 'Lámina 1m',        1, 45000.00, 'Unidad', 200),
    ('P-003', 'Tubo cuadrado 3m', 2, 30000.00, 'Metro',  300),
    ('P-004', 'Ángulo 1.5m',      3, 25000.00, 'Metro',  180);

-- PEDIDOS
INSERT INTO PEDIDOS (id_cliente, id_estado, id_tipo, fecha_pedido, ciudad_entrega, total) VALUES
    (1, 3, 1, '2024-01-10', 'Bogotá',   250000.00),
    (2, 1, 1, '2024-01-12', 'Medellín', 300000.00),
    (1, 2, 2, '2024-01-15', 'Bogotá',   395000.00);

-- DETALLE_PEDIDO
INSERT INTO DETALLE_PEDIDO (id_pedido, id_producto, cantidad, precio_unit) VALUES
    (1, 'P-001', 5,  80000.00),
    (1, 'P-002', 2,  45000.00),
    (2, 'P-003', 10, 30000.00),
    (3, 'P-001', 4,  80000.00),
    (3, 'P-004', 3,  25000.00);


-- ============================================================
-- CONSULTAS DE VERIFICACIÓN
-- ============================================================

-- 1. Todos los pedidos con cliente y estado
SELECT
    p.id_pedido,
    p.fecha_pedido,
    c.nombre            AS cliente,
    c.ciudad            AS ciudad_cliente,
    p.ciudad_entrega,
    e.nombre_estado     AS estado,
    t.nombre_tipo       AS tipo,
    p.total
FROM       PEDIDOS       p
INNER JOIN CLIENTES      c ON p.id_cliente = c.id_cliente
INNER JOIN ESTADO_PEDIDO e ON p.id_estado  = e.id_estado
INNER JOIN TIPO_PEDIDO   t ON p.id_tipo    = t.id_tipo
ORDER BY p.fecha_pedido;

-- 2. Detalle completo de pedidos (productos y subtotales)
SELECT
    p.id_pedido,
    p.fecha_pedido,
    c.nombre                AS cliente,
    pr.nombre_producto,
    cat.nombre_categoria    AS categoria,
    d.cantidad,
    d.precio_unit,
    d.subtotal
FROM       DETALLE_PEDIDO       d
INNER JOIN PEDIDOS              p   ON d.id_pedido    = p.id_pedido
INNER JOIN CLIENTES             c   ON p.id_cliente   = c.id_cliente
INNER JOIN PRODUCTO             pr  ON d.id_producto  = pr.id_producto
INNER JOIN CATEGORIAS_PRODUCTO  cat ON pr.id_categoria = cat.id_categoria
ORDER BY p.id_pedido, d.id_detalle;

-- 3. Total de pedidos por cliente
SELECT
    c.nombre                AS cliente,
    COUNT(p.id_pedido)      AS total_pedidos,
    SUM(p.total)            AS valor_total
FROM       PEDIDOS  p
INNER JOIN CLIENTES c ON p.id_cliente = c.id_cliente
GROUP BY c.id_cliente, c.nombre;

-- 4. Pedidos activos (pendientes o en proceso)
SELECT
    p.id_pedido,
    p.fecha_pedido,
    c.nombre            AS cliente,
    e.nombre_estado     AS estado,
    p.total
FROM       PEDIDOS       p
INNER JOIN CLIENTES      c ON p.id_cliente = c.id_cliente
INNER JOIN ESTADO_PEDIDO e ON p.id_estado  = e.id_estado
WHERE e.nombre_estado IN ('Pendiente', 'En proceso')
ORDER BY p.fecha_pedido;

-- 5. Productos más pedidos
SELECT
    pr.nombre_producto,
    cat.nombre_categoria    AS categoria,
    SUM(d.cantidad)         AS total_unidades_pedidas
FROM       DETALLE_PEDIDO      d
INNER JOIN PRODUCTO            pr  ON d.id_producto   = pr.id_producto
INNER JOIN CATEGORIAS_PRODUCTO cat ON pr.id_categoria = cat.id_categoria
GROUP BY pr.id_producto, pr.nombre_producto, cat.nombre_categoria
ORDER BY total_unidades_pedidas DESC;
