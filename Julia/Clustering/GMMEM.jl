module GMMEM

using GMM
using InitialMeans
using Distributions
using MatrixUtil
using Clustering

type Parameters <: Clustering.Parameters
  iterations::Int
  threshold::Float64
  k::Int
  initialization::InitialMeans.Method
end

type Model <: Clustering.Model
  gmm::GMM.Model
end

type Result <: Clustering.Result
    responsibilities::GMM.Responsibilities
end

# Utility functions that call gmm.XXXX so we can use GMMEM.Model as a Clustering.Model without having to extract m.gmm
get_clusters(x::GMM.Input,m::Model)=GMM.get_clusters(x,m.gmm)
get_soft_clusters(x::GMM.Input,m::Model) = GMM.responsibilities(x,m.gmm)
likelihood(x::GMM.Input,m::Model)=GMM.likelihood(x,m.gmm)

get_clusters(r::Result)=GMM.get_clusters(r.responsibilities)
get_soft_clusters(r::Result) =  r.responsibilities
likelihood(r::Result)=GMM.likelihood(r.responsibilities)


function initialize(x::GMM.Input,p::Parameters)
  means=InitialMeans.initial_means(p.k,x,p.initialization)
  d,n=size(x)
  responsibilities=zeros(p.k,n)
  components=[]
  covariance=cov(x')
  default_tita=1.0/float(p.k)
  for i=1:p.k
    mu=means[:,i]
    component=GMM.GaussianComponent(default_tita,Distributions.MvNormal(mu,covariance))
    #println(component.distribution)
    push!(components,component)
  end
  m=Model(GMM.Model(components))
  r=Result(responsibilities)
  r,m
end

function maximization!(x::GMM.Input,m::Model,r::Result)
  k,n = size(r.responsibilities)
  total_responsibilities_per_component = sum(r.responsibilities,2)
  gmm = m.gmm
  for j=1:k
      component = gmm.components[j]
      mu = (x* r.responsibilities[j,:]' )
      component.tita = total_responsibilities_per_component[j]/n
      mu /= total_responsibilities_per_component[j]

      sigma = zeros(size(component.distribution.Σ))
      for i=1:n
        dx=x[:,i]-mu
        sigma+= r.responsibilities[j,i]* (dx * dx')
      end
      sigma/=total_responsibilities_per_component[j]
      gmm.components[j].distribution = MvNormal(vec(mu),sigma)
    end
end

function expectation!(x::GMM.Input,m::Model,r::Result)
  GMM.responsibilities!(x,m.gmm,r.responsibilities)
end


function fit(x::GMM.Input,p::Parameters)
  r,m=initialize(x,p)
  fit!(x,p,m,r)
end

function fit!(x::GMM.Input,p::Parameters,m::Model,r::Result)
  i=1
  expectation!(x,m,r)
  likelihood_act = likelihood(r)
  likelihood_ant = abs(likelihood_act)+ 3 * p.threshold+1
  while i<p.iterations && abs(likelihood_act - likelihood_ant) > p.threshold
      maximization!(x,m,r)
      expectation!(x,m,r)
      likelihood_ant = likelihood_act
      likelihood_act = likelihood(r)
      i=i+1
  end
  r,m
end

end
