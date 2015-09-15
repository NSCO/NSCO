module MeanShift
export MeanShiftConfig, build_model, gaussian_window

using PyPlot
using Distributions
using  PDMats 

type MeanShiftConfig
    learning_rate::Float64
    window_size::Float64
    window::Function
end


function build_model(x,c::MeanShiftConfig)
    original_data = deepcopy(x)
    examples=size(x,2)
    ion()
    show()
    for j=0:300
        println(j)
        
        clf()
        axis((0,1,0,1))
                
        scatter(x=original_data[1,:],y=original_data[2,:],color="g",marker="o")
                        
        for i=1:examples                     
            
            x[:,i] = shift(x[:,i],original_data,c)
            
        end
                
        scatter(x=x[1,:],y=x[2,:], color="r",marker="o")
        
        draw()
        pause(0.01)    
    end
    

end


function shift(pattern, x, c::MeanShiftConfig)
    denominator = 0
    numerator   = 0
    examples=size(x,2)
    for i=1:examples
        point=x[:,i]
        estimation = c.window(point,pattern,c.window_size)
        denominator = denominator + estimation
        numerator   = numerator   + estimation*point
    end
    mean_shift = (numerator/denominator) - pattern
    return pattern + c.learning_rate *(mean_shift)
end



function gaussian_window(x,mu,sigma)
    var=IsoNormal(mu, ScalMat(size(x,1),sigma) )
    return pdf(var,x)
end

  
end     
     
