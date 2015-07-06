# -*- coding: utf-8 -*-
"""
Created on Mon Jul  6 06:27:33 2015

Asumo que fue llamado configurarPath antes en el entorno
"""



from  clusterincluster import clusterInCluster
from  scipy.spatial.distance import pdist
from  scipy.cluster.hierarchy import linkage,dendrogram,fcluster
from matplotlib.pyplot import plot,figure
import matplotlib.pyplot as plt
from scipy import indices
import numpy

datos = clusterInCluster()
datos = datos[:,range(0,2)]
#Calculo la matriz de distancias
distancias =  pdist(datos,metric='euclidean')
#Tomo el metodo de single linkage
dendro     = linkage(distancias,method='single')
#Ploteo el dendrograma
dendrogram(dendro)
#Utilizo el valor 1.5 para cortar el dendrograma
clusters = fcluster(dendro,1,criterion='distance')

#Obtengo los indices de os patrones pertenecientes a cada cluster
indClus1 =numpy.where(clusters ==1)
indClus2 =numpy.where(clusters ==2)
#Los dibujo
figure()
plt.plot(datos[indClus1,0],datos[indClus1,1],'ro')
plt.plot(datos[indClus2,0],datos[indClus2,1],'bo')
plt.show()



