import numpy as np
from scipy.stats import multivariate_normal
import heapq as heapq
import math
import pandas as pd
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from scipy.stats import multivariate_normal
from sklearn.metrics import confusion_matrix
import scipy
import sys
sys.path.append('/home/luciano/fuentes/NSCO/Estimators')
sys.path.append('/home/luciano/fuentes/NSCO/datos/Artificiales/')

from clusterincluster import clusterInCluster
def  sphere_volume(dimensions,radius):
    V = math.pi ** float(dimensions/2) / math.gamma((dimensions/2) + 1)
    return V*radius**dimensions  
    
        

def KL(z1,z2):
    z1=np.ravel(z1)
    z2=np.ravel(z2)
    kl = 0
    for i in range(0,len(z1)):             
        kl+=z1[i]*np.log((z1[i]+0.00000001)/(z2[i]+0.00000001))     
    return kl

class Estimator:
    def estimate(self,x):
        raise NotImplementedError(":(")
    
    def KL(self,q,mesh):
        x = np.array(mesh[0])    
        y = np.array(mesh[1])    
        dx = abs(x[0][0] - x[0][1])
        dy = abs(y[0][0] - y[1][0])        
        z1=[]
        z2=[]
        for i in range(0,points_per_dimension):
            for j in range(0,points_per_dimension):
               x_val = x[i,j]
               y_val = y[i,j]
               point2d = (np.array([x_val, y_val]))
               z1.append(self.estimate(point2d))
               z2.append(q.estimate(point2d))
        return (KL(z1,z2)*dx*dy,z1,z2)
        
        
class GaussianEstimator(Estimator):
    def __init__(self,means,covas):
        
        self.constant = 1/float(len(means))
        self.distributions = []
        for mu,sigma in zip(means,covas):
           self.distributions.append(scipy.stats.multivariate_normal(mu,sigma))
           
    def estimate(self,x):
        contributions = sum([d.pdf(x) for d in self.distributions])
        return contributions* self.constant
        
class DataEstimator(Estimator):
    def __init__(self,datos):
        self.datos = datos
        
class BayesEstimator(Estimator):
    def __init__(self,datos):
        Estimator.__init__(self, datos)
    def estimate(self, x):
        return 1 

        
class KNNEstimator(DataEstimator):
    def __init__(self,datos,k):
        DataEstimator.__init__(self, datos)
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
      
class ParzenEstimator(DataEstimator):
    def __init__(self, datos,window_size,window):
        DataEstimator.__init__(self,datos)
        self.window=window;
        self.window_size=window_size
    def estimate(self, x):
        contributions=[self.window(xi,x,self.window_size) for xi in self.datos]
        N = self.datos.shape[0]
        return sum(contributions)/float(N)
    
def gaussian_window(x,mu,sigma):
    #dx  = x-mu
    #distance=np.linalg.norm(dx)
    #d=len(x)
    #constant=1/np.sqrt( (2*np.pi *sigma)**d )
    #exponent=np.exp( -0.5  * (distance / sigma)**2)
    #return constant*exponent
    var =  multivariate_normal(mean=mu, cov=sigma)
    return var.pdf(x)
    

def euclidean_window(x,center,radius):
    dx  = x-center
    distance=np.linalg.norm(dx)
    if distance<radius:
        V=sphere_volume(len(x),radius)
        return 1/V
    else:
        return 0   
def kernel_product_window(x,center,radius):
    prod = 1
    for i in range(0,len(x)):
        prod *= gaussian_window(x[i],center[i],radius[i])               
    return prod
def chebyshev_window(x,center,radius):
    dx  = x-center
    distances=np.abs(dx)
    max_distance = max(distances)
    #if np.all(distances < np.repeat(radius, len(x))):
    if (max_distance <= radius):
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
        
def read_iris():     
    file_path = '../datos/Iris.csv'
    labelCol = 4 
    df=pd.read_csv(file_path, sep=';',header=0)
    data = df.values
    
    labels = data[:,labelCol]
    data = data[:,0:labelCol]
    data = data[:, 0:2]
    for (i,c) in enumerate(np.unique(labels)):
        labels[labels == c] = i  
    return (data,labels)
    

