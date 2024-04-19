#ifndef GPU_BRANCH_H
#define GPU_BRANCH_H

#include <vector>

class Input{
    int nUmpires;
    int nTeams;
    int nRounds;
    std::vector<std::vector<int>> dist;
    std::vector<std::vector<int>> opponents;
    std::vector<std::vector<std::vector<int>>> games;

public:
    Input();

    ~Input()= default;

    int getnUmpires();

    int getnTeams();

    int getnRounds();

    int getDist(int i, int j);

    int getGame(int round , int gameNr , bool away);

    int getOpponent(int team, int round);
};

#endif