module GAP
    export  GapConfig,GapIndexResult,gap,gap_evaluate
    type GapConfig
      numberOfRadomSamples::Integer
      clusterMethod::Function
      mMin::Integer
      mMax::Integer
    end
    type GapIndexResult
         gapIndex
         referenceIndexDesviation
         mMin::Integer
         mMax::Integer
         nPatterns::Integer
    end
    function sum_distance(D::Matrix)
        (nAttributes,nPatterns) =size(D)
        sum =0
        for i =1:nPatterns
            for j=1:nPatterns
                sum += norm( D[:,i] - D[:,j])
            end
        end
        return sum
    end




    function random_sample(data_max,data_min,N,M)
            data_diff = data_max-data_min
            sample = rand(N,M)
            return  (sample.* data_diff) .+ data_min
    end

    function calculate_Wm(D::Matrix, assignments::Array)
        (nAttributes,nPatterns) =size(D)
        unique_labels = unique(assignments)
        gap_score = zeros(length(assignments))
        Wm=0
        for i =1:nPatterns
            label = assignments[i]
            columns_idx=assignments.==label
            data_filtered = D[:,columns_idx]
            dq = sum_distance(data_filtered)
            nq = sum(columns_idx)
            Wm += dq/(2*nq )
        end
        return log(Wm)

    end
    function gap( D::Matrix,config::GapConfig)
        data_max = maximum(D,2)
        data_min = minimum(D,2)

        indexForRealData   = zeros(length(config.mMin:config.mMax))
        indexExpectationForRandomData = zeros(length(config.mMin:config.mMax))
        indexDesviationForRandomData = zeros(length(config.mMin:config.mMax))


        i=1
        for m=config.mMin:config.mMax
            println(string("m=",m))
            labels = config.clusterMethod(D,m)
            wm = calculate_Wm(D,labels)
            indexForRealData[i] = wm


            randomWm = zeros(config.numberOfRadomSamples)
            j=1
            for n=1:config.numberOfRadomSamples
                println(string("     n=",n))
                randomSamples = random_sample(data_max,data_min,size(D,1),size(D,2))
                randomSamplesLabels = config.clusterMethod(randomSamples,m)
                randomWm[j] = calculate_Wm(randomSamples,randomSamplesLabels)
                j=j+1
            end

            indexExpectationForRandomData[i] = mean(randomWm)
            indexDesviationForRandomData[i]  = std(randomWm)
            i=i+1
        end
        return GapIndexResult(indexExpectationForRandomData-indexForRealData,
                              indexDesviationForRandomData,
                              config.mMin,
                              config.mMax,
                              size(D,2))
    end
    function gap_evaluate(result::GapIndexResult)
        optimalK = result.mMin
        desv       = result.referenceIndexDesviation .* sqrt(1+(1/result.nPatterns))
        found=false
        m=1
        while(m<length(result.gapIndex)) && (!found)
           if  (result.gapIndex[m+1]-desv[m+1]) <= result.gapIndex[m]
               found=true
           else
               optimalK=optimalK+1
               m=m+1
           end
        end
        return  optimalK
    end

end
