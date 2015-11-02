push!(LOAD_PATH, joinpath(dirname(@__FILE__),"..","Datasets"))
push!(LOAD_PATH, dirname(@__FILE__))

srand(12345)

function test()
  include("Clustering.jl")
  include("FuzzyCMeans.jl")
  include("KMeans.jl")
  include("GMMEM.jl")
  include("GMM.jl")
  include("DBScan.jl")
  include("MeanShift.jl")
  include(joinpath("..","Datasets","Datasets.jl"))
  include("TestClusterings.jl")
end

using Clustering
using InitialMeans
using Datasets
using KMeans
using FuzzyCMeans
using Distances
using GMMEM
using GMM
using DBScan
using MeanShift

type ClusteringAlgorithm
    name::AbstractString
    config_generator::Function
    mod::Module
end

function make_datasets(samples)
  ks=[2,2,3,3]
  centers=[ 0 -1 1.0;
            1 -1 -1]
  datasets=Any[Datasets.make_circles(samples),
            Datasets.make_moons(samples,1.0),
            Datasets.make_gaussian_blobs(samples,centers,0.1),
            rand(2,samples)]
  ks,datasets
end

function make_cluster_algorithms()
    iterations=50
    fuzzyness=2
    fcm(k) = FuzzyCMeans.Parameters(iterations,k,fuzzyness,Distances.SqEuclidean(),InitialMeans.SampleRandom())
    km(k) = KMeans.Parameters(iterations,k,Distances.SqEuclidean(),InitialMeans.SampleRandom())

    gmm(k) = GMMEM.Parameters(1000,0.0,k,InitialMeans.Random())
    dbscan(k) = DBScan.Parameters(0.05,1)
    mean_shift(k) = MeanShift.Parameters(1.0,0.002,MeanShift.gaussian_window,50)
    algorithms=ClusteringAlgorithm[
              ClusteringAlgorithm("FCM",fcm,FuzzyCMeans)
              ,ClusteringAlgorithm("KMeans",km,KMeans)
              ,ClusteringAlgorithm("EM-GMM",gmm,GMMEM)
              ,ClusteringAlgorithm("DBSCAN",dbscan,DBScan)
              ,ClusteringAlgorithm("MeanShift",mean_shift,MeanShift)
              ]
    algorithms
end

function clustering_algorithms_comparison(ks,datasets,cluster_algorithms)
  clf()
  rows=length(datasets)
  columns=1+length(cluster_algorithms)
  for i=1:length(datasets)
      data=datasets[i]
      subplot(rows,columns, (i-1)*columns+1)
      scatter(x=data[1,:],y=data[2,:],marker="o")
      if (i==1) title("Datasets") end
      for j=1:length(cluster_algorithms)
         clustering_algorithm=cluster_algorithms[j]
         config=clustering_algorithm.config_generator(ks[i])
         result,model=clustering_algorithm.mod.fit(data,config)
         clusters=clustering_algorithm.mod.get_clusters(result)
         subplot(rows,columns, (i-1)*columns+j+1)
         scatter(x=data[1,:],y=data[2,:],c=clusters/ks[i],cmap=get_cmap("rainbow"),marker="o")
         if (i==1)
           title(clustering_algorithm.name)
         end
      end
  end
end



using PyPlot
tic()
samples=200
ks,datasets=make_datasets(samples)
cluster_algorithms=make_cluster_algorithms()
clustering_algorithms_comparison(ks,datasets,cluster_algorithms)
toc()
