#include <string>
#include <iostream>
#include <vector>
#include "Input.h"
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
    DFS(i, visited, 0, 0, w);
}