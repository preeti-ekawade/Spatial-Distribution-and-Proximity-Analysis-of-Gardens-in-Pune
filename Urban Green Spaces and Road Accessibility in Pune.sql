
CREATE EXTENSION IF NOT EXISTS postgis;


CREATE TABLE pune_gardens (
    id SERIAL PRIMARY KEY,
    sr_no INTEGER,
    facility_type VARCHAR(50),
    garden_name VARCHAR(200),
    address TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    prabhag_name VARCHAR(100),
    ward_name VARCHAR(100),
    geom GEOMETRY(Point, 4326)
);


INSERT INTO pune_gardens
(sr_no, facility_type, garden_name, address,
 latitude, longitude, prabhag_name, ward_name, geom)
VALUES
(16, 'Garden', 'Sh.Abdul Hamid Ayurvedic Udyan',
 'Kondhwa Bk', 18.473664, 73.895746,
 'Kondhwa-wanawdi', NULL,
 ST_SetSRID(ST_MakePoint(73.895746, 18.473664), 4326)),

(37, 'Garden', 'Late. Vitthalrao Shivarkar Udyan Jogging Track',
 'Wanawadi', 18.498382, 73.899974,
 'Kondhwa-wanawdi', NULL,
 ST_SetSRID(ST_MakePoint(73.899974, 18.498382), 4326)),

(39, 'Garden', 'St.Mary Church',
 'Sopan Buag', 18.527458, 73.905006,
 'Kondhwa-wanawdi', NULL,
 ST_SetSRID(ST_MakePoint(73.905006, 18.527458), 4326)),

(41, 'Garden', 'Ramchandra Mane Rd, Ramkrishna Paramhans Nagar, Kothrud',
 'kishkindha nagar', 18.507941, 73.80627000000004,
 'Kishkindha Nagar', 'Kothrud',
 ST_SetSRID(ST_MakePoint(73.80627000000004, 18.507941), 4326)),

(58, 'Garden', 'In front of Kalyani Nagar Steel',
 'Sopan Buag', 18.525302, 73.909414,
 'Kondhwa-wanawdi', NULL,
 ST_SetSRID(ST_MakePoint(73.909414, 18.525302), 4326)),

(75, 'Garden', 'Shivaji Udyan',
 'Kondhva', 18.49109801181133, 73.9014217989502,
 'NIBM', 'Kondhwa-wanawdi',
 ST_SetSRID(ST_MakePoint(73.9014217989502, 18.49109801181133), 4326)),

(77, 'Garden', 'sarasbaug',
 '335, kishkindha nagar, kothrud',
 18.507941, 73.80627000000004,
 'Kishkindha Nagar', 'Kothrud',
 ST_SetSRID(ST_MakePoint(73.80627000000004, 18.507941), 4326)),

(78, 'Garden', 'Late. Tatyasaheb Thorat',
 'This is just for testing purpose.',
 18.504008, 73.81228799999997,
 'Mayur Colony', 'Kothrud',
 ST_SetSRID(ST_MakePoint(73.81228799999997, 18.504008), 4326)),

(79, 'Garden', 'Gandharv garden',
 'Kondhava', 18.5185035, 73.90739200000007,
 'Sopan Buag', 'Kondhwa-wanawdi',
 ST_SetSRID(ST_MakePoint(73.90739200000007, 18.5185035), 4326)),

(80, 'Garden', 'Katraj Sarpodyan',
 'near Katraj milk dairy',
 18.517025661701638, 73.80831767193604,
 'Kishkindha Nagar', 'Kothrud',
 ST_SetSRID(ST_MakePoint(73.80831767193604, 18.517025661701638), 4326)),

(81, 'Garden', 'Bharatratna Dr. Bhimsen Joshi',
 'bavdhan', 18.511476, 73.79134299999998,
 'Bavdhan Khurd', 'Kothrud',
 ST_SetSRID(ST_MakePoint(73.79134299999998, 18.511476), 4326));


 SELECT
    sr_no,
    garden_name,
    latitude,
    longitude,
    ST_AsText(geom) AS point_geometry
FROM pune_gardens;



-- Create a line table connecting nearby gardens
CREATE TABLE garden_connectors (
    id SERIAL PRIMARY KEY,
    line_name VARCHAR(100),
    garden_a INTEGER,
    garden_b INTEGER,
    geom GEOMETRY(LineString, 4326)
);


INSERT INTO garden_connectors
(line_name, garden_a, garden_b, geom)
SELECT
    v.line_name,
    v.garden_a,
    v.garden_b,
    ST_MakeLine(a.geom, b.geom)
