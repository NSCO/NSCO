module BaggingClassifier

using Distributions

type Parameters
   modelCount::Integer
   modelParameter
   dataProportion::Float64
end

type BaggingClassifier
   models::Vector{Any}
   modelParameter
end

function sample_data(data::Matrix, labels::Vector{Int}, proportion::Float64)
    (nAttributes,nPatterns) = size(data)
    #idx = floor(rand(nPatterns*proportion) * nPatterns)
    idx = Distributions.sample(1:nPatterns, floor(nPatterns*proportion), replace=true)
    return (data[:,idx], labels[idx])
end

function build_model(data::Matrix, labels::Vector{Int}, conf::Parameters)
   models=[]
   for i=1:conf.modelCount
      (sampledData, sampledLabels) = sample_data(data,labels, conf.dataProportion)
      push!(models, build_model(sampledData, classes, modelParameter))
   end
   return BaggingClassifier(models)
end

function classify_example(example, params::BaggingClassifier)
    predictions = zeros(params.modelCount)

    for i=1:conf.modelCount
        predictions[i] = classify_example(example, params.models[i], params.modelParameter)
    end
    (range, histogram) = hist(predictions)
    return indmax(histogram)
end

function classify(data::Matrix, model::BaggingClassifier)
  (nAttrs, nExamples) = size(data)
  predictions = zeros(nExamples)
  for i=1:nExamples
    predictions[i] = classify_example(data[:,i], model)
  end
  return predictions
end

end
