
-- Este script incluye dos vistas, una funcion, un procedimiento almacenado y un trigger

-- ========================================================================
-- 1. VISTA: vista_maquinas
-- ------------------------------------------------------------------------
-- Descripcion:
-- Muestra informacion detallada de cada maquina expendedora, combinando
-- datos de la tabla 'maquinas' y 'ubicaciones'.
-- ========================================================================
CREATE VIEW vista_maquinas AS
SELECT
    m.id_maquina,
    m.estado,
    m.keep_alive,
    m.habilitada,
    m.stock_actual,
    u.direccion,
    u.ciudad,
    u.latitud,
    u.longitud,
    u.tel_contacto
FROM
    maquinas m
INNER JOIN
    ubicaciones u ON m.id_ubicacion = u.id_ubicacion;

-- ========================================================================
-- 2. VISTA: vista_operadores
-- ------------------------------------------------------------------------
-- Descripcion:
-- Muestra informacion detallada de los operadores y las maquinas que tienen asignadas,
-- incluyendo datos de las tablas 'operadores', 'maquinas' y 'ubicaciones'.
-- ========================================================================
CREATE VIEW vista_operadores AS
SELECT
    o.operador,
    m.id_maquina AS maquina_asignada,
    m.estado AS estado_maquina,
    m.stock_actual AS stock_maquina,
    u.direccion,
    u.ciudad,
    u.tel_contacto AS telefono
FROM
    operadores o
INNER JOIN
    maquinas m ON o.id_maquina = m.id_maquina
INNER JOIN
    ubicaciones u ON m.id_ubicacion = u.id_ubicacion;


-- procedimientos almacenados y triggers.
DELIMITER $$

-- ========================================================================
-- 3. FUNCION: fn_total_ventas_maquina
-- ------------------------------------------------------------------------
-- Descripcion:
-- Calcula el total de ventas completadas para una maquina especifica.
-- Retorna un valor REAL que representa el monto total.
-- Si no hay ventas, devuelve 0.
-- ========================================================================
CREATE FUNCTION fn_total_ventas_maquina(p_id_maquina INT)
RETURNS REAL
DETERMINISTIC
BEGIN
    DECLARE total_vendido REAL;
    
    -- Suma las ventas donde el estado es 'completada' para la maquina dada
    SELECT SUM(purchase) INTO total_vendido
    FROM ventas
    WHERE id_maquina = p_id_maquina AND estado = 'completada';
    
    -- Retorna 0 si el total es NULL, de lo contrario retorna el total
    RETURN IFNULL(total_vendido, 0);
END$$

-- ========================================================================
-- 4. PROCEDIMIENTO ALMACENADO: sp_generar_reporte_ventas_mensual
-- ------------------------------------------------------------------------
-- Descripcion:
-- Genera un reporte detallado y un resumen de las ventas mensuales
-- para una maquina expendedora, con un mes y año especificos.
-- ========================================================================
CREATE PROCEDURE sp_generar_reporte_ventas_mensual(
    IN p_id_maquina INT,
    IN p_mes INT,
    IN p_anio INT
)
BEGIN
    -- Variable para almacenar el total mensual que luego voy ir sumando
    DECLARE v_total_mensual REAL;

    -- Calcula el total de ventas completadas para el periodo
    SELECT SUM(purchase)
    INTO v_total_mensual
    FROM ventas
    WHERE id_maquina = p_id_maquina
      AND estado = 'completada'
      AND MONTH(fecha) = p_mes
      AND YEAR(fecha) = p_anio;

    -- Asigna 0 si el total es NULL
    IF v_total_mensual IS NULL THEN
        SET v_total_mensual = 0;
    END IF;

    -- Genera el reporte detallado
    SELECT
        id_venta,
        fecha,
        p.descripcion AS producto,
        v.purchase AS monto_venta
    FROM ventas v
    JOIN productos p ON v.id_producto = p.id_producto
    WHERE v.id_maquina = p_id_maquina
      AND v.estado = 'completada'
      AND MONTH(v.fecha) = p_mes
      AND YEAR(v.fecha) = p_anio
    ORDER BY v.fecha ASC;

    -- Muestra el resumen del total
    SELECT
        p_id_maquina AS maquina_id,
        CONCAT(p_mes, '/', p_anio) AS periodo,
        v_total_mensual AS total_ventas_mes;

END$$

-- ========================================================================
-- 5. TRIGGER: tr_actualizar_stock
-- ------------------------------------------------------------------------
-- Descripcion:
-- Actualiza automaticamente el stock de una maquina expendedora
-- despues de que el estado de una venta en la tabla 'ventas' sea modificado.
-- ========================================================================
CREATE TRIGGER tr_actualizar_stock
AFTER UPDATE ON ventas
FOR EACH ROW
BEGIN
    -- Si la venta cambia a 'completada', disminuye el stock en 1
    IF NEW.estado = 'completada' AND OLD.estado != 'completada' THEN
        UPDATE maquinas
        SET stock_actual = stock_actual - 1
        WHERE id_maquina = NEW.id_maquina AND stock_actual > 0;

    -- Si la venta cambia a 'devolucion', aumenta el stock en 1
    ELSEIF NEW.estado = 'devolucion' AND OLD.estado != 'devolucion' THEN
        UPDATE maquinas
        SET stock_actual = stock_actual + 1
        WHERE id_maquina = NEW.id_maquina;
    END IF;
END$$


DELIMITER ;