FROM (
    VALUES
        ('Connector 1', 16, 75),
        ('Connector 2', 16, 37),
        ('Connector 3', 37, 75),
        ('Connector 4', 39, 58),
        ('Connector 5', 58, 79),
        ('Connector 6', 41, 78)
) AS v(line_name, garden_a, garden_b)
JOIN pune_gardens a ON a.sr_no = v.garden_a
JOIN pune_gardens b ON b.sr_no = v.garden_b;


SELECT
    id,
    line_name,
    garden_a,
    garden_b,
    ST_AsText(geom) AS line_geometry
FROM garden_connectors;



-- Create polygon table
CREATE TABLE garden_polygons (
    id SERIAL PRIMARY KEY,
    sr_no INTEGER,
    garden_name VARCHAR(200),
    geom GEOMETRY(Polygon, 4326)
);


INSERT INTO garden_polygons (sr_no, garden_name, geom)
SELECT
    sr_no,
    garden_name,
    ST_Transform(
        ST_MakeEnvelope(
            ST_X(ST_Transform(geom, 32643)) - 50,
            ST_Y(ST_Transform(geom, 32643)) - 50,
            ST_X(ST_Transform(geom, 32643)) + 50,
            ST_Y(ST_Transform(geom, 32643)) + 50,
            32643
        ),
        4326
    )::geometry(Polygon, 4326)
FROM pune_gardens
WHERE geom IS NOT NULL;



SELECT
    id,
    sr_no,
    garden_name,
    ST_GeometryType(geom) AS geometry_type,
    ST_IsValid(geom) AS is_valid
FROM garden_polygons;




SELECT
    a.garden_name AS garden_1,
    b.garden_name AS garden_2,
    ROUND(
        ST_Distance(a.geom::geography, b.geom::geography)::numeric,
        2
    ) AS distance_m
FROM pune_gardens a
JOIN pune_gardens b
    ON a.sr_no = 16
   AND b.sr_no = 37;


SELECT
    a.garden_name AS garden_name,
    nearest.garden_name AS nearest_garden,
    ROUND(nearest.distance_m::numeric, 2) AS distance_m
FROM pune_gardens a
CROSS JOIN LATERAL (
    SELECT
        b.garden_name,
        ST_Distance(a.geom::geography, b.geom::geography)
            AS distance_m
    FROM pune_gardens b
    WHERE b.id <> a.id
    ORDER BY a.geom <-> b.geom
    LIMIT 1
) nearest
ORDER BY a.sr_no;


SELECT
    garden_name,
    ST_Buffer(geom::geography, 100)::geometry AS buffer_geom
FROM pune_gardens;


SELECT
    a.id AS polygon_1,
    b.id AS polygon_2,
    ST_Intersection(a.geom, b.geom) AS intersection_geom
FROM garden_polygons a
JOIN garden_polygons b
    ON a.id < b.id
   AND ST_Intersects(a.geom, b.geom);



   
CREATE EXTENSION IF NOT EXISTS postgis;

DROP TABLE IF EXISTS analysis_buffer_100m;

CREATE TABLE analysis_buffer_100m AS
SELECT
    ROW_NUMBER() OVER (ORDER BY sr_no)::integer AS id,
    sr_no,
    garden_name,
    100 AS buffer_distance_m,
    ST_Buffer(geom::geography, 100)::geometry(Polygon,4326) AS geom
FROM pune_gardens
WHERE geom IS NOT NULL;

SELECT * FROM analysis_buffer_100m;





DROP TABLE IF EXISTS analysis_intersections;

CREATE TABLE analysis_intersections AS
SELECT
    ROW_NUMBER() OVER (ORDER BY a.id,b.id)::integer AS id,
    a.id AS polygon_a,
    b.id AS polygon_b,
    a.garden_name AS garden_a,
    b.garden_name AS garden_b,
    ST_Area(ST_Intersection(a.geom,b.geom)::geography)
        AS intersection_area_m2,
    ST_CollectionExtract(
        ST_Intersection(a.geom,b.geom), 3
    )::geometry(Polygon,4326) AS geom
FROM garden_polygons a
JOIN garden_polygons b
    ON a.id < b.id
   AND ST_Intersects(a.geom,b.geom)
WHERE ST_Area(ST_Intersection(a.geom,b.geom)) > 0;



DROP TABLE IF EXISTS analysis_spatial_join;

