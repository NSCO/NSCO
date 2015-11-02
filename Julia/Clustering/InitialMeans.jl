module InitialMeans

using Distributions
using Clustering
abstract Method


type Random <: Method end
type SampleRandom <: Method end

function initial_means(k::Int,x::Clustering.FloatInput,i::Random)
  indices=Distributions.sample(1:size(x,2),k,replace=false)
  means=copy(x[:,indices])
  means+=rand(size(means))*0.1
  means
end
function initial_means(k::Int,x::Clustering.FloatInput,i::SampleRandom)
    rand(size(x,1),k)
end

function means_from_clustering(x::Clustering.FloatInput,clustering::Clustering.Hard)
  mean_ids=sort(unique(clustering))
  if length(mean_ids)>0 && mean_ids[1]==0
    deleteat!(mean_ids,1)
  end
  means=zeros(size(x,1),length(mean_ids))
  for i=1:length(mean_ids)
      mean_id=mean_ids[i]
      means[:,i]=mean(x[:,clustering.==mean_id])
  end
  means
end

end
