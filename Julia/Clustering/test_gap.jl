push!(LOAD_PATH,dirname(@__FILE__))
push!(LOAD_PATH,joinpath(dirname(@__FILE__),"../Datasets/"))
import Datasets
import GAP
using GAP
using Datasets
using PyPlot
import HierarchicalClustering
hc = HierarchicalClustering


function hierarchical_adapter(Data::Matrix, k::Integer)
  conf =hc.single_linkage_configuration(hc.euclidean_dist,k)
  clusterModel = hc.build_model(data,conf)
  return clusterModel.assignments
end


data = Datasets.skinpoints()
data = data[:,1:80:end]


gapConfig = GapConfig(10, hierarchical_adapter,2,10)
gapResult=gap(data,gapConfig)
print(gap_evaluate(gapResult))
pygui(:qt)
plot(gapResult.gapIndex)
