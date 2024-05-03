#include <vector>
#define nRounds 14
#define nTeams 8
#define nUmpires 4
#define q1 4
#define q2 2

class Input{
    int dist[nTeams][nTeams] = {
        {    0,  745,  665,  929,  605,  521,  370,  587},
        {  745,    0,   80,  337, 1090,  315,  567,  712},
        {  665,  80 ,    0,  380, 1020,  257,  501,  664},
        {  929, 337 , 380 ,    0, 1380,  408,  622,  646},
        {  605, 1090, 1020, 1380,    0, 1010,  957, 1190},
        {  521,  315,  257,  408, 1010,    0,  253,  410},
        {  370,  567,  501,  622,  957,  253,    0,  250},
        {  587,  712,  664,  646, 1190,  410,  250,    0}
      };;
    int opponents[nRounds][nTeams] = {
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
    int games[nRounds][nTeams/2][2];

public:
    Input();

    // ~Input()= default;

    __device__ int getDist(int i, int j)const;

    __device__ int getGame(int round , int gameNr , bool away)const;

    /**
     * gives the opponent for the given team in the given round, a negative value is given when playing at the opponent, and a positive value when playing at home
     * @param team team index
     * @param round round index
     * @return oponent number (not index)
     */
    __device__ int getOpponent(int team, int round)const;
};