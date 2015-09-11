#using DataFrame
module HierarchicalClustering
export single_linkage_configuration, build_model, HierarchicalConfiguration, euclidean_dist,
    complete_linkage_configuration, average_linkage_configuration, ward_linkage_configuration

type Clustering
    assignments :: Array{Int64,1}
end
type HierarchicalConfiguration
    metric::Function
    joining_criterion::Function
    k::Integer
end

function single_linkage(cluster_i::Array{Int64,1}, cluster_j::Array{Int64,1}, data::Matrix, metric::Function)
    dmin = typemax(Int64)
    for i = cluster_i
        for j = cluster_j
            d = metric(data[:,i], data[:,j])
            if (d < dmin)
                dmin = d
            end
        end
    end
    return dmin
end

function complete_linkage(cluster_i::Array{Int64,1}, cluster_j::Array{Int64,1}, data::Matrix, metric::Function)
    dmax = typemin(Int64)
    for i = cluster_i
        for j = cluster_j
            d = metric(data[:,i], data[:,j])
            if (d > dmax)
                dmax = d
            end
        end
    end
    return dmax
end

function average_linkage(cluster_i::Array{Int64,1}, cluster_j::Array{Int64,1}, data::Matrix, metric::Function)
    distances = zeros(length(cluster_i) * length(cluster_j))
    k = 1
    for i=cluster_i
        for j=cluster_j
            distances[k] = metric(data[:,i], data[:,j])
            k += 1
        end
    end
    return mean(distances)
end

function error_sum_squares(cluster_i::Array{Int64,1}, cluster_j::Array{Int64,1}, data::Matrix, metric::Function)
    union = copy(cluster_i)
    append!(union, cluster_j)
    filtered_data = data[:, union]
    (nRows, nCols) = size(filtered_data)
    #sum(X^2) - (sum(X)^2)/n implementation, 11 secs
    sq_errors = sum(filtered_data.^2,2) - (sum(filtered_data, 2).^2)/length(union)

    #reduce implementation, 18 secs
    #sq_errors = zeros(nRows)
    #for i = 1:nRows
        #(vsum, vsumsq) = reduce((p, x) -> (p[1] + x, p[2] + x * x), (0,0), filtered_data[i, :])
        #sq_errors[i] = vsumsq - (vsum^2) / length(union)
    #end

    #X - mean implementation, 13 secs
    #means = mean(filtered_data, 2)
    #sq_errors = sum((filtered_data - repmat(means, 1, nCols)).^2, 2)
    return sum(sq_errors)
end


function single_linkage_configuration(metric::Function,k::Integer)
    return HierarchicalConfiguration(metric, single_linkage, k)
end

function complete_linkage_configuration(metric::Function,k::Integer)
    return HierarchicalConfiguration(metric, complete_linkage, k)
end

function average_linkage_configuration(metric::Function,k::Integer)
    return HierarchicalConfiguration(metric, average_linkage, k)
end

function ward_linkage_configuration(metric::Function,k::Integer)
    return HierarchicalConfiguration(metric, error_sum_squares, k)
end


function euclidean_dist(e1, e2)
    return norm(e1 - e2)
end

function build_model(data::Matrix, conf::HierarchicalConfiguration)
    (nRows, nCols) = size(data)
    assignments = zeros(nRows)
    clusters = Array{Int64,1}[]
    for i=1:nCols
        push!(clusters, [i])
    end
    for c=nCols:-1:conf.k+1
        println(string("clusters=",length(clusters)))
        imin = -1
        jmin = -1
        dmin = typemax(Int64)
        for i=1:c-1
            for j=i+1:c
            #distFun is the joining criterion (single, complete, etc)
            d = conf.joining_criterion(clusters[i], clusters[j], data, conf.metric)
                if (d < dmin)
                    dmin = d
                    imin = i
                    jmin = j
                end
            end
        end
        c1 = clusters[imin]
        c2 = clusters[jmin]
        append!(c1, c2)
        splice!(clusters, jmin)
    end
  return clusters
end

end
