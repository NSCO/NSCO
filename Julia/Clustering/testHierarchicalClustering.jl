
push!(LOAD_PATH,pwd())
include("hierarchicalClustering.jl")
include("../Datasets/Datasets.jl")
import HierarchicalClustering
hc = HierarchicalClustering

m = Datasets.skinpoints()
m = m[:,1:50:end]
#m = m ./ maximum(m,2)
selected = 4
k = 3
configs = [hc.single_linkage_configuration, hc.complete_linkage_configuration,
  hc.average_linkage_configuration, hc.ward_linkage_configuration]
tic()
clusters=hc.build_model(m, configs[selected](hc.euclidean_dist, k))
toc()

using PyPlot
colors=["red","yellow","blue","green"]
figure()
for i=1:length(clusters)
  scatter(x=m[1,clusters[i]], y=m[2,clusters[i]],color=colors[i])
end
title("Iris")