def evaluate_estimator_meshgrid(data,estimator,points_per_dimension=30,padding=1):
    mins = np.min(data,0) - padding
    maxs = np.max(data,0) + padding
    #np.meshgrid([mins[0]:maxs[0]:0.01 ])
    
    (x, y) = np.meshgrid(np.linspace(mins[0], maxs[0], points_per_dimension), np.linspace(mins[1], maxs[1], points_per_dimension))
    x = np.array(x)    
    y = np.array(y)    
    z = np.zeros(x.shape)
    for i in range(0,points_per_dimension):
        for j in range(0,points_per_dimension):
           x_val = x[i,j]
           y_val = y[i,j]
           z[i,j] = estimator.estimate(np.array([x_val, y_val]))
    return (x,y,z)





def plot_density(x,y,z,data,labels,c,ax=None):
     
    if (ax == None):
        fig = plt.figure()
        ax = fig.gca(projection="3d")  
    z[z<=0.01]=0
    #ax.plot_surface(x,y,z, lw=10, rstride=1, cstride=1, cmap=plt.cm.coolwarm, linewidth=0.2, antialiased=False,alpha=0.4)
    ax.plot_wireframe(x,y,z, color=c)
    
    ax.plot(data[labels == 0,0],data[labels == 0,1], 'ro', ms=5)
    ax.plot(data[labels == 1,0],data[labels == 1,1], 'go', ms=5)
    ax.plot(data[labels == 2,0],data[labels == 2,1], 'bo', ms=5)

class Classifier:
    def __init__(self, estimators):
        self.estimators = estimators
    def classify(self,x):
        estimations = [ estimator.estimate(x) for estimator in self.estimators]
        return np.argmax(estimations)

if __name__ == '__main__':
    # MAIN
    data,labels = read_iris()
    (nRows, nCols) = np.shape(data) 
    #data = np.array(clusterInCluster(100));   
    #labels = data[:,2].astype(np.int32)
    labels = np.zeros(data.shape[0]).astype(np.int32)
    data   = data[:,0:2] .astype(np.float)
    (nRows, nCols) = np.shape(data) 
    #k=5
    #estimator= KNNEstimator(data, k)
    
    #sigma=1/math.sqrt(nRows)
    #sigma = np.cov(data.T) * 1/math.sqrt(nRows)
    #estimator=ParzenEstimator(data,sigma,gaussian_window)
    
    #radius=0.3
    #estimator=ParzenEstimator(data,radius,chebyshev_window)
    
    sigmas = np.diag(np.cov(data.T))*(1/math.sqrt(nRows))
    #estimator=ParzenEstimator(data,sigmas,kernel_product_window)
    
    points_per_dimension=30
    #x,y,z=evaluate_estimator_meshgrid(data,estimator,points_per_dimension)
    
    #plot_density(x,y,z,data,labels)
    
    #dx = abs(x[0][0] - x[0][1])
    #dy = abs(y[0][0] - y[1][0])
    #print np.sum(z) * dx * dy
    
    label_range = np.unique(labels)
    estimators=[]
    fig = plt.figure()
    ax = fig.gca(projection="3d")  
    plt.ion()
    plt.show()
    colors=['r','g','b']
    for i in label_range:
        data_filtered=data[labels==i,:]
        (n_rows_f, n_cols_f) = np.shape(data) 
        #sigmas_f = np.mean(np.diag(np.cov(data_filtered.T)))*(13/math.sqrt(n_rows_f))
        sigmas_f = np.cov(data_filtered.T)*(0.5/math.sqrt(n_rows_f))    
        estimator=ParzenEstimator(data_filtered,sigmas_f,gaussian_window)
        estimators.append(estimator)
        x,y,z=evaluate_estimator_meshgrid(data_filtered,estimator,points_per_dimension)
        plot_density(x,y,z,data_filtered,labels[labels==i],colors[i],ax)
    plt.draw()
    
        
    c = Classifier(estimators)
    predictions = [c.classify(i) for i in data]
    print confusion_matrix(labels.astype(float), predictions)    
      
    
  