#ifndef GPU_BRANCH_H
#define GPU_BRANCH_H

#include <vector>

class Input{
    int nUmpires = 0;
    int nTeams = 0;
    int nRounds = 0;
    int q1 = 0;
    int q2 = 0;
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

    /**
     * gives the opponent for the given team in the given round, a negative value is given when playing at the opponent, and a positive value when playing at home
     * @param team team index
     * @param round round index
     * @return oponent number (not index)
     */
    int getOpponent(int team, int round);
};

#endif