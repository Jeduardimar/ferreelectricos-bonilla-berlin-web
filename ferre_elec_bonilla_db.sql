-- MySQL Script Refactorizado y Optimizado - ferrelectricos_bonilla_berlin
-- Correcciones aplicadas: Eliminación de 'VISIBLE' para compatibilidad con MariaDB, nombrado explicito de Constraints (fk_*), e integridad de Primary Keys (NOT NULL).

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema ferrelectricos_bonilla_berlin
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `ferrelectricos_bonilla_berlin` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci ;
USE `ferrelectricos_bonilla_berlin` ;

-- -----------------------------------------------------
-- Table `ferrelectricos_bonilla_berlin`.`departamentos`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ferrelectricos_bonilla_berlin`.`departamentos` (
  `id_departamento` INT NOT NULL AUTO_INCREMENT,
  `codigo_dane_dep` VARCHAR(5) NOT NULL,
  `nombre_departamento` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`id_departamento`),
  UNIQUE INDEX (`codigo_dane_dep` ASC))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `ferrelectricos_bonilla_berlin`.`ciudades`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ferrelectricos_bonilla_berlin`.`ciudades` (
  `id_ciudad` INT NOT NULL AUTO_INCREMENT,
  `id_departamento` INT NOT NULL,
  `codigo_dane_mun` VARCHAR(10) NOT NULL,
  `nombre_ciudad` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`id_ciudad`),
  UNIQUE INDEX (`codigo_dane_mun` ASC),
  INDEX (`id_departamento` ASC),
  CONSTRAINT `fk_ciudades_departamentos`
    FOREIGN KEY (`id_departamento`)
    REFERENCES `ferrelectricos_bonilla_berlin`.`departamentos` (`id_departamento`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `ferrelectricos_bonilla_berlin`.`estados`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ferrelectricos_bonilla_berlin`.`estados` (
  `id_estado` INT NOT NULL AUTO_INCREMENT,
  `nombre_estado` VARCHAR(30) NOT NULL,
  `descripcion` VARCHAR(255) NULL DEFAULT NULL,
  `color_representativo` VARCHAR(7) NULL DEFAULT NULL,
  PRIMARY KEY (`id_estado`),
  UNIQUE INDEX (`nombre_estado` ASC))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `ferrelectricos_bonilla_berlin`.`tipos_documento`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ferrelectricos_bonilla_berlin`.`tipos_documento` (
  `id_tipo_doc` INT NOT NULL AUTO_INCREMENT,
  `sigla` VARCHAR(5) NOT NULL,
  `nombre_completo` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`id_tipo_doc`),
  UNIQUE INDEX (`sigla` ASC))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `ferrelectricos_bonilla_berlin`.`roles`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ferrelectricos_bonilla_berlin`.`roles` (
  `id_rol` INT NOT NULL AUTO_INCREMENT,
  `nombre_rol` VARCHAR(50) NOT NULL,
  `descripcion` TEXT NULL DEFAULT NULL,
  PRIMARY KEY (`id_rol`),
  UNIQUE INDEX (`nombre_rol` ASC))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `ferrelectricos_bonilla_berlin`.`permisos`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ferrelectricos_bonilla_berlin`.`permisos` (
  `id_permiso` INT NOT NULL AUTO_INCREMENT,
  `clave_permiso` VARCHAR(100) NOT NULL,
  `descripcion` VARCHAR(255) NULL DEFAULT NULL,
  PRIMARY KEY (`id_permiso`),
  UNIQUE INDEX (`clave_permiso` ASC))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `ferrelectricos_bonilla_berlin`.`roles_permisos`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ferrelectricos_bonilla_berlin`.`roles_permisos` (
  `id_rol` INT NOT NULL,
  `id_permiso` INT NOT NULL,
  PRIMARY KEY (`id_rol`, `id_permiso`),
  INDEX (`id_permiso` ASC),
  CONSTRAINT `fk_roles_permisos_rol`
    FOREIGN KEY (`id_rol`)
    REFERENCES `ferrelectricos_bonilla_berlin`.`roles` (`id_rol`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_roles_permisos_permiso`
    FOREIGN KEY (`id_permiso`)
    REFERENCES `ferrelectricos_bonilla_berlin`.`permisos` (`id_permiso`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `ferrelectricos_bonilla_berlin`.`usuarios`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ferrelectricos_bonilla_berlin`.`usuarios` (
  `id_usuario` INT NOT NULL AUTO_INCREMENT,
  `id_rol` INT NOT NULL,
  `id_estado` INT NOT NULL DEFAULT 1,
  `id_tipo_doc` INT NOT NULL,
  `numero_identificacion` VARCHAR(20) NOT NULL,
  `nombres` VARCHAR(100) NOT NULL,
  `apellidos` VARCHAR(100) NOT NULL,
  `email` VARCHAR(100) NOT NULL,
  `contrasena_hash` VARCHAR(255) NOT NULL,
  `telefono` VARCHAR(20) NULL DEFAULT NULL,
  `fecha_creacion` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_usuario`),
  UNIQUE INDEX (`numero_identificacion` ASC),
  UNIQUE INDEX (`email` ASC),
  INDEX (`id_rol` ASC),
  INDEX (`id_estado` ASC),
  INDEX (`id_tipo_doc` ASC),
  CONSTRAINT `fk_usuarios_rol`
    FOREIGN KEY (`id_rol`)
    REFERENCES `ferrelectricos_bonilla_berlin`.`roles` (`id_rol`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_usuarios_estado`
    FOREIGN KEY (`id_estado`)
    REFERENCES `ferrelectricos_bonilla_berlin`.`estados` (`id_estado`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_usuarios_tipo_doc`
    FOREIGN KEY (`id_tipo_doc`)
    REFERENCES `ferrelectricos_bonilla_berlin`.`tipos_documento` (`id_tipo_doc`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `ferrelectricos_bonilla_berlin`.`auditoria_transaccional`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ferrelectricos_bonilla_berlin`.`auditoria_transaccional` (
  `id_auditoria` BIGINT NOT NULL AUTO_INCREMENT,
  `id_usuario` INT NOT NULL,
  `tabla_afectada` VARCHAR(50) NOT NULL,
  `id_registro_afectado` INT NOT NULL,
  `accion` ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
  `estado_anterior` JSON NULL DEFAULT NULL,
  `estado_nuevo` JSON NULL DEFAULT NULL,
  `ip_origen` VARCHAR(45) NULL DEFAULT NULL,
  `fecha_hora` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_auditoria`),
  INDEX (`id_usuario` ASC),
  CONSTRAINT `fk_auditoria_usuario`
    FOREIGN KEY (`id_usuario`)
    REFERENCES `ferrelectricos_bonilla_berlin`.`usuarios` (`id_usuario`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `ferrelectricos_bonilla_berlin`.`categorias`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ferrelectricos_bonilla_berlin`.`categorias` (
  `id_categoria` INT NOT NULL AUTO_INCREMENT,
  `nombre_categoria` VARCHAR(100) NOT NULL,
  `id_padre` INT NULL DEFAULT NULL,
  `id_estado` INT NOT NULL DEFAULT 1,
  PRIMARY KEY (`id_categoria`),
  INDEX (`id_padre` ASC),
  INDEX (`id_estado` ASC),
  CONSTRAINT `fk_categorias_padre`
    FOREIGN KEY (`id_padre`)
    REFERENCES `ferrelectricos_bonilla_berlin`.`categorias` (`id_categoria`)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  CONSTRAINT `fk_categorias_estado`
    FOREIGN KEY (`id_estado`)
    REFERENCES `ferrelectricos_bonilla_berlin`.`estados` (`id_estado`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `ferrelectricos_bonilla_berlin`.`unidades_medida`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ferrelectricos_bonilla_berlin`.`unidades_medida` (
  `id_unidad` INT NOT NULL AUTO_INCREMENT,
  `nombre_unidad` VARCHAR(50) NOT NULL,
  `sigla_dian` VARCHAR(10) NOT NULL,
  PRIMARY KEY (`id_unidad`))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `ferrelectricos_bonilla_berlin`.`tasas_iva`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ferrelectricos_bonilla_berlin`.`tasas_iva` (
  `id_iva` INT NOT NULL AUTO_INCREMENT,
  `porcentaje` DECIMAL(5,2) NOT NULL,
  `descripcion` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`id_iva`))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `ferrelectricos_bonilla_berlin`.`productos`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ferrelectricos_bonilla_berlin`.`productos` (
  `id_producto` INT NOT NULL AUTO_INCREMENT,
  `sku_interno` VARCHAR(50) NOT NULL,
  `codigo_barras` VARCHAR(100) NULL DEFAULT NULL,
  `nombre_producto` VARCHAR(200) NOT NULL,
  `descripcion_corta` VARCHAR(255) NULL DEFAULT NULL,
  `descripcion_larga` TEXT NULL DEFAULT NULL,
  `id_categoria` INT NOT NULL,
  `id_unidad` INT NOT NULL,
  `id_iva` INT NOT NULL,
  `id_estado` INT NOT NULL DEFAULT 1,
  `precio_base_venta` DECIMAL(15,2) NOT NULL,
  `costo_promedio_ponderado` DECIMAL(15,2) NULL DEFAULT 0.00,
  `stock_minimo_alerta` INT NULL DEFAULT 5,
  `imagen_principal` MEDIUMBLOB NULL DEFAULT NULL,
  `es_venta_fraccionada` TINYINT NULL DEFAULT 0,
  `fecha_creacion` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_producto`),
  UNIQUE INDEX (`sku_interno` ASC),
  UNIQUE INDEX (`codigo_barras` ASC),
  INDEX (`id_categoria` ASC),
  INDEX (`id_unidad` ASC),
  INDEX (`id_iva` ASC),
  INDEX (`id_estado` ASC),
  CONSTRAINT `fk_productos_categoria`
    FOREIGN KEY (`id_categoria`)
    REFERENCES `ferrelectricos_bonilla_berlin`.`categorias` (`id_categoria`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_productos_unidad`
    FOREIGN KEY (`id_unidad`)
    REFERENCES `ferrelectricos_bonilla_berlin`.`unidades_medida` (`id_unidad`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_productos_iva`
    FOREIGN KEY (`id_iva`)
    REFERENCES `ferrelectricos_bonilla_berlin`.`tasas_iva` (`id_iva`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_productos_estado`
    FOREIGN KEY (`id_estado`)
    REFERENCES `ferrelectricos_bonilla_berlin`.`estados` (`id_estado`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `ferrelectricos_bonilla_berlin`.`bodegas`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ferrelectricos_bonilla_berlin`.`bodegas` (
  `id_bodega` INT NOT NULL AUTO_INCREMENT,
  `id_ciudad` INT NOT NULL,
  `nombre_bodega` VARCHAR(100) NOT NULL,
  `direccion` VARCHAR(200) NULL DEFAULT NULL,
  `es_punto_venta` TINYINT NULL DEFAULT 1,
  `id_estado` INT NOT NULL DEFAULT 1,
  PRIMARY KEY (`id_bodega`),
  INDEX (`id_ciudad` ASC),
  INDEX (`id_estado` ASC),
  CONSTRAINT `fk_bodegas_ciudad`
    FOREIGN KEY (`id_ciudad`)
    REFERENCES `ferrelectricos_bonilla_berlin`.`ciudades` (`id_ciudad`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_bodegas_estado`
    FOREIGN KEY (`id_estado`)
    REFERENCES `ferrelectricos_bonilla_berlin`.`estados` (`id_estado`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `ferrelectricos_bonilla_berlin`.`existencias_bodega`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ferrelectricos_bonilla_berlin`.`existencias_bodega` (
  `id_producto` INT NOT NULL,
  `id_bodega` INT NOT NULL,
  `cantidad_actual` DECIMAL(12,2) NULL DEFAULT 0.00,
  `ultima_actualizacion` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_producto`, `id_bodega`),
  INDEX (`id_bodega` ASC),
  CONSTRAINT `fk_existencias_producto`
    FOREIGN KEY (`id_producto`)
    REFERENCES `ferrelectricos_bonilla_berlin`.`productos` (`id_producto`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_existencias_bodega`
    FOREIGN KEY (`id_bodega`)
    REFERENCES `ferrelectricos_bonilla_berlin`.`bodegas` (`id_bodega`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `ferrelectricos_bonilla_berlin`.`movimientos_kardex`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ferrelectricos_bonilla_berlin`.`movimientos_kardex` (
  `id_movimiento` BIGINT NOT NULL AUTO_INCREMENT,
  `id_producto` INT NOT NULL,
  `id_bodega_origen` INT NULL DEFAULT NULL,
  `id_bodega_destino` INT NULL DEFAULT NULL,
  `tipo_movimiento` ENUM('Compra', 'Venta', 'Traslado', 'Ajuste', 'Garantia', 'Baja') NOT NULL,
  `cantidad` DECIMAL(12,2) NOT NULL,
  `costo_unitario_movimiento` DECIMAL(15,2) NOT NULL,
  `id_usuario_registra` INT NOT NULL,
  `documento_soporte` VARCHAR(50) NULL DEFAULT NULL,
  `observaciones` TEXT NULL DEFAULT NULL,
  `fecha_registro` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_movimiento`),
  INDEX (`id_producto` ASC),
  INDEX (`id_usuario_registra` ASC),
  INDEX (`id_bodega_origen` ASC),
  INDEX (`id_bodega_destino` ASC),
  CONSTRAINT `fk_kardex_producto`
    FOREIGN KEY (`id_producto`)
    REFERENCES `ferrelectricos_bonilla_berlin`.`productos` (`id_producto`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_kardex_usuario`
    FOREIGN KEY (`id_usuario_registra`)
    REFERENCES `ferrelectricos_bonilla_berlin`.`usuarios` (`id_usuario`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_kardex_bodega_origen`
    FOREIGN KEY (`id_bodega_origen`)
    REFERENCES `ferrelectricos_bonilla_berlin`.`bodegas` (`id_bodega`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_kardex_bodega_destino`
    FOREIGN KEY (`id_bodega_destino`)
    REFERENCES `ferrelectricos_bonilla_berlin`.`bodegas` (`id_bodega`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `ferrelectricos_bonilla_berlin`.`resoluciones_facturacion`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ferrelectricos_bonilla_berlin`.`resoluciones_facturacion` (
  `id_resolucion` INT NOT NULL AUTO_INCREMENT,
  `numero_resolucion` VARCHAR(50) NOT NULL,
  `prefijo` VARCHAR(10) NULL DEFAULT NULL,
  `consecutivo_desde` INT NOT NULL,
  `consecutivo_hasta` INT NOT NULL,
  `consecutivo_actual` INT NOT NULL,
  `fecha_inicio` DATE NOT NULL,
  `fecha_fin` DATE NOT NULL,
  `clave_tecnica_dian` VARCHAR(255) NULL DEFAULT NULL,
  `id_bodega_asignada` INT NOT NULL,
  `id_estado` INT NOT NULL DEFAULT 1,
  PRIMARY KEY (`id_resolucion`),
  INDEX (`id_bodega_asignada` ASC),
  INDEX (`id_estado` ASC),
  CONSTRAINT `fk_resoluciones_bodega`
    FOREIGN KEY (`id_bodega_asignada`)
    REFERENCES `ferrelectricos_bonilla_berlin`.`bodegas` (`id_bodega`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_resoluciones_estado`
    FOREIGN KEY (`id_estado`)
    REFERENCES `ferrelectricos_bonilla_berlin`.`estados` (`id_estado`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `ferrelectricos_bonilla_berlin`.`pedidos`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ferrelectricos_bonilla_berlin`.`pedidos` (
  `id_pedido` INT NOT NULL AUTO_INCREMENT,
  `id_usuario_cliente` INT NOT NULL,
  `id_usuario_vendedor` INT NULL DEFAULT NULL,
  `id_resolucion` INT NULL DEFAULT NULL,
  `id_estado` INT NOT NULL DEFAULT 1,
  `numero_comprobante` VARCHAR(20) NULL DEFAULT NULL,
  `tipo_documento` ENUM('Cotizacion', 'Factura', 'POS', 'Remision') NOT NULL,
  `origen` ENUM('Web', 'Tienda') NOT NULL,
  `subtotal` DECIMAL(15,2) NOT NULL,
  `total_iva` DECIMAL(15,2) NOT NULL,
  `total_retenciones` DECIMAL(15,2) NULL DEFAULT 0.00,
  `total_neto` DECIMAL(15,2) NOT NULL,
  `cufe_dian` VARCHAR(255) NULL DEFAULT NULL,
  `qr_cadena` TEXT NULL DEFAULT NULL,
  `fecha_pedido` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_pedido`),
  INDEX (`id_usuario_cliente` ASC),
  INDEX (`id_usuario_vendedor` ASC),
  INDEX (`id_resolucion` ASC),
  INDEX (`id_estado` ASC),
  CONSTRAINT `fk_pedidos_cliente`
    FOREIGN KEY (`id_usuario_cliente`)
    REFERENCES `ferrelectricos_bonilla_berlin`.`usuarios` (`id_usuario`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_pedidos_vendedor`
    FOREIGN KEY (`id_usuario_vendedor`)
    REFERENCES `ferrelectricos_bonilla_berlin`.`usuarios` (`id_usuario`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_pedidos_resolucion`
    FOREIGN KEY (`id_resolucion`)
    REFERENCES `ferrelectricos_bonilla_berlin`.`resoluciones_facturacion` (`id_resolucion`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_pedidos_estado`
    FOREIGN KEY (`id_estado`)
    REFERENCES `ferrelectricos_bonilla_berlin`.`estados` (`id_estado`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `ferrelectricos_bonilla_berlin`.`detalle_pedidos`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ferrelectricos_bonilla_berlin`.`detalle_pedidos` (
  `id_detalle` BIGINT NOT NULL AUTO_INCREMENT,
  `id_pedido` INT NOT NULL,
  `id_producto` INT NOT NULL,
  `id_bodega_despacho` INT NOT NULL,
  `cantidad` DECIMAL(12,2) NOT NULL,
  `precio_unitario_venta` DECIMAL(15,2) NOT NULL,
  `iva_porcentaje` DECIMAL(5,2) NOT NULL,
  `costo_unitario_historico` DECIMAL(15,2) NOT NULL,
  PRIMARY KEY (`id_detalle`),
  INDEX (`id_pedido` ASC),
  INDEX (`id_producto` ASC),
  INDEX (`id_bodega_despacho` ASC),
  CONSTRAINT `fk_detalle_pedido`
    FOREIGN KEY (`id_pedido`)
    REFERENCES `ferrelectricos_bonilla_berlin`.`pedidos` (`id_pedido`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_detalle_producto`
    FOREIGN KEY (`id_producto`)
    REFERENCES `ferrelectricos_bonilla_berlin`.`productos` (`id_producto`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_detalle_bodega`
    FOREIGN KEY (`id_bodega_despacho`)
    REFERENCES `ferrelectricos_bonilla_berlin`.`bodegas` (`id_bodega`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `ferrelectricos_bonilla_berlin`.`pqrsd`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ferrelectricos_bonilla_berlin`.`pqrsd` (
  `id_pqrsd` INT NOT NULL AUTO_INCREMENT,
  `id_usuario_cliente` INT NOT NULL,
  `id_pedido_relacionado` INT NULL DEFAULT NULL,
  `tipo_solicitud` ENUM('Peticion', 'Queja', 'Reclamo', 'Sugerencia', 'Denuncia') NOT NULL,
  `asunto` VARCHAR(150) NOT NULL,
  `descripcion_detalle` TEXT NOT NULL,
  `id_estado_tramite` INT NOT NULL DEFAULT 1,
  `fecha_radicacion` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_vencimiento_ley` DATE NOT NULL,
  `id_usuario_responsable` INT NULL DEFAULT NULL,
  PRIMARY KEY (`id_pqrsd`),
  INDEX (`id_usuario_cliente` ASC),
  INDEX (`id_pedido_relacionado` ASC),
  INDEX (`id_usuario_responsable` ASC),
  CONSTRAINT `fk_pqrsd_cliente`
    FOREIGN KEY (`id_usuario_cliente`)
    REFERENCES `ferrelectricos_bonilla_berlin`.`usuarios` (`id_usuario`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_pqrsd_pedido`
    FOREIGN KEY (`id_pedido_relacionado`)
    REFERENCES `ferrelectricos_bonilla_berlin`.`pedidos` (`id_pedido`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_pqrsd_vendedor`
    FOREIGN KEY (`id_usuario_responsable`)
    REFERENCES `ferrelectricos_bonilla_berlin`.`usuarios` (`id_usuario`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;

USE `ferrelectricos_bonilla_berlin`;

DELIMITER $$
USE `ferrelectricos_bonilla_berlin`$$
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
END$$


DELIMITER ;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

------------------------------------------------------DATOS DE PRUEBA-------------------------------------------------------------
---observe que en la terminal de XAMPP las letras con tilde las imprime con este signo ?
-- Insertar departamentos de prueba
INSERT INTO `ferrelectricos_bonilla_berlin`.`departamentos` (`codigo_dane_dep`, `nombre_departamento`) VALUES
('05', 'ANTIOQUIA'),
('11', 'CUNDINAMARCA'),
('76', 'VALLE DEL CAUCA'),
('08', 'ATLÁNTICO'),
('68', 'SANTANDER');

-- Insertar ciudades de prueba (relacionadas con los departamentos anteriores)
INSERT INTO `ferrelectricos_bonilla_berlin`.`ciudades` (`id_departamento`, `codigo_dane_mun`, `nombre_ciudad`) VALUES
-- Antioquia
(1, '05001', 'MEDELLIN'),
(1, '05002', 'ABEJORRAL'),
(1, '05004', 'ABRIAQUÍ'),
-- Cundinamarca
(2, '11001', 'BOGOTA D.C.'),
(2, '11228', 'FUNZA'),
(2, '11232', 'GIRARDOT'),
-- Valle del Cauca
(3, '76001', 'CALI'),
(3, '76109', 'BUENAVENTURA'),
(3, '76233', 'PALMIRA'),
-- Atlántico
(4, '08001', 'BARRANQUILLA'),
(4, '08078', 'SOLEDAD'),
(4, '08128', 'MALAMBO'),
-- Santander
(5, '68001', 'BUCARAMANGA'),
(5, '68013', 'BARRANCABERMEJA'),
(5, '68179', 'FLORIDABLANCA');

-- 1. Inserción de estados comunes del sistema
INSERT INTO `ferrelectricos_bonilla_berlin`.`estados` (`nombre_estado`, `descripcion`, `color_representativo`) VALUES
('Activo', 'Registro activo y operativo', '#28A745'),
('Inactivo', 'Registro deshabilitado temporalmente', '#DC3545'),
('Proceso', 'En tramite o pendiente', '#FFC107'),
('Anulado', 'Registro anulado o cancelado', '#6C757D'),
('Finalizado', 'Proceso completado exitosamente', '#17A2B8');

-- 2. Inserción de tipos de documento de identificación
INSERT INTO `ferrelectricos_bonilla_berlin`.`tipos_documento` (`sigla`, `nombre_completo`) VALUES
('CC', 'Cedula de Ciudadania'),
('NIT', 'Numero de Identificacion Tributaria'),
('CE', 'Cedula de Extranjeria'),
('Pas', 'Pasaporte'),
('TI', 'Tarjeta de Identidad');

-- 3. Inserción de roles del sistema
INSERT INTO `ferrelectricos_bonilla_berlin`.`roles` (`nombre_rol`, `descripcion`) VALUES
('Administrador', 'Acceso total a configuración y gestion del sistema'),
('Vendedor', 'Gestion de pedidos, cotizaciones y atención al cliente'),
('Cliente', 'Consulta de productos, compras en linea y seguimiento de pedidos'),
('Bodeguero', 'Gestion de inventarios, movimientos kardex y traslados'),
('Contador', 'Acceso a reportes financieros y facturación');

-- 4. Inserción de unidades de medida (basadas en resolución DIAN)
INSERT INTO `ferrelectricos_bonilla_berlin`.`unidades_medida` (`nombre_unidad`, `sigla_dian`) VALUES
('Unidad', 'UND'),
('Metro', 'MT'),
('Kilogramo', 'KG'),
('Litro', 'LT'),
('Par', 'PR');

-- 5. Inserción de tasas de IVA aplicables en Colombia
INSERT INTO `ferrelectricos_bonilla_berlin`.`tasas_iva` (`porcentaje`, `descripcion`) VALUES
(19.00, 'Tarifa general'),
(5.00, 'Tarifa reducida (canasta familiar)'),
(0.00, 'Exento'),
(14.00, 'Servicios financieros'),
(8.00, 'Algunos productos agropecuarios');

-- 1. Insertar categorías de prueba (jerarquía simple)
INSERT INTO `ferrelectricos_bonilla_berlin`.`categorias` (`nombre_categoria`, `id_padre`, `id_estado`) VALUES
('Material Electrico', NULL, 1),      -- id_categoria = 1
('Cables y Alambres', 1, 1),          -- id_categoria = 2
('Tomacorrientes', 1, 1),             -- id_categoria = 3
('Interruptores', 1, 1),              -- id_categoria = 4
('Herramientas Manuales', NULL, 1);   -- id_categoria = 5

-- 2. Insertar productos de prueba
INSERT INTO `ferrelectricos_bonilla_berlin`.`productos` (
    `sku_interno`, 
    `codigo_barras`, 
    `nombre_producto`, 
    `descripcion_corta`, 
    `descripcion_larga`, 
    `id_categoria`, 
    `id_unidad`, 
    `id_iva`, 
    `id_estado`, 
    `precio_base_venta`, 
    `costo_promedio_ponderado`, 
    `stock_minimo_alerta`, 
    `es_venta_fraccionada`
) VALUES
('CAB-12-100', '7701234567890', 'Cable THHN 12 AWG 100m', 'Cable electrico THHN calibre 12, rollo 100 metros', 'Cable de cobre para instalaciones electricas residenciales e industriales, aislamiento THHN, 600V', 2, 2, 1, 1, 185000.00, 168000.00, 10, 0),
('TOM-DBL-10', '7701234567891', 'Tomacorriente Doble 10A', 'Tomacorriente doble polarizado, 10 amperios', 'Base de tomacorriente doble con puesta a tierra, 10A/250V, color blanco', 3, 1, 1, 1, 8500.00, 6200.00, 15, 0),
('INT-SEN-1', '7701234567892', 'Interruptor Sencillo 10A', 'Interruptor sencillo tipo palanca, 10A', 'Interruptor unipolar, 10A/250V, mecanismo de palanca, color blanco', 4, 1, 1, 1, 6200.00, 4800.00, 15, 0),
('CAB-14-50', '7701234567893', 'Cable THHN 14 AWG 50m', 'Cable THHN calibre 14, rollo 50 metros', 'Cable de cobre flexible, aislamiento THHN, adecuado para circuitos secundarios', 2, 2, 1, 1, 72000.00, 65500.00, 8, 0),
('DES-PEL-1', '7701234567894', 'Destornillador Electrico', 'Juego de destornillador eléctrico recargable 3.6V', 'Destornillador inalámbrico con batería Li-Ion, incluye 6 puntas intercambiables', 5, 1, 2, 1, 65000.00, 52000.00, 5, 0);

-- Insertar usuarios de prueba (contraseñas: 'password123' para todos, hasheadas con SHA2-256)
INSERT INTO `ferrelectricos_bonilla_berlin`.`usuarios` (
    `id_rol`, 
    `id_estado`, 
    `id_tipo_doc`, 
    `numero_identificacion`, 
    `nombres`, 
    `apellidos`, 
    `email`, 
    `contrasena_hash`, 
    `telefono`
) VALUES
-- Administrador (rol 1, estado activo 1, tipo doc CC 1)
(1, 1, 1, '12345678', 'Juan', 'Perez', 'juan.perez@empresa.com', SHA2('password123', 256), '3001234567'),

-- Vendedor (rol 2, estado activo 1, tipo doc CC 1)
(2, 1, 1, '87654321', 'María', 'Gomez', 'maria.gomez@empresa.com', SHA2('password123', 256), '3109876543'),

-- Cliente (rol 3, estado activo 1, tipo doc CC 1)
(3, 1, 1, '11223344', 'Carlos', 'Lopez', 'carlos.lopez@gmail.com', SHA2('password123', 256), '3201122334'),

-- Bodeguero (rol 4, estado activo 1, tipo doc CC 1)
(4, 1, 1, '44332211', 'Ana', 'Martinez', 'ana.martinez@empresa.com', SHA2('password123', 256), '3154433221'),

-- Contador (rol 5, estado inactivo 2, tipo doc NIT 2)
(5, 2, 2, '900123456', 'Luis', 'Rodriguez', 'luis.rodriguez@empresa.com', SHA2('password123', 256), '3119988776');

-- Insertar bodegas (si no existen)
INSERT INTO `ferrelectricos_bonilla_berlin`.`bodegas` 
(`id_ciudad`, `nombre_bodega`, `direccion`, `es_punto_venta`, `id_estado`) 
VALUES 
(1, 'Bodega Principal Medellin', 'Calle 50 # 70-20', 1, 1),
(4, 'Centro de Distribución Bogota', 'Av. Caracas # 45-78', 1, 1);

-- Insertar resolución de facturación (asignada a una bodega)
INSERT INTO `ferrelectricos_bonilla_berlin`.`resoluciones_facturacion` 
(`numero_resolucion`, `prefijo`, `consecutivo_desde`, `consecutivo_hasta`, `consecutivo_actual`, 
 `fecha_inicio`, `fecha_fin`, `clave_tecnica_dian`, `id_bodega_asignada`, `id_estado`) 
VALUES 
('RESOL-001', 'FER', 1000, 2000, 1005, '2025-01-01', '2025-12-31', 'clave_dian_123', 1, 1);

-- Insertar pedido de prueba (cliente: Carlos López, vendedor: María Gómez)
INSERT INTO `ferrelectricos_bonilla_berlin`.`pedidos` 
(`id_usuario_cliente`, `id_usuario_vendedor`, `id_resolucion`, `id_estado`, `numero_comprobante`, 
 `tipo_documento`, `origen`, `subtotal`, `total_iva`, `total_retenciones`, `total_neto`, `cufe_dian`) 
VALUES 
(3, 2, 1, 5, 'FER1005', 'Factura', 'Tienda', 185000.00, 35150.00, 0.00, 220150.00, 'cufe_muestra_123');
