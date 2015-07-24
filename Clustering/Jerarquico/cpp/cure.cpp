#include <vector>
#include <limits>
#include <functional>
#include <boost/python.hpp>
#include <numpy/ndarrayobject.h>
#include <numpy/ndarraytypes.h>
#include <boost/python/suite/indexing/vector_indexing_suite.hpp>
#include <eigen3/Eigen/Dense>

using namespace Eigen;



using namespace boost::python;

using namespace std;

typedef Eigen::Stride<Eigen::Dynamic, Eigen::Dynamic> DynamicStride;

template <class T>
using PyEigenMat = Eigen::Map<Eigen::Matrix<T,Eigen::Dynamic,Eigen::Dynamic,Eigen::RowMajor>,Eigen::Unaligned, DynamicStride >;
typedef Eigen::Map<Eigen::RowVectorXd>   PyEigenVec;


template <class T>
PyEigenMat<T>         NumpyToEigen(const PyArrayObject* arr)
{

    int nrows  = arr->dimensions[0];
    int ncols = arr->dimensions[1];
    int strideRows = PyArray_STRIDE(arr, 0) / (PyArray_DESCR(arr))->elsize;
    int strideCols = PyArray_STRIDE(arr, 1) / (PyArray_DESCR(arr))->elsize;
    int elemSize   = (PyArray_DESCR(arr))->elsize;
    T* data        = (T*)PyArray_DATA(arr);

    return PyEigenMat<T> (
                data ,
                nrows,
                ncols,
                DynamicStride(strideRows,strideCols)


                );

}
template <class T>
PyEigenMat<T>         NumpyToEigen(const numeric::array & data)
{
    return NumpyToEigen<T>(  reinterpret_cast<PyArrayObject*>(data.ptr()));

}

typedef std::function<double(const Eigen::RowVectorXd & ,const Eigen::RowVectorXd & )> DistFun;
typedef std::function<double(const std::vector<Eigen::RowVectorXd> &, const std::vector<Eigen::RowVectorXd> & , const DistFun &)> LinkageFun;




struct CureCluster
{
    
    vector<Eigen::RowVectorXd> representatives;
    vector<int> exampleIds;
    Eigen::RowVectorXd mean;
    
    CureCluster(const std::vector<Eigen::RowVectorXd> & examples, const std::vector<int> & exampleIds, const Eigen::RowVectorXd & mean) :
        exampleIds(exampleIds),
        representatives(examples),
        mean(mean)
    {
        
    }
    static CureCluster singleton(const Eigen::RowVectorXd & example, int exampleId)
    {
        return CureCluster( {example}, {exampleId}, example);
    }
    
    


}; 

template <class Vector>
void quickDelete( Vector &vec ,int idx )
{
    vec[idx] = vec.back();
    vec.pop_back();
}
struct Cure
{
    int k;
    int cantRep;
    double alpha;
    Cure(int k, int cantRep, double alpha):
        k(k),
        cantRep(cantRep),
        alpha(alpha)
    {
        
        
    }
    
    //generative agglomerative scheme (GAS)
    vector<CureCluster> agglomerativeClustering(const  PyEigenMat<double> & data,  const LinkageFun & linkageFun,  const DistFun & metric) {
        vector<CureCluster> clusters;
        for (int i=0;i<data.rows();i++) {

            clusters.push_back(CureCluster::singleton(data.row(i),i));
        }

        for (int c =data.rows(); c>k;c--) {
            std::cout << c << "\n";
            int imin = -1;
            int jmin = -1;
            double dmin = std::numeric_limits<double>::max();
            for (int i=0;i<c-1;i++) {
                for (int j=i+1;j<c;j++) {
                    double d = linkageFun(clusters[i].representatives, clusters[j].representatives, metric);
                    if (d < dmin) {
                        dmin = d;
                        imin = i;
                        jmin = j;
                    }
                }
            }
               ;
            auto clusNuevo = this->merge(clusters[imin],clusters[jmin],data,metric);
            quickDelete(clusters, std::max(jmin,imin));
            quickDelete(clusters, std::min(jmin,imin));
            clusters.push_back(clusNuevo);
        }
        return clusters;
    }
    int getMaxPoint(const vector<int> & new_examples, const  PyEigenMat<double> & data, const vector<unsigned int> & temp_set)
    {
        int maxPoint = -5;
        double maxDist = -std::numeric_limits<double>::max();
        for (int exampleID : new_examples) {
            double minDist = std::numeric_limits<double>::max();
            for (unsigned int tempId : temp_set) {
                double dist = ( data.row(exampleID) - data.row(tempId)).lpNorm<2>();
                if (dist < minDist) {
                    minDist = dist;
                }
            }
            if (minDist >= maxDist) {
                maxDist = minDist;
                maxPoint = exampleID;
            }
        }

        return maxPoint;
    }
    int getFurtherPointFromMean(const  Eigen::RowVectorXd &new_mean, const std::vector<int> & new_examples, const  PyEigenMat<double>  & data)
    {
        int maxPoint = -5;
        double maxDist = -std::numeric_limits<double>::max();
        for (int exampleId : new_examples) {
            double dist =( data.row(exampleId) - new_mean).lpNorm<2>();
            if (dist >= maxDist) {
                maxDist = dist;
                maxPoint = exampleId;
            }
        }
        return maxPoint;
    }

