# -*- coding: utf-8 -*-
"""
Created on Tue Sep  8 08:55:15 2015

@author: luciano
"""
import numpy as np
import scipy
import sklearn
import pandas as pd

file_path = '/home/luciano/fuentes/NSCO/datos/skin_points.csv'
data=pd.read_csv(file_path, sep=',',header=None)
X = data.astype(np.float64)

P = scipy.spatial.distance.pdist(X)
kmeans = sklearn.cluster.KMeans(5)
data = kmeans.fit(X)


