module KMeans
#export Parameters,Model, build_model,get_clusters

using Distributions,Distances
using InitialMeans
using Clustering

typealias Input Matrix{Float64}

type Parameters <: Clustering.Parameters
  iterations::Int
  k::Int
  metric::SemiMetric
  initialization::InitialMeans.Method
end

type Model <: Clustering.Model
  means::Input
  p::Parameters
end

type Result <: Clustering.Result
    assignments::Clustering.Hard
end

function get_clusters(r::Result)
  r.assignments
end

function get_clusters(x::Input,m::Model)
   r=Result(zeros(size(x,2)))
   update_assignments(x,m,r)
   r.assignments
end

function update_means(x::Input,m::Model,r::Result)
  m.means[:]=0
  for i=1:size(x,2)
      j=r.assignments[i]
      m.means[:,j]+=x[:,i]
  end

  for j=1:size(m.means,2)
       m.means[:,j]/=(sum(r.assignments.==j)+1)
  end
end

function update_assignments(x::Input,m::Model,r::Result)
  d=pairwise(m.p.metric,m.means,x)
  for i=1:size(x,2)
    #println(indmin(vec(d[:,i])))
    r.assignments[i]=indmin(vec(d[:,i]))
  end
end

function fit(x::Input,p::Parameters)
  means=InitialMeans.initial_means(p.k,x,p.initialization)
  r=Result( zeros(size(x,2)) )
  m=Model(means,p)
  for j=1:p.iterations
      #println(r.assignments)
      update_assignments(x,m,r)
      #println("Updating centroids $j,$(m.means)")
      update_means(x,m,r)
      #clf()
      #clusters=m.assignments
      #scatter(x=x[1,:],y=x[2,:],c=clusters/c.k,cmap=get_cmap("rainbow"),marker="x")
      #scatter(x=m.means[1,:],y=m.means[2,:],c="black",s=30,marker="o")
      #E=energy(m,c,x)
      #println("Energy $E")
      #sleep(0.00001)
  end
  (r,m)
end

function energy(x::Input,m::Model)
  examples=length(m.assignments)
  E=0
  for i=1:examples
      j=m.assignments[i]
      E+= evaluate(m.p.metric,x[:,i],m.means[:,j])
  end
  E
end

end
