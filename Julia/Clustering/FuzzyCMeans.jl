module FuzzyCMeans


#export Parameters,Model, build_model,harden_soft_assigments,get_clusters
using Clustering
using Distributions,Distances
using InitialMeans,MatrixUtil

typealias Input Matrix{Float64}

type Parameters <: Clustering.Parameters
  iterations::Int
  k::Int
  fuzzyness::Float64
  metric::SemiMetric
  initialization::InitialMeans.Method
end

type Model
  means::Input
  p::Parameters
end

type Result
  soft_clusters::Clustering.Soft
end

get_clusters(m::Model,x::Input) = Clustering.harden_soft_clusters(get_soft_clusters(m,x))

function get_soft_clusters(m::Model,x::Input) #::Clustering.Soft
    responsibilities=zeros(c.k,size(x,2))
    r=Result(responsibilities)
    update_responsibilities(m,x,responsabilities)
    r.soft_clusters
end

get_clusters(r::Result) = Clustering.harden_soft_clusters(get_soft_clusters(r))
get_soft_clusters(r::Result)=r.soft_clusters


function weighted_centroids(m::Model,x::Input,w::Clustering.Soft)
  w2=w.^m.p.fuzzyness
  for i=1:size(m.means,2)
      normalizing_constant=sum(w2[i,:])
      m.means[:,i]=(x*(w2[i,:]'))/normalizing_constant
  end
end


function update_responsibilities(m::Model,x::Input,responsibilities::Clustering.Soft)
  d=pairwise(m.p.metric,m.means,x)

  exponent=1/(1-m.p.fuzzyness)
  #exponent=1/c.fuzzyness
  for i=1:size(x,2)
    fuzzy_distance=d[:,i].^exponent;
    normalizing_constant = sum(fuzzy_distance)
    responsibilities[:,i]=fuzzy_distance
    responsibilities[:,i]/=normalizing_constant
  end
end

function fit(x::Input,p::Parameters)
  means=InitialMeans.initial_means(p.k,x,p.initialization)
  responsibilities=zeros(p.k,size(x,2))
  r=Result(responsibilities)
  m=Model(means,p)
  for j=1:p.iterations
      #println("Updating responsibilties $j,$responsibilities")
      update_responsibilities(m,x,r.soft_clusters)
      #println("Updating centroids $j,$means")
      weighted_centroids(m,x,r.soft_clusters)
      #clusters=harden_soft_clusters(r.soft_clusters)
      #clf()
      #scatter(x=x[1,:],y=x[2,:],c=clusters/c.k,cmap=get_cmap("rainbow"),marker="x")
      #scatter(x=means[1,:],y=means[2,:],c="black",s=30,marker="o")
      #E=energy(r,c,x)
      #println("Energy $E")
      #sleep(0.00001)
  end
  r,m
end

function energy(m::Model,x::Input)
  soft_clusters= get_soft_clusters(m,x)
  d=pairwise(m.p.metric,r.means,x)
  E=0
  for j=1:size(m.means,2)
    for i=1:size(x,2)
        E+=soft_clusters[j,i]^m.p.fuzzyness*d[j,i]
    end
  end
  E
end

end
