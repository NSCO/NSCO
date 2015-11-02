module Clustering
export fit,get_clusters,get_soft_clusters,Soft,Hard
using MatrixUtil

abstract Model
abstract Parameters
fit(x::Any,m::Parameters) = error("fit not implemented #= … =#") #::(Result,Model)
get_clusters(x::Any,m::Model) = error("get_clusters(x::Any,m::Model) not implemented #= … =#") #::Hard
get_soft_clusters(x::Any,m::Model) = error("get_soft_clusters(x::Any,m::Model) not implemented #= … =#")   #::Soft

abstract Result
get_clusters(r::Result) = error("get_clusters(r::Result) not implemented #= … =#") #::Hard
get_soft_clusters(r::Result) =error("get_soft_clusters(r::Result) not implemented #= …=#")  #::Soft

typealias Soft Matrix{Float64}
typealias Hard Vector{Int}
typealias FloatInput Matrix{Float64}

function harden_soft_clusters(soft_clusters::Soft)
  clusters=MatrixUtil.indmaximum(soft_clusters,2)
  clusters=[ c[1] for c in clusters]
  clusters
end
#k= number of clusters
function soften_hard_clusters(clusters::Hard,k::Int)
  n=length(clusters)
  soft_clusters=zeros(k,n)
  for i=1:n
    soft_clusters[clusters[i],i]=1
  end
  soft_clusterss
end


end
