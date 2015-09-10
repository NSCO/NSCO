# -*- coding: utf-8 -*-
"""
Created on Fri Sep  4 06:35:36 2015

@author: luciano
"""
import sys
sys.path.append('/home/luciano/fuentes/NSCO/Estimators')
sys.path.append('/home/luciano/fuentes/NSCO/datos/Artificiales/')

from clusterincluster import clusterInCluster

from numpy import *
from Estimators import *

import matplotlib.pyplot as plt


class MeanShift:
    def __init__(self,data, learning_rate,window_size,window):
        self.data = data
        self.learning_rate = learning_rate
        self.window  = window
        self.window_size = window_size
    def shift(self,pattern, original_data):
        denominator = 0
        numerator   = 0
        for i in original_data:            
            estimation = self.window(i,pattern,self.window_size)
            denominator = denominator + estimation
            numerator   = numerator   + estimation*i
        mean_shift = (numerator/denominator) - pattern
        return pattern + self.learning_rate *(mean_shift)
            
            
            
        
    def run(self):
        original_data = copy(self.data)
        plt.ion()
        plt.show()
        for j in range(0,300):
           
           print(j)
           plt.clf()
           plt.axis((0,1,0,1))
           
           plt.plot(original_data[:,0],original_data[:,1],'bo')
           #plt.plot(self.data[:,0],self.data[:,1],'ro')
                 
           for i in range(0,self.data.shape[0]):               
               self.data[i,:] = self.shift(self.data[i,:],original_data)
           
           plt.plot(self.data[:,0],self.data[:,1],'go')   
           plt.draw()
           plt.pause(0.00001)    
        
          

    
print 'Reading data...'
file_path = '/home/luciano/fuentes/NSCO/datos/skin_points.csv'
df=pd.read_csv(file_path, sep=',',header=None)
#data = df.values[:, 0:2]
data  = df.values
data = data[0:data.shape[0]:150,:].astype(np.float64)
row_sum = data.max(axis=0)
data    = data / row_sum[ np.newaxis,:]
(nRows, nCols) = data.shape
learning_rate = 1
window_size = 0.02
em=MeanShift(data,learning_rate,window_size,gaussian_window)
print 'Running algorithm....'
em.run()
               
               
        
            
            