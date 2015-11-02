push!(LOAD_PATH, joinpath(dirname(@__FILE__),"..","Datasets"))
push!(LOAD_PATH, dirname(@__FILE__))

function test()
  include("GMM.jl")
  include("InitialMeans.jl")
  include(joinpath("..","Datasets","Datasets.jl"))
  include("MatrixUtil.jl")
  include("GMMEM.jl")
  include("TestGMMEM.jl")
end

using Clustering
using Datasets
using GMMEM
using GMM
using InitialMeans
using PyPlot

srand(1234)
x = Datasets.skinpoints_small_normalized()

iterations=100
k=3
threshold=0.0#1e-10
p=GMMEM.Parameters(iterations,threshold,k,InitialMeans.Random())

println("Running algorithm...")
r,m=GMMEM.fit(x,p)
clusters=GMMEM.get_clusters(r)

println("Plotting...")
clf()
scatter(x=x[1,:],y=x[2,:],c=float(clusters)/float(p.k),cmap=get_cmap("rainbow"),marker="x")
means = GMM.get_means(m.gmm)
scatter(x=means[1,:],y=means[2,:],c="black",s=30,marker="o")
