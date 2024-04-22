#include <string>
#include <iostream>
#include <vector>
#include "Input.h"
#define BLOCKS 1
#define THREAD_PER_BLOCK 1
#define nTeams 20
#define nRounds 38
#define nUmpires 10

__global__ void treeSearch(Input* in, int a_s[nTeams][nRounds], double costReduction, double dualCostW[nTeams][nRounds]){
    //TODO
    if(in != nullptr){
        
    }
}

int main(){
    Input* i = new Input();
    int a_s[nTeams][nRounds];
    for (int i = 0; i < nTeams; i++){
        for (int r = 0; r < nRounds; r++){
            a_s[i][r] = 0;
        }
    }
    int w[nTeams][nRounds];
    for (int i = 0; i < nTeams; i++){
        for (int r = 0; r < nRounds; r++){
            w[i][r] = 0;
        }
    }
    treeSearch<<<BLOCKS, THREAD_PER_BLOCK>>>(i, 0, a_s, 0);
}


void DFS(Input const*const in, std::vector<int[2]> visited, double cost, int[nTeams][nRounds]& w){
    if (in == nullptr) return;
    int round = visited.lenth() - 1
    cost += w[visited[round][0]][round];
    for (int game = 0; game < nUmpires; game++){
        if (testFeasibility()){
            DFS(in, visited, cost, w);
        }
    }
}
//TODO op het einde ook checken of ump op alle locaties geweest is
bool testFeasibility(std::vector<int[2]> currentPath, int gameIndex, Input const*const in){
//q1:
    for (int q = 0; q < q1 - 1; q++){
        if(in->getGame(currentPath.length(), gameIndex, false) == currentPath.get(currentPath.length() - 1 - q)){
            return false;
        }
    }
//q2:
    for (int q = 0; q < q2 - 1; q++){
        int gameIndexToCompare = currentPath.length() - 1 - q;
        if(
                in->getGame(currentPath.length(), gameIndex, false) == currentPath[gameIndexToCompare][0] ||
                in->getGame(currentPath.length(), gameIndex, true ) == currentPath[gameIndexToCompare][0] ||
                in->getGame(currentPath.length(), gameIndex, false) == currentPath[gameIndexToCompare][1] ||
                in->getGame(currentPath.length(), gameIndex, true ) == currentPath[gameIndexToCompare][1]
        ){
            return false;
        }
    }
    return true;
}