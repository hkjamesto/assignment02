/*
	What are the bottom five neighborhoods according to your accessibility metric?
*/
WITH stops_in_neighborhoods AS (
    SELECT
        neighborhood.name AS neighborhood_name,
        neighborhood.geog AS neighborhood_geog,
        bstops.wheelchair_boarding
    FROM phl.neighborhoods AS neighborhood
    INNER JOIN septa.bus_stops AS bstops
        ON ST_INTERSECTS(bstops.geog, neighborhood.geog)
    WHERE bstops.wheelchair_boarding IN (1, 2)
),

agg AS (
    SELECT
        neighborhood_name,
        neighborhood_geog,
        COUNT(*) FILTER (WHERE wheelchair_boarding = 1) AS num_bus_stops_accessible,
        COUNT(*) FILTER (WHERE wheelchair_boarding = 2) AS num_bus_stops_inaccessible
    FROM stops_in_neighborhoods
    GROUP BY neighborhood_name, neighborhood_geog
),

metric AS (
    SELECT
        neighborhood_name,
        num_bus_stops_accessible,
        num_bus_stops_inaccessible,
        ROUND((ST_AREA(neighborhood_geog) / 1000000.0)::numeric, 3) AS area_km2,
        (num_bus_stops_accessible::numeric / NULLIF((ST_AREA(neighborhood_geog) / 1000000.0)::numeric, 0)) AS accessibility_metric
    FROM agg
),

stats AS (
    SELECT
        MIN(accessibility_metric) AS min_metric,
        MAX(accessibility_metric) AS max_metric
    FROM metric
    WHERE area_km2 > 0
)

SELECT
    metric.neighborhood_name,
    metric.num_bus_stops_accessible,
    metric.num_bus_stops_inaccessible,
    ROUND(
        (metric.accessibility_metric - stats.min_metric)
        / NULLIF(stats.max_metric - stats.min_metric, 0), 3
    ) AS accessibility_metric
FROM metric
CROSS JOIN stats
WHERE metric.area_km2 > 0
ORDER BY accessibility_metric ASC, metric.num_bus_stops_accessible ASC
LIMIT 5;
