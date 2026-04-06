CREATE DATABASE ferrelectricos_bonilla_berlin
CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE ferrelectricos_bonilla_berlin;

-- ==========================================
-- 1. NÚCLEO GEOGRÁFICO Y PARAMÉTRICO
-- ==========================================

CREATE TABLE departamentos (
    id_departamento INT AUTO_INCREMENT PRIMARY KEY,
    codigo_dane_dep VARCHAR(5) UNIQUE NOT NULL,
    nombre_departamento VARCHAR(50) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE ciudades (
    id_ciudad INT AUTO_INCREMENT PRIMARY KEY,
    id_departamento INT NOT NULL,
    codigo_dane_mun VARCHAR(10) UNIQUE NOT NULL,
    nombre_ciudad VARCHAR(50) NOT NULL,
    FOREIGN KEY (id_departamento) REFERENCES departamentos(id_departamento)
) ENGINE=InnoDB;

CREATE TABLE estados (
    id_estado INT AUTO_INCREMENT PRIMARY KEY,
    nombre_estado VARCHAR(30) UNIQUE NOT NULL,
    descripcion VARCHAR(255),
    color_representativo VARCHAR(7)
) ENGINE=InnoDB;

CREATE TABLE tipos_documento (
    id_tipo_doc INT AUTO_INCREMENT PRIMARY KEY,
    sigla VARCHAR(5) UNIQUE NOT NULL,
    nombre_completo VARCHAR(100) NOT NULL
) ENGINE=InnoDB;

-- ==========================================
-- 2. SEGURIDAD
-- ==========================================

CREATE TABLE roles (
    id_rol INT AUTO_INCREMENT PRIMARY KEY,
    nombre_rol VARCHAR(50) UNIQUE NOT NULL,
    descripcion TEXT
) ENGINE=InnoDB;

CREATE TABLE permisos (
    id_permiso INT AUTO_INCREMENT PRIMARY KEY,
    clave_permiso VARCHAR(100) UNIQUE NOT NULL,
    descripcion VARCHAR(255)
) ENGINE=InnoDB;

CREATE TABLE roles_permisos (
    id_rol INT NOT NULL,
    id_permiso INT NOT NULL,
    PRIMARY KEY (id_rol, id_permiso),
    FOREIGN KEY (id_rol) REFERENCES roles(id_rol),
    FOREIGN KEY (id_permiso) REFERENCES permisos(id_permiso)
) ENGINE=InnoDB;

CREATE TABLE usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    id_rol INT NOT NULL,
    id_estado INT NOT NULL DEFAULT 1,
    id_tipo_doc INT NOT NULL,
    numero_identificacion VARCHAR(20) UNIQUE NOT NULL,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    contrasena_hash VARCHAR(255) NOT NULL,
    telefono VARCHAR(20),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_rol) REFERENCES roles(id_rol),
    FOREIGN KEY (id_estado) REFERENCES estados(id_estado),
    FOREIGN KEY (id_tipo_doc) REFERENCES tipos_documento(id_tipo_doc)
) ENGINE=InnoDB;

CREATE TABLE auditoria_transaccional (
    id_auditoria BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    tabla_afectada VARCHAR(50) NOT NULL,
    id_registro_afectado INT NOT NULL,
    accion ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    estado_anterior JSON,
    estado_nuevo JSON,
    ip_origen VARCHAR(45),
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
) ENGINE=InnoDB;

-- ==========================================
-- 3. PRODUCTOS
-- ==========================================

CREATE TABLE categorias (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nombre_categoria VARCHAR(100) NOT NULL,
    id_padre INT NULL,
    id_estado INT NOT NULL DEFAULT 1,
    FOREIGN KEY (id_padre) REFERENCES categorias(id_categoria),
    FOREIGN KEY (id_estado) REFERENCES estados(id_estado)
) ENGINE=InnoDB;

