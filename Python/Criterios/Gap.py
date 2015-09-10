# -*- coding: utf-8 -*-
"""
Created on Tue Sep  8 09:32:10 2015

@author: luciano
"""
import numpy as np
import scipy.spatial
import sklearn.cluster
import pandas as pd
import matplotlib.pyplot as plt


class Gap:
    
    def run(self,data):
        
file_path = '/home/luciano/fuentes/NSCO/datos/skin_points.csv'
data=pd.read_csv(file_path, sep=',',header=None)
X = data.astype(np.float64)

P = scipy.spatial.distance.pdist(X)
