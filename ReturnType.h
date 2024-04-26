class ReturnType{
    ReturnType* previous;//start: nullptr
    int distance;
    int depth;
    int location;
public:
    ReturnType(ReturnType* prev, int extraDist, int loc):
        previous(prev),
        distance(prev->distance + extraDist),
        depth(prev->depth + 1),
        location(loc)
    {}
    ReturnType(int loc): previous(nullptr), distance(0), depth(0), location(loc){}
    ~ReturnType(){
        if(previous != nullptr)
            delete previous;
    }

    ReturnType* getPrevious() const{
        return previous;
    }
    int getDistance() const{
        return distance;
    }
    int getDepth() const{
        return depth;
    }
    int getLocation() const{
        return location;
    }
};