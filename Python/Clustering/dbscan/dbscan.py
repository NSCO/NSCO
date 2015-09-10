import numpy as np
from matplotlib import pyplot as plt
import matplotlib.cm as cm


class DBSCAN:
    def __init__(self,eps,minimum_points):
        self.eps=eps
        self.minimum_points=minimum_points

    def append_all_except_duplicates(self,a,b):
       for e in b:
           if e not in a:
               a.append(e)

    def assign_to_new_cluster(self,clusters,x,new_cluster_id,points_reachable_from_example):
        i=0
        while i<len(points_reachable_from_example):
            point_index=points_reachable_from_example[i]
            if clusters[point_index]==0:
                clusters[point_index]=new_cluster_id
                neightbour=x[:,point_index]
                points_near_neightbour=self.points_near(neightbour,x)
                self.append_all_except_duplicates(points_reachable_from_example,points_near_neightbour)
            i+=1
    def points_near(self,point,x):
        indices=[]
        for i in range(x.shape[1]):
            possible_neighbour=x[:,i]
            if np.sqrt(sum(np.square(possible_neighbour-point)))<self.eps:
                indices.append(i)
        return indices

    def cluster(self,x):
        dimensions,examples=x.shape
        clusters=np.zeros(examples)
        next_cluster_id=1
        for i in range(examples):
            point=x[:,i]
            if clusters[i]!= 0: #already assigned examples dont get reassigned to other clusters
                continue;
            points_near_example=self.points_near(point,x)
            if (len(points_near_example)>=self.minimum_points): # fullfills conditions to make a new cluster
                self.assign_to_new_cluster(clusters,x,next_cluster_id,points_near_example)
                next_cluster_id+=1
        return clusters

if __name__ == "__main__":
    eps=20
    minimum_points=3
    dbscan=DBSCAN(eps,minimum_points)
    #x=np.random.rand(2,20)
    x=np.loadtxt(open("skin_points.csv","rb"),delimiter=",",skiprows=0)
    x=x.T
    x=x[:,1:14000:140]
    clusters=dbscan.cluster(x)
    k=np.unique(clusters)
    colors = cm.rainbow(np.linspace(0, 1, len(k)))
    gray=np.array([0.8,0.8,0.8,1])
    colors=np.vstack((gray,colors))
    for c in k:
        xi=x[:,clusters==c]
        plt.scatter(xi[0,:],xi[1,:],color=colors[c])
    plt.show()
