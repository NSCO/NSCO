module ClassificationUtils

function confusionmatrix(real, pred)
  real_range = unique(real)
  pred_range = unique(pred)
  conf_matrix = zeros(length(pred_range) + 1, length(real_range) + 1)
  #count hits and misses
  for i = 1:length(pred_range)
    for j = 1:length(real_range)
      conf_matrix[i,j] = sum((pred .== pred_range[i]) & (real .== real_range[j]))
    end
  end
  #class precision, recall and accuracy
  for i = 1:length(real_range)
    #precision
    conf_matrix[i, end] = conf_matrix[i,i] / sum(conf_matrix[i,:])
    #recall
    conf_matrix[end, i] = conf_matrix[i,i] / sum(conf_matrix[:,i])
    #accumulate hits for accuracy
    conf_matrix[end, end] += conf_matrix[i,i]
  end
  #normalize accuracy
  conf_matrix[end, end] /= length(real)  
  return conf_matrix
end

end
