# -*- coding: utf-8 -*-
"""
Created on Fri Jul 10 19:54:13 2015

@author: geraq
"""

import numpy as np
import sys as sys
import matplotlib.pyplot as plt
import pandas as pd

from clusterincluster import clusterInCluster

def single_dist(cluster_i, cluster_j, data, metric):
    dmin = sys.maxint
    for i in cluster_i:
        for j in cluster_j:
            d = metric(data[i,:], data[j,:])
            if (d < dmin):
                dmin = d
    return dmin            
                
def complete_dist(cluster_i, cluster_j, data, metric):
    dmax = -sys.maxint - 1
    for i in cluster_i:
        for j in cluster_j:
            d = metric(data[i,:], data[j,:])
            if (d > dmax):
                dmax = d                
    return dmax        

def average_dist(cluster_i, cluster_j, data, metric):
    distances =  [metric(data[i,:], data[j,:]) for i in cluster_i for j in cluster_j]            
    return np.mean(distances)     
    
def error_sum_squares(cluster_i, cluster_j, data, metric):
    union = cluster_i + cluster_j
    (nRows, nCols) = data.shape
    sq_errors = np.zeros((1, nCols));
    for i in range(0, nCols):
        (vsum, vsumsq) = reduce(lambda (t, sq), x: (t + x, sq + x * x), data[union, i], (0,0))
        sq_errors[0,i] = vsumsq - (vsum**2) / len(union)        
    return np.sum(sq_errors);    

def agglomerative_clustering(data, k, dist_fun, metric):
    (nRows, nCols) = data.shape
    clusters = [[i] for i in range(0,nRows)]
    #distances = [dist_fun(data[i,:], data[j,:]) for j in range(i + 1, nRows) for i in range(0, nRows - 1)]
    for c in range(nRows, k, -1):
        print c
        imin = -1; jmin = -1;
        dmin = sys.maxint
        for i in range(0, c - 1):
            for j in range(i + 1, c):
                d = dist_fun(clusters[i], clusters[j], data, metric);
                if (d < dmin):
                    dmin = d;
                    imin = i;
                    jmin = j;
        c1 = clusters[imin];        
        c2 = clusters[jmin];
        c_new = c1 + c2;
        clusters.remove(c1);
        clusters.remove(c2);
        clusters.append(c_new);
    return clusters    

def euclidean_dist(e1, e2):
    return np.sqrt(np.sum((e1 - e2)**2))

def single_linkage(data, k, metric):
    return agglomerative_clustering(data, k, single_dist, metric)
    
def complete_linkage(data, k, metric):
    return agglomerative_clustering(data, k, complete_dist, metric)

def average_linkage(data, k, metric):
    return agglomerative_clustering(data, k, average_dist, metric)

def ward_linkage(data, k, metric):
    return agglomerative_clustering(data, k, error_sum_squares, metric)


use_iris = 0
k = 4

functions = [single_linkage, complete_linkage, average_linkage, ward_linkage]
selected_func = 3

if (use_iris):
    file_path = 'Iris.csv'
    df=pd.read_csv(file_path, sep=';',header=0)
    data = df.values
    labels = data[:,4]
    data = data[:,0:4]
    
    for (i,c) in enumerate(np.unique(labels)):
        labels[labels == c] = i        
    
    clusters = functions[selected_func](data, k, euclidean_dist);    
    
    #plotting
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
            axes[i, j].plot(data[clusters[2],i],data[clusters[2],j], 'go', ms=5)
else:            
    N = 100
    data = np.array(clusterInCluster(N));
    original_clusters = data[:,2]
    data = data[:,0:2]
    
    file_path = 'skin_points.csv'
    df=pd.read_csv(file_path, sep=',',header=None)
    #data = df.values[:, 0:2]
    data  = df.values
    data = data[0:data.shape[0]:50,:].astype(np.float64)
    
    clusters = functions[selected_func](data, k, euclidean_dist);      
    
    plt.plot(data[clusters[0],0],data[clusters[0],1], 'ro', ms=5)
    plt.plot(data[clusters[1],0],data[clusters[1],1], 'bo', ms=5)
    if k > 1:
        plt.plot(data[clusters[2],0],data[clusters[2],1], 'go', ms=5)
        if k > 2:
            plt.plot(data[clusters[3],0],data[clusters[3],1], 'yo', ms=5)







