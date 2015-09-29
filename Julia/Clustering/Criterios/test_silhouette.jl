push!(LOAD_PATH,dirname(@__FILE__))
push!(LOAD_PATH,joinpath(dirname(@__FILE__),"../../Datasets/"))
push!(LOAD_PATH,joinpath(dirname(@__FILE__),"../"))
import Datasets
import Silhouette
using Datasets
using Silhouette
import HierarchicalClustering
hc = HierarchicalClustering
sl = Silhouette

data = Datasets.skinpoints()
data = data[:,1:100:end]
selected = 4
 configs = [hc.single_linkage_configuration, hc.complete_linkage_configuration,
    hc.average_linkage_configuration, hc.ward_linkage_configuration]

maxK = 20
scores1 = zeros(maxK-1)
scores2 = zeros(maxK-1)

for k=2:maxK
  println(k)
clusterModel=hc.build_model(data, configs[selected](hc.euclidean_dist, k))
idx = Silhouette.silhouette(data,clusterModel.assignments)
  scores1[k-1]=mean(idx[2])
  scores2[k-1]=mean(idx[1])
end
using PyPlot
scatter(2:maxK,scores1,color="g")
plot(2:maxK,scores1,color="g")

scatter(2:maxK,scores2,color="r")
plot(2:maxK,scores2,color="r")
