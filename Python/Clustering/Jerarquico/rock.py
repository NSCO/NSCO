# -*- coding: utf-8 -*-
"""
Created on Tue Jul  7 07:07:26 2015

@author: emi
"""
#clus guarda

from outlier import outlier
from  clusterincluster import clusterInCluster
from numpy.linalg import norm
from  clusterincluster import clusterInCluster
from matplotlib.pyplot import plot,figure
import matplotlib.pyplot as plt

from scipy.spatial import KDTree
from scipy.sparse import lil_matrix
def f(alpha):
    return (1-alpha)/(1+alpha)
class ROCK:
    def __init__(self,datos,r):
        self._datos = datos
        _arbol =KDTree(datos)
        _vecinos = _arbol.query_ball_point(self._datos,r,2)
        self._datos = datos
        self._links = lil_matrix((datos.shape[0], datos.shape[0]))
        for i in range(0,self._datos.shape[0]):
            N = _vecinos[i]
            for j in range(0,len(N)-1):
                for k in range(j+1,len(N)):
                    self._links[N[j],N[k]]+=1
        
            
    def dist(self,clusi,clusj):
        suma=0
        for i in clusi:
            for j in clusj:
                suma+=self._links[i,j]
        n1 = len(clusi)
        n2 = len(clusj)
        exp=1+2*f(self._alpha)
        return suma/(pow(n1+n2,exp) - pow(n1,exp) - pow(n2,exp))
        
    def ejecutar(self,k,alpha):
        self._alpha = alpha
        clus=[[i] for i in range (0, self._datos.shape[0])]
        maxG=float("-inf")
        while (len(clus) > k):
            maxG=float("-inf")
            for i in range (0, len(clus)):
                  for j in range (i+1, len(clus)):
                      g = self.dist(clus[i], clus[j])     
                      if (maxG < g):
                          maxG=g
                          imax=i
                          jmax=j

            clusNuevo=clus[imax] + clus[jmax]
            aux = clus[jmax]        
            clus.remove(clus[imax])
            clus.remove(aux)
            clus.append(clusNuevo)
        return clus




                          


datos=outlier(N=150,outliers=0.2)
datos=datos[:,range(0,2)]
r = ROCK(datos,10)
clusters = r.ejecutar(4,0.5)
#Los dibujo
figure()
plt.plot(datos[clusters[0],0],datos[clusters[0],1],'ro')
plt.plot(datos[clusters[1],0],datos[clusters[1],1],'bo')
plt.plot(datos[clusters[2],0],datos[clusters[2],1],'go')
plt.plot(datos[clusters[3],0],datos[clusters[3],1],'yo')
plt.show()

