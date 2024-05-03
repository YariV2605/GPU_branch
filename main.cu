#include <string>
#include <iostream>
#include <vector>
#include <algorithm>
#include <array>

#include "Input.h"
#include "ReturnType.h"

#define BLOCKS 1
#define THREAD_PER_BLOCK 1




//TODO op het einde ook checken of ump op alle locaties geweest is
// bool testFeasibility(int currentPath[nRounds][2], int pathSize, int gameIndex, Input const*const in){
// //q1:
//     for (int q = 0; q < q1 - 1; q++){
//         int gameIndexToCompare = pathSize - 1 - q;
//         if(in->getGame(pathSize, gameIndex, false) == currentPath[gameIndexToCompare][0]){
//             return false;
//         }
//     }
// //q2:
//     for (int q = 0; q < q2 - 1; q++){
//         int gameIndexToCompare = pathSize - 1 - q;
//         if(
//                 in->getGame(pathSize, gameIndex, false) == currentPath[gameIndexToCompare][0] ||
//                 in->getGame(pathSize, gameIndex, true ) == currentPath[gameIndexToCompare][0] ||
//                 in->getGame(pathSize, gameIndex, false) == currentPath[gameIndexToCompare][1] ||
//                 in->getGame(pathSize, gameIndex, true ) == currentPath[gameIndexToCompare][1]
//         ){
//             return false;
//         }
//     }
//     return true;
// }

__device__ bool q1_constr(const ReturnType *const toTest){
    int locationToTest = toTest->getLocation();
    ReturnType* testing = toTest->getPrevious();
    
    for (int q = 0; q < q1 && testing != nullptr; q++){
        if (testing->getLocation() == locationToTest) return false;
        testing = testing->getPrevious();
    }
    return true;
}

