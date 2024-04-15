#ifndef GPU_BRANCH_H
#define GPU_BRANCH_H

#include <vector>

class input{
    static int nUmpires;
    static int nTeams;
    static int nRounds;
    std::vector<std::vector<int>> dist;
    std::vector<std::vector<int>> opponents;
    //const static int games[][][];

public:
    void init();
    
    int getDist(int i, int j);
};

#endif