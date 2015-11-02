module GMM
using Clustering
using Distributions
using MatrixUtil

typealias Input Array{Float64,2}
typealias Responsibilities Clustering.Soft

type GaussianComponent
  tita::Float64
  distribution::MvNormal
end

type Model
  components::Vector{GaussianComponent}
end

function likelihood(x::Input,m::Model)
   r=responsibilities(x,m)
   likelihood(r)
end

function likelihood(r::Responsibilities)
  n=Float64(size(r,2))
  result=-sum(log(sum(r,1)))/n
  return result
end


function responsibilities(x::Input,m::Model)
  k=length(m.components)
  d,n=size(x)
  r=zeros(k,n)
  responsibilities!(x,m,r)
  r
end

function responsibilities!(x::Input,m::Model,r::Responsibilities)
  k,n=size(r)
  default_responsibility=1.0/k
  for i=1:n
    for j=1:k
        component=m.components[j]
        r[j,i] = pdf(component.distribution, x[:,i]) * component.tita
    end
    example_responsibility=sum(r[:,i])
    if (example_responsibility<0.0000000000000001)
        r[:,i] =  default_responsibility
    else
        r[:,i]  /=  example_responsibility
    end
  end
end

function get_clusters(x::GMM.Input,m::Model)
  r=responsibilities(x,m)
  get_clusters(r)
end

function get_clusters(r::Responsibilities)
  MatrixUtil.indmaximum2(r,2)
end

function get_means(m::Model)
    if length(m.components)==0
      return []
    end
    d=length(m.components[1].distribution.μ)
    k=length(m.components)
    means=zeros(d,k)
    for i=1:k
      means[:,i]=m.components[i].distribution.μ
    end
    means
end

end
