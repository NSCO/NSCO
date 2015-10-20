module Bagging

using Distributions

type Parameters
   modelCount::Integer
   dataProportion::Float64
   build_model::Function
   classify_example::Function
end

type Model
   models::Vector{Any}
   classify_example::Function
end

function sample_data(data::Matrix, labels::Vector{Int}, proportion::Float64)
    (nAttributes,nPatterns) = size(data)
    #idx = floor(rand(nPatterns*proportion) * nPatterns)
    idx = Distributions.sample(1:nPatterns, round(Int, nPatterns*proportion), replace=true)
    return (data[:,idx], labels[idx])
end

function build_model(data::Matrix, labels::Vector{Int}, conf::Parameters)
   models=[]
   for i=1:conf.modelCount
      (sampledData, sampledLabels) = sample_data(data, labels, conf.dataProportion)
      push!(models, conf.build_model(sampledData, sampledLabels))
   end
   return Model(models, conf.classify_example)
end

function classify_example(example, m::Model)
    modelCount = length(m.models)
    predictions = zeros(Int, modelCount)
    for i=1:modelCount
        predictions[i] = m.classify_example(example, m.models[i])
    end    
    (range, histogram) = hist(predictions, 0:maximum(predictions))
    return indmax(histogram)
end

function classify(data::Matrix, model::Model)
  (nAttrs, nExamples) = size(data)
  predictions = zeros(Int, nExamples)
  for i=1:nExamples
    predictions[i] = classify_example(data[:,i], model)
  end
  return predictions
end

end
