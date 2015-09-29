module Dunn
export dunn
function clusters_dissimilarity(cl1::Matrix,cl2::Matrix)
  (nAttributesCluster1,nPatternsCluster1) =size(cl1)
  (nAttributesCluster2,nPatternsCluster2) =size(cl2)
  minDist = typemax(Float64)
  for i=1:nPatternsCluster1
    for j=1:nPatternsCluster2
      dist = norm(cl1[:,i]-cl2[:,j])
      if (dist  < minDist)
        minDist = dist
      end
    end
  end
  return minDist
end
function cluster_diamater(D::Matrix)
  (nAttributes,nPatterns) =size(D)
  maxDistance = -1
  for i=1:nPatterns-1
    for j=i+1:nPatterns
      dist = norm(D[:,i]-D[:,j])
      if (maxDistance <  dist)
        maxDistance = dist
      end
    end
  end
  return maxDistance
end
function max_diameter(D::Matrix, assignments::Array)
  (nAttributes,nPatterns) =size(D)
  unique_labels = unique(assignments)
  maxDiameter = typemin(Float64)
  for label in length(unique_labels)
    diameter = cluster_diamater(D[:,assignments.==label])
    if (maxDiameter <  diameter)
      maxDiameter = diameter
    end
  end
  return maxDiameter
end
function dunn(D::Matrix, assignments::Array)
    (nAttributes,nPatterns) =size(D)
    unique_labels = unique(assignments)
    maxDiameter = max_diameter(D,assignments)

    minDunnIndex = typemax(Float64)
    for i=1:length(unique_labels)-1
       for j=i+1:length(unique_labels)
           cluster1 = D[:,assignments.==unique_labels[i]]
           cluster2 = D[:,assignments.==unique_labels[j]]
           dunnIndex = clusters_dissimilarity(cluster1,cluster2)/maxDiameter
           if (dunnIndex < minDunnIndex )
               minDunnIndex = dunnIndex
           end
       end
    end
  return minDunnIndex


end
end
