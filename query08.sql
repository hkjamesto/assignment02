/*
	With a query, find out how many census block groups Penn's main campus fully contains. Discuss which dataset you chose for defining Penn's campus.
*/
WITH penn_parcels AS (
    SELECT
        geog,
        objectid
    FROM phl.pwd_parcels
    WHERE
        owner1 ILIKE '%TRS UNIV PENN%'
        OR
        owner1 ILIKE '%TRS UNIV OF PENN%'
        OR
        owner1 ILIKE '%TRUSTEES OF UNIV OF PENN%'
        OR
        owner1 ILIKE '%UNIVERSITY OF PENN%'
        OR
        owner1 ILIKE '%THE UNIV OF PENN%'
        OR
        owner1 ILIKE '%TRUSTEES OF THE U OF PENN%'
        OR
        owner2 ILIKE '%TRS UNIV PENN%'
        OR
        owner2 ILIKE '%TRS UNIV OF PENN%'
        OR
        owner2 ILIKE '%TRUSTEES OF UNIV OF PENN%'
        OR
        owner2 ILIKE '%UNIVERSITY OF PENN%'
        OR
        owner2 ILIKE '%THE UNIV OF PENN%'
        OR
        owner2 ILIKE '%TRUSTEES OF THE U OF PENN%'
),

upenn AS (
    SELECT *
    FROM penn_parcels AS a
    WHERE EXISTS (
        SELECT 1 FROM penn_parcels AS b
        WHERE
            a.objectid != b.objectid
            AND a.geog <-> b.geog <= 10
    )
),

campus_geom AS (
    SELECT ST_CONVEXHULL(ST_UNION(geog::geometry)) AS campus_geom
    FROM upenn
)

SELECT COUNT(*) AS count_block_groups
FROM census.blockgroups_2020 AS cb,
    campus_geom AS cg
WHERE ST_CONTAINS(cg.campus_geom, cb.geog::geometry);
