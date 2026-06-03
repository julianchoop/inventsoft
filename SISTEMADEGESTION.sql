-- =====================================================
-- SCRIPT DE CREACIÓN DE BASE DE DATOS
-- Trabajo Final - Sistema de Gestión
-- Autor: Sistema de Base de Datos
-- Fecha: 2025
-- =====================================================

-- Crear la base de datos
CREATE DATABASE IF NOT EXISTS sistema_gestion
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE sistema_gestion;

-- =====================================================
-- TABLAS PRINCIPALES
-- =====================================================

-- -----------------------------------------------
-- Tabla: Clientes
-- Descripción: Almacena información de clientes
-- -----------------------------------------------
CREATE TABLE Clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    telefono VARCHAR(20),
    direccion VARCHAR(255),
    ciudad VARCHAR(100),
    codigo_postal VARCHAR(10),
    fecha_registro DATE NOT NULL,
    estado ENUM('Activo', 'Inactivo') DEFAULT 'Activo',
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_apellido (apellido),
    INDEX idx_ciudad (ciudad)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tabla de clientes del sistema';

-- -----------------------------------------------
-- Tabla: Categorias
-- Descripción: Categorías de productos (estructura jerárquica)
-- -----------------------------------------------
CREATE TABLE Categorias (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT,
    id_categoria_padre INT NULL,
    estado ENUM('Activa', 'Inactiva') DEFAULT 'Activa',
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_categoria_padre) REFERENCES Categorias(id_categoria) 
        ON DELETE SET NULL 
        ON UPDATE CASCADE,
    INDEX idx_nombre_cat (nombre),
    INDEX idx_estado (estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Categorías de productos';

-- -----------------------------------------------
-- Tabla: Productos
-- Descripción: Catálogo de productos
-- -----------------------------------------------
CREATE TABLE Productos (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    codigo_producto VARCHAR(50) UNIQUE NOT NULL,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    stock_minimo INT DEFAULT 5,
    id_categoria INT,
    marca VARCHAR(100),
    peso DECIMAL(8,2) COMMENT 'Peso en kilogramos',
    dimensiones VARCHAR(100) COMMENT 'Alto x Ancho x Largo en cm',
    imagen_url VARCHAR(255),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    estado ENUM('Disponible', 'Agotado', 'Descontinuado') DEFAULT 'Disponible',
    FOREIGN KEY (id_categoria) REFERENCES Categorias(id_categoria) 
        ON DELETE SET NULL 
        ON UPDATE CASCADE,
    INDEX idx_codigo (codigo_producto),
    INDEX idx_categoria (id_categoria),
    INDEX idx_nombre (nombre),
    INDEX idx_estado (estado),
    CHECK (precio >= 0),
    CHECK (stock >= 0),
    CHECK (stock_minimo >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Catálogo de productos';

-- -----------------------------------------------
-- Tabla: Empleados
-- Descripción: Información de empleados (estructura jerárquica)
-- -----------------------------------------------
CREATE TABLE Empleados (
    id_empleado INT AUTO_INCREMENT PRIMARY KEY,
    codigo_empleado VARCHAR(20) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    telefono VARCHAR(20),
    direccion VARCHAR(255),
    cargo VARCHAR(100),
    departamento VARCHAR(100),
    fecha_contratacion DATE NOT NULL,
    fecha_nacimiento DATE,
    salario DECIMAL(10,2),
    id_supervisor INT NULL,
    estado ENUM('Activo', 'Inactivo', 'Vacaciones', 'Licencia') DEFAULT 'Activo',
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_supervisor) REFERENCES Empleados(id_empleado) 
        ON DELETE SET NULL 
        ON UPDATE CASCADE,
    INDEX idx_codigo_emp (codigo_empleado),
    INDEX idx_departamento (departamento),
    INDEX idx_apellido_emp (apellido),
    INDEX idx_estado_emp (estado),
    CHECK (salario >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Información de empleados';

-- -----------------------------------------------
-- Tabla: Proveedores
-- Descripción: Proveedores de productos
-- -----------------------------------------------
CREATE TABLE Proveedores (
    id_proveedor INT AUTO_INCREMENT PRIMARY KEY,
    codigo_proveedor VARCHAR(20) UNIQUE NOT NULL,
    nombre_empresa VARCHAR(150) NOT NULL,
    nombre_contacto VARCHAR(100),
    cargo_contacto VARCHAR(100),
    email VARCHAR(150) UNIQUE,
    telefono VARCHAR(20),
    telefono_alternativo VARCHAR(20),
    direccion VARCHAR(255),
    ciudad VARCHAR(100),
    estado_provincia VARCHAR(100),
    codigo_postal VARCHAR(10),
    pais VARCHAR(100) DEFAULT 'Colombia',
    sitio_web VARCHAR(255),
    fecha_registro DATE NOT NULL,
    calificacion DECIMAL(3,2) DEFAULT 0.00 COMMENT 'Calificación de 0 a 5',
    estado ENUM('Activo', 'Inactivo', 'Suspendido') DEFAULT 'Activo',
    notas TEXT,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_codigo_prov (codigo_proveedor),
    INDEX idx_nombre_empresa (nombre_empresa),
    INDEX idx_pais (pais),
    CHECK (calificacion >= 0 AND calificacion <= 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Proveedores de productos';

-- -----------------------------------------------
-- Tabla: Pedidos
-- Descripción: Pedidos realizados por clientes
-- -----------------------------------------------
CREATE TABLE Pedidos (
    id_pedido INT AUTO_INCREMENT PRIMARY KEY,
    numero_pedido VARCHAR(50) UNIQUE NOT NULL,
    id_cliente INT NOT NULL,
    id_empleado INT NULL COMMENT 'Empleado que procesó el pedido',
    fecha_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_requerida DATE,
    fecha_envio DATE,
    fecha_entrega DATE,
    total DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    descuento DECIMAL(10,2) DEFAULT 0.00,
    impuestos DECIMAL(10,2) DEFAULT 0.00,
    total_final DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    estado ENUM('Pendiente', 'Procesando', 'Empacado', 'Enviado', 'Entregado', 'Cancelado') DEFAULT 'Pendiente',
    metodo_pago VARCHAR(50),
    estado_pago ENUM('Pendiente', 'Pagado', 'Reembolsado') DEFAULT 'Pendiente',
    direccion_envio VARCHAR(255),
    ciudad_envio VARCHAR(100),
    codigo_postal_envio VARCHAR(10),
    empresa_envio VARCHAR(100),
    numero_rastreo VARCHAR(100),
    notas TEXT,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    FOREIGN KEY (id_empleado) REFERENCES Empleados(id_empleado) 
        ON DELETE SET NULL 
        ON UPDATE CASCADE,
    INDEX idx_numero_pedido (numero_pedido),
    INDEX idx_fecha_pedido (fecha_pedido),
    INDEX idx_estado (estado),
    INDEX idx_cliente (id_cliente),
    INDEX idx_fecha_cliente (id_cliente, fecha_pedido),
    CHECK (total >= 0),
    CHECK (descuento >= 0),
    CHECK (impuestos >= 0),
    CHECK (total_final >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Pedidos de clientes';

-- -----------------------------------------------
-- Tabla: Detalle_Pedidos
-- Descripción: Detalle de productos por pedido
-- -----------------------------------------------
CREATE TABLE Detalle_Pedidos (
    id_detalle INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    descuento DECIMAL(10,2) DEFAULT 0.00,
    subtotal DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (id_pedido) REFERENCES Pedidos(id_pedido) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    FOREIGN KEY (id_producto) REFERENCES Productos(id_producto) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    INDEX idx_pedido (id_pedido),
    INDEX idx_producto (id_producto),
    UNIQUE KEY unique_pedido_producto (id_pedido, id_producto),
    CHECK (cantidad > 0),
    CHECK (precio_unitario >= 0),
    CHECK (descuento >= 0),
    CHECK (subtotal >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Detalle de pedidos';

-- -----------------------------------------------
-- Tabla: Productos_Proveedores (Relación N:N)
-- Descripción: Relación entre productos y proveedores
-- -----------------------------------------------
CREATE TABLE Productos_Proveedores (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_producto INT NOT NULL,
    id_proveedor INT NOT NULL,
    codigo_proveedor_producto VARCHAR(50) COMMENT 'Código del producto según el proveedor',
    precio_compra DECIMAL(10,2) NOT NULL,
    tiempo_entrega_dias INT DEFAULT 0,
    cantidad_minima_pedido INT DEFAULT 1,
    es_proveedor_principal BOOLEAN DEFAULT FALSE,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NULL,
    fecha_ultima_compra DATE,
    estado ENUM('Activo', 'Inactivo') DEFAULT 'Activo',
    FOREIGN KEY (id_producto) REFERENCES Productos(id_producto) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    FOREIGN KEY (id_proveedor) REFERENCES Proveedores(id_proveedor) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    UNIQUE KEY unique_producto_proveedor (id_producto, id_proveedor),
    INDEX idx_proveedor (id_proveedor),
    INDEX idx_producto_prov (id_producto),
    CHECK (precio_compra >= 0),
    CHECK (tiempo_entrega_dias >= 0),
    CHECK (cantidad_minima_pedido > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Relación productos-proveedores';

-- -----------------------------------------------
-- Tabla: Ordenes_Compra
-- Descripción: Órdenes de compra a proveedores
-- -----------------------------------------------
CREATE TABLE Ordenes_Compra (
    id_orden_compra INT AUTO_INCREMENT PRIMARY KEY,
    numero_orden VARCHAR(50) UNIQUE NOT NULL,
    id_proveedor INT NOT NULL,
    id_empleado INT NULL COMMENT 'Empleado que generó la orden',
    fecha_orden DATE NOT NULL,
    fecha_requerida DATE,
    fecha_recepcion DATE,
    total DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    estado ENUM('Pendiente', 'Aprobada', 'Enviada', 'Recibida', 'Cancelada') DEFAULT 'Pendiente',
    notas TEXT,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_proveedor) REFERENCES Proveedores(id_proveedor) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    FOREIGN KEY (id_empleado) REFERENCES Empleados(id_empleado) 
        ON DELETE SET NULL 
        ON UPDATE CASCADE,
    INDEX idx_numero_orden (numero_orden),
    INDEX idx_proveedor_orden (id_proveedor),
    INDEX idx_fecha_orden (fecha_orden),
    CHECK (total >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Órdenes de compra a proveedores';

-- -----------------------------------------------
-- Tabla: Detalle_Ordenes_Compra
-- Descripción: Detalle de productos por orden de compra
-- -----------------------------------------------
CREATE TABLE Detalle_Ordenes_Compra (
    id_detalle INT AUTO_INCREMENT PRIMARY KEY,
    id_orden_compra INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad_solicitada INT NOT NULL,
    cantidad_recibida INT DEFAULT 0,
    precio_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (id_orden_compra) REFERENCES Ordenes_Compra(id_orden_compra) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    FOREIGN KEY (id_producto) REFERENCES Productos(id_producto) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    INDEX idx_orden_compra (id_orden_compra),
    INDEX idx_producto_compra (id_producto),
    CHECK (cantidad_solicitada > 0),
    CHECK (cantidad_recibida >= 0),
    CHECK (precio_unitario >= 0),
    CHECK (subtotal >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Detalle de órdenes de compra';

-- -----------------------------------------------
-- Tabla: Pagos
-- Descripción: Pagos realizados por pedidos
-- -----------------------------------------------
CREATE TABLE Pagos (
    id_pago INT AUTO_INCREMENT PRIMARY KEY,
    numero_pago VARCHAR(50) UNIQUE NOT NULL,
    id_pedido INT NOT NULL,
    fecha_pago TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    monto DECIMAL(10,2) NOT NULL,
    metodo_pago ENUM('Tarjeta Crédito', 'Tarjeta Débito', 'Efectivo', 'Transferencia', 'PayPal', 'Otro') NOT NULL,
    estado ENUM('Completado', 'Pendiente', 'Rechazado', 'Reembolsado') DEFAULT 'Pendiente',
    referencia_transaccion VARCHAR(100),
    banco VARCHAR(100),
    numero_autorizacion VARCHAR(50),
    notas TEXT,
    FOREIGN KEY (id_pedido) REFERENCES Pedidos(id_pedido) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    INDEX idx_numero_pago (numero_pago),
    INDEX idx_pedido_pago (id_pedido),
    INDEX idx_fecha_pago (fecha_pago),
    INDEX idx_metodo_pago (metodo_pago),
    CHECK (monto >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Pagos de pedidos';

-- -----------------------------------------------
-- Tabla: Inventario (Movimientos)
-- Descripción: Historial de movimientos de inventario
-- -----------------------------------------------
CREATE TABLE Inventario (
    id_movimiento INT AUTO_INCREMENT PRIMARY KEY,
    id_producto INT NOT NULL,
    tipo_movimiento ENUM('Entrada', 'Salida', 'Ajuste', 'Devolución', 'Merma') NOT NULL,
    cantidad INT NOT NULL,
    fecha_movimiento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    id_empleado INT NULL,
    id_pedido INT NULL COMMENT 'Si es una salida por venta',
    id_orden_compra INT NULL COMMENT 'Si es una entrada por compra',
    motivo VARCHAR(255),
    stock_anterior INT NOT NULL,
    stock_nuevo INT NOT NULL,
    costo_unitario DECIMAL(10,2),
    FOREIGN KEY (id_producto) REFERENCES Productos(id_producto) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    FOREIGN KEY (id_empleado) REFERENCES Empleados(id_empleado) 
        ON DELETE SET NULL 
        ON UPDATE CASCADE,
    FOREIGN KEY (id_pedido) REFERENCES Pedidos(id_pedido) 
        ON DELETE SET NULL 
        ON UPDATE CASCADE,
    FOREIGN KEY (id_orden_compra) REFERENCES Ordenes_Compra(id_orden_compra) 
        ON DELETE SET NULL 
        ON UPDATE CASCADE,
    INDEX idx_producto_inv (id_producto),
    INDEX idx_fecha_movimiento (fecha_movimiento),
    INDEX idx_tipo_movimiento (tipo_movimiento),
    INDEX idx_empleado_inv (id_empleado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Movimientos de inventario';

-- -----------------------------------------------
-- Tabla: Devoluciones
-- Descripción: Devoluciones de productos por clientes
-- -----------------------------------------------
CREATE TABLE Devoluciones (
    id_devolucion INT AUTO_INCREMENT PRIMARY KEY,
    numero_devolucion VARCHAR(50) UNIQUE NOT NULL,
    id_pedido INT NOT NULL,
    id_cliente INT NOT NULL,
    fecha_devolucion DATE NOT NULL,
    motivo TEXT NOT NULL,
    estado ENUM('Solicitada', 'Aprobada', 'Rechazada', 'Completada') DEFAULT 'Solicitada',
    monto_devolucion DECIMAL(10,2) DEFAULT 0.00,
    metodo_reembolso VARCHAR(50),
    fecha_reembolso DATE,
    notas TEXT,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_pedido) REFERENCES Pedidos(id_pedido) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    INDEX idx_numero_dev (numero_devolucion),
    INDEX idx_pedido_dev (id_pedido),
    INDEX idx_cliente_dev (id_cliente),
    CHECK (monto_devolucion >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Devoluciones de productos';

-- -----------------------------------------------
-- Tabla: Detalle_Devoluciones
-- Descripción: Detalle de productos devueltos
-- -----------------------------------------------
CREATE TABLE Detalle_Devoluciones (
    id_detalle_devolucion INT AUTO_INCREMENT PRIMARY KEY,
    id_devolucion INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    condicion_producto ENUM('Nuevo', 'Usado', 'Dañado') NOT NULL,
    FOREIGN KEY (id_devolucion) REFERENCES Devoluciones(id_devolucion) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    FOREIGN KEY (id_producto) REFERENCES Productos(id_producto) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    INDEX idx_devolucion (id_devolucion),
    INDEX idx_producto_dev (id_producto),
    CHECK (cantidad > 0),
    CHECK (precio_unitario >= 0),
    CHECK (subtotal >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Detalle de devoluciones';

-- =====================================================
-- VISTAS
-- =====================================================

-- Vista: Resumen de Pedidos por Cliente
CREATE OR REPLACE VIEW Vista_Pedidos_Cliente AS
SELECT 
    c.id_cliente,
    c.codigo_postal,
    CONCAT(c.nombre, ' ', c.apellido) AS nombre_completo,
    c.email,
    c.ciudad,
    c.estado AS estado_cliente,
    COUNT(p.id_pedido) AS total_pedidos,
    SUM(CASE WHEN p.estado = 'Entregado' THEN 1 ELSE 0 END) AS pedidos_entregados,
    SUM(CASE WHEN p.estado = 'Cancelado' THEN 1 ELSE 0 END) AS pedidos_cancelados,
    COALESCE(SUM(p.total_final), 0) AS monto_total,
    COALESCE(AVG(p.total_final), 0) AS promedio_compra,
    MAX(p.fecha_pedido) AS ultima_compra,
    MIN(p.fecha_pedido) AS primera_compra,
    DATEDIFF(CURDATE(), MAX(p.fecha_pedido)) AS dias_desde_ultima_compra
FROM Clientes c
LEFT JOIN Pedidos p ON c.id_cliente = p.id_cliente
GROUP BY c.id_cliente, c.nombre, c.apellido, c.email, c.ciudad, c.codigo_postal, c.estado;

-- Vista: Productos Más Vendidos
CREATE OR REPLACE VIEW Vista_Productos_Vendidos AS
SELECT 
    pr.id_producto,
    pr.codigo_producto,
    pr.nombre,
    pr.marca,
    c.nombre AS categoria,
    pr.precio,
    pr.stock,
    pr.stock_minimo,
    pr.estado,
    COALESCE(SUM(dp.cantidad), 0) AS total_vendido,
    COALESCE(SUM(dp.subtotal), 0) AS ingresos_generados,
    COALESCE(AVG(dp.precio_unitario), pr.precio) AS precio_promedio_venta,
    COUNT(DISTINCT dp.id_pedido) AS numero_pedidos
FROM Productos pr
LEFT JOIN Detalle_Pedidos dp ON pr.id_producto = dp.id_producto
LEFT JOIN Pedidos p ON dp.id_pedido = p.id_pedido AND p.estado != 'Cancelado'
LEFT JOIN Categorias c ON pr.id_categoria = c.id_categoria
GROUP BY pr.id_producto, pr.codigo_producto, pr.nombre, pr.marca, c.nombre, 
         pr.precio, pr.stock, pr.stock_minimo, pr.estado
ORDER BY total_vendido DESC;

-- Vista: Estado de Inventario
CREATE OR REPLACE VIEW Vista_Estado_Inventario AS
SELECT 
    p.id_producto,
    p.codigo_producto,
    p.nombre,
    c.nombre AS categoria,
    p.stock,
    p.stock_minimo,
    p.precio,
    p.estado,
    CASE 
        WHEN p.stock = 0 THEN 'Crítico - Sin Stock'
        WHEN p.stock < p.stock_minimo THEN 'Bajo - Requiere Reabastecimiento'
        WHEN p.stock < (p.stock_minimo * 2) THEN 'Medio - Monitorear'
        ELSE 'Alto - Stock Suficiente'
    END AS nivel_stock,
    CASE 
        WHEN p.stock = 0 THEN 'Urgente'
        WHEN p.stock < p.stock_minimo THEN 'Alta'
        WHEN p.stock < (p.stock_minimo * 2) THEN 'Media'
        ELSE 'Baja'
    END AS prioridad_reabastecimiento,
    (p.stock_minimo * 2) - p.stock AS cantidad_sugerida_orden,
    p.fecha_actualizacion
FROM Productos p
LEFT JOIN Categorias c ON p.id_categoria = c.id_categoria
WHERE p.estado = 'Disponible';

-- Vista: Ventas por Mes
CREATE OR REPLACE VIEW Vista_Ventas_Mensuales AS
SELECT 
    YEAR(p.fecha_pedido) AS año,
    MONTH(p.fecha_pedido) AS mes,
    DATE_FORMAT(p.fecha_pedido, '%Y-%m') AS periodo,
    COUNT(p.id_pedido) AS total_pedidos,
    SUM(CASE WHEN p.estado = 'Entregado' THEN 1 ELSE 0 END) AS pedidos_completados,
    SUM(CASE WHEN p.estado = 'Cancelado' THEN 1 ELSE 0 END) AS pedidos_cancelados,
    COALESCE(SUM(CASE WHEN p.estado != 'Cancelado' THEN p.total_final ELSE 0 END), 0) AS total_ventas,
    COALESCE(AVG(CASE WHEN p.estado != 'Cancelado' THEN p.total_final ELSE NULL END), 0) AS ticket_promedio,
    COUNT(DISTINCT p.id_cliente) AS clientes_unicos
FROM Pedidos p
GROUP BY YEAR(p.fecha_pedido), MONTH(p.fecha_pedido), DATE_FORMAT(p.fecha_pedido, '%Y-%m')
ORDER BY año DESC, mes DESC;

-- Vista: Productos por Proveedor
CREATE OR REPLACE VIEW Vista_Productos_Proveedor AS
SELECT 
    prov.id_proveedor,
    prov.nombre_empresa,
    prov.ciudad,
    prov.pais,
    prov.calificacion,
    COUNT(pp.id_producto) AS total_productos,
    AVG(pp.precio_compra) AS precio_compra_promedio,
    SUM(CASE WHEN pp.es_proveedor_principal = TRUE THEN 1 ELSE 0 END) AS productos_principal,
    MIN(pp.fecha_inicio) AS proveedor_desde
FROM Proveedores prov
LEFT JOIN Productos_Proveedores pp ON prov.id_proveedor = pp.id_proveedor
WHERE prov.estado = 'Activo' AND (pp.estado = 'Activo' OR pp.estado IS NULL)
GROUP BY prov.id_proveedor, prov.nombre_empresa, prov.ciudad, prov.pais, prov.calificacion;

-- Vista: Rendimiento de Empleados (Ventas)
CREATE OR REPLACE VIEW Vista_Rendimiento_Empleados AS
SELECT 
    e.id_empleado,
    e.codigo_empleado,
    CONCAT(e.nombre, ' ', e.apellido) AS nombre_completo,
    e.cargo,
    e.departamento,
    COUNT(p.id_pedido) AS pedidos_procesados,
    COALESCE(SUM(CASE WHEN p.estado != 'Cancelado' THEN p.total_final ELSE 0 END), 0) AS total_ventas,
    COALESCE(AVG(CASE WHEN p.estado != 'Cancelado' THEN p.total_final ELSE NULL END), 0) AS ticket_promedio,
    MAX(p.fecha_pedido) AS ultima_venta
FROM Empleados e
LEFT JOIN Pedidos p ON e.id_empleado = p.id_empleado
WHERE e.estado = 'Activo'
GROUP BY e.id_empleado, e.codigo_empleado, e.nombre, e.apellido, e.cargo, e.departamento;

-- =====================================================
-- PROCEDIMIENTOS ALMACENADOS
-- =====================================================

DELIMITER //

-- Procedimiento: Registrar Nueva Venta
CREATE PROCEDURE sp_registrar_venta(
    IN p_id_cliente INT,
    IN p_id_empleado INT,
    IN p_id_producto INT,
    IN p_cantidad INT,
    IN p_metodo_pago VARCHAR(50),
    IN p_direccion_envio VARCHAR(255),
    OUT p_id_pedido INT,
    OUT p_mensaje VARCHAR(255)
)
BEGIN
    DECLARE v_precio DECIMAL(10,2);
    DECLARE v_stock_actual INT;
    DECLARE v_subtotal DECIMAL(10,2);
    DECLARE v_numero_pedido VARCHAR(50);
    DECLARE v_stock_nuevo INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_mensaje = 'Error al procesar la venta';
        SET p_id_pedido = 0;
    END;
    
    START TRANSACTION;
    
    -- Verificar que el producto exista y obtener información
    SELECT precio, stock INTO v_precio, v_stock_actual
    FROM Productos
    WHERE id_producto = p_id_producto AND estado = 'Disponible';
    
    IF v_precio IS NULL THEN
        SET p_mensaje = 'Producto no encontrado o no disponible';
        SET p_id_pedido = 0;
        ROLLBACK;
    ELSEIF v_stock_actual < p_cantidad THEN
        SET p_mensaje = CONCAT('Stock insuficiente. Disponible: ', v_stock_actual);
        SET p_id_pedido = 0;
        ROLLBACK;
    ELSE
        -- Generar número de pedido
        SET v_numero_pedido = CONCAT('PED-', DATE_FORMAT(NOW(), '%Y%m%d'), '-', 
                                     LPAD((SELECT COALESCE(MAX(CAST(SUBSTRING(numero_pedido, -6) AS UNSIGNED)), 0) + 1 
                                           FROM Pedidos 
                                           WHERE numero_pedido LIKE CONCAT('PED-', DATE_FORMAT(NOW(), '%Y%m%d'), '%')), 6, '0'));
        
        -- Calcular subtotal
        SET v_subtotal = v_precio * p_cantidad;
        
        -- Crear pedido
        INSERT INTO Pedidos (
            numero_pedido, 
            id_cliente, 
            id_empleado, 
            total, 
            total_final, 
            metodo_pago, 
            direccion_envio, 
            estado,
            estado_pago
        )
        VALUES (
            v_numero_pedido, 
            p_id_cliente, 
            p_id_empleado, 
            v_subtotal, 
            v_subtotal, 
            p_metodo_pago, 
            p_direccion_envio, 
            'Procesando',
            'Pendiente'
        );
        
        SET p_id_pedido = LAST_INSERT_ID();
        
        -- Crear detalle del pedido
        INSERT INTO Detalle_Pedidos (
            id_pedido, 
            id_producto, 
            cantidad, 
            precio_unitario, 
            subtotal
        )
        VALUES (
            p_id_pedido, 
            p_id_producto, 
            p_cantidad, 
            v_precio, 
            v_subtotal
        );
        
        -- Calcular nuevo stock
        SET v_stock_nuevo = v_stock_actual - p_cantidad;
        
        -- Actualizar stock
        UPDATE Productos
        SET stock = v_stock_nuevo,
            estado = CASE 
                WHEN v_stock_nuevo = 0 THEN 'Agotado'
                ELSE estado
            END
        WHERE id_producto = p_id_producto;
        
        -- Registrar movimiento de inventario
        INSERT INTO Inventario (
            id_producto, 
            tipo_movimiento, 
            cantidad, 
            id_empleado,
            id_pedido,
            stock_anterior, 
            stock_nuevo, 
            motivo,
            costo_unitario
        )
        VALUES (
            p_id_producto, 
            'Salida', 
            p_cantidad, 
            p_id_empleado,
            p_id_pedido,
            v_stock_actual, 
            v_stock_nuevo, 
            CONCAT('Venta - Pedido ', v_numero_pedido),
            v_precio
        );
        
        SET p_mensaje = CONCAT('Venta registrada exitosamente. Pedido: ', v_numero_pedido);
        COMMIT;
    END IF;
END //

-- Procedimiento: Actualizar Stock del Producto
CREATE PROCEDURE sp_actualizar_stock(
    IN p_id_producto INT,
    IN p_cantidad INT,
    IN p_tipo VARCHAR(20),
    IN p_id_empleado INT,
    IN p_motivo VARCHAR(255),
    OUT p_mensaje VARCHAR(255)
)
BEGIN
    DECLARE v_stock_actual INT;
    DECLARE v_stock_nuevo INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_mensaje = 'Error al actualizar el stock';
    END;
    
    START TRANSACTION;
    
    -- Obtener stock actual
    SELECT stock INTO v_stock_actual
    FROM Productos
    WHERE id_producto = p_id_producto;
    
    IF v_stock_actual IS NULL THEN
        SET p_mensaje = 'Producto no encontrado';
        ROLLBACK;
    ELSE
        -- Calcular nuevo stock según el tipo de movimiento
        IF p_tipo = 'Entrada' THEN
            SET v_stock_nuevo = v_stock_actual + p_cantidad;
        ELSEIF p_tipo = 'Salida' THEN
            IF v_stock_actual < p_cantidad THEN
                SET p_mensaje = CONCAT('Stock insuficiente para la salida. Disponible: ', v_stock_actual);
                ROLLBACK;
            ELSE
                SET v_stock_nuevo = v_stock_actual - p_cantidad;
            END IF;
        ELSEIF p_tipo = 'Ajuste' THEN
            SET v_stock_nuevo = p_cantidad;
        ELSE
            SET p_mensaje = 'Tipo de movimiento inválido';
            ROLLBACK;
        END IF;
        
        IF p_mensaje IS NULL THEN
            -- Actualizar stock del producto
            UPDATE Productos
            SET stock = v_stock_nuevo,
                estado = CASE 
                    WHEN v_stock_nuevo = 0 THEN 'Agotado'
                    WHEN v_stock_nuevo > 0 AND estado = 'Agotado' THEN 'Disponible'
                    ELSE estado
                END
            WHERE id_producto = p_id_producto;
            
            -- Registrar movimiento en el historial
            INSERT INTO Inventario (
                id_producto, 
                tipo_movimiento, 
                cantidad, 
                id_empleado, 
                motivo, 
                stock_anterior, 
                stock_nuevo
            )
            VALUES (
                p_id_producto, 
                p_tipo, 
                ABS(v_stock_nuevo - v_stock_actual), 
                p_id_empleado, 
                p_motivo, 
                v_stock_actual, 
                v_stock_nuevo
            );
            
            SET p_mensaje = CONCAT('Stock actualizado correctamente. Nuevo stock: ', v_stock_nuevo);
            COMMIT;
        END IF;
    END IF;
END //

-- Procedimiento: Procesar Devolución
CREATE PROCEDURE sp_procesar_devolucion(
    IN p_id_pedido INT,
    IN p_id_producto INT,
    IN p_cantidad INT,
    IN p_motivo TEXT,
    OUT p_id_devolucion INT,
    OUT p_mensaje VARCHAR(255)
)
BEGIN
    DECLARE v_id_cliente INT;
    DECLARE v_precio_unitario DECIMAL(10,2);
    DECLARE v_cantidad_pedido INT;
    DECLARE v_monto_devolucion DECIMAL(10,2);
    DECLARE v_numero_devolucion VARCHAR(50);
    DECLARE v_stock_actual INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_mensaje = 'Error al procesar la devolución';
        SET p_id_devolucion = 0;
    END;
    
    START TRANSACTION;
    
    -- Obtener información del pedido
    SELECT ped.id_cliente, dp.precio_unitario, dp.cantidad
    INTO v_id_cliente, v_precio_unitario, v_cantidad_pedido
    FROM Pedidos ped
    INNER JOIN Detalle_Pedidos dp ON ped.id_pedido = dp.id_pedido
    WHERE ped.id_pedido = p_id_pedido 
    AND dp.id_producto = p_id_producto;
    
    IF v_id_cliente IS NULL THEN
        SET p_mensaje = 'Pedido o producto no encontrado';
        SET p_id_devolucion = 0;
        ROLLBACK;
    ELSEIF p_cantidad > v_cantidad_pedido THEN
        SET p_mensaje = 'Cantidad a devolver excede la cantidad del pedido';
        SET p_id_devolucion = 0;
        ROLLBACK;
    ELSE
        -- Generar número de devolución
        SET v_numero_devolucion = CONCAT('DEV-', DATE_FORMAT(NOW(), '%Y%m%d'), '-', 
                                        LPAD((SELECT COALESCE(MAX(CAST(SUBSTRING(numero_devolucion, -6) AS UNSIGNED)), 0) + 1 
                                              FROM Devoluciones 
                                              WHERE numero_devolucion LIKE CONCAT('DEV-', DATE_FORMAT(NOW(), '%Y%m%d'), '%')), 6, '0'));
        
        -- Calcular monto de devolución
        SET v_monto_devolucion = v_precio_unitario * p_cantidad;
        
        -- Crear registro de devolución
        INSERT INTO Devoluciones (
            numero_devolucion,
            id_pedido,
            id_cliente,
            fecha_devolucion,
            motivo,
            estado,
            monto_devolucion
        )
        VALUES (
            v_numero_devolucion,
            p_id_pedido,
            v_id_cliente,
            CURDATE(),
            p_motivo,
            'Solicitada',
            v_monto_devolucion
        );
        
        SET p_id_devolucion = LAST_INSERT_ID();
        
        -- Crear detalle de devolución
        INSERT INTO Detalle_Devoluciones (
            id_devolucion,
            id_producto,
            cantidad,
            precio_unitario,
            subtotal,
            condicion_producto
        )
        VALUES (
            p_id_devolucion,
            p_id_producto,
            p_cantidad,
            v_precio_unitario,
            v_monto_devolucion,
            'Usado'
        );
        
        -- Actualizar stock (devolver productos al inventario)
        SELECT stock INTO v_stock_actual FROM Productos WHERE id_producto = p_id_producto;
        
        UPDATE Productos
        SET stock = stock + p_cantidad,
            estado = CASE 
                WHEN estado = 'Agotado' AND (stock + p_cantidad) > 0 THEN 'Disponible'
                ELSE estado
            END
        WHERE id_producto = p_id_producto;
        
        -- Registrar movimiento de inventario
        INSERT INTO Inventario (
            id_producto,
            tipo_movimiento,
            cantidad,
            id_pedido,
            motivo,
            stock_anterior,
            stock_nuevo
        )
        VALUES (
            p_id_producto,
            'Devolución',
            p_cantidad,
            p_id_pedido,
            CONCAT('Devolución - ', v_numero_devolucion),
            v_stock_actual,
            v_stock_actual + p_cantidad
        );
        
        SET p_mensaje = CONCAT('Devolución procesada exitosamente. Número: ', v_numero_devolucion);
        COMMIT;
    END IF;
END //

-- Procedimiento: Obtener Productos con Stock Bajo
CREATE PROCEDURE sp_productos_stock_bajo()
BEGIN
    SELECT 
        p.id_producto,
        p.codigo_producto,
        p.nombre,
        c.nombre AS categoria,
        p.stock,
        p.stock_minimo,
        (p.stock_minimo * 2) - p.stock AS cantidad_sugerida,
        p.precio,
        COUNT(pp.id_proveedor) AS num_proveedores
    FROM Productos p
    LEFT JOIN Categorias c ON p.id_categoria = c.id_categoria
    LEFT JOIN Productos_Proveedores pp ON p.id_producto = pp.id_producto AND pp.estado = 'Activo'
    WHERE p.stock <= p.stock_minimo 
    AND p.estado = 'Disponible'
    GROUP BY p.id_producto, p.codigo_producto, p.nombre, c.nombre, p.stock, p.stock_minimo, p.precio
    ORDER BY p.stock ASC;
END //

-- Procedimiento: Reporte de Ventas por Período
CREATE PROCEDURE sp_reporte_ventas_periodo(
    IN p_fecha_inicio DATE,
    IN p_fecha_fin DATE
)
BEGIN
    SELECT 
        DATE_FORMAT(p.fecha_pedido, '%Y-%m-%d') AS fecha,
        COUNT(p.id_pedido) AS total_pedidos,
        SUM(CASE WHEN p.estado = 'Entregado' THEN 1 ELSE 0 END) AS pedidos_entregados,
        SUM(CASE WHEN p.estado = 'Cancelado' THEN 1 ELSE 0 END) AS pedidos_cancelados,
        COALESCE(SUM(CASE WHEN p.estado != 'Cancelado' THEN p.total_final ELSE 0 END), 0) AS total_ventas,
        COALESCE(AVG(CASE WHEN p.estado != 'Cancelado' THEN p.total_final ELSE NULL END), 0) AS ticket_promedio,
        COUNT(DISTINCT p.id_cliente) AS clientes_unicos,
        COUNT(DISTINCT dp.id_producto) AS productos_distintos,
        COALESCE(SUM(dp.cantidad), 0) AS unidades_vendidas
    FROM Pedidos p
    LEFT JOIN Detalle_Pedidos dp ON p.id_pedido = dp.id_pedido
    WHERE p.fecha_pedido BETWEEN p_fecha_inicio AND p_fecha_fin
    GROUP BY DATE_FORMAT(p.fecha_pedido, '%Y-%m-%d')
    ORDER BY fecha;
END //

DELIMITER ;

-- =====================================================
-- TRIGGERS
-- =====================================================

DELIMITER //

-- Trigger: Actualizar total del pedido después de insertar detalle
CREATE TRIGGER tr_actualizar_total_pedido_insert
AFTER INSERT ON Detalle_Pedidos
FOR EACH ROW
BEGIN
    UPDATE Pedidos
    SET total = (
        SELECT COALESCE(SUM(subtotal - descuento), 0)
        FROM Detalle_Pedidos
        WHERE id_pedido = NEW.id_pedido
    ),
    total_final = (
        SELECT COALESCE(SUM(subtotal - descuento), 0) + COALESCE(impuestos, 0) - COALESCE(descuento, 0)
        FROM Detalle_Pedidos
        WHERE id_pedido = NEW.id_pedido
    )
    WHERE id_pedido = NEW.id_pedido;
END //

-- Trigger: Actualizar total del pedido después de actualizar detalle
CREATE TRIGGER tr_actualizar_total_pedido_update
AFTER UPDATE ON Detalle_Pedidos
FOR EACH ROW
BEGIN
    UPDATE Pedidos
    SET total = (
        SELECT COALESCE(SUM(subtotal - descuento), 0)
        FROM Detalle_Pedidos
        WHERE id_pedido = NEW.id_pedido
    ),
    total_final = (
        SELECT COALESCE(SUM(subtotal - descuento), 0) + COALESCE(impuestos, 0) - COALESCE(descuento, 0)
        FROM Detalle_Pedidos
        WHERE id_pedido = NEW.id_pedido
    )
    WHERE id_pedido = NEW.id_pedido;
END //

-- Trigger: Actualizar total del pedido después de eliminar detalle
CREATE TRIGGER tr_actualizar_total_pedido_delete
AFTER DELETE ON Detalle_Pedidos
FOR EACH ROW
BEGIN
    UPDATE Pedidos
    SET total = (
        SELECT COALESCE(SUM(subtotal - descuento), 0)
        FROM Detalle_Pedidos
        WHERE id_pedido = OLD.id_pedido
    ),
    total_final = (
        SELECT COALESCE(SUM(subtotal - descuento), 0) + COALESCE(impuestos, 0) - COALESCE(descuento, 0)
        FROM Detalle_Pedidos
        WHERE id_pedido = OLD.id_pedido
    )
    WHERE id_pedido = OLD.id_pedido;
END //

-- Trigger: Calcular subtotal automáticamente antes de insertar
CREATE TRIGGER tr_calcular_subtotal_insert
BEFORE INSERT ON Detalle_Pedidos
FOR EACH ROW
BEGIN
    SET NEW.subtotal = (NEW.cantidad * NEW.precio_unitario) - NEW.descuento;
END //

-- Trigger: Calcular subtotal automáticamente antes de actualizar
CREATE TRIGGER tr_calcular_subtotal_update
BEFORE UPDATE ON Detalle_Pedidos
FOR EACH ROW
BEGIN
    SET NEW.subtotal = (NEW.cantidad * NEW.precio_unitario) - NEW.descuento;
END //

-- Trigger: Generar código de producto automáticamente
CREATE TRIGGER tr_generar_codigo_producto
BEFORE INSERT ON Productos
FOR EACH ROW
BEGIN
    IF NEW.codigo_producto IS NULL OR NEW.codigo_producto = '' THEN
        SET NEW.codigo_producto = CONCAT('PROD-', LPAD((SELECT COALESCE(MAX(id_producto), 0) + 1 FROM Productos), 6, '0'));
    END IF;
END //

-- Trigger: Generar código de cliente automáticamente
CREATE TRIGGER tr_generar_codigo_cliente
BEFORE INSERT ON Clientes
FOR EACH ROW
BEGIN
    DECLARE v_contador INT;
    SELECT COUNT(*) + 1 INTO v_contador FROM Clientes;
    -- No generamos código aquí ya que no hay campo codigo_cliente en la tabla actual
END //

-- Trigger: Generar código de empleado automáticamente
CREATE TRIGGER tr_generar_codigo_empleado
BEFORE INSERT ON Empleados
FOR EACH ROW
BEGIN
    IF NEW.codigo_empleado IS NULL OR NEW.codigo_empleado = '' THEN
        SET NEW.codigo_empleado = CONCAT('EMP-', LPAD((SELECT COALESCE(MAX(id_empleado), 0) + 1 FROM Empleados), 4, '0'));
    END IF;
END //

-- Trigger: Generar código de proveedor automáticamente
CREATE TRIGGER tr_generar_codigo_proveedor
BEFORE INSERT ON Proveedores
FOR EACH ROW
BEGIN
    IF NEW.codigo_proveedor IS NULL OR NEW.codigo_proveedor = '' THEN
        SET NEW.codigo_proveedor = CONCAT('PROV-', LPAD((SELECT COALESCE(MAX(id_proveedor), 0) + 1 FROM Proveedores), 4, '0'));
    END IF;
END //

-- Trigger: Validar que haya stock suficiente antes de confirmar venta
CREATE TRIGGER tr_validar_stock_venta
BEFORE INSERT ON Detalle_Pedidos
FOR EACH ROW
BEGIN
    DECLARE v_stock_disponible INT;
    DECLARE v_nombre_producto VARCHAR(150);
    
    SELECT stock, nombre INTO v_stock_disponible, v_nombre_producto
    FROM Productos
    WHERE id_producto = NEW.id_producto;
    
    IF v_stock_disponible < NEW.cantidad THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Stock insuficiente para completar el pedido';
    END IF;
END //

-- Trigger: Actualizar total de orden de compra
CREATE TRIGGER tr_actualizar_total_orden_compra
AFTER INSERT ON Detalle_Ordenes_Compra
FOR EACH ROW
BEGIN
    UPDATE Ordenes_Compra
    SET total = (
        SELECT COALESCE(SUM(subtotal), 0)
        FROM Detalle_Ordenes_Compra
        WHERE id_orden_compra = NEW.id_orden_compra
    )
    WHERE id_orden_compra = NEW.id_orden_compra;
END //

DELIMITER ;

-- =====================================================
-- ÍNDICES ADICIONALES PARA OPTIMIZACIÓN
-- =====================================================

-- Índices compuestos para mejores consultas
CREATE INDEX idx_pedido_cliente_fecha ON Pedidos(id_cliente, fecha_pedido, estado);
CREATE INDEX idx_pedido_fecha_estado ON Pedidos(fecha_pedido, estado);
CREATE INDEX idx_producto_categoria_estado ON Productos(id_categoria, estado, stock);
CREATE INDEX idx_detalle_pedido_completo ON Detalle_Pedidos(id_pedido, id_producto, cantidad);
CREATE INDEX idx_inventario_producto_fecha ON Inventario(id_producto, fecha_movimiento);
CREATE INDEX idx_pago_fecha_estado ON Pagos(fecha_pago, estado);

-- =====================================================
-- DATOS DE EJEMPLO (OPCIONAL - COMENTADO)
-- =====================================================

/*
-- Insertar categorías de ejemplo
INSERT INTO Categorias (nombre, descripcion) VALUES
('Electrónica', 'Dispositivos electrónicos, computadoras y accesorios tecnológicos'),
('Electrodomésticos', 'Aparatos eléctricos para el hogar'),
('Ropa y Moda', 'Prendas de vestir, calzado y accesorios de moda'),
('Hogar y Decoración', 'Muebles, decoración y artículos para el hogar'),
('Deportes y Fitness', 'Artículos deportivos, gimnasio y actividades al aire libre'),
('Libros y Medios', 'Libros, revistas, música y películas'),
('Juguetes y Juegos', 'Juguetes, juegos de mesa y videojuegos'),
('Salud y Belleza', 'Productos de cuidado personal, cosmética y salud');

-- Insertar clientes de ejemplo
INSERT INTO Clientes (nombre, apellido, email, telefono, direccion, ciudad, codigo_postal, fecha_registro) VALUES
('Juan', 'Pérez García', 'juan.perez@email.com', '300-1234567', 'Calle 123 #45-67', 'Bogotá', '110111', '2024-01-15'),
('María', 'González López', 'maria.gonzalez@email.com', '310-2345678', 'Carrera 8 #34-56', 'Medellín', '050001', '2024-02-20'),
('Carlos', 'Rodríguez Martínez', 'carlos.rodriguez@email.com', '320-3456789', 'Avenida 5 #78-90', 'Cali', '760001', '2024-03-10'),
('Ana', 'Martínez Silva', 'ana.martinez@email.com', '315-4567890', 'Calle 50 #12-34', 'Barranquilla', '080001', '2024-03-25'),
('Luis', 'Fernández Torres', 'luis.fernandez@email.com', '301-5678901', 'Carrera 15 #67-89', 'Cartagena', '130001', '2024-04-05');

-- Insertar productos de ejemplo
INSERT INTO Productos (codigo_producto, nombre, descripcion, precio, stock, stock_minimo, id_categoria, marca) VALUES
('PROD-000001', 'Laptop HP Pavilion', 'Laptop HP 15.6" Intel Core i5, 8GB RAM, 512GB SSD', 2500000.00, 15, 5, 1, 'HP'),
('PROD-000002', 'Mouse Logitech Inalámbrico', 'Mouse óptico inalámbrico con receptor USB', 45000.00, 50, 10, 1, 'Logitech'),
('PROD-000003', 'Teclado Mecánico Gaming', 'Teclado mecánico retroiluminado RGB', 180000.00, 25, 5, 1, 'Razer'),
('PROD-000004', 'Monitor Samsung 24"', 'Monitor LED Full HD 24 pulgadas', 650000.00, 12, 3, 1, 'Samsung'),
('PROD-000005', 'Nevera LG 420L', 'Nevera LG No Frost 420 litros', 2200000.00, 8, 2, 2, 'LG'),
('PROD-000006', 'Microondas Panasonic', 'Horno microondas 1.2 cu ft', 380000.00, 15, 4, 2, 'Panasonic'),
('PROD-000007', 'Camiseta Deportiva Nike', 'Camiseta Dri-FIT para deporte', 85000.00, 100, 20, 3, 'Nike'),
('PROD-000008', 'Zapatillas Running Adidas', 'Zapatillas para correr Ultraboost', 450000.00, 30, 8, 5, 'Adidas'),
('PROD-000009', 'Sofá 3 Puestos', 'Sofá moderno tapizado en tela', 1800000.00, 5, 2, 4, 'Generic'),
('PROD-000010', 'Bicicleta Montaña', 'Bicicleta de montaña aro 29', 1500000.00, 10, 3, 5, 'Trek');

-- Insertar empleados de ejemplo
INSERT INTO Empleados (codigo_empleado, nombre, apellido, email, telefono, cargo, departamento, fecha_contratacion, salario) VALUES
('EMP-0001', 'Ana', 'Martínez Ruiz', 'ana.martinez@empresa.com', '300-1111111', 'Gerente de Ventas', 'Ventas', '2023-01-10', 5000000.00),
('EMP-0002', 'Pedro', 'López Gómez', 'pedro.lopez@empresa.com', '310-2222222', 'Vendedor Senior', 'Ventas', '2023-06-15', 3000000.00),
('EMP-0003', 'Laura', 'Ramírez Castro', 'laura.ramirez@empresa.com', '320-3333333', 'Vendedor', 'Ventas', '2024-01-20', 2500000.00),
('EMP-0004', 'Diego', 'Torres Mendoza', 'diego.torres@empresa.com', '315-4444444', 'Gerente de Compras', 'Compras', '2023-03-01', 4800000.00),
('EMP-0005', 'Sofia', 'Hernández Díaz', 'sofia.hernandez@empresa.com', '301-5555555', 'Supervisor Inventario', 'Logística', '2023-08-10', 3500000.00);

-- Establecer relaciones jerárquicas de empleados
UPDATE Empleados SET id_supervisor = 1 WHERE id_empleado IN (2, 3);
UPDATE Empleados SET id_supervisor = 4 WHERE id_empleado = 5;

-- Insertar proveedores de ejemplo
INSERT INTO Proveedores (codigo_proveedor, nombre_empresa, nombre_contacto, email, telefono, ciudad, pais, fecha_registro, calificacion) VALUES
('PROV-0001', 'Tech Supplies Colombia', 'Roberto Silva', 'contacto@techsupplies.co', '601-5551000', 'Bogotá', 'Colombia', '2023-01-01', 4.50),
('PROV-0002', 'Electrodomésticos del Valle', 'Carmen Díaz', 'ventas@electroval.co', '602-3331000', 'Cali', 'Colombia', '2023-02-15', 4.20),
('PROV-0003', 'Sports World International', 'Laura Ramírez', 'info@sportsworld.com', '604-2221000', 'Medellín', 'Colombia', '2023-03-10', 4.80),
('PROV-0004', 'Fashion Imports SAS', 'Miguel Ángel Torres', 'compras@fashionimports.co', '605-4441000', 'Barranquilla', 'Colombia', '2023-05-20', 4.30);

-- Insertar relaciones productos-proveedores
INSERT INTO Productos_Proveedores (id_producto, id_proveedor, precio_compra, es_proveedor_principal, fecha_inicio) VALUES
(1, 1, 2000000.00, TRUE, '2023-01-15'),
(2, 1, 30000.00, TRUE, '2023-01-15'),
(3, 1, 120000.00, TRUE, '2023-02-01'),
(4, 1, 450000.00, TRUE, '2023-02-10'),
(5, 2, 1800000.00, TRUE, '2023-03-01'),
(6, 2, 280000.00, TRUE, '2023-03-01'),
(7, 4, 45000.00, TRUE, '2023-04-15'),
(8, 3, 300000.00, TRUE, '2023-05-01'),
(9, 2, 1200000.00, TRUE, '2023-06-01'),
(10, 3, 1000000.00, TRUE, '2023-07-15');
*/

-- =====================================================
-- FIN DEL SCRIPT SQL
-- =====================================================

-- Para ejecutar este script:
-- 1. Abrir MySQL Workbench o línea de comandos MySQL
-- 2. Ejecutar: SOURCE ruta/al/archivo/sistema_gestion_database.sql;
-- 3. O copiar y pegar el contenido completo en el editor SQL

-- Notas importantes:
-- - Este script crea una base de datos completa con todas las relaciones
-- - Incluye constraints, índices y optimizaciones
-- - Los triggers mantienen la integridad de los datos automáticamente
-- - Los procedimientos almacenados facilitan operaciones comunes
-- - Las vistas proporcionan consultas complejas preconfiguradas
