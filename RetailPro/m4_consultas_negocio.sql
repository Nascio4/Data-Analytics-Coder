-- ============================================================
-- M4 - Extrayendo metricas clave con SQL
-- Base de datos: Ventas_Tech_DB (tabla ventas, creada en M3)
-- ============================================================

-- ------------------------------------------------------------
-- Consulta 1: Resumen ejecutivo mensual
-- Total facturado, cantidad de pedidos y ticket promedio por mes
-- ------------------------------------------------------------

SELECT
    EXTRACT(MONTH FROM fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    COUNT(*) AS cantidad_pedidos,
    ROUND(SUM(cantidad * precio_unitario) / COUNT(*), 2) AS ticket_promedio
FROM ventas
GROUP BY EXTRACT(MONTH FROM fecha_venta)
ORDER BY mes;

-- ------------------------------------------------------------
-- Consulta 2: Ranking de productos
-- Top 5 de id_producto por total facturado
-- ------------------------------------------------------------

SELECT
    id_producto,
    SUM(cantidad) AS unidades_vendidas,
    SUM(cantidad * precio_unitario) AS total_facturado
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC
LIMIT 5;

-- ------------------------------------------------------------
-- Consulta 3: Clientes recurrentes
-- Clientes con mas de un pedido, cantidad de pedidos y total gastado
-- ------------------------------------------------------------

SELECT
    id_cliente,
    COUNT(*) AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC;

-- ------------------------------------------------------------
-- Consulta 4: Meses por encima/por debajo del promedio
-- Total facturado por mes, comparado contra el promedio mensual general
-- ------------------------------------------------------------

SELECT
    mes,
    total_facturado,
    CASE
        WHEN total_facturado > promedio_general THEN 'Por encima'
        ELSE 'Por debajo'
    END AS comparacion_promedio
FROM (
    SELECT
        EXTRACT(MONTH FROM fecha_venta) AS mes,
        SUM(cantidad * precio_unitario) AS total_facturado,
        AVG(SUM(cantidad * precio_unitario)) OVER () AS promedio_general
    FROM ventas
    GROUP BY EXTRACT(MONTH FROM fecha_venta)
) AS resumen_mensual
ORDER BY mes;

-- ------------------------------------------------------------
-- Hallazgos
-- ------------------------------------------------------------
-- 1. El producto 1 concentra el 56% de la facturacion total
--    ($3.600 de $6.444) a pesar de representar solo 2 de las
--    10 ventas registradas: es el producto mas caro y arrastra
--    todo el ranking.
-- 2. Los 5 clientes cargados son recurrentes (cada uno hizo
--    exactamente 2 pedidos), pero el gasto varia fuerte entre
--    ellos: el cliente 1 gasto $2.640 mientras que el cliente 4
--    solo gasto $510.
-- 3. Las 10 ventas caen todas en marzo de 2024, por lo que la
--    comparacion mes a mes de la Consulta 4 todavia no es
--    representativa; va a tomar sentido real recien cuando la
--    base tenga datos de varios meses.
