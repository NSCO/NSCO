# -*- coding: utf-8 -*-
"""
Created on Thu Jul 16 09:59:16 2015

@author: luciano
"""

from numpy.linalg import norm
from numpy import matrix,vstack
from  clusterincluster import clusterInCluster
from KDTree import kdtree
def dist(a, b):
        
    if ( ((type(a) == float) and (type(b) == float)) or ((type(a) == int) and (type(b) == int)) ):
        return (a - b)**2.0;
        
    return norm(a-b,2)    
    
class CureCluster:
   
    def __init__(self,punto=None):
        if (punto is not None):
          self.rep=[punto]
          self.media=punto
          self.puntos=[punto]
        else:
          self.puntos = [ ];
          self.media = None;
          self.rep = [ ];
        self.masCercano = None;
        self.distMasCercano = float('inf'); 
    def cantPuntos(self):
        return len(self.puntos)

class CURE:
    def __init__(self, datos, k, n_rep = 5, compression = 0.5):
        self._datos = datos;
        self._k = k;
        self._rep = n_rep;
        self._comp = compression;
        self._crearCola();
        self._crearArbolKD();
    def _distanciaClusters(self, cluster1, cluster2):
        #Hace el single linkage pero entre los representantes
        minDist = float('inf');
        for i in range(0, len(cluster1.rep)):
            for k in range(0, len(cluster2.rep)):                
                distActual = dist(cluster1.rep[i], cluster2.rep[k]);      
                if (distActual < minDist):
                    minDist = distActual;
        return minDist
                    
    def _crearCola(self):
        self._cola = [CureCluster(patron) for patron in self._datos];        
        for i in range(0, len(self._cola)):
            minDist = float('inf');
            minIndi = -1;            
            for k in range(0, len(self._cola)):
                if (i != k):
                    dist = self._distanciaClusters(self._cola[i], self._cola[k]);
                    if (dist < minDist):
                        minDist = dist;
                        minIndi = k;
            self._cola[i].masCercano   = self._cola[minIndi];
            self._cola[i].distancia = minDist;          
        #Ordena la cola por distancia            
        self._cola.sort(key = lambda x: x.distMasCercano, reverse = False);
    def _crearArbolKD(self):            
       self._arbol =  kdtree();    
    
       #print(reduce(lambda lista, x: lista + x.rep, self._cola, list()))
       for cluster in self._cola:           
            for representante in cluster.rep:    
                self._arbol.insert(representante.tolist()[0],cluster)                   
  
       
    def _borarRepresentantes(self,cluster):        
        for punto in cluster.rep:
            self._arbol.remove(punto.tolist()[0]);
    def ejecutar(self):
        while (len(self._cola) > self._k):
            cluster1 = self._cola[0];       #Cluster que tiene el vecino más cercano
            cluster2 = cluster1.masCercano; #Cluster más cercano
            
            #Saco los  dos clusteres
            self._cola.remove(cluster1)

            self._cola.remove(cluster2)
            
            self._borarRepresentantes(cluster1)
            self._borarRepresentantes(cluster2)
            
            clusterNuevo = self._unirClusters(cluster1, cluster2);
            
            self._insertarNuevoRepresentantes(clusterNuevo);
            
            cluster_relocation_requests = [];
            clusterNuevo.masCercano = self._cola[0]; #eligo un cluster arbitrario
            clusterNuevo.distMasCercano = self._distanciaClusters(clusterNuevo, clusterNuevo.masCercano);
            
            for clus in self._cola:
                dist = self._distanciaClusters(clusterNuevo, clus);
                if (dist < clusterNuevo.distMasCercano):
                    clusterNuevo.masCercano = clus;
                    clusterNuevo.distMasCercano = dist;
                    
                if ( (clus.masCercano is cluster1) or (clus.masCercano is cluster2) ):
                     if (clus.distMasCercano < dist):
                         (clus.masCercano, clus.distMasCercano) = self._clusterMasCercano(clus, dist);
                     else:
                        clus.masCercano = clusterNuevo;
                        clus.distMasCercano = dist;
                        
                     cluster_relocation_requests.append(clus);
                elif (clus.distMasCercano > dist):
                   clus.masCercano = clusterNuevo;
                   clus.distMasCercano = dist;
                   cluster_relocation_requests.append(clus);
           
            self._insertarNuevoCluster(clusterNuevo);
            [self._realocarCluster(item) for item in cluster_relocation_requests];
        
            # Change cluster representation
            self._clusters = [ cureCluster.puntos for cureCluster in self._cola ];
    def _insertarNuevoCluster(self, cluster):        
        for i in range(len(self._cola)):
            if (cluster.distMasCercano < self._cola[i].distMasCercano):
                self._cola.insert(i, cluster);
                return;
    
        self._cola.append(cluster);                          
    def _realocarCluster(self, cluster):        
        self._cola.remove(cluster);
        self._insertarNuevoCluster(cluster);
    def _clusterMasCercano(self, cluster, distance):
       
        
        minCluster = None;
        minDist = float('inf');
        
        for punto in cluster.rep:     
            puntoLista = punto.tolist()[0]
            vecinosProximos = self._arbol.find_nearest_dist_nodes(puntoLista, distance);
            for (distCandidato, kdtree_node) in vecinosProximos:
                if ( (distCandidato < minDist) and (kdtree_node is not None) and (kdtree_node.payload is not cluster) ):
                    minDist = distCandidato;
                    minCluster = kdtree_node.payload;
                    
        return (minCluster, minDist);                            
    def _insertarNuevoRepresentantes(self,clusterNuevo):      
        for representante in clusterNuevo.rep:
            self._arbol.insert(representante.tolist()[0], clusterNuevo);            
            
    def _unirClusters(self, cluster1, cluster2):
        """!
        @brief Une los dos clusters y calcula los representantes y la media        
        """
        
        clusterNuevo = CureCluster();
        
        clusterNuevo.puntos = cluster1.puntos + cluster2.puntos;
        
      
        clusterNuevo.media = ((cluster1.cantPuntos() * cluster1.media) + (cluster2.cantPuntos() + cluster2.media));
        clusterNuevo.media = clusterNuevo.media /(cluster1.cantPuntos() + cluster2.cantPuntos());
        
        listaTemp = list(); 
        
        for idx in range(self._rep): #por cada uno de los respresenatnes
            maxDist = 0;
            maxPunto = None;
            
            for punto in clusterNuevo.puntos:
                minDist = 0;
                if (idx == 0):
                    minDist = dist(punto, clusterNuevo.media);                    
                else:
                    minTempDist = float('inf')
                    for q in listaTemp:      
                        distActual = dist(punto, q);                    
                        if (minTempDist < distActual):
                            minTempDist = distActual
                    minDist = minTempDist                  
                    
                if (minDist >= maxDist):
                    maxDist = minDist;
                    maxPunto = punto;


            i=0
            encontre=False
            while (i<len(listaTemp) and not(encontre)):            
                if (norm(listaTemp[i]-maxPunto)<0.00001):
                    encontre=True
                i=i+1
            
            if (not(encontre)):
                listaTemp.append(maxPunto);
                
        #Los achico hacia la media                
        for punto in listaTemp:
            clusterNuevo.rep.append(punto + self._comp*(clusterNuevo.media - punto))      
        
        return clusterNuevo;
            
            
            
datos = clusterInCluster()
datos = datos[:,range(0,2)]
c = CURE(datos,5)
r = c.ejecutar()
            
        