import sys as sys
from numpy.linalg import norm
from numpy import array
from clusterincluster import clusterInCluster
import random
import matplotlib.pyplot as pt

def single_linkage(datos, k):
        (nFilas, nCols) = datos.shape
        # clus = []
        # for i in range(0,nFilas)
        #   clus.append([i])
        clus = [[i] for i in range(0,nFilas)]        
        while len(clus) > k:

            print(len(clus))
            #python3
            dmin= sys.maxsize
            #python2
            #dmin= sys.maxint
            imin = -1
            jmin = -1
            for i in range(0,len(clus)-1):
                for j in range(i + 1, len(clus)):
                   
                    #dist busca la minima arista para single linkage
                    d = single_link_dist(clus[i], clus[j], datos) 
                    if (dmin > d):                        
                        dmin = d
                        imin = i
                        jmin = j            
            v1 = clus[imin]
            v2 = clus[jmin]
            clusNuevo = v1 + v2
            clus.remove(v1)
            clus.remove(v2)
            clus.append(clusNuevo)
        return clus    
        
def single_link_dist(clus_i, clus_j, datos):
      #dmin= sys.maxint
      dmin= sys.maxsize
      for i in clus_i:
          for j in clus_j:
              d = norm(datos[i,:] - datos[j,:])
              if (dmin > d):
                  dmin=d
      return dmin
     
     
     
#datos = [[random.randint(0,100) for x in range(0,5)] for x in range(0,5)]
#datos = [[random.randint(0,100) for x in range(0,2)] for x in range(0,100)]
#datos = array(datos)     
#print(datos)

datos = clusterInCluster(N=70);
clusters=datos[:,2]
datos=datos[:,0:2]
k = 2    

clusters = single_linkage(datos, k)
pt.plot(datos[clusters[0],0],datos[clusters[0],1], 'r*', ms=10)
pt.plot(datos[clusters[1],0],datos[clusters[1],1], 'b*', ms=10)

     