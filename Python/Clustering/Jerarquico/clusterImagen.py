# -*- coding: utf-8 -*-
"""
Created on Tue Jul 21 18:54:02 2015

@author: luciano
"""

# -*- coding: utf-8 -*-
"""
Created on Tue Jul 21 16:40:34 2015

@author: luciano
"""
from   cpp.curecpp import curecpp
from pyclustering.cluster.cure import cure
from scipy import misc
#from cure import cure 
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.cm as cm
import  numpy.random as rd
imagen = misc.imread('/home/luciano/aa.jpg')
plt.imshow(imagen)
m = np.zeros((imagen.shape[0]*imagen.shape[1],3))
puntos = []
p=0
for i in range(0,imagen.shape[0]):
   for j in range(0,imagen.shape[1]):
     m[p,:] = [ i , j , np.sum(imagen[i,j]/3)]
     puntos.append([ i , j , np.sum(imagen[i,j]/3)])
     p=p+1






imgplot = plt.imshow(imagen)

imagenByN=np.reshape(m[:,2],(imagen.shape[0],imagen.shape[1]))
imgplot = plt.imshow(np.reshape(m[:,2],(imagen.shape[0],imagen.shape[1])),cmap=cm.Greys_r)


    
K=1
imagenNueva = imagen
#clusters = cure(m,3,6,0.5)
datos = np.array(puntos)
cure_instance = curecpp(datos, 3, 5, 0.5);
clusters = cure_instance
for cluster in clusters:    
   color = [rd.randint(0,255), rd.randint(0,255),rd.randint(0,255)]
   for i in cluster:
      imagenNueva[puntos[i][0],puntos[i][1],:] = color  
plt.figure()       
plt.imshow(imagenNueva)