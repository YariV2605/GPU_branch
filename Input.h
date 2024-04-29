#include <vector>
#define nRounds 14
#define nTeams 8
#define nUmpires 4
#define q1 4
#define q2 2

class Input{
    std::vector<std::vector<int>> dist;
    std::vector<std::vector<int>> opponents;
    int games[nRounds][nTeams/2][2];

public:
    Input();

    ~Input()= default;

    int getDist(int i, int j)const;

    int getGame(int round , int gameNr , bool away)const;

    /**
     * gives the opponent for the given team in the given round, a negative value is given when playing at the opponent, and a positive value when playing at home
     * @param team team index
     * @param round round index
     * @return oponent number (not index)
     */
    int getOpponent(int team, int round)const;
};