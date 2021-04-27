-- COPY (select parid, lstat, mhhi, tractce, blkgrpce from volusia.parcel ) to 'C:\temp\cs540\lstat.txt' WITH (FORMAT 'csv', DELIMITER E'\t', NULL '', HEADER);

drop table if exists volusia.lstat;

create table volusia.lstat
(
parid int,
lstat double precision,
mhhi double precision,
tractce char(6),
blkgrpce char(1)
);

COPY volusia.lstat from 'C:\temp\cs540\lstat.txt' WITH (FORMAT 'csv', DELIMITER E'\t', NULL '', HEADER);

create index idx_lstat on volusia.lstat (parid);

update volusia.parcel p set lstat=l.lstat, mhhi=l.mhhi, tractce=l.tractce, blkgrpce=l.blkgrpce from volusia.lstat l where p.parid=l.parid;