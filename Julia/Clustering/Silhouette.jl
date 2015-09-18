module Silhouette
export silhouette
function average_distance(v,D::Matrix)
    (nAttributes,nPatterns) =size(D)
    sum =0
    for i =1:nPatterns
        sum += norm( D[:,i] - v)
    end
    return sum /nPatterns
end
function min_average_outer_distance(v,D::Matrix,assignments::Array,actual_label)    
    min = typemax(Float64)
    for label in assignments
        if (actual_label != label)
           dist = average_distance(v,D[:,assignments.==label])
           if (dist < min ) 
             min = dist
           end
        end
    end
    return min
end
function silhouette(D::Matrix, assignments::Array)
    (nAttributes,nPatterns) =size(D)
    unique_labels = unique(assignments)
    silhouette_score = zeros(length(assignments))
    for i =1:nPatterns
       label = assignments[i]
       a = average_distance(D[:,i],D[:,assignments.==label])
       b = min_average_outer_distance(D[:,i],D, assignments,label)
       silhouette_score[i] = (b-a)/(max(a,b))
    end   
    silhouette_idx_per_cluster = zeros(length(unique_labels))
    for i=1:length(unique_labels)
        silhouette_idx_per_cluster[i] = mean(silhouette_score[assignments.==unique_labels[i]])
    end
    return (silhouette_score,silhouette_idx_per_cluster)
    
end
end