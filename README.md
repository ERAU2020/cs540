# cs540
Add these columns to your parcel table

alter table volusia.parcel add column lstat double precision;
alter table volusia.parcel add column mhhi double precision;
alter table volusia.parcel add column tractce char(6);
alter table volusia.parcel add column blkgrpce char(1);

 
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

-- load table 
COPY (select parid, lstat, mhhi, tractce, blkgrpce from volusia.parcel ) to 'C:\temp\cs540\lstat.txt' WITH (FORMAT 'csv', DELIMITER E'\t', NULL '', HEADER);

-- create index
create index idx_parcel on volusia.parcel (parid);

update volusia.parcel p set lstat=l.lstat, mhhi=l.mhhi, tractce=l.tractce, blkgrpce=l.blkgrpce from volusia.lstat l where p.parid=l.parid;