    CureCluster merge(const CureCluster &c1, const CureCluster &c2, const  PyEigenMat<double> & data,  const DistFun & metric)
    {
        int n1 = c1.exampleIds.size();
        int n2 = c2.exampleIds.size();
        Eigen::RowVectorXd new_mean = (n1*c1.mean + n2*c2.mean)/(n1+n2);
        vector<int> new_examples = c1.exampleIds;
        new_examples.insert(new_examples.end(), c2.exampleIds.cbegin(), c2.exampleIds.cend());

        vector<unsigned int> tempSet;
        tempSet.push_back( this->getFurtherPointFromMean(new_mean, new_examples, data));

        int upperBound = std::min((int)this->cantRep, (int)new_examples.size());
        for (int repId =1;repId < upperBound;repId++) {
            tempSet.push_back( this->getMaxPoint(new_examples, data, tempSet));
        }

        vector<Eigen::RowVectorXd> newRepresentatives  = this->shrinkRepresentatives(data,tempSet, new_mean);
        return CureCluster(newRepresentatives, new_examples, new_mean);
    }
    
    vector<Eigen::RowVectorXd> shrinkRepresentatives(const  PyEigenMat<double> &  representatives,const  vector<unsigned int> &tempSet, const Eigen::RowVectorXd & new_mean)
    {
        vector<Eigen::RowVectorXd> newRepresentatives;
        for (unsigned int i : tempSet) {
            Eigen::RowVectorXd r = representatives.row(i);
            newRepresentatives.push_back( r + alpha * (new_mean - r));
        }
        return newRepresentatives;
    }




};


double euclideanDist(const RowVectorXd & e1,const RowVectorXd & e2) {
    return (e1-e2).lpNorm<2>();
}


double singleDist(const std::vector<RowVectorXd> & clusterI, const std::vector<RowVectorXd> & clusterJ, const DistFun & metric)
{
    double dmin = std::numeric_limits<double>::max();
    for (const RowVectorXd & i : clusterI) {
        for (const RowVectorXd & j : clusterJ) {
            double d = metric(i,j);
            if (d < dmin) {
                dmin = d;
            }
        }
    }
    return dmin;
}



typedef std::vector<int> Cluster;
typedef std::vector<Cluster> AsignacionesPorCluster;
boost::python::list curecpp(const numeric::array & data, int K, int cant_rep, float alpha)
{
    boost::python::list list;

    Cure cure_instance = Cure(K, cant_rep, alpha);

    vector<CureCluster> clusters =  cure_instance.agglomerativeClustering(NumpyToEigen<double>(data), singleDist, euclideanDist) ;


    for (const CureCluster & c : clusters) {
        boost::python::list listCluster;
        for (int id : c.exampleIds) {
            listCluster.append(id);
        }
        list.append(listCluster)       ;
    }
    return list;

}


BOOST_PYTHON_MODULE(curecpp)
{
    
    using namespace boost::python;
    numeric::array::set_module_and_type( "numpy", "ndarray");
    class_<AsignacionesPorCluster>("AsignacionesPorCluster")
            .def(vector_indexing_suite<AsignacionesPorCluster>() );

    class_<Cluster>("Cluster")
            .def(vector_indexing_suite<Cluster>() );
    def("curecpp", curecpp);
}







/*int main(int arch,char**argv)
{
    arma::mat data;
    
    int K = 3;
    int cant_rep = 20;
    double alpha = 0.5;
    cure(data,K,cant_rep,alpha);
    return 0;

}
*/
