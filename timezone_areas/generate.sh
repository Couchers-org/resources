# pull the timezone areas from https://github.com/evansiroky/timezone-boundary-builder
wget https://github.com/evansiroky/timezone-boundary-builder/releases/download/2020d/timezones-with-oceans.shapefile.zip
unzip timezones-with-oceans.shapefile.zip

# convert to pg dump
ogr2ogr -overwrite \
  -nln timezone_areas \
  -nlt PROMOTE_TO_MULTI \
  -nlt MULTIPOLYGON \
  -lco CREATE_TABLE=NO \
  -lco GEOMETRY_NAME=geom \
  timezone_areas-raw.sql combined-shapefile-with-oceans.shp

# remove stuff we don't need, this will leave a bunch of INSERTS (but we have to make sure it's run in a tx)
grep -v 'standard_conforming_strings\|BEGIN\|COMMIT\|COMMENT ON TABLE' timezone_areas-raw.sql > timezone_areas.sql

# compress
zstd -22 --ultra timezone_areas.sql

# remove leftover stuff
rm timezones-with-oceans.shapefile.zip
rm combined-shapefile-with-oceans*
rm timezone_areas-raw.sql
