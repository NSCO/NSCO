push!(LOAD_PATH,dirname(@__FILE__))
push!(LOAD_PATH,joinpath(dirname(@__FILE__),"../../Datasets/"))
push!(LOAD_PATH,joinpath(dirname(@__FILE__),"../"))
using Autoreload

import AIC
import Datasets
import HierarchicalClustering
#arequire("AIC")
#arequire("Datasets")
#arequire("HierarchicalClustering")
hc = HierarchicalClustering
areload()
data=Datasets.skinpoints()
data=data[:,1:100:end]
mins = minimum(data, 2)
maxs = maximum(data, 2)
#data = data ./ maximum(data, 2)
data = (data .- mins) ./ (maxs .- mins)

maxK = 20
scores = zeros(maxK)
for k=1:maxK
  println(string("K=", k))
  clusterModel=hc.build_model(data, hc.single_linkage_configuration(hc.euclidean_dist, k))
  scores[k] = AIC.aic_centroid(clusterModel, data)
end
println(scores)
