module NaiveBayes
export NaiveBayesConfig, NaiveBayesModel, train, classify

type NaiveBayesConfig
    column_type::Array{Bool}
    laplacian_correction::Bool
end

type NaiveBayesModel
    priors
    label_range
    parameters
    config::NaiveBayesConfig
    posteriors
end

function computemultinomialestimate( data, attr, labels, naive_bayes_model::NaiveBayesModel)
        attrLikelihoods = Dict()
        for c in naive_bayes_model.label_range
            dataOfLabel = data[:, labels .== c]
            attrValues = dataOfLabel[attr,: ]
            attrRange = sort(unique(attrValues))
            likelihoods = Dict()
            for a in attrRange
                likelihoods[a] = sum(attrValues .== a)
            end
            #for each (attr,label) pair we have to store the likelihoods and
            #attr range, both included in the dict
            attrLikelihoods[c] = likelihoods
        end
        return attrLikelihoods
end

function computegaussianestimate( data, attr, labels, naive_bayes_model::NaiveBayesModel)
        attrLikelihoods = Dict()
        for c in naive_bayes_model.label_range
            dataOfLabel = data[:,labels .== c]
            attrMean = mean(dataOfLabel[attr,:])
            attrStd = std(convert(Array{Float64}, dataOfLabel[attr,:]))
            attrLikelihoods[c] = (attrMean, attrStd)
        end
        return attrLikelihoods
end

function computepriors(labels)
        # self.priors = map(lambda c: sum(labels == c), self.labelRange)
        label_range = sort(unique(labels))
        priors = Dict()
        for c in label_range
            priors[c] = sum(labels .== c) / length(labels) #normalized to sum up to 1
        end
        return priors
end

function train(data::Matrix,labels::Array,config::NaiveBayesConfig)
    label_range = sort(unique(labels))
    (nAttrs, nExamples) = size(data)
    #estimate priors P(Ci):
    priors = computepriors(labels)
    naive_bayes_model = NaiveBayesModel(priors,label_range,[],config,[])
    #estimate parameters for likelihood P(Xj | Ci)
    parameters = []

    for attr in range(1, nAttrs)
        if config.column_type[attr]
            #assume it is gaussian, estimate mean and std
            push!(parameters, computegaussianestimate(data, attr, labels, naive_bayes_model))
        else
            #if it is categorical estimate the multinomial probabilities
            #using the proportion of each value of the attribute
            push!(parameters, computemultinomialestimate(data, attr, labels, naive_bayes_model))
        end
    end
    naive_bayes_model.parameters=parameters
    return naive_bayes_model
end

function classify(data::Matrix, model::NaiveBayesModel)
   # P(X|C) = prod(X1|C, X2|C ,..., Xn|C)
   (nAttrs, nExamples) = size(data)
   #predictions = np.zeros((1, nRows))
   predictions = []
   posteriors = zeros(nExamples, length(model.label_range)) #one for each class, have to find the maximum
   for i in range(1, nExamples)
        for c in range(1, length(model.label_range))
            label = model.label_range[c]
            posteriors[i,c] = model.priors[label]
           for a in range(1, nAttrs)
              attrValue = data[a, i]
              if model.config.column_type[a]
                  #calculate using gaussian parameters
                  (mean, std) = model.parameters[a][label]
                  #println(mean)
                  #println(attrValue)
                  prob = 1 / (std * sqrt(2 * pi))
                  prob = prob * exp((-1/2) * ((attrValue - mean) / std)^2)
              else
                  #use the multinomial estimate, i.e. the proportions
                  distribution = model.parameters[a][label]
                  #if attrValue in distribution
                  if haskey(distribution, attrValue)
                      count = distribution[attrValue]
                  else
                      count = 0
                  end
                  if model.config.laplacian_correction
                      prob = (count + 1) / (sum(values(distribution)) + length(distribution))
                  else
                      prob = count / sum(values(distribution))
                  end
              end
              posteriors[i,c] = posteriors[i,c] * prob
           end
       end
      index = indmax(posteriors[i,:])
      push!(predictions, model.label_range[index])
   end
   model.posteriors = posteriors
   return predictions
end

end
