USE vendingmachine;

-- ========================================================================
-- INSERTS para la tabla 'ubicaciones'
-- (10 ubicaciones de ejemplo en Montevideo, Uruguay)
-- ========================================================================
INSERT INTO ubicaciones (direccion, ciudad, latitud, longitud, tel_contacto) VALUES
('Av. 18 de Julio 1234', 'Montevideo', -34.9056, -56.1923, '2401-1234'),
('Rambla Rep. del Perú 876', 'Montevideo', -34.9125, -56.1419, '2701-5678'),
('Bulevar Artigas 2500', 'Montevideo', -34.9022, -56.1669, '2209-8765'),
('Av. Italia 3200', 'Montevideo', -34.8879, -56.1308, '2619-4321'),
('18 de Julio 1050', 'Montevideo', -34.9080, -56.1865, '2900-0987'),
('Av. General Flores 3400', 'Montevideo', -34.8722, -56.1705, '2508-1122'),
('Av. Rivera 2800', 'Montevideo', -34.9110, -56.1488, '2628-3344'),
('Carlos María Ramírez 1215', 'Montevideo', -34.8893, -56.2084, '2309-5566'),
('Luis Alberto de Herrera 1248', 'Montevideo', -34.8988, -56.1633, '2622-7788'),
('Francisco Bauzá 3343', 'Montevideo', -34.9085, -56.1519, '2710-9900');

-- ========================================================================
-- INSERTS para la tabla 'maquinas'
-- (10 máquinas asociadas a las ubicaciones anteriores)
-- ========================================================================
INSERT INTO maquinas (estado, keep_alive, habilitada, stock_actual, id_ubicacion) VALUES
('ok', NOW(), 1, 5, 1),
('offline', '2025-07-28 10:00:00', 0, 0, 2),
('ok', NOW(), 1, 10, 3),
('ok', NOW(), 1, 10, 4),
('ok', NOW(), 1, 10, 5),
('offline', '2025-07-27 15:30:00', 0, 0, 6),
('ok', NOW(), 1, 10, 7),
('ok', NOW(), 1, 10, 8),
('ok', NOW(), 1, 10, 9),
('ok', NOW(), 1, 10, 10);


-- ========================================================================
-- INSERTS para la tabla 'productos'
-- (2 productos)
-- ========================================================================
INSERT INTO productos (descripcion, precio) VALUES
('Envase + Carga de 13kg', 5040),
('Recarga de garrafa de 13 kg', 1050);


-- ========================================================================
-- INSERTS para la tabla 'operadores'
-- (Un operador asignado a cada una de las 10 máquinas)
-- ========================================================================
INSERT INTO operadores (id_maquina, operador, password) VALUES
(1, 'operador1', 'password_hashed_op1'),
(2, 'operador2', 'password_hashed_op2'),
(3, 'operador3', 'password_hashed_op3'),
(4, 'operador4', 'password_hashed_op4'),
(5, 'operador5', 'password_hashed_op5'),
(6, 'operador6', 'password_hashed_op6'),
(7, 'operador7', 'password_hashed_op7'),
(8, 'operador8', 'password_hashed_op8'),
(9, 'operador9', 'password_hashed_op9'),
(10, 'operador10', 'password_hashed_op10');


-- ========================================================================
-- INSERTS para la tabla 'tecnicos'
-- (Dos técnicos)
-- ========================================================================
INSERT INTO tecnicos (tecnico, password) VALUES
('tecnico1', 'password_hashed_tec1'),
('tecnico2', 'password_hashed_tec2');


-- ========================================================================
-- INSERTS para la tabla 'reposiciones'
-- (20 recargas de máquinas aleatorias)
-- ========================================================================
INSERT INTO reposiciones (fecha, cantidad, id_maquina, id_operador) VALUES
('2025-07-01 09:00:00', 15, 1, 1),
('2025-07-03 11:30:00', 20, 3, 3),
('2025-07-05 14:00:00', 10, 5, 5),
('2025-07-07 16:00:00', 25, 7, 7),
('2025-07-09 08:45:00', 12, 9, 9),
('2025-07-11 10:15:00', 18, 2, 2),
('2025-07-13 13:20:00', 30, 4, 4),
('2025-07-15 15:50:00', 22, 6, 6),
('2025-07-17 09:30:00', 14, 8, 8),
('2025-07-19 11:00:00', 28, 10, 10),
('2025-07-21 12:45:00', 17, 1, 1),
('2025-07-23 14:10:00', 21, 3, 3),
('2025-07-25 15:30:00', 13, 5, 5),
('2025-07-27 10:00:00', 26, 7, 7),
('2025-07-29 11:45:00', 19, 9, 9),
('2025-07-31 14:20:00', 23, 2, 2),
('2025-08-02 16:10:00', 16, 4, 4),
('2025-08-04 09:55:00', 29, 6, 6),
('2025-08-06 11:15:00', 24, 8, 8),
('2025-08-08 13:00:00', 11, 10, 10);

