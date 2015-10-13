using Distributions

function error_upper_bound(e::Integer, n::Integer, c::Float64)
  # e is the number of successes (or failures)
  # n is the number of runs of the experiment (size of the sample)
  #f = e/n is the proportion of successes (or failures)
  # 1 - c is the confidence level of the test
  # P (x < z) = 1 - c
  # or
  # P (x > z) = c
  f = e/n
  z = (quantile(Normal(), 1-c))
  #println(string("f=", f))
  #println(string("z=", z))
  return (f + (z*z / 2n) + z * sqrt(f*(1-f)/n + z*z/(4n*n))) / (z*z/n + 1)
end

function classification_error(label_hist::Array{Int,1}, c::Float64)
  selected_label = indmax(label_hist)
  sample_size = sum(label_hist)
  errors = sample_size - label_hist[selected_label]
  error_proportion = errors / sample_size
  return (error_proportion, error_upper_bound(errors, sample_size, c))
end

function compare_parent_and_children(parent::Array{Int,1}, children::Array{Array{Int,1},1}, c::Float64)
  #parent and all children are lists with the quantities of elements for each label
  #all list measure the same
  #it is assumed that the sum of all children are equal to the parent.
  (parent_error, parent_error_estimate) = classification_error(parent, c)
  children_error = zeros(length(children))
  partition_error = 0 #weighted sum of all children error
  for i=1:length(children)
    child = children[i]
    (error, estimate) = classification_error(child, c)
    children_error[i] = estimate
    #println(string("estimate=", estimate))
    #println(string("sum(child)=", sum(child)))
    partition_error += (sum(child)) * children_error[i]
  end
  partition_error /= sum(parent)
  (parent_error_estimate, partition_error)
end