CREATE TABLE unidades_medida (
    id_unidad INT AUTO_INCREMENT PRIMARY KEY,
    nombre_unidad VARCHAR(50) NOT NULL,
    sigla_dian VARCHAR(10) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE tasas_iva (
    id_iva INT AUTO_INCREMENT PRIMARY KEY,
    porcentaje DECIMAL(5,2) NOT NULL,
    descripcion VARCHAR(50) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE productos (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    sku_interno VARCHAR(50) UNIQUE NOT NULL,
    codigo_barras VARCHAR(100) UNIQUE,
    nombre_producto VARCHAR(200) NOT NULL,
    descripcion_corta VARCHAR(255),
    descripcion_larga TEXT,
    id_categoria INT NOT NULL,
    id_unidad INT NOT NULL,
    id_iva INT NOT NULL,
    id_estado INT NOT NULL DEFAULT 1,
    precio_base_venta DECIMAL(15,2) NOT NULL,
    costo_promedio_ponderado DECIMAL(15,2) DEFAULT 0,
    stock_minimo_alerta INT DEFAULT 5,
    imagen_principal VARCHAR(255),
    es_venta_fraccionada BOOLEAN DEFAULT FALSE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria),
    FOREIGN KEY (id_unidad) REFERENCES unidades_medida(id_unidad),
    FOREIGN KEY (id_iva) REFERENCES tasas_iva(id_iva),
    FOREIGN KEY (id_estado) REFERENCES estados(id_estado)
) ENGINE=InnoDB;

-- ==========================================
-- 4. BODEGA (SOLO TESALIA)
-- ==========================================

CREATE TABLE bodegas (
    id_bodega INT AUTO_INCREMENT PRIMARY KEY,
    id_ciudad INT NOT NULL,
    nombre_bodega VARCHAR(100) NOT NULL,
    direccion VARCHAR(200),
    es_punto_venta BOOLEAN DEFAULT TRUE,
    id_estado INT NOT NULL DEFAULT 1,
    FOREIGN KEY (id_ciudad) REFERENCES ciudades(id_ciudad),
    FOREIGN KEY (id_estado) REFERENCES estados(id_estado)
) ENGINE=InnoDB;

CREATE TABLE existencias_bodega (
    id_producto INT NOT NULL,
    id_bodega INT NOT NULL,
    cantidad_actual DECIMAL(12,2) DEFAULT 0,
    ultima_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id_producto, id_bodega),
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto),
    FOREIGN KEY (id_bodega) REFERENCES bodegas(id_bodega)
) ENGINE=InnoDB;

CREATE TABLE movimientos_kardex (
    id_movimiento BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_producto INT NOT NULL,
    id_bodega_origen INT NULL,
    id_bodega_destino INT NULL,
    tipo_movimiento ENUM('Compra', 'Venta', 'Traslado', 'Ajuste', 'Garantia', 'Baja') NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL,
    costo_unitario_movimiento DECIMAL(15,2) NOT NULL,
    id_usuario_registra INT NOT NULL,
    documento_soporte VARCHAR(50),
    observaciones TEXT,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto),
    FOREIGN KEY (id_usuario_registra) REFERENCES usuarios(id_usuario)
) ENGINE=InnoDB;

-- ==========================================
-- 5. FACTURACIÓN
-- ==========================================

CREATE TABLE resoluciones_facturacion (
    id_resolucion INT AUTO_INCREMENT PRIMARY KEY,
    numero_resolucion VARCHAR(50) NOT NULL,
    prefijo VARCHAR(10),
    consecutivo_desde INT NOT NULL,
    consecutivo_hasta INT NOT NULL,
    consecutivo_actual INT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    clave_tecnica_dian VARCHAR(255),
    id_bodega_asignada INT NOT NULL,
    id_estado INT NOT NULL DEFAULT 1,
    FOREIGN KEY (id_bodega_asignada) REFERENCES bodegas(id_bodega),
    FOREIGN KEY (id_estado) REFERENCES estados(id_estado)
) ENGINE=InnoDB;

CREATE TABLE pedidos (
    id_pedido INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario_cliente INT NOT NULL,
    id_usuario_vendedor INT NULL,
    id_resolucion INT NULL,
    id_estado INT NOT NULL DEFAULT 1,
    numero_comprobante VARCHAR(20),
    tipo_documento ENUM('Cotizacion', 'Factura', 'POS', 'Remision') NOT NULL,
    origen ENUM('Web', 'Tienda') NOT NULL,
    subtotal DECIMAL(15,2) NOT NULL,
    total_iva DECIMAL(15,2) NOT NULL,
    total_retenciones DECIMAL(15,2) DEFAULT 0,
    total_neto DECIMAL(15,2) NOT NULL,
    cufe_dian VARCHAR(255) NULL,
    qr_cadena TEXT NULL,
    fecha_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario_cliente) REFERENCES usuarios(id_usuario),
    FOREIGN KEY (id_usuario_vendedor) REFERENCES usuarios(id_usuario),
    FOREIGN KEY (id_resolucion) REFERENCES resoluciones_facturacion(id_resolucion),
    FOREIGN KEY (id_estado) REFERENCES estados(id_estado)
) ENGINE=InnoDB;

