/*
	Using the bus_shapes, bus_routes, and bus_trips tables from GTFS bus feed, find the two routes with the longest trips.
*/
WITH trip_shapes AS (
    SELECT
        btrips.trip_id,
        btrips.route_id,
        btrips.trip_headsign,
        bshapes.shape_id,
        ST_MakeLine(
            ST_SetSRID(
                ST_MakePoint(bshapes.shape_pt_lon, bshapes.shape_pt_lat), 4326
            ) ORDER BY bshapes.shape_pt_sequence
        )::geography AS shape_geog
    FROM
        septa.bus_trips AS btrips
    JOIN septa.bus_shapes AS bshapes
        ON btrips.shape_id = bshapes.shape_id
    GROUP BY
        btrips.trip_id, btrips.route_id, btrips.trip_headsign, bshapes.shape_id
),
trip_lengths AS (
    SELECT
        tshapes.trip_id,
        tshapes.route_id,
        tshapes.trip_headsign,
        tshapes.shape_geog,
        ROUND(ST_Length(tshapes.shape_geog)) AS shape_length
    FROM trip_shapes AS tshapes
),
longest_trip_per_route AS (
    SELECT
        tlengths.*,
        ROW_NUMBER() OVER (PARTITION BY tlengths.route_id ORDER BY tlengths.shape_length DESC) AS rn
    FROM trip_lengths AS tlengths
)
SELECT DISTINCT
    broutes.route_short_name,
    ltp.trip_headsign,
    ltp.shape_geog,
    ltp.shape_length
FROM longest_trip_per_route AS ltp
JOIN septa.bus_routes AS broutes
    ON ltp.route_id = broutes.route_id
WHERE ltp.rn = 1
ORDER BY ltp.shape_length DESC
LIMIT 2;
