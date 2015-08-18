# -*- coding: utf-8 -*-
"""
Created on Tue Aug 18 12:19:57 2015

@author: geraq
"""
import numpy as np

class GaussianDistribution:
    def __init__(self, mu, sigma):
        self.mu = mu            
        self.sigma = sigma

# labels are assumed to be 1-based integers
class NaiveBayes:        
    
    def computeMultinomialEstimate(self, data, attr, labels):           
        attrLikelihoods = {}
        for c in self.labelRange:
            dataOfLabel = data[labels == c,:]
            attrValues = dataOfLabel[:, attr]
            attrRange = np.sort(np.unique(attrValues))
            likelihoods = {}
            for a in attrRange:
                likelihoods[a] = sum(attrValues == a)
            #for each (attr,label) pair we have to store the likelihoods and 
            #attr range, both included in the dict
            attrLikelihoods[c] = likelihoods
        return attrLikelihoods
        
    def computeGaussianEstimate(self, data, attr, labels):        
        attrLikelihoods = {}
        for c in self.labelRange:
            dataOfLabel = data[labels == c,:]
            attrMean = np.mean(dataOfLabel[:,attr])
            attrStd = np.std(dataOfLabel[:,attr])
            attrLikelihoods[c] = GaussianDistribution(attrMean, attrStd)
        return attrLikelihoods    
    
    def computePriors(self, labels):   
        # self.priors = map(lambda c: sum(labels == c), self.labelRange)                   
        priors = {}
        for c in self.labelRange:            
            priors[c] = sum(labels == c) / float(len(labels)) #normalized to sum up to 1         
        return priors
    
    def train(self, data, labels, attrIsNumeric):
        self.attrIsNumeric = attrIsNumeric
        self.labelRange = np.sort(np.unique(labels))
        (nExamples, nAttrs) = np.shape(data)        
        #estimate priors P(Ci):
        self.priors = self.computePriors(labels);
        #estimate parameters for likelihood P(Xj | Ci)
        self.parameters = []
        for attr in range(0, nAttrs):
            if attrIsNumeric[attr]:
                #assume it is gaussian, estimate mean and std
                self.parameters.append(self.computeGaussianEstimate(data, attr, labels))    
            else:
                #if it is categorical estimate the multinomial probabilities 
                #using the proportion of each value of the attribute                
                self.parameters.append(self.computeMultinomialEstimate(data, attr, labels))    
            
    def test(self, data, useLaplaceCorrection):
       # P(X|C) = prod(X1|C, X2|C ,..., Xn|C)          
       (nRows, nCols) = np.shape(data)
       #predictions = np.zeros((1, nRows))
       predictions = []
       self.posteriors = np.zeros((nRows, len(self.labelRange))) #one for each class, have to find the maximum
       for i in range(0, nRows):                      
           for c in range(0, len(self.labelRange)):
               label = self.labelRange[c]
               self.posteriors[i,c] = self.priors[label]
               for a in range(0, nCols):
                  attrValue = data[i, a]
                  if self.attrIsNumeric[a]:
                      #calculate using gaussian parameters
                      gaussian = self.parameters[a][label]
                      prob = 1 / (gaussian.sigma * np.sqrt(2 * np.pi))
                      prob = prob * np.exp((-1.0/2.0) * ((attrValue - gaussian.mu) / gaussian.sigma)**2)
                  else:                          
                      #use the multinomial estimate, i.e. the proportions
                      distribution = self.parameters[a][label]
                      if attrValue in distribution:
                          count = distribution[attrValue]
                      else:
                          count = 0
                      if useLaplaceCorrection:                         
                          prob = (count + 1) / float(sum(distribution.values()) + len(distribution))   
                      else:                   
                          prob = count / float(sum(distribution.values()))                  
                  self.posteriors[i,c] = self.posteriors[i,c] * prob
           index = np.argmax(self.posteriors[i,:])
           #predictions[0, i] = self.labelRange[index]
           predictions.append(self.labelRange[index])
       return predictions           
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
        