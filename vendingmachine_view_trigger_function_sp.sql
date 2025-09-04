
-- Este script incluye cinco vistas, dos funciones, tres procedimientos almacenados y dos triggers

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


-- ========================================================================
-- 3. VISTA: vista_reportes_fallas_pendientes
-- ------------------------------------------------------------------------
-- Descripcion:
-- Muestra informacion detallada de los reportes de fallas que estan pendientes,
-- incluyendo datos de las tablas 'operadores', 'maquinas' y 'ubicaciones'.
-- ========================================================================
CREATE VIEW vista_reportes_fallas_pendientes AS
SELECT
    rf.id_reporte,
    rf.fecha,
    rf.fallaDetalle,
    rf.estado,
    u.direccion AS ubicacion_maquina,
    u.ciudad AS ciudad_maquina,
    u.tel_contacto AS telefono_contacto,
    o.operador AS nombre_operador
FROM
    reportes_fallas rf
JOIN
    maquinas m ON rf.id_maquina = m.id_maquina
JOIN
    ubicaciones u ON m.id_ubicacion = u.id_ubicacion
JOIN
    operadores o ON rf.id_operador = o.id_operador
WHERE
    rf.estado = 'pendiente';



-- ========================================================================
-- 4. VISTA: vista_fallas_solucionadas
-- ------------------------------------------------------------------------
-- Descripcion:
-- Muestra informacion detallada de las soluiciones a fallas reportadas,
-- incluyendo datos de las tablas 'fallas_solucionadas', 'reportes_fallas' y 'tecnicos'.
-- ========================================================================
CREATE VIEW vista_fallas_solucionadas AS
SELECT
    rf.id_reporte AS id_falla,
    rf.fallaDetalle AS detalle_falla,
    rf.fecha AS fecha_falla,
    t.tecnico AS tecnico_solucionador,
    fs.fecha AS fecha_solucion,
    fs.detalleSolucion AS detalle_solucion
FROM
    fallas_solucionadas fs
JOIN
    reportes_fallas rf ON fs.id_reporte_falla = rf.id_reporte
JOIN
    tecnicos t ON fs.id_tecnico = t.id_tecnico;



-- ========================================================================
-- 5. VISTA: vista_mantenimientos
-- ------------------------------------------------------------------------
-- Descripcion:
-- Muestra informacion detallada de los mantenimientos realizados,
-- incluyendo datos de las tablas 'mantenimientos', 'maquinas', 'ubicaciones' y 'tecnicos'.
-- ========================================================================
CREATE VIEW vista_mantenimientos AS
SELECT
    mant.id_mantenimiento AS id_mantenimiento,
    mant.fecha AS fecha,
    mant.detalle AS detalle,
    m.id_maquina AS id_maquina,
    u.direccion AS ubicacion_maquina,
    u.ciudad AS ciudad_maquina,
    t.tecnico AS tecnico_realizador
FROM
    mantenimientos mant
JOIN
    maquinas m ON mant.id_maquina = m.id_maquina
JOIN
    ubicaciones u ON m.id_ubicacion = u.id_ubicacion
JOIN
    tecnicos t ON mant.id_tecnico = t.id_tecnico;




-- procedimientos almacenados, funciones y triggers.
DELIMITER $$

-- ========================================================================
-- 1. FUNCION: fn_total_ventas_maquina
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
-- 2. FUNCION: fn_total_reparaciones_tecnico
-- ------------------------------------------------------------------------
-- Descripcion:
-- Calcula el total de reparaciones realizadas por un tecnico especifico.
-- Retorna un valor INT que representa el numero total de reparaciones.
-- Si no hay reparaciones, devuelve 0.
-- ========================================================================
CREATE FUNCTION fn_total_reparaciones_tecnico(
    p_id_tecnico INT
)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE total_reparaciones INT;
    SELECT
        COUNT(*)
    INTO
        total_reparaciones
    FROM
        fallas_solucionadas
    WHERE
        id_tecnico = p_id_tecnico;
    RETURN IFNULL(total_reparaciones, 0);
