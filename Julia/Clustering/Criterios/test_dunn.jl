push!(LOAD_PATH,dirname(@__FILE__))
push!(LOAD_PATH,joinpath(dirname(@__FILE__),"../../Datasets/"))
push!(LOAD_PATH,joinpath(dirname(@__FILE__),"../"))
using PyPlot
pygui(:qt)
import Datasets
import Dunn
using Datasets
using Dunn
import HierarchicalClustering
hc = HierarchicalClustering
include("Dunn.jl")

data = Datasets.skinpoints()
data = data[:,1:50:end]
selected = 4

indexes = []
for k=2:10
configs = [hc.single_linkage_configuration, hc.complete_linkage_configuration,
    hc.average_linkage_configuration, hc.ward_linkage_configuration]
clusterModel=hc.build_model(data, configs[selected](hc.euclidean_dist, k))
  idx = Dunn.dunn(data,clusterModel.assignments)
  push!(indexes,idx)
end
plot(indexes)

