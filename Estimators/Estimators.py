import numpy as np
from scipy.stats import multivariate_normal
import heapq as heapq
import math
import pandas as pd
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

def  sphere_volume(dimensions,radius):
    V = math.pi ** float(dimensions/2) / math.gamma((dimensions/2) + 1)
    return V*radius
        

class Estimator:
    def __init__(self,datos):
        self.datos = datos
    def estimate(self,x):
        raise NotImplementedError(":(")
        
class KNNEstimator(Estimator):
    def __init__(self,datos,k):
        Estimator.__init__(self, datos)
        self.k = k
    def estimate(self, x):
        (farthest_neighbor_distance, farthest_neighbor_index) = self.find_farthest_neighbor(x)
        D = self.datos.shape[1]
        V=sphere_volume(D,farthest_neighbor_distance)
        N = self.datos.shape[0]        
        return self.k /float(N * V ) 
        
        
    def find_farthest_neighbor(self,x):
       return self.find_k_neighbors(x)[-1]

    def find_k_neighbors(self,x):       
       distances =[(np.linalg.norm(x-p),ind) for ind,p in enumerate(self.datos)]
       heapq.heapify(distances)
       return  heapq.nsmallest(self.k, distances)
      
class ParzenEstimator(Estimator):
    def __init__(self, datos,window_size,window):
        Estimator.__init__(self,datos)
        self.window=window;
        self.window_size=window_size
    def estimate(self, x):
        contributions=[self.window(xi,x,self.window_size) for xi in self.datos]
        N = self.datos.shape[0]
        return sum(contributions)/N
    
def gaussian_window(x,mu,sigma):
    dx  = x-mu
    distance=np.linalg.norm(dx)
    d=len(x)
    constant=1/np.sqrt( (2*np.pi *sigma)**d )
    exponent=np.exp( -0.5  * (distance / sigma)**2)
    return constant*exponent

def euclidean_window(x,center,radius):
    dx  = x-center
    distance=np.linalg.norm(dx)
    if distance<radius:
        V=sphere_volume(len(x),radius)
        return 1/V
    else:
        return 0   
        
def square_window(x,center,radius):
    dx  = x-center
    distances=np.abs(dx)
    if np.all(distances<radius):
        V=(radius*2)**len(x) #TODO
        return 1/V
    else:
        return 0   
        
def manhattan_window(x,center,radius):
    dx  = x-center
    distance=np.sum(np.abs(dx))
    if distance<radius:
        V=(radius*2)**len(x)
        return 1/V
    else:
        return 0   
        
file_path = '../datos/Iris.csv'
labelCol = 4 
df=pd.read_csv(file_path, sep=';',header=0)
data = df.values

labels = data[:,labelCol]
data = data[:,0:labelCol]
data = data[:, 0:2]
(nRows, nCols) = np.shape(data) 

for (i,c) in enumerate(np.unique(labels)):
        labels[labels == c] = i  

#k=5
#estimator= KNNEstimator(data, k)

#sigma=0.17
#estimator=ParzenEstimator(data,sigma,gaussian_window)

radius=0.17*3
estimator=ParzenEstimator(data,radius,square_window)
mins = np.min(data,0)
maxs = np.max(data,0)
#np.meshgrid([mins[0]:maxs[0]:0.01 ])
density = 80
(x, y) = np.meshgrid(np.linspace(mins[0], maxs[0], density), np.linspace(mins[1], maxs[1], density))
x = np.array(x)    
y = np.array(y)    
z = np.zeros(x.shape)
for i in range(0,density):
    for j in range(0,density):
       x_val = x[i,j]
       y_val = y[i,j]
       z[i,j] = estimator.estimate(np.array([x_val, y_val]))
fig = plt.figure()
ax = fig.gca(projection="3d")       
ax.plot_surface(x,y,z)

ax.plot(data[labels == 0,0],data[labels == 0,1], 'ro', ms=5)
ax.plot(data[labels == 1,0],data[labels == 1,1], 'bo', ms=5)
ax.plot(data[labels == 2,0],data[labels == 2,1], 'go', ms=5)



    
    
    