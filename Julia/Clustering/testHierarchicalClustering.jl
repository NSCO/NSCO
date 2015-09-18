
push!(LOAD_PATH,pwd())
include("hierarchicalClustering.jl")
include("../Datasets/Datasets.jl")
import HierarchicalClustering
hc = HierarchicalClustering

data = Datasets.skinpoints()
data = data[:,1:50:end]
selected = 4
k = 4
configs = [hc.single_linkage_configuration, hc.complete_linkage_configuration,
    hc.average_linkage_configuration, hc.ward_linkage_configuration]
tic()
clusterModel=hc.build_model(data, configs[selected](hc.euclidean_dist, k))
toc()

using PyCall
pygui(:qt)
using PyPlot

colors=["red","yellow","blue","green"]
figure()
for i=1:size(data, 2)
  scatter(x=data[1, i], y=data[2,i], color=colors[clusterModel.assignments[i]])
end
for i=1:k
  plot(clusterModel.centroids[1,i], clusterModel.centroids[2,i], color=colors[i], "*", ms=15)
end
title("Iris")
