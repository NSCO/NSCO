#include("../Datasets")
push!(LOAD_PATH, joinpath(pwd(),"..","Datasets"))
push!(LOAD_PATH, pwd())

function test()
  include(joinpath("..","Datasets","Datasets.jl"))
  include("Clustering.jl")
  include("DBScan.jl")
  include("TestDBScan.jl")
end


using Datasets
using DBScan


x = Datasets.skinpoints_small_normalized()

maximum_distance=0.05
minimum_points=10
p=DBScan.Parameters(maximum_distance,minimum_points)

r,m=DBScan.fit(x,p)
clusters=DBScan.get_clusters(r)

println("Plotting...")
using PyPlot
ax=scatter(x=x[1,:],y=x[2,:],c=clusters/maximum(clusters),cmap=get_cmap("rainbow"),marker="x")
cbar = colorbar(ax, ticks=unique(clusters))
title("Cluster 0 = outliers")
