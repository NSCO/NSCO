push!(LOAD_PATH,dirname(@__FILE__))
push!(LOAD_PATH,joinpath(dirname(@__FILE__),"../Datasets/"))
import Datasets
import Silhouette
using Datasets
using Silhouette
import HierarchicalClustering
hc = HierarchicalClustering
sl = Silhouette

data = Datasets.skinpoints()
data = data[:,1:50:end]
selected = 4
k = 4
configs = [hc.single_linkage_configuration, hc.complete_linkage_configuration,
    hc.average_linkage_configuration, hc.ward_linkage_configuration]

clusterModel=hc.build_model(data, configs[selected](hc.euclidean_dist, k))

idx = Silhouette.silhouette(data,clusterModel.assignments)
print(idx)