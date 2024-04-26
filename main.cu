#include <string>
#include <iostream>
#include <vector>
#include <algorithm>
#include <array>

#include "Input.h"
#include "ReturnType.h"

#define BLOCKS 1
#define THREAD_PER_BLOCK 1


__global__ void treeSearch(Input* in, int a_s[nTeams][nRounds], double costReduction, double dualCostW[nTeams][nRounds]){
    //TODO
    if(in != nullptr){
        
    }
}

//TODO op het einde ook checken of ump op alle locaties geweest is
bool testFeasibility(int currentPath[nRounds][2], int pathSize, int gameIndex, Input const*const in){
//q1:
    for (int q = 0; q < q1 - 1; q++){
        int gameIndexToCompare = pathSize - 1 - q;
        if(in->getGame(pathSize, gameIndex, false) == currentPath[gameIndexToCompare][0]){
            return false;
        }
    }
//q2:
    for (int q = 0; q < q2 - 1; q++){
        int gameIndexToCompare = pathSize - 1 - q;
        if(
                in->getGame(pathSize, gameIndex, false) == currentPath[gameIndexToCompare][0] ||
                in->getGame(pathSize, gameIndex, true ) == currentPath[gameIndexToCompare][0] ||
                in->getGame(pathSize, gameIndex, false) == currentPath[gameIndexToCompare][1] ||
                in->getGame(pathSize, gameIndex, true ) == currentPath[gameIndexToCompare][1]
        ){
            return false;
        }
    }
    return true;
}


void DFS(Input const*const in, int visited[nRounds][2], int amountVisited, double cost, double w[nTeams][nRounds]){
    if (in == nullptr) return;
    if (amountVisited > 0){
        int round = amountVisited - 1;
        cost += w[visited[round][0]][round];
    }
    if (amountVisited < nRounds){
        for (int game = 0; game < nUmpires; game++){
            if (testFeasibility(visited, amountVisited, game, in)){
                DFS(in, visited, amountVisited, cost, w);
            }
        }
    }
}

bool q1_constr(const ReturnType *const toTest){
    if (toTest == nullptr) std::cout << "nog nullptr's q1" << std::endl;
    int locationToTest = toTest->getLocation();
    ReturnType* testing = toTest->getPrevious();
    
    for (int q = 0; q < q1 && testing != nullptr; q++){
        if(testing == nullptr){
            std::cout << "een nullptr" << std::endl;
        }
        if (testing->getLocation() == locationToTest) return false;
        testing = testing->getPrevious();
    }
    return true;
}

bool q2_constr(const ReturnType *const toTest, const Input *const in){
    if (toTest == nullptr) std::cout << "nog nullptr's q2" << std::endl;
    int loc = toTest->getLocation();
    int opponent = in->getOpponent(loc, toTest->getDepth());
    ReturnType* testing = toTest->getPrevious();

    for (int q = 0; q < q2 && testing != nullptr; q++){
        if(testing == nullptr){
            std::cout << "nullptr" << std::endl;
        }
        int loc_this = testing->getLocation();
        int opponent_this = in->getOpponent(loc_this, toTest->getDepth());
        if (loc_this == loc             ||
            loc_this == opponent        ||
            opponent_this == loc        ||
            opponent_this == opponent
        ) {
            return false;
        }
        testing = testing->getPrevious();
    }

    return true;
}

//TODO een cost calc toevoegen
void DFS_new(const Input *const in, ReturnType* ret, const double v, const double w[nTeams][nRounds]){
    if (in == nullptr       ||
        ret == nullptr      ||
        !q1_constr(ret)     ||
        !q2_constr(ret, in)
    ) {
        ret = nullptr;
        return;
    }

    //nRounds - 1 omdat na de laatste ronde niet dieper moeet gegaan worden
    if (ret->getDepth() < nRounds - 1){
        //dieper door gaan
        ReturnType* fromDeeper[10];
        for (int i = 0; i < nTeams/2; i++){
            int next_loc = in->getGame(ret->getDepth()+1, i, false);
            if(ret == nullptr) std::cout << "weeral" << std:: endl;
            fromDeeper[i] = new ReturnType(ret, in->getDist(ret->getLocation(), next_loc), next_loc);
            DFS_new(in, fromDeeper[i], v, w);
        }
        int minDist= 0x7fffffff;
        ret = nullptr;
        for (ReturnType* test: fromDeeper){
            if (test!=nullptr &&
                test->getDistance() < minDist
            ){
                ret = test;
                minDist = test->getDistance();
            }
        }
    }
    //TODO check of elk team bezocht is --> zoniet ret == nullptr
    if (ret->getDepth() == nRounds - 1){
        ReturnType* testing = ret;
        int teamVisited[nTeams];
        for (int i = 0; i < nTeams; i++){
            teamVisited[i] = 0;
        }
        for (int i = 0; i < nRounds; i++){
            if(testing == nullptr){
                std::cout << "testing is a nullptr" << std::endl;
            }
            teamVisited[testing->getLocation()] += 1;
            
            testing = testing->getPrevious();
        }
        //verschillend als 0 gevonden is --> er is een team niet bezocht.
        if (std::end(teamVisited) != std::find(std::begin(teamVisited), std::end(teamVisited), 0)){
            ret = nullptr;
        }
    }
}


int main(){
    std::cout << "hello";
    Input* i = new Input();
    int a_s[nTeams][nRounds];
    for (int i = 0; i < nTeams; i++){
        for (int r = 0; r < nRounds; r++){
            a_s[i][r] = 0;
        }
    }
    double w[nTeams][nRounds];
    for (int i = 0; i < nTeams; i++){
        for (int r = 0; r < nRounds; r++){
            w[i][r] = 0;
        }
    }
    // treeSearch<<<BLOCKS, THREAD_PER_BLOCK>>>(i, a_s, 0, w);
    int visited[nRounds][2];
    for (int r = 0; r < nRounds; r++){
        visited[r][0] = -1;
        visited[r][1] = -1;
    }
    ReturnType* t = new ReturnType(3);
    DFS_new(i, t, 0, w);
    std::cout << "dist: " << t->getDistance() << std::endl;
    delete(t);
}


//GPU-only function: __device__