END$$


-- ========================================================================
-- 1. PROCEDIMIENTO ALMACENADO: sp_generar_reporte_ventas_mensual
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
-- 2. PROCEDIMIENTO ALMACENADO: sp_contar_fallas_por_maquina
-- ------------------------------------------------------------------------
-- Descripcion:
-- Genera un reporte que lista todas las maquinas expendedoras
-- y por cada maquina mostrar cuantos reportes de fallos se han reportado
-- para cada una de ellas. de esta manera podemos saber estadisticamente
-- cuales maquinas tienen mas fallas reportadas.
-- ========================================================================
CREATE PROCEDURE sp_contar_fallas_por_maquina()
BEGIN
    SELECT
        m.id_maquina,
        COUNT(rf.id_reporte) AS total_fallas_reportadas
    FROM
        maquinas m
    LEFT JOIN
        reportes_fallas rf ON m.id_maquina = rf.id_maquina
    GROUP BY
        m.id_maquina
    ORDER BY
        m.id_maquina;
END$$


-- ========================================================================
-- 3. PROCEDIMIENTO ALMACENADO: sp_registrar_reposicion
-- ------------------------------------------------------------------------
-- Descripcion:
-- Procedimiento almacenado para registrar una reposicion de stock
-- en una maquina expendedora y actualizar el stock actual de la maquina.
-- usando transacciones para asegurar la integridad de la base de datos.
-- ========================================================================
CREATE PROCEDURE sp_registrar_reposicion(
    IN p_id_maquina INT,
    IN p_id_operador INT,
    IN p_cantidad TINYINT
)
BEGIN
    -- Declara una variable para manejar errores.
    DECLARE v_error BOOLEAN DEFAULT FALSE;

    -- Define un handler para manejar cualquier excepción (error)
    -- Si ocurre un error, se establece la variable v_error a TRUE.
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        SET v_error = TRUE;
    END;

    -- Inicia la transacción.
    START TRANSACTION;

    -- Paso 1: Inserta el registro en la tabla de reposiciones.
    INSERT INTO reposiciones (fecha, cantidad, id_maquina, id_operador)
    VALUES (NOW(), p_cantidad, p_id_maquina, p_id_operador);

    -- Paso 2: Actualiza el stock de la maquina.
    UPDATE maquinas
    SET stock_actual = stock_actual + p_cantidad
    WHERE id_maquina = p_id_maquina;

    -- Verifica si ha ocurrido un error
    IF v_error THEN
        -- Si hubo un error, revierte todos los cambios de la transacción.
        ROLLBACK;
        SELECT 'Error: No se pudo completar la reposición. La transacción ha sido revertida.' AS resultado;
    ELSE
        -- Si todo fue exitoso, confirma los cambios.
        COMMIT;
        SELECT 'Éxito: La reposición ha sido registrada y el stock actualizado.' AS resultado;
    END IF;

END$$

-- ========================================================================
-- 1. TRIGGER: tr_actualizar_stock
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


-- ========================================================================
-- 1. TRIGGER: tr_actualizar_estado_falla
-- ------------------------------------------------------------------------
-- Descripcion:
-- Actualiza automaticamente el repor de una falla en la tabla 'reportes_fallas'
-- cambia el estado de pendiente a solucionado despues de que se insertada una fila
-- en la tabla 'fallas_solucionadas'.
-- ========================================================================
CREATE TRIGGER tr_actualizar_estado_falla
AFTER INSERT ON fallas_solucionadas
FOR EACH ROW
BEGIN
    -- Actualiza el estado de la falla en la tabla 'reportes_fallas'
    -- usando el id_reporte_falla de la nueva fila insertada.
    UPDATE reportes_fallas
    SET
        estado = 'solucionado'
    WHERE
        id_reporte = NEW.id_reporte_falla;
END$$


DELIMITER ;