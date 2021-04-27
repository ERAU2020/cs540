-- outter loop identifies all parcels and centroids
--    then for each record
--        find average census block, tract that contains parcel centroid,
--        update parcel lstat, mhhi, block, tract

DO
LANGUAGE plpgsql
$$
DECLARE
g1 geometry;
rec RECORD;
rec2 RECORD;
llstat double precision;

BEGIN
  --alter table volusia.parcel add column lstat double precision;
  update volusia.parcel set lstat = 50, mhhi=46000, tractce='unknwn', blkgrpce='0';
  for rec in select parid, ST_Centroid(geom) as geom from volusia.parcel where geom is not null loop
  g1 := rec.geom;

  select into rec2 lstat, mhhi, tractce, blkgrpce from volusia.volusia_census_blocks where ST_Contains(geom, g1);
 
  update volusia.parcel set lstat=rec2.llstat, mhhi=rec2.mhhi, tractce=rec2.tractce, blkgrpce=rec2.blkgrpce where parid=rec.parid;
  --RAISE NOTICE 'set to % %', rec.parid, llstat;


  END loop;
END;

$$;