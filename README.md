# cs540
The goal of this github is to determine the LSTAT of each parcel in the county.  

Why?  the measure LSTAT is used in the Boston Data Set from Chapter 6 of PML text.  LSTAT is shown to have a high correlation to house pricing.  Another student is researching where & how LSTAT was actually computed, but Diogo and Prof Lehr put together a script to compute a similar measure of LSTAT by scaling the Median HouseHold Incomes (mhhi) provided by the Census Bureau at the census block group level.  FYI:  Census provides data at 3 levels:  Tracts, Block Groups, and Tabulation Blocks.  The lowest geospatial area is the tabulation block, which is collected into block groups and those are gathered into census tracts.  (see work of Bryce for further information)

Lehr to do- provide a quick image here...

LSTAT in the Boston Sales Dataset was reported as the percentage of the lower status of population, however we do not have this information in the Volusia county data set, but we did know the census bureau contains data on median house hold income.  We interpreted LSTAT to mean which percentile of median household income did the census block group's mhhi compare to all other block groups in the county's mhhi.  i.e. how did this block group's mhhi compare to the others, and if we rank them which percentage group would they fall into?  Furthermore, LSTAT's description is reported as what percentage of the lower status of the population, and thus we reversed the scale from 100 to 0 to obtain a similar measure, i.e. the lowest mhhi block groups was scored to be 100th percentile and the highest mhhi was scored to be 0th percentile.  In the end, we've added the column LSTAT to each census block group scaling each block groups mhhi compared to all other block groups mhhi in the county.

Before scoring LSTAT, it was noticed that some census block groups in our data set did not have the MHHI information.  To cleanse the dataset, we updated the mhhi to be the average of the 3 nearest neighbors census block groups mhhi.   See:  update_null_mhhi_plpgsql.sql  which is the Postgres Scripting Language Code which enables you to run loops, decision, and functions in SQL in postgres.  Discussed in the 4/22 announcement:  https://erau.instructure.com/courses/125189/discussion_topics/2168232

Next we computed the LSTAT for each block group using the code:  determine_lsats.py - which employs the logic of the paragraphs above, find all mhhi's, rank them, score them, update the census block group's mhhi.

Next we determined the block group each parcel in the county is inside and updated the volusia.parcel record to include the tract, block group, lstat, and median household income.  With the data being maintained by two different government agencies (highly accurated local government maintaining the parcel's geospatial boundaries and the census bureau data block groups, we determined which block group contained the centroid of the parcel as a parcel polygon could cross boundaries of multiple block groups and thus we used the centroid of a parcel which would be more likely to be in only one block group.   The sql script in this repository:  update_parcel_lstat.sql, contains the code to update the volusia.parcel information.

Add these columns to your parcel table

alter table volusia.parcel add column lstat double precision;

alter table volusia.parcel add column mhhi double precision;

alter table volusia.parcel add column tractce char(6);

alter table volusia.parcel add column blkgrpce char(1);

-- here's how I extracted the above text file, first I get my SQL command correct, then I used the COPY command in reverse to generate a text file, i.e. in reverse of load_tables.bat scripts

select parid, lstat, mhhi, tractce, blkgrpce from volusia.parcel;

COPY (select parid, lstat, mhhi, tractce, blkgrpce from volusia.parcel ) to 'C:\temp\cs540\lstat.txt' WITH (FORMAT 'csv', DELIMITER E'\t', NULL '', HEADER);

-- on your side, create a table, download the data, and run copy into sql, and update statements below...

drop table if exists volusia.lstat;

create table volusia.lstat
(
parid int,
lstat double precision,
mhhi double precision,
tractce char(6),
blkgrpce char(1)
);

-- load table (see zip file in repository, extract to c:\temp\cs540)

COPY (select parid, lstat, mhhi, tractce, blkgrpce from volusia.parcel ) to 'C:\temp\cs540\lstat.txt' WITH (FORMAT 'csv', DELIMITER E'\t', NULL '', HEADER);

-- create indexes

create index idx_parcel on volusia.parcel (parid);

create index idx_lstat on volusia.lstat (parid);

update volusia.parcel p set lstat=l.lstat, mhhi=l.mhhi, tractce=l.tractce, blkgrpce=l.blkgrpce from volusia.lstat l where p.parid=l.parid;

-- now many of you will also want to add this lstat and mhhi to your sales analysis table too, so create fields in sales analysis like above, then update those fields with an update-join query like above.


alter table volusia.sales_analysis add column lstat double precision;

alter table volusia.sales_analysis add column mhhi double precision;

update volusia.sales_analysis s set lstat=l.lstat, mhhi=l.mhhi from volusia.lstat l where s.parid=l.parid;

-- if you are interested in the census tracts, block-groups, and tabulation blocks see Announcement 4/19 which contains the zip files of the raw shapefiles
https://erau.instructure.com/courses/125189/discussion_topics/2161653