CREATE TABLE analysis_spatial_join AS
SELECT
    ROW_NUMBER() OVER (ORDER BY g.sr_no,p.id)::integer AS id,
    g.sr_no,
    g.garden_name,
    p.id AS polygon_id,
    p.garden_name AS polygon_name,
    g.geom AS geom
FROM pune_gardens g
JOIN garden_polygons p
    ON ST_Intersects(g.geom,p.geom);

SELECT * FROM analysis_spatial_join;




DROP TABLE IF EXISTS analysis_within_contains;

CREATE TABLE analysis_within_contains AS
SELECT
    ROW_NUMBER() OVER (ORDER BY g.sr_no,p.id)::integer AS id,
    g.sr_no,
    g.garden_name,
    p.id AS polygon_id,
    ST_Within(g.geom,p.geom) AS point_within_polygon,
    ST_Contains(p.geom,g.geom) AS polygon_contains_point,
    g.geom AS geom
FROM pune_gardens g
JOIN garden_polygons p
    ON ST_Within(g.geom,p.geom);

SELECT * FROM analysis_within_contains;



DROP TABLE IF EXISTS analysis_nearest_garden;

CREATE TABLE analysis_nearest_garden AS
SELECT
    ROW_NUMBER() OVER (ORDER BY a.sr_no)::integer AS id,
    a.sr_no AS source_sr_no,
    a.garden_name AS source_garden,
    n.sr_no AS nearest_sr_no,
    n.garden_name AS nearest_garden,
    n.distance_m,
    ST_MakeLine(a.geom,n.geom)::geometry(LineString,4326) AS geom
FROM pune_gardens a
CROSS JOIN LATERAL (
    SELECT
        b.sr_no,
        b.garden_name,
        b.geom,
        ST_Distance(a.geom::geography,b.geom::geography) AS distance_m
    FROM pune_gardens b

    WHERE b.id <> a.id
    ORDER BY ST_Distance(a.geom::geography,b.geom::geography)
    LIMIT 1
) n;

SELECT * FROM analysis_nearest_garden;

SELECT * FROM analysis_intersections;




DROP TABLE IF EXISTS analysis_area;

CREATE TABLE analysis_area AS
SELECT
    id,
    sr_no,
    garden_name,
    ROUND(ST_Area(geom::geography)::numeric,2) AS area_m2,
    geom
FROM garden_polygons;

SELECT * FROM analysis_area;



DROP TABLE IF EXISTS analysis_length;

CREATE TABLE analysis_length AS
SELECT
    id,
    line_name,
    garden_a,
    garden_b,
    ROUND(ST_Length(geom::geography)::numeric,2) AS length_m,
    geom
FROM garden_connectors;

SELECT * FROM analysis_length;



DROP TABLE IF EXISTS analysis_spatial_filter;

CREATE TABLE analysis_spatial_filter AS
SELECT
    ROW_NUMBER() OVER (ORDER BY b.sr_no)::integer AS id,
    b.sr_no,
    b.garden_name,
    ROUND(
        ST_Distance(a.geom::geography,b.geom::geography)::numeric,
        2
    ) AS distance_from_garden_16_m,
    b.geom
FROM pune_gardens a
JOIN pune_gardens b
    ON ST_DWithin(a.geom::geography,b.geom::geography,5000)
WHERE a.sr_no = 16
  AND b.id <> a.id;

SELECT * FROM analysis_spatial_filter;


DROP TABLE IF EXISTS analysis_transformed_points;

CREATE TABLE analysis_transformed_points AS
SELECT
    id,
    sr_no,
    garden_name,
    ST_Transform(geom,32643)::geometry(Point,32643) AS geom
FROM pune_gardens
WHERE geom IS NOT NULL;

SELECT * FROM analysis_transformed_points;




DROP TABLE IF EXISTS analysis_relationship_1km;

CREATE TABLE analysis_relationship_1km AS
SELECT
    ROW_NUMBER() OVER (ORDER BY a.sr_no,b.sr_no)::integer AS id,
    a.sr_no AS garden_a_sr_no,
    a.garden_name AS garden_a,
    b.sr_no AS garden_b_sr_no,
    b.garden_name AS garden_b,
    ROUND(
        ST_Distance(a.geom::geography,b.geom::geography)::numeric,
        2
    ) AS distance_m,
    ST_MakeLine(a.geom,b.geom)::geometry(LineString,4326) AS geom
FROM pune_gardens a
JOIN pune_gardens b
    ON a.id < b.id
   AND ST_DWithin(a.geom::geography,b.geom::geography,1000);

SELECT * FROM analysis_relationship_1km;