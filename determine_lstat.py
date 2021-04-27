# -*- coding: utf-8 -*-
"""
Created on Tue Apr 20 17:04:28 2021

@author: lehrs
"""

import psycopg2
import re
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from scipy.stats import percentileofscore


# connection to database:
try:
    conn = psycopg2.connect("dbname='spatial' user='postgres' host='localhost' password='qp123'")
except:
    print("cant connect to the database")
    
#cur = conn.cursor(cursor_factory=psycopg2.extras.DictCursor) # allows for row['field'] accessing/simpler/more intuitive
cur = conn.cursor()

sql2 = "select statefp, countyfp, tractce, blkgrpce, b19013e1 as mhhi from public.acs_2018_5yr_bg_12_florida where statefp='12' and countyfp='127' and b19013e1 is not null order by b19013e1"
sql2 = "select statefp, countyfp, tractce, blkgrpce, mhhi as mhhi from volusia.volusia_census_blocks where statefp='12' and countyfp='127' and mhhi is not null order by mhhi"
df = pd.read_sql_query(sql2, conn)
pcts = np.arange(0,101,10)
vals = np.array(df.mhhi)
bins = np.histogram(vals, 10)
bins = np.percentile(vals, pcts, interpolation='midpoint')


#percentile = 63000
#print(100-percentileofscore(vals, percentile))

# loop over the df and update the LSTAT # for each 
for index, row in df.iterrows(): 
    lstat = np.round(100-percentileofscore(vals, row.mhhi),0)
    #print(row.statefp, row.countyfp, row.tractce, row.blkgrpce, row.mhhi, lstat)
    #sql = "update public.acs_2018_5yr_bg_12_florida set lstat=" + str(lstat) + " where statefp='12' and countyfp='127' and tractce='" + str(row.tractce) + "' and blkgrpce='" + row.blkgrpce + "'";
    sql = "update volusia.volusia_census_blocks set lstat=" + str(lstat) + " where statefp='12' and countyfp='127' and tractce='" + str(row.tractce) + "' and blkgrpce='" + row.blkgrpce + "'";
    #sql = "update volusia.volusia_census_blocks set mhhi=" + str(row.mhhi) + ", lstat=" + str(lstat) + " where statefp='12' and countyfp='127' and tractce='" + str(row.tractce) + "' and blkgrpce='" + row.blkgrpce + "'";
    print(sql)
    cur.execute(sql)

conn.commit()
conn.close()

