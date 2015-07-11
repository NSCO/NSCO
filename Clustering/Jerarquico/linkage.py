from numpy.linalg import norm
from numpy import zeros
import numpy
def singleLinkage(clusI,clusJ, datos):
    mind=999999999
    
    for i in clusI:
        for j in clusJ:
            d=norm(datos[i,:]-datos[j,:])
            if (d<mind):
                mind=d;
                ii=i
                jj=j
    return [mind, ii, jj]
    
def centroide(clusI, datos):
    centro = zeros([1,datos.shape[1]])
    for i in clusI:
        centro+=datos[i,:]
    centro/=len(clusI)
    return centro
def averageLinkage(clusI,clusJ, datos):
    centroI = centroide(clusI,datos)
    centroJ = centroide(clusJ,datos)
    d = norm(centroI-centroJ)
    ii = clusI[0]
    jj = clusJ[0]
    return [d, ii, jj]
def completeLinkage(clusI,clusJ, datos):
    maxd=-1
    for i in clusI:
        for j in clusJ:
            d=norm(datos[i,:]-datos[j,:])
            if (d>maxd):
                maxd=d;
                ii=i
                jj=j
    return[ maxd, ii, jj]