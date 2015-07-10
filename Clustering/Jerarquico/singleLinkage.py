# -*- coding: utf-8 -*-
"""
Created on Tue Jul  7 07:07:26 2015

@author: emi
"""
#clus guarda

from numpy.linalg import norm
from  clusterincluster import clusterInCluster
from matplotlib.pyplot import plot,figure
import matplotlib.pyplot as plt


def singleLinkage(datos,k):
    nfilas=datos.shape[0]
   
    clus=[]
    clus=[[i] for i in range (0, nfilas)]
    while len(clus) > k:
          print (len(clus))
          imin=0
          rmin=99999999
          jmin=0
          for i in range (0, len(clus)):
                  for j in range (i+1, len(clus)):
                      distancia = distLinkage(clus[i], clus[j] ,datos)              
                      if (rmin > distancia ):
                          rmin=distancia
                          imin=i
                          jmin=j
          clusNuevo=clus[imin] + clus[jmin]
          aux = clus[jmin]        
          clus.remove(clus[imin])
          clus.remove(aux)
          clus.append(clusNuevo)
    return clus
    

def distLinkage(clusI,clusJ, datos):
    mind=999999999
    for i in clusI:
        for j in clusJ:
            d=norm(datos[i,:]-datos[j,:])
            if (d<mind):
                mind=d;
    return mind

                          

datos=clusterInCluster(70)
datos=datos[:,range(0,2)]
clusters=singleLinkage(datos,2)
#Los dibujo
figure()
plt.plot(datos[clusters[0],0],datos[clusters[0],1],'ro')
plt.plot(datos[clusters[1],0],datos[clusters[1],1],'bo')
plt.show()



         
    
    