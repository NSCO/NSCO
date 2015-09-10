push!(LOAD_PATH,pwd())
include("hierarchicalClustering.jl")
#push!(LOAD_PATH,pwd()+"../Datasets")
using HierarchicalClustering
import HierarchicalClustering
m = rand(4,500)
#c=HierarchicalClustering.build_model(m,HierarchicalClustering.single_linkage_configuration(HierarchicalClustering.euclidean_dist,4))
c=build_model(m, single_linkage_configuration(euclidean_dist,4))
