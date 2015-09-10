
push!(LOAD_PATH,pwd())
include("hierarchicalClustering.jl")
include("../Datasets/Datasets.jl")
using HierarchicalClustering
import HierarchicalClustering
m = Datasets.skinpoints()
m = m[:,1:100:end]
clusters=build_model(m, single_linkage_configuration(euclidean_dist,4))

using PyPlot
colors=['red','yellow','blue','green']
for i=1:length(clusters)
scatter(x=m[1,clusters[i]], y=m[2,clusters[i]],color=colors[i])
title("Iris")

end
