#include("../Datasets")
push!(LOAD_PATH, joinpath(pwd(),"../Datasets"))
push!(LOAD_PATH, pwd())

using Datasets
using DBScan
using PyPlot

data=Datasets.skinpoints()
data=data[:,1:100:end]
c=DBScan.DBScanConfig(100,4)

clusters=DBScan.build_model(data,c)

colors=["red","blue","yellow","green","black"]
for i=unique(clusters)
    if i>0
      cluster_data=data[:,clusters.==i]
      scatter(cluster_data[1,:], cluster_data[2,:],color=colors[int(i)])
    end
end
