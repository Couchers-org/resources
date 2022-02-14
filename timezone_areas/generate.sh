# run postgis in docker while doing this:
docker run -d --rm --name tz_pg -p 5433:5433 -e POSTGRES_PASSWORD=local -e PGPORT=5433 postgis/postgis

# pull the timezone areas from https://github.com/evansiroky/timezone-boundary-builder
wget https://github.com/evansiroky/timezone-boundary-builder/releases/download/2020d/timezones-with-oceans.shapefile.zip
unzip timezones-with-oceans.shapefile.zip

# convert to pg dump
ogr2ogr -overwrite \
  -nln timezone_areas_raw \
  -nlt PROMOTE_TO_MULTI \
  -nlt MULTIPOLYGON \
  -lco GEOMETRY_NAME=geom \
  timezone_areas-raw.sql combined-shapefile-with-oceans.shp

# insert into postgis
docker exec -i tz_pg psql -U postgres < timezone_areas-raw.sql

# do st_subdivide on it to make polygons faster for lookups
docker exec -i tz_pg psql -U postgres -c "select * into timezone_areas from (select tzid, ST_Multi(ST_Subdivide(geom, 500)) as geom from timezone_areas_raw) t;"

# export
docker exec -i tz_pg pg_dump -U postgres --data-only --table timezone_areas --column-inserts | grep '^INSERT INTO public.timezone_areas' > timezone_areas.sql

# compress
zstd -22 --ultra timezone_areas.sql

# remove leftover stuff
rm timezones-with-oceans.shapefile.zip
rm combined-shapefile-with-oceans*
rm timezone_areas-raw.sql
rm timezone_areas.sql

# stop the docker container
docker stop tz_pg
