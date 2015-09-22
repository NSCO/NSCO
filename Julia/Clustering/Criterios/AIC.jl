push!(LOAD_PATH,dirname(@__FILE__))
push!(LOAD_PATH,joinpath(dirname(@__FILE__),"../../Datasets/"))
push!(LOAD_PATH,joinpath(dirname(@__FILE__),"../"))
module AIC
import Distributions
import ClusterModelModule
cm = ClusterModelModule

export aic_centroid

function aic_centroid(c::cm.ClusterModel, data::Matrix)
    #the cluster model has only the centroids of the clusters.
    #as hard clustering is being used, the likelihood is calculated over
    #a 'hard' mixture of gaussians, i.e. each cluster probability model is
    #applied over its respective sample.
    #AIC(m) = -2 log_likelihood(m) + 2*size(m)
    (nAttrs, nExamples) = size(data)
    nClusters = size(c.centroids, 2)
    covs = Array{Matrix}(nClusters)
    likelihood = 0
    for i=1:nClusters
      #estimate the covariance matrices for each cluster
      sample = data[:, c.assignments .== i]
      if size(sample,2) > 1
        covs[i] = cov(sample')
        if (!isposdef(covs[i]))
          println(size(sample))
          println(covs[i])
          println(sample)
        else
          #the parameters are used to calculate the likelihood of the model
          distribution = Distributions.MvNormal(c.centroids[:,i], covs[i])
          probs = Distributions.pdf(distribution, sample)
          likelihood += sum(probs)
        end
      end
    end
    #as we try to minimize the criteria, we try to maximize the likelihood
    score = -2 * log(likelihood)
    #consider the complexity of the model, we try to minimize its size
    score += 2 * prod(size(c.centroids))
    #score += 2 * (prod(size(c.centroids)) + nClusters * nAttrs * nAttrs)
    return score
end

end
