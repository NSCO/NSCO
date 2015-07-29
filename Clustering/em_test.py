import numpy as np;
import sys as sys
import matplotlib.pyplot as plt
import pandas as pd
import time
from scipy.stats import multivariate_normal
from numpy import *
from numpy.linalg import *
    
class GaussianComponent:
  def __init__(self,mu,sigma,tita):
    self.sigma = sigma
    self.mu    = mu
    self.tita  = tita

  def eval(self,x):   
    var =  multivariate_normal(mean=self.mu, cov=self.sigma)
    return var.pdf(x)
    #print(len(x))
    
    dx  = x-self.mu
#    print str(self.sigma)
#    print str(self.mu)
#    print str(x)
#    print str(dx)
    sigma_inv = np.linalg.inv(self.sigma)
    constant=1/np.sqrt(((2*np.pi)**len(x))*np.linalg.det(self.sigma) )
    exponent=np.exp( -0.5  * dx.dot(sigma_inv).dot(dx.T))
    return constant*exponent
  
  def responsibility(self, x):
  	return self.eval(x)*self.tita

class EM:
  def __init__(self):
    self.w = []

  def expectation(self,datos):
      (nFilas, nCols) = datos.shape    
      for i in range(0, nFilas):
          for j in range(0, self.k):
              self.w[i,j] = self.distributions[j].responsibility(datos[i,:])
              
          example_responsibility=np.sum(self.w[i,:])
         
          if (example_responsibility<0.0000000000000001):
              self.w[i,:]=1.0/self.k
          else:
              self.w[i,:] = self.w[i,:] / example_responsibility

  def maximization(self,datos):
    (nFilas, nCols) = datos.shape
    w_sum = np.sum(self.w,axis=0)
    print(w_sum)
    for j in range(0, self.k):
        self.distributions[j].tita = w_sum[j] / nFilas
        self.distributions[j].mu = np.zeros( (nCols))
        self.distributions[j].sigma = np.zeros( (nCols, nCols))
        for i in range(0,nFilas):   
            x = datos[i,:]          
            self.distributions[j].mu += self.w[i,j] * x
        self.distributions[j].mu = self.distributions[j].mu / w_sum[j]
        for i in range(0,nFilas):
            x = datos[i,:]
            dx = x - self.distributions[j].mu
            self.distributions[j].sigma += self.w[i,j] * np.outer(dx, dx)
        self.distributions[j].sigma =  (self.distributions[j].sigma / w_sum[j])
  
  
  def likelihood(self, datos):
    (nFilas, nCols) = datos.shape
    result = 0
    for i in range(0, nFilas):
      example_likelihood = 0;
      for j in range(0, self.k):      
        example_likelihood += self.distributions[j].responsibility(datos[i,:])
      result += np.log(example_likelihood)
    return result   

  def initialize(self,datos):
    (nFilas, nCols) = datos.shape
    self.w = np.random.rand(nFilas, k)
    self.distributions = []
    indices=np.random.choice(range(0,nFilas),(k))    
    C=np.cov(datos.T)
 
    for i in range(0,self.k):
      mu = datos[indices[i],:]      
      sigma = C 
      tita = 1.0/self.k
      self.distributions.append(GaussianComponent(mu, sigma, tita))

  def run(self,datos,k, t = 0.01):
    self.k=k
    self.initialize(datos)
    self.threshold = t    
    likelihood_ant = 900000
    likelihood_act = 0
    i=0

    plt.ion()
    plt.show()
    while ( abs(likelihood_act - likelihood_ant) > self.threshold ):
      i+=1
      plt.clf()
      plt.plot(datos[:,0],datos[:,1],'ro')
      for j in range(0,k):
          plt.plot(self.distributions[j].mu[0],self.distributions[j].mu[1],'b*')
      
      plt.draw()
      plt.pause(0.1)
      
      
      #print 'W: %s' % str(self.w)
      self.expectation(datos)
      #print 'W: %s' % str(self.w)
      self.maximization(datos)
      likelihood_ant = likelihood_act
      likelihood_act = self.likelihood(datos)
      
      
      
      print 'Iteration %d, likelihood %.2f' % (i,likelihood_act)
      
    

print 'Reading data...'
#file_path = 'Jerarquico/Iris.csv'
file_path = 'Jerarquico/skin_points.csv'
df=pd.read_csv(file_path, sep=',',header=None)
#data = df.values[:, 0:2]
data  = df.values
data = data[0:data.shape[0]:50,:].astype(np.float64)

(nRows, nCols) = data.shape

em=EM()
k=3
t=0.001
print 'Running algorithm....'
em.run(data,k,t)

print 'Results:'    
for i in range(0,k):
    c=em.distributions[i]
    print 'Component %d mean: %s, sigma: %s ' % (i,str(c.mu),str(c.sigma))
