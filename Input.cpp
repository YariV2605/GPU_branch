#include "Input.h"
#include <vector>
#include <iostream>

Input::Input(){
    dist = {
        {    0,  745,  665,  929,  605,  521,  370,  587},
        {  745,    0,   80,  337, 1090,  315,  567,  712},
        {  665,  80 ,    0,  380, 1020,  257,  501,  664},
        {  929, 337 , 380 ,    0, 1380,  408,  622,  646},
        {  605, 1090, 1020, 1380,    0, 1010,  957, 1190},
        {  521,  315,  257,  408, 1010,    0,  253,  410},
        {  370,  567,  501,  622,  957,  253,    0,  250},
        {  587,  712,  664,  646, 1190,  410,  250,    0}
      };

    opponents = {
        { 5  , -6 ,  -7 ,  8 ,  -1 ,  2 ,  3 ,  -4},
        { 6  , 8  , -5  , 7  , 3   ,-1  , -4 ,  -2},
        { 4  , 7  , 8   ,-1  , 6   ,-5  , -2 ,  -3},
        { -6 ,  -8,   7 ,  -5,   4 ,  1 ,  -3,   2},
        { -8 ,  -7,   4 ,  -3,   -6,   5,   2,   1},
        { -7 ,  3 ,  -2 ,  6 ,  -8 ,  -4,   1,   5},
        { 8  , 6  , -4  , 3  , -7  , -2 ,  5 ,  -1},
        { 7  , 4  , 6   ,-2  , 8   ,-3  , -1 ,  -5},
        { -4 ,  -3,   2 ,  1 ,  7  , 8  , -5 ,  -6},
        { -2 ,  1 ,  -6 ,  5 ,  -4 ,  3 ,  -8,   7},
        { -3 ,  5 ,  1  , -8 ,  -2 ,  -7,   6,   4},
        { 2  , -1 ,  5  , -7 ,  -3 ,  -8,   4,   6},
        { 3  , -5 ,  -1 ,  -6,   2 ,  4 ,  8 ,  -7},
        { -5 ,  -4,   -8,   2,   1 ,  7 ,  -6,   3}
    };

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

int Input::getDist(int i, int j)const{
    return dist[i][j];
}

int Input::getGame(int round, int gameNr, bool away)const{
    return games[round][gameNr][(int)away];
}

int Input::getOpponent(int team, int round)const{
    return opponents [round][team];
}
