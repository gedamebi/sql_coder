CREATE DATABASE IF NOT EXISTS `vendingmachine`;
USE `vendingmachine`;

CREATE TABLE `ubicaciones` (
  `id_ubicacion` int AUTO_INCREMENT PRIMARY KEY,
  `direccion` varchar(50) NOT NULL,
  `ciudad` varchar(50),
  `latitud` real,
  `longitud` real,
  `tel_contacto` varchar(50)
);

CREATE TABLE `maquinas` (
  `id_maquina` int AUTO_INCREMENT PRIMARY KEY,
  `estado` enum('ok','offline','en falla') DEFAULT NULL,
  `keep_alive` datetime,
  `habilitada` tinyint DEFAULT 0,
  `stock_actual` tinyint DEFAULT 0,
  `id_ubicacion` int
);

CREATE TABLE `productos` (
  `id_producto` int AUTO_INCREMENT PRIMARY KEY,
  `descripcion` varchar(50) NOT NULL,
  `precio` real NOT NULL
);

CREATE TABLE `ventas` (
  `id_venta` int AUTO_INCREMENT PRIMARY KEY,
  `fecha` datetime DEFAULT CURRENT_TIMESTAMP,
  `id_producto` int NOT NULL,
  `id_maquina` int NOT NULL,
  `estado` enum('pendiente','completada','rechazada','devolucion') NOT NULL,
  `metodo_pago` tinyint NOT NULL, -- 0: Mercado Pago, 1: POS
  `purchase` real NOT NULL
);

CREATE TABLE `operadores` (
  `id_operador` int AUTO_INCREMENT PRIMARY KEY,
  `id_maquina` int NOT NULL,
  `operador` varchar(10) UNIQUE NOT NULL,
  `password` varchar(255) NOT NULL
);

CREATE TABLE `tecnicos` (
  `id_tecnico` int AUTO_INCREMENT PRIMARY KEY,
  `tecnico` varchar(10) UNIQUE NOT NULL,
  `password` varchar(255) NOT NULL
);

CREATE TABLE `reposiciones` (
  `id_reposicion` int AUTO_INCREMENT PRIMARY KEY,
  `fecha` datetime DEFAULT CURRENT_TIMESTAMP,
  `cantidad` tinyint NOT NULL,
  `id_maquina` int NOT NULL,
  `id_operador` int NOT NULL
);

CREATE TABLE `mantenimientos` (
  `id_mantenimiento` int AUTO_INCREMENT PRIMARY KEY,
  `fecha` datetime DEFAULT CURRENT_TIMESTAMP,
  `detalle` varchar(300) NOT NULL,
  `id_maquina` int NOT NULL,
  `id_tecnico` int NOT NULL
);

ALTER TABLE `maquinas` ADD FOREIGN KEY (`id_ubicacion`) REFERENCES `ubicaciones` (`id_ubicacion`);

ALTER TABLE `ventas` ADD FOREIGN KEY (`id_producto`) REFERENCES `productos` (`id_producto`);

ALTER TABLE `ventas` ADD FOREIGN KEY (`id_maquina`) REFERENCES `maquinas` (`id_maquina`);

ALTER TABLE `operadores` ADD FOREIGN KEY (`id_maquina`) REFERENCES `maquinas` (`id_maquina`);

ALTER TABLE `reposiciones` ADD FOREIGN KEY (`id_maquina`) REFERENCES `maquinas` (`id_maquina`);

ALTER TABLE `reposiciones` ADD FOREIGN KEY (`id_operador`) REFERENCES `operadores` (`id_operador`);

ALTER TABLE `mantenimientos` ADD FOREIGN KEY (`id_maquina`) REFERENCES `maquinas` (`id_maquina`);

ALTER TABLE `mantenimientos` ADD FOREIGN KEY (`id_tecnico`) REFERENCES `tecnicos` (`id_tecnico`);
