#ifdef __CUDACC__
#define CUDA_CALLABLE_MEMBER __host__ __device__
#else
#define CUDA_CALLABLE_MEMBER
#endif 


class ReturnType{
    ReturnType* previous;//start: nullptr
    int distance;
    int depth;
    int location;
public:
    __device__ ReturnType(ReturnType* prev, int extraDist, int loc):
        previous(prev),
        distance(prev->distance + extraDist),
        depth(prev->depth + 1),
        location(loc)
    {}
    CUDA_CALLABLE_MEMBER ReturnType(int loc): previous(nullptr), distance(0), depth(0), location(loc){}
    __device__ ReturnType(ReturnType* toCopy): 
        previous(toCopy->previous),
        distance(toCopy->distance),
        depth(toCopy->depth),
        location(toCopy->location)
    {}
    CUDA_CALLABLE_MEMBER ~ReturnType(){}

    __device__ __host__ ReturnType* getPrevious() const{
        return previous;
    }
    __device__ __host__ int getDistance() const{
        return distance;
    }
    __device__ int getDepth() const{
        return depth;
    }
    __device__ __host__ int getLocation() const{
        return location;
    }
};