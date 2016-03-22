# -*- coding: utf-8 -*-
"""
Simple Script to Download Stock Data
Dillon R. Gardner
7 March 2015
"""

import pandas.io.data as web
import datetime

path = "/Users/dillon/src/ArchConfRML/4-1-LinearRegression/Data/"

start = datetime.datetime(2016, 1, 12)
end = datetime.datetime(2016,2,20)

f = web.DataReader("ENOC", 'yahoo', start, end)
f["Day"] = f.index.dayofyear
f = f[["Day", "High"]]
f.rename(columns={"Day":"x", "High":"y"}, inplace=True)
f.to_csv(path + "validation.csv",index = False)
valid = f.sample(n=16, random_state=88)
valid = valid.append(f.head(1))
valid = valid.append(f.tail(1))
valid = valid.drop_duplicates()
valid.sort_index().to_csv(path + "train.csv",index=False)
