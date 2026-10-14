# Spatial Distribution and Proximity Analysis of Gardens in Pune

An interactive web dashboard and GIS analysis of 11 mapped gardens in Pune, Maharashtra. It shows where the gardens are, how they group together, and which of them lie within 1 km of each other. The analysis was done in PostgreSQL/PostGIS and QGIS, and the results are presented in a single-page Leaflet dashboard.

**Live dashboard:** https://preeti-ekawade.github.io/Spatial-Distribution-and-Proximity-Analysis-of-Gardens-in-Pune/

![Spatial Distribution and Proximity Analysis of Gardens in Pune](Spatial_Distribution_and_Proximity_Analysis_of_Gardens_in_Pune.png)

## Dashboard features

- **Interactive map** with zoom, pop-ups, permanent garden name labels and a choice of Esri Light Gray or Esri Streets basemaps
- **Five spatial layers** (point, line and polygon) that can be switched on and off
- **Classified symbology**: gardens and polygons coloured by prabhag, and 1 km pair lines coloured by distance class
- **Charts and statistics**: gardens by prabhag, distances between garden pairs, and a statistical summary
- **Downloads**: chart images (PNG), the statistical summary (CSV), the print map (JPG) and all layers (GeoJSON)
- **Section navigation**: a sticky menu and clickable summary tiles that jump to each section
- **Garden register**: a table of all gardens with prabhag, ward, coordinates and nearest-garden distance. Click a row to zoom to that garden.

## Spatial layers

| Layer | Geometry | Source table | Symbology |
|---|---|---|---|
| Garden points | Point | `pune_gardens` | Colour by prabhag (6 classes) |
| Garden polygons | Polygon | `garden_polygons` | 100 m × 100 m footprints, colour by prabhag |
| Pairs within 1 km | Line | `analysis_relationship_1km` | Three distance classes: under 600 m, 600–800 m, 800–1000 m |
| Nearest-garden links | Line | `analysis_nearest_garden` | Dashed line from each garden to its nearest neighbour |
| Garden connectors | Line | `garden_connectors` | Dashed line for six selected pairs |

## Key results

- **11 gardens** fall into **6 prabhag classes**. Kondhwa-wanawdi has 4 gardens, Kishkindha Nagar has 3, and NIBM, Mayur Colony, Sopan Buag and Bavdhan Khurd have 1 each.
- The gardens form three groupings: Kothrud and Bavdhan in the west, Sopan Buag in the north-east, and Kondhwa–Wanawadi in the south-east.
- **6 garden pairs** lie within 1 km, with distances of 0 m, 523 m, 771 m, 771 m, 785 m and 824 m. The 0 m pair is Ramchandra Mane Rd and Sarasbaug, which share the same coordinates.
- Each garden has a 100 m × 100 m polygon (10,000 m²), giving a uniform footprint for comparison.

## Method

1. Garden records were loaded into PostGIS as the `pune_gardens` point table (EPSG:4326).
2. Polygons were built as 100 m × 100 m envelopes around each point in EPSG:32643 (UTM zone 43N) and transformed back to EPSG:4326.
3. Pairs within 1 km were found with `ST_DWithin` on geography at 1,000 m and joined with `ST_MakeLine`.
4. Nearest neighbours were found with a lateral join ordered by distance.
5. The layers were mapped in QGIS to produce the print map, and rebuilt in the dashboard for interactive use.

Distances in the dashboard are calculated in the browser from the coordinates using the great-circle (haversine) formula.

## Repository contents

| File | Description |
|---|---|
| `index.html` | The dashboard. It is a single self-contained file and is what GitHub Pages serves. |
| `Urban Green Spaces and Road Accessibility in Pune.sql` | PostGIS script that creates the tables and runs the spatial analysis |
| `Spatial_Distribution_and_Proximity_Analysis_of_Gardens_in_Pune.png` | Print map exported from QGIS |
| `greenspaces.xml` | Supporting data file |
| `pie chart` | Chart image of garden records by prabhag |

## Run it locally

No build step is needed. Download `index.html` and open it in a web browser with an internet connection, because the map libraries and basemap tiles load online.

## Publish on GitHub Pages

1. Keep the dashboard at the top level of the repository as `index.html`.
2. Open **Settings**, then **Pages**.
3. Under **Build and deployment**, choose **Deploy from a branch**, select `main` and `/ (root)`, then save.
4. After a minute or two the dashboard is available at the live link above.

## Built with

- [Leaflet](https://leafletjs.com/) for the interactive map
- [Chart.js](https://www.chartjs.org/) for the charts
- PostgreSQL / [PostGIS](https://postgis.net/) for the spatial analysis
- [QGIS](https://qgis.org/) for the print map
- Basemap tiles from Esri (World Light Gray Canvas and World Street Map), using data from OpenStreetMap contributors
