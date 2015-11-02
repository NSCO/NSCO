push!(LOAD_PATH, joinpath(dirname(@__FILE__),"..","Datasets"))
push!(LOAD_PATH, dirname(@__FILE__))

function test()
  include(joinpath("..","Datasets","Datasets.jl"))
  include("Clustering.jl")
  include("FuzzyCMeans.jl")
  include("TestFuzzyCMeans.jl")
end

using Datasets
using FuzzyCMeans
using Distances
using InitialMeans

using PyPlot

x = Datasets.skinpoints_small_normalized()

iterations=20
k=3
fuzzyness=2
p=FuzzyCMeans.Parameters(iterations,k,fuzzyness,Distances.SqEuclidean(),InitialMeans.SampleRandom())

println("Running algorithm...")

(r,m)=FuzzyCMeans.fit(x,p)
clusters=FuzzyCMeans.get_clusters(r)



scatter(x=x[1,:],y=x[2,:],c=clusters/float(m.p.k),cmap=get_cmap("rainbow"),marker="x")
#scatter(x=m.means[1,:],y=m.means[2,:],c="black",s=30,marker="o")



function plot_clusters(x::FuzzyCMeans.Input,m::FuzzyCMeans.Model,r::FuzzyCMeans.Result)
  soft_clusters=FuzzyCMeans.get_soft_clusters(r)
  for i=1:size(soft_clusters,1)
    figure()
    ax=scatter(x=x[1,:],y=x[2,:],c=soft_clusters[i,:],cmap=get_cmap("summer"),marker="x")
    colorbar(ax)
    scatter(x=m.means[1,i],y=m.means[2,i],c="black",s=30,marker="o")
  end
end

plot_clusters(x,m,r)
