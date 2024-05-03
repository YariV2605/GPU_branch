#include "Input.h"
#include <vector>
#include <iostream>

Input::Input(){
    for(int round = 0; round < nRounds;  round++){
        int i = 0;
        for(int teams = 0; teams < nTeams; teams++) {
            int opp = opponents[round][teams];
            if (opp > 0) {
                games[round][i][0] = teams;
                games[round][i][1] = opp - 1;
                i++;
            }
        }
    }
}


__device__ int Input::getDist(int i, int j)const{
    return dist[i][j];
}

__device__ int Input::getGame(int round, int gameNr, bool away)const{
    return games[round][gameNr][(int)away];
}

__device__ int Input::getOpponent(int team, int round)const{
    return opponents [round][team];
}
