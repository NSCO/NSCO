# -*- coding: utf-8 -*-
"""
Created on Tue Aug 25 06:28:41 2015

@author: luciano
"""
import random
import numpy as np
from numpy import random as rd
import matplotlib.pyplot as plt
from Estimators import  *

def create_gaussian_clusters(n_points=1000,dim=2,k=3):
   points_per_cluster=n_points/k
   means = np.random.rand(k,dim)
   covas = [ np.eye(dim) * (np.random.random()/1000) for i in range(0,k) ]
    
   data_points=np.empty((0,dim))
   labels     =np.empty((0))
   for i in range(0,k):
      cluster     =   rd.multivariate_normal(means[i],covas[i],[points_per_cluster])
      labels      = np.hstack((labels,np.repeat(i,points_per_cluster)))
      data_points = np.vstack((data_points,cluster))
   return (data_points,labels,means,covas)


random.seed(17)  
np.random.seed(17)  
data_points,labels,means,covas = create_gaussian_clusters(k=5)
#plt.scatter(data_points[:,0],data_points[:,1],c=labels)

gaussian_estimator = GaussianEstimator(means,covas)
#radius=0.01
#model_estimator=ParzenEstimator(data_points,radius,chebyshev_window)
knn=10
model_estimator=KNNEstimator(data_points,knn)

#radius=0.001
#model_estimator=ParzenEstimator(data_points,radius,gaussian_window)

point_per_dimension = 50

fig = plt.figure()
ax = fig.gca(projection="3d")  
plt.ion()
plt.show()
(x,y,z_model) = evaluate_estimator_meshgrid(data_points,model_estimator,point_per_dimension,padding=0.05)
(x,y,z_gauss) = evaluate_estimator_meshgrid(data_points,gaussian_estimator,point_per_dimension,padding=0.05)
ax.plot_wireframe(x,y,z_gauss, color='r')
ax.plot_wireframe(x,y,z_model, color='b')
ax.scatter(data_points[:,0],data_points[:,1], np.zeros((data_points.shape[0],1)),c=labels)
plt.draw()
    
dx = abs(x[0][0] - x[0][1])
dy = abs(y[0][0] - y[1][0])    
        
print(KL(z_model,z_gauss)*dx*dy)
print(KL(z_gauss,z_model)*dx*dy)

#print(parzen_estimator.KL(gaussian_estimator,mins,maxs,point_per_dimension))
