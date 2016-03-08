# -*- coding: utf-8 -*-
"""
Simple Script to Download Stock Data
Dillon R. Gardner
7 March 2015
"""

import pandas.io.data as web
import datetime

path = "/Users/dillon/src/ArchConfRML/4-1-LinearRegression/Data/"

start = datetime.datetime(2016, 1, 1)
end = datetime.datetime(2016,2,1)

f = web.DataReader("ENOC", 'yahoo', start, end)
f["High"].to_csv(path + "ENOC_validation.csv")
f.sample(n=18, random_state=60)["High"].to_csv(path + "ENOC_train.csv")
