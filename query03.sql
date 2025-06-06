/*
	Using the Philadelphia Water Department Stormwater Billing Parcels dataset, pair each parcel with its closest bus stop. The final result should give the parcel address, bus stop name, and distance apart in meters, rounded to two decimals. Order by distance (largest on top).
*/
WITH parcel_closest_bus_stop AS (
    SELECT
        parcel.ogc_fid,
        parcel.address AS parcel_address,
        bs.stop_name,
        ROUND(ST_DISTANCE(parcel.geog, bs.geog)::numeric, 2) AS distance
    FROM
        phl.pwd_parcels AS parcel
    INNER JOIN LATERAL (
        SELECT
            bus_stops.stop_name,
            bus_stops.geog
        FROM septa.bus_stops
        ORDER BY parcel.geog <-> bus_stops.geog
        LIMIT 1
    ) AS bs ON TRUE
)

SELECT
    parcel_address,
    stop_name,
    distance
FROM parcel_closest_bus_stop
ORDER BY distance DESC;
