# cs540
LSTAT - a similar measure used in the Boston Data Set from Chapter 6 of PML text, to determine the % of the Lower Status of the Population.  This measure was shown to have a high correlation to house pricing.  Another student is researching where & how LSTAT is computed, but Diogo and Prof Lehr put together a script to grab the Median HouseHold Income (mhhi) from the Census Bureau.  

Once the MHHI was determined by census block group, any census block group with a null values was updated with its 3 nearest neighbors average mhhi.   See:  update_null_mhhi_plpgsql.sql  which is the Postgres Scripting Language Code which enables you to run loops, decision, and functions in SQL in postgres.  Discussed in the 4/22 announcement:  https://erau.instructure.com/courses/125189/discussion_topics/2168232

Then LSTAT was computed as % of lower status of population, however we interpreted this to mean percentile of mhhi, and then reversed the scale from 100 to 0 to make the measure similar, i.e. the lowest mhhi block groups was scored to be 100th percentile and the highest was scored to be 0th percentile.  And then each value in between was computed as its percentile.

See the code above - determine_lsats.py

Next we found each parcel in the county and which block group the parcel is inside; now since the data is maintained by two different government agencies (local government of Volusia county maintaining the parcel's geospatial boundaries and the census bureau data block groups.  (see Bryce work on LSTAT and Census Tracts, Census Block Groups, and Census Tabulation Blocks).  For this we used the postgres scripting language code:  update_parcel_lstat.sql

Add these columns to your parcel table

alter table volusia.parcel add column lstat double precision;

alter table volusia.parcel add column mhhi double precision;

alter table volusia.parcel add column tractce char(6);

alter table volusia.parcel add column blkgrpce char(1);

-- here's how I extracted the text file, used the COPY command in reverse, i.e. in reverse of load_tables.bat scripts

select parid, lstat, mhhi, tractce, blkgrpce from volusia.parcel 
COPY (select parid, lstat, mhhi, tractce, blkgrpce from volusia.parcel ) to 'C:\temp\cs540\lstat.txt' WITH (FORMAT 'csv', DELIMITER E'\t', NULL '', HEADER);

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


