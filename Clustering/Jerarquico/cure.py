# -*- coding: utf-8 -*-
"""
Created on Tue Jul 21 17:12:32 2015

@author: geraq
"""
import numpy as np
import sys as sys
import matplotlib.pyplot as plt
import pandas as pd
import scipy.spatial.distance as spdist

def euclidean_dist(e1, e2):
    return np.sqrt(np.sum((e1 - e2)**2))

def single_dist(cluster_i, cluster_j, metric):
    dmin = sys.maxint
    for i in cluster_i:
        for j in cluster_j:
            d = metric(i, j)
            if (d < dmin):
                dmin = d
    return dmin            


class Cure:
    def __init__(self, K, cant_rep, alpha):
        self.K = K
        self.cant_rep = cant_rep
        self.alpha = alpha

    #generative agglomerative scheme (GAS)
    def agglomerative_clustering(self, data, dist_fun, metric):
        (nRows, nCols) = data.shape
        clusters = [Cluster.singleton(data[i,:], i) for i in range(0,nRows)]
        #distances = [dist_fun(data[i,:], data[j,:]) for j in range(i + 1, nRows) for i in range(0, nRows - 1)]
        for c in range(nRows, self.K, -1):
            print c
            imin = -1; jmin = -1;
            dmin = sys.maxint
            for i in range(0, c - 1):
                for j in range(i + 1, c):
                    d = dist_fun(clusters[i].representatives, clusters[j].representatives, metric);
                    #hack                    
                    #d = d + (len(clusters[i].exampleIds) * len(clusters[j].exampleIds))/(nRows**2) * 100 #???
                    #d = d * (1 + 17 * (len(clusters[i].exampleIds) * len(clusters[j].exampleIds))/((nRows/2)**2)) #???
                    if (d < dmin):
                        dmin = d;
                        imin = i;
                        jmin = j;
            c1 = clusters[imin];        
            c2 = clusters[jmin];
            c_new = self.merge(c1, c2, data, metric);
            clusters.remove(c1);
            clusters.remove(c2);
            clusters.append(c_new);
        return clusters 
    
    def get_max_point(self, new_examples, new_mean, data, temp_set):   
        maxDist = float("-inf") #-sys.maxint;
        for exampleId in new_examples:
            minDist = float("inf")
            for tempId in temp_set:
                dist = np.linalg.norm(data[exampleId,:] - data[tempId,:])
                if (dist < minDist):
                    minDist = dist
            if (minDist >= maxDist):
                maxDist = minDist
                max_point = exampleId
        return max_point        
    
    def get_further_point_from_mean(self, new_mean, new_examples, data):
        maxDist = float("-inf") #-sys.maxint;
        for exampleId in new_examples:            
            dist = np.linalg.norm(data[exampleId,:] - new_mean)
            if (dist >= maxDist):
                maxDist = dist
                max_point = exampleId    
        return max_point        
    
    def shrink_representatives(self, representatives, new_mean, alpha):
        new_representatives = []
        for rep in representatives:
            new_representatives.append(rep + alpha * (new_mean - rep))
        return new_representatives    
    
    def merge(self, c1, c2, data, metric):
        n1 = len(c1.exampleIds)
        n2 = len(c2.exampleIds)
        new_mean = (n1 * c1.mean + n2 * c2.mean) / (n1 + n2)
        new_examples = c1.exampleIds + c2.exampleIds
        temp_set = [self.get_further_point_from_mean(new_mean, new_examples, data)]
        upper_bound = min(self.cant_rep, len(new_examples))        
        for repId in range(1, upper_bound):
            #max_point is an index!!
            max_point = self.get_max_point(new_examples, new_mean, data, temp_set)            
            temp_set.append(max_point)
        new_representatives = self.shrink_representatives(data[temp_set, :], new_mean, self.alpha)
        return Cluster(new_representatives, new_examples, new_mean)    
    
class Cluster:
    def __init__(self, examples, exampleIds, mean):
        self.exampleIds = exampleIds
        self.representatives = examples
        self.mean = mean
     
    @classmethod     
    def singleton(cls, example, exampleId):
        return cls([example], [exampleId], example)
         
def cure(data, K, cant_rep, alpha):    
    cure_instance = Cure(K, cant_rep, alpha)
    clusters = cure_instance.agglomerative_clustering(data, single_dist, euclidean_dist)        
    return clusters 

if __name__ == "__main__": 
    K = 3;
    cant_rep = 3;
    alpha = 0.5;
    file_path = 'Iris.csv'
    #file_path = 'skin_points.csv'
    df=pd.read_csv(file_path, sep=';',header=0)
    #df=pd.read_csv(file_path, sep=',',header=None)
    data = df.values
    (nRows, nCols) = data.shape
    #data = data[0:nRows:50,:]
    
    noLabels = False
    if (not noLabels):
        labels = data[:,4]
    data = data[:,0:4]
    clusterObjs = cure(data, K, cant_rep, alpha)
    clusters = [obj.exampleIds for obj in clusterObjs]
    
    #plotting
    if (not noLabels):
        for (i,c) in enumerate(np.unique(labels)):
            labels[labels == c] = i
        
        (nRows, nCols) = data.shape
        fig_size = 10;
        (fig, axes) = plt.subplots(nCols, nCols, figsize=(fig_size, fig_size));
        fig.suptitle('Real')
        for i in range(0, nCols):
            for j in range(0, nCols):
                if (i == j):
                    continue
                axes[i, j].plot(data[labels == 0,i],data[labels == 0,j], 'ro', ms=5)
                axes[i, j].plot(data[labels == 1,i],data[labels == 1,j], 'bo', ms=5)
                axes[i, j].plot(data[labels == 2,i],data[labels == 2,j], 'go', ms=5)
    
    (fig, axes) = plt.subplots(nCols, nCols, figsize=(fig_size, fig_size));
    fig.suptitle('Found')
    for i in range(0, nCols):
        for j in range(0, nCols):
            if (i == j):
                continue
            axes[i, j].plot(data[clusters[0],i],data[clusters[0],j], 'ro', ms=5)
            axes[i, j].plot(data[clusters[1],i],data[clusters[1],j], 'bo', ms=5)
            if (K >= 3):
                axes[i, j].plot(data[clusters[2],i],data[clusters[2],j], 'go', ms=5)
                if (K >= 4):
                    axes[i, j].plot(data[clusters[3],i],data[clusters[3],j], 'yo', ms=5)


        