__device__ bool q2_constr(const ReturnType *const toTest, const Input in){
    int loc = toTest->getLocation();
    int opponent = in.getOpponent(loc, toTest->getDepth());
    ReturnType* testing = toTest->getPrevious();

    for (int q = 0; q < q2 && testing != nullptr; q++){
        int loc_this = testing->getLocation();
        int opponent_this = in.getOpponent(loc_this, toTest->getDepth());
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

__device__ bool beenEverywhere(ReturnType* toTest) {
    if (toTest->getDepth() == nRounds - 1){
        ReturnType* testing = new ReturnType(toTest);
        int teamVisited[nTeams];
        for (int i = 0; i < nTeams; i++){
            teamVisited[i] = 0;
        }
        for (int i = 0; i < nRounds; i++){
            teamVisited[testing->getLocation()] += 1;
            
            testing = testing->getPrevious();
        }
        //verschillend als 0 gevonden is --> er is een team niet bezocht.
        for (int i = 0; i < nTeams; i++){
            if (teamVisited[i] == 0){
                return false;
            }
        }
        return true;
    }
    return true;
}

//WERKT NIET!!!!!
// void DFS_new(const Input *const in, ReturnType** ret, const double v, const double w[nTeams][nRounds]){
//     if (in == nullptr       ||
//         ret == nullptr      ||
//         !q1_constr(*ret)     ||
//         !q2_constr(*ret, in)
//     ) {
//         ret = nullptr;
//         return;
//     }

//     //nRounds - 1 omdat na de laatste ronde niet dieper moeet gegaan worden
//     if ((*ret)->getDepth() < nRounds - 1){
//         //dieper door gaan
//         ReturnType* fromDeeper[nTeams/2];
//         for (int i = 0; i < nTeams/2; i++){
//             int next_loc = in->getGame((*ret)->getDepth()+1, i, false);
//             if(ret == nullptr) std::cout << "weeral" << std:: endl;
//             fromDeeper[i] = new ReturnType(*ret, in->getDist((*ret)->getLocation(), next_loc), next_loc);
//             DFS_new(in, &fromDeeper[i], v, w);
//         }
//         int minDist= 0x7fffffff;
//         *ret = nullptr;
//         for (ReturnType* test: fromDeeper){
//             //FIXME een probleem met get Distance die wordt uitgevoerd op ongeldig memory ?? opgelost door een copyConstructor ??
//             if (test!=nullptr &&
//                 test->getDistance() < minDist &&
//                 beenEverywhere(test)
//             ){
//                 *ret = test;
//                 minDist = test->getDistance();
//             }
//         }
//     }
// }



__global__ void DFS_GPU(const Input in, ReturnType** ret, const double v, const double w[nTeams][nRounds]){
    //FIXME ret[0] is een illegal memory acces, cuda malloc zal dus niet werken zoals ik bedoeld had.
    printf("%d", ret[0]);
    int index = threadIdx.x;


    //if infesible (or incorrect call)
    if (ret == nullptr              ||
        !q1_constr(ret[index])      ||
        !q2_constr(ret[index], in)
    ){
        delete (ret[index]);
        ret[index] = nullptr;
        __syncthreads();
        return;
    }

    printf("depth: %d", ret[index]->getDepth());

    //if not yet at deepest level
    if (ret[index]->getDepth() < nRounds - 1){
        ReturnType* nextNodes[nTeams/2];
        ReturnType** nextNodes_gpu = nullptr;

        for (int i = 0; i < nTeams/2; i++){
            int nextLocation = in.getGame(ret[index]->getDepth()+1, i, false);
            nextNodes[i] = new ReturnType(ret[index], in.getDist(ret[index]->getLocation(), nextLocation), nextLocation);
        }

        DFS_GPU<<<1, nTeams/2>>>(in, nextNodes_gpu, v, w);
        
        //set this ret to the best possible (or nullptr if none are possible)
        int minDistance = 0x7fffffff;
        ret[index] = nullptr;
        //wait for results from next level before continuing
        cudaDeviceSynchronize();
        for (int i = 0; i < nTeams/2; i++){
            if (nextNodes[i] != nullptr &&
                nextNodes[i]->getDistance() < minDistance &&
                beenEverywhere(nextNodes[i])
            ){
                minDistance = nextNodes[i]->getDistance();
                ret[index] = nextNodes[i];
            }
        }
        //delete all unneeded nodes
        for (int i = 0; i < nTeams/2; i++){
            if(nextNodes[i] != ret[index]){
                delete nextNodes[i];
            }
        }
    }
    //reached last node
    if (ret[index]->getDepth() == nRounds - 1){
        if(!beenEverywhere(ret[index])) {
            delete (ret[index]);
            ret[index] = nullptr;
            __syncthreads();
            return;
        }
    }
    __syncthreads();
}



int main(){
    Input in = Input();
    double w[nTeams][nRounds];
    for (int i = 0; i < nTeams; i++){
        for (int r = 0; r < nRounds; r++){
            w[i][r] = 0;
        }
    }
    ReturnType* t_element = new ReturnType(3);
    ReturnType* t_element_gpu;
    ReturnType** t_gpu;


    //FIXME
    cudaMalloc(&t_element_gpu, 1*sizeof(ReturnType));//deze array zal maar 1 element groot zijn
    cudaMemcpy(t_element_gpu, t_element, sizeof(ReturnType), cudaMemcpyHostToDevice);

    cudaMalloc(&t_gpu, 1*sizeof(ReturnType*));
    cudaMemcpy(t_gpu, &t_element, sizeof(ReturnType*), cudaMemcpyHostToDevice);



    DFS_GPU<<<1, 1>>>(in, &t_element_gpu, 0, w);
    cudaDeviceSynchronize();
    std::cout << cudaGetErrorString(cudaGetLastError()) << std::endl;

    cudaMemcpy(t_element, t_element_gpu, sizeof(ReturnType), cudaMemcpyDeviceToHost);

    ReturnType* a = t_element;
    std::cout << "dist: " << t_element->getDistance() << std::endl;
    std::cout << t_element->getLocation() << " ";
    while (t_element->getPrevious() != nullptr){
        t_element = t_element->getPrevious();
        std::cout << t_element->getLocation() << " ";
    }
    std::cout << std::endl;
    delete(a);
}