-- ========================================================================
-- INSERTS para la tabla 'mantenimientos'
-- (2 visitas técnicas a dos máquinas aleatorias)
-- ========================================================================
INSERT INTO mantenimientos (fecha, detalle, id_maquina, id_tecnico) VALUES
('2025-07-06 10:00:00', 'Mantenimiento preventivo. Limpieza general y revisión de sensores.', 3, 1),
('2025-07-18 14:30:00', 'Reparación de dispensador. Se reemplazó el motor y se ajustó el mecanismo.', 9, 2);


-- ========================================================================
-- INSERTS para la tabla 'ventas'
-- (50 ventas)
-- ========================================================================
INSERT INTO ventas (fecha, id_producto, id_maquina, estado, metodo_pago, purchase) VALUES
('2025-07-01 09:05:00', 1, 1, 'completada', 0, 5040),
('2025-07-01 10:15:00', 2, 4, 'completada', 1, 1050),
('2025-07-01 11:30:00', 1, 7, 'completada', 0, 5040),
('2025-07-02 12:45:00', 2, 10, 'rechazada', 1, 1050),
('2025-07-02 14:00:00', 1, 5, 'completada', 0, 5040),
('2025-07-03 15:20:00', 2, 2, 'completada', 1, 1050),
('2025-07-03 16:30:00', 1, 8, 'completada', 0, 5040),
('2025-07-04 09:40:00', 2, 6, 'pendiente', 0, 1050),
('2025-07-04 10:55:00', 1, 3, 'completada', 1, 5040),
('2025-07-05 11:20:00', 2, 9, 'devolucion', 0, 1050),
('2025-07-05 13:10:00', 1, 1, 'completada', 1, 5040),
('2025-07-06 14:45:00', 2, 4, 'completada', 0, 1050),
('2025-07-06 16:00:00', 1, 7, 'completada', 1, 5040),
('2025-07-07 09:15:00', 2, 10, 'completada', 0, 1050),
('2025-07-07 10:35:00', 1, 5, 'completada', 1, 5040),
('2025-07-08 11:50:00', 2, 2, 'pendiente', 0, 1050),
('2025-07-08 12:40:00', 1, 8, 'completada', 1, 5040),
('2025-07-09 14:00:00', 2, 6, 'completada', 0, 1050),
('2025-07-09 15:30:00', 1, 3, 'completada', 1, 5040),
('2025-07-10 16:45:00', 2, 9, 'completada', 0, 1050),
('2025-07-11 09:20:00', 1, 1, 'completada', 1, 5040),
('2025-07-11 10:55:00', 2, 4, 'completada', 0, 1050),
('2025-07-12 12:15:00', 1, 7, 'completada', 1, 5040),
('2025-07-12 13:40:00', 2, 10, 'completada', 0, 1050),
('2025-07-13 14:50:00', 1, 5, 'completada', 1, 5040),
('2025-08-13 16:10:00', 2, 2, 'devolucion', 0, 1050),
('2025-08-14 09:00:00', 1, 8, 'completada', 1, 5040),
('2025-08-14 10:30:00', 2, 6, 'completada', 0, 1050),
('2025-08-15 11:45:00', 1, 3, 'completada', 1, 5040),
('2025-08-15 13:00:00', 2, 9, 'completada', 0, 1050),
('2025-08-16 14:20:00', 1, 1, 'completada', 1, 5040),
('2025-08-16 15:50:00', 2, 4, 'completada', 0, 1050),
('2025-08-17 09:10:00', 1, 7, 'completada', 1, 5040),
('2025-08-17 10:40:00', 2, 10, 'completada', 0, 1050),
('2025-08-18 12:00:00', 1, 5, 'completada', 1, 5040),
('2025-08-18 13:25:00', 2, 2, 'completada', 0, 1050),
('2025-08-19 14:30:00', 1, 8, 'completada', 1, 5040),
('2025-08-19 15:50:00', 2, 6, 'completada', 0, 1050),
('2025-08-20 16:00:00', 1, 3, 'completada', 1, 5040),
('2025-08-20 17:15:00', 2, 9, 'completada', 0, 1050),
('2025-08-21 09:30:00', 1, 1, 'completada', 1, 5040),
('2025-08-21 10:45:00', 2, 4, 'completada', 0, 1050),
('2025-08-22 12:00:00', 1, 7, 'completada', 1, 5040),
('2025-08-22 13:15:00', 2, 10, 'completada', 0, 1050),
('2025-08-23 14:25:00', 1, 5, 'completada', 1, 5040),
('2025-08-23 15:40:00', 2, 2, 'completada', 0, 1050),
('2025-08-24 16:50:00', 1, 8, 'completada', 1, 5040),
('2025-08-25 09:05:00', 2, 6, 'completada', 0, 1050),
('2025-08-25 10:20:00', 1, 3, 'completada', 1, 5040),
('2025-08-26 11:30:00', 2, 9, 'completada', 0, 1050);