/*
	With a query involving PWD parcels and census block groups, find the geo_id of the block group that contains Meyerson Hall. ST_MakePoint() and functions like that are not allowed.
*/
SELECT cb.geoid AS geo_id
FROM phl.pwd_parcels AS parcel
INNER JOIN census.blockgroups_2020 AS cb
    ON ST_CONTAINS(cb.geog::geometry, parcel.geog::geometry)
WHERE parcel.address ILIKE '%220-30 S 34TH%'
LIMIT 1;
