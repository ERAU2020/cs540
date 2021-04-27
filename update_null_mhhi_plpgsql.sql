-- postgres has plpgsql
-- Procedural Language PostGres SQL
-- used for functions and more complicated SQL structures
-- rather then writing a python script
-- can do something like the following
-- I've got census block groups that do not have a median house hold income (mhhi)
-- value, I want to update the ones that are null with the average of the 3 nearest neighbors

-- so the outter loop identifies all block groups with a null mhhi
--    then for each record
--        find average mhhi of 3 NN
--        update mhhi

DO
LANGUAGE plpgsql
$$
DECLARE
g1 geometry;
rec RECORD;
rec2 RECORD;
avg_mhhi double precision;

BEGIN
  for rec in select tractce, blkgrpce, mhhi, geom from volusia.volusia_census_blocks where mhhi is null loop
  g1 := rec.geom;

  select into avg_mhhi avg(knn.mhhi) from (
    select b.tractce, b.blkgrpce, b.mhhi
    from volusia.volusia_census_blocks b
    where b.mhhi is not null
    order by b.geom <-> (select b1.geom from  volusia.volusia_census_blocks b1 where b1.tractce=rec.tractce and b1.blkgrpce=rec.blkgrpce) limit 3
  ) as knn;
  
  update volusia.volusia_census_blocks set mhhi=avg_mhhi where tractce=rec.tractce and blkgrpce=rec.blkgrpce;
  RAISE NOTICE 'set to % % %', rec.tractce, rec.blkgrpce, avg_mhhi;


  END loop;
END;

$$;