CREATE TABLE detalle_pedidos (
    id_detalle BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT NOT NULL,
    id_producto INT NOT NULL,
    id_bodega_despacho INT NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL,
    precio_unitario_venta DECIMAL(15,2) NOT NULL,
    iva_porcentaje DECIMAL(5,2) NOT NULL,
    costo_unitario_historico DECIMAL(15,2) NOT NULL,
    FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido),
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto),
    FOREIGN KEY (id_bodega_despacho) REFERENCES bodegas(id_bodega)
) ENGINE=InnoDB;

-- ==========================================
-- 6. PQRSD
-- ==========================================

CREATE TABLE pqrsd (
    id_pqrsd INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario_cliente INT NOT NULL,
    id_pedido_relacionado INT NULL,
    tipo_solicitud ENUM('Peticion', 'Queja', 'Reclamo', 'Sugerencia', 'Denuncia') NOT NULL,
    asunto VARCHAR(150) NOT NULL,
    descripcion_detalle TEXT NOT NULL,
    id_estado_tramite INT NOT NULL DEFAULT 1,
    fecha_radicacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_vencimiento_ley DATE NOT NULL,
    id_usuario_responsable INT NULL,
    FOREIGN KEY (id_usuario_cliente) REFERENCES usuarios(id_usuario),
    FOREIGN KEY (id_pedido_relacionado) REFERENCES pedidos(id_pedido),
    FOREIGN KEY (id_usuario_responsable) REFERENCES usuarios(id_usuario)
) ENGINE=InnoDB;

-- ==========================================
-- 7. TRIGGER
-- ==========================================

DELIMITER //
CREATE TRIGGER trg_movimiento_inventario_automatico
AFTER INSERT ON movimientos_kardex
FOR EACH ROW
BEGIN
    IF NEW.id_bodega_destino IS NOT NULL THEN
        INSERT INTO existencias_bodega (id_producto, id_bodega, cantidad_actual)
        VALUES (NEW.id_producto, NEW.id_bodega_destino, NEW.cantidad)
        ON DUPLICATE KEY UPDATE cantidad_actual = cantidad_actual + NEW.cantidad;
    END IF;

    IF NEW.id_bodega_origen IS NOT NULL THEN
        UPDATE existencias_bodega 
        SET cantidad_actual = cantidad_actual - NEW.cantidad
        WHERE id_producto = NEW.id_producto AND id_bodega = NEW.id_bodega_origen;
    END IF;
END //
DELIMITER ;

-- ==========================================
-- 8. DATOS INICIALES
-- ==========================================

INSERT INTO estados (nombre_estado, descripcion, color_representativo) VALUES 
('Activo', 'Entidad operativa', '#28a745'),
('Pendiente', 'En proceso', '#ffc107'),
('Anulado', 'Sin validez', '#dc3545');

INSERT INTO departamentos VALUES (1,'41','Huila');

INSERT INTO ciudades VALUES 
(1,1,'41396','La Plata'),
(2,1,'41791','Tesalia');

INSERT INTO tipos_documento (sigla, nombre_completo) VALUES 
('CC','Cédula de Ciudadanía'),
('NIT','Número de Identificación Tributaria');

INSERT INTO tasas_iva (porcentaje, descripcion) VALUES 
(0.00,'Exento'),
(5.00,'Reducido'),
(19.00,'General');

INSERT IGNORE INTO unidades_medida (nombre_unidad, sigla_dian) VALUES
('Unidad', 'H87'),       -- Tornillos, herramientas, etc.
('Metro', 'MTR'),        -- Tubos, cables, mangueras
('Centímetro', 'CMT'),   -- Medidas pequeñas
('Kilogramo', 'KGM'),    -- Clavos, cemento, materiales
('Gramo', 'GRM'),        -- Tornillería pequeña
('Litro', 'LTR'),        -- Pintura, químicos
('Galón', 'GLL'),        -- Pintura grande
('Caja', 'BX'),          -- Tornillos por caja
('Paquete', 'PA'),       -- Bolsas o kits pequeños
('Metro cuadrado', 'MTK'); -- Cerámica, pisos

INSERT INTO bodegas (id_ciudad, nombre_bodega) VALUES 
(2,'Sede Principal Tesalia');

INSERT INTO roles (nombre_rol, descripcion) VALUES 
('Administrador','Control total'),
('Vendedor POS','Ventas'),
('Almacenista','Inventario'),
('Cliente','Comprador web');