/*
	You're tasked with giving more contextual information to rail stops to fill the stop_desc field in a GTFS feed. Using any of the data sets above, PostGIS functions (e.g., ST_Distance, ST_Azimuth, etc.), and PostgreSQL string functions, build a description (alias as stop_desc) for each stop. Feel free to supplement with other datasets (must provide link to data used so it's reproducible), and other methods of describing the relationships. SQL's CASE statements may be helpful for some operations.
*/
SELECT
    rstops.stop_id,
    rstops.stop_name,
    rstops.stop_lon,
    rstops.stop_lat,
    ROUND(
        ST_DISTANCE(rstops.geog, parcel.geog)::numeric, 1
    ) || ' meters '
    || CASE
        WHEN DEGREES(ST_AZIMUTH(ST_CENTROID(parcel.geog::geometry), rstops.geog::geometry)) BETWEEN 22.5 AND 67.5 THEN 'NE'
        WHEN DEGREES(ST_AZIMUTH(ST_CENTROID(parcel.geog::geometry), rstops.geog::geometry)) BETWEEN 67.5 AND 112.5 THEN 'E'
        WHEN DEGREES(ST_AZIMUTH(ST_CENTROID(parcel.geog::geometry), rstops.geog::geometry)) BETWEEN 112.5 AND 157.5 THEN 'SE'
        WHEN DEGREES(ST_AZIMUTH(ST_CENTROID(parcel.geog::geometry), rstops.geog::geometry)) BETWEEN 157.5 AND 202.5 THEN 'S'
        WHEN DEGREES(ST_AZIMUTH(ST_CENTROID(parcel.geog::geometry), rstops.geog::geometry)) BETWEEN 202.5 AND 247.5 THEN 'SW'
        WHEN DEGREES(ST_AZIMUTH(ST_CENTROID(parcel.geog::geometry), rstops.geog::geometry)) BETWEEN 247.5 AND 292.5 THEN 'W'
        WHEN DEGREES(ST_AZIMUTH(ST_CENTROID(parcel.geog::geometry), rstops.geog::geometry)) BETWEEN 292.5 AND 337.5 THEN 'NW'
        ELSE 'N'
    END || ' of '
    || COALESCE(parcel.address, parcel.owner1, 'an unnamed parcel') AS stop_desc
FROM
    septa.rail_stops AS rstops
INNER JOIN LATERAL (
    SELECT *
    FROM phl.pwd_parcels AS parcel
    ORDER BY rstops.geog <-> parcel.geog
    LIMIT 1
) AS parcel ON TRUE;
