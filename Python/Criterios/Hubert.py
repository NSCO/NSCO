# -*- coding: utf-8 -*-
"""
Created on Tue Sep  8 08:55:15 2015

@author: luciano
"""
import numpy as np
import scipy.spatial
import sklearn.cluster
import pandas as pd
import matplotlib.pyplot as plt

class Hubert:
    def __init__(self,data):
        self.P = scipy.spatial.distance.pdist(data)
        N = data.shape[0]
        self.M = (N*(N-1))/float(2)
    def run(self,labels,centers):
        center_data = np.array([centers[label] for label in labels])
        Q = scipy.spatial.distance.pdist(center_data)
        mean_p = np.mean(self.P)
        mean_q = np.mean(Q)
        std_p = np.std(self.P)
        std_q = np.std(Q)
        self.P=self.P-mean_p
        Q=Q-mean_q
        prod   = self.P.dot(Q)
        return (1/float(self.M))*np.sum(prod)/(std_p*std_q)
   


class HubertGap:
    def hubert(self,data,kmeans):
      
        h = Hubert(data)
        kmeans_result = kmeans.fit(X)
        labels = kmeans_result.labels_
        centers = kmeans_result.cluster_centers_
        return h.run(labels,centers)
    def random_sample(self,data_max,data_min,N,M):
        
        data_diff =  np.repeat([data_max-data_min],N,0)     
        sample = np.random.rand(N,M)        
        return  sample* data_diff + np.repeat([data_min],N,0)
    def run(self,data, kmeans, r):
        self.data = data
        N = data.shape[0]
        M = data.shape[1]
        data_max = np.max(data,0)
        data_min = np.min(data,0)
        hubert = 0
        for i in range(r):
            print(i)
            sample = self.random_sample(data_max,data_min,N,M)
            value = self.hubert(sample,kmeans)
            print(value)
            hubert += np.log(value+1.000001)
        hubert_expectation=hubert/float(r)
        
        hubert_data  = np.log(self.hubert(data,kmeans)+1.00001)
        return hubert_data - hubert_expectation
        
        
        
        
        
        
                 
file_path = '../datos/skin_points.csv'
data=pd.read_csv(file_path, sep=',',header=None)
X = np.array(data.astype(np.float64))

#h = Hubert(data)
hubert_gap = HubertGap()
huberts=[]
for k in range(2,10):
    print(k)
    kmeans = sklearn.cluster.KMeans(k)
    h_gap = hubert_gap.run(X,kmeans,5)
    huberts.append(h_gap)
plt.plot(huberts)
    