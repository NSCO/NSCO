# -*- coding: utf-8 -*-

from  clusterincluster import clusterInCluster
import heapq
from scipy.spatial import KDTree
class ROCKCluster:
    def __init__(self, idx,rock):
        self._elementos = [idx] 
        self.idx = idx
        self.rock = rock
    def __lt__(self, otro):
        self.rock.linkCluster(self,otr)
        return True
class ROCK:
    def __init__(self,datos,r):
        self._datos = datos
        self._arbol = KDTree(datos)
        self._calcularLinks(r)
    def _calcularLinks(self,r):
        self._vecinos = self._arbol.query_ball_point(self._datos,r)
        self._clusters = [ROCKCluster(i,self) for i in range(0,self._datos.shape[0])]
        self._q = []
        for clus in self._clusters:
            self._q.append(self._armarHeapLocal(clus))
    def linkVecinos(self,i,j):
        return len(list(set(self._vecinos[i]) & set(self._vecinos[j]))  )
    def linkCluster(self,clusi,clusj):
        suma = 0
        for i in clusi._elementos:
            for j in clusj._elementos:
                suma = suma+ self.linkVecinos(i,j)
        return suma
                
    def _armarHeapLocal(self, iclus):
        heap =[];
        for vecino in self._vecinos[iclus.idx]:
             heapq.heappush(heap,self._clusters[vecino]);
        return heap;
        
        
datos = clusterInCluster()
datos = datos[:,range(0,2)]
r = ROCK(datos,5)