push!(LOAD_PATH, joinpath(dirname(@__FILE__),"../Datasets"))
push!(LOAD_PATH, dirname(@__FILE__))


function test()
  include(joinpath("..","Datasets","Datasets.jl"))
  include("Clustering.jl")
  include("InitialMeans.jl")
  include("MeanShift.jl")
  include("TestMeanShift.jl")
end


using Datasets
using MeanShift

x = Datasets.skinpoints_small_normalized()
iterations=50
p=MeanShift.Parameters(1.0,0.002,MeanShift.gaussian_window,iterations)

println("Running algorithm...")

r,m=MeanShift.fit(x,p)

clusters=MeanShift.get_clusters(r)

println("Plotting...")
using PyPlot
ax=scatter(x=x[1,:],y=x[2,:],c=clusters/maximum(clusters),cmap=get_cmap("rainbow"),marker="x")
cbar = colorbar(ax, ticks=unique(clusters))
