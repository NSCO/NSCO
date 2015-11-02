push!(LOAD_PATH, joinpath(dirname(@__FILE__),"..","Datasets"))
push!(LOAD_PATH, dirname(@__FILE__))

function test()
  include(joinpath("..","Datasets","Datasets.jl"))
  include("KMeans.jl")
  include("TestKMeans.jl")
end

using Datasets
using KMeans
using Distances
using InitialMeans

x = Datasets.skinpoints_small_normalized()

iterations=10
k=3
p=KMeans.Parameters(iterations,k,Distances.SqEuclidean(),InitialMeans.SampleRandom())

println("Running algorithm...")
(r,m)=KMeans.fit(x,p)
clusters=KMeans.get_clusters(r)

println("Plotting...")
using PyPlot
scatter(x=x[1,:],y=x[2,:],c=clusters/p.k,cmap=get_cmap("rainbow"),marker="x")
scatter(x=m.means[1,:],y=m.means[2,:],c="black",s=30,marker="o")
