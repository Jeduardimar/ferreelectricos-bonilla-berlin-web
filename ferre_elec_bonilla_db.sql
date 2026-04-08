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
