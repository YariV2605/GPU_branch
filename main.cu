#include <string>
#include <iostream>
#include <vector>
#include <algorithm>
#include <array>

#include "Input.h"
#include "ReturnType.h"



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



__global__ void DFS_GPU(const Input in, ReturnType** ret/*, const double v, const double w[nTeams][nRounds]*/){
    int index = threadIdx.x;


    //if infeasible (or incorrect call)
    if (ret == nullptr              ||
        !q1_constr(ret[index])      ||
        !q2_constr(ret[index], in)
    ){
        delete (ret[index]);
        ret[index] = nullptr;
        printf("not branching futher\n");
        __syncthreads();
        return;
    }

    printf("depth: %d\n", ret[index]->getDepth());

    //if not yet at deepest level
    if (ret[index]->getDepth() < nRounds - 1){
        //dynamic allocation in order to be able to pass it to the next level (can't be in local)
        ReturnType** nextNodes = (ReturnType**)malloc(nTeams/2 * sizeof(ReturnType*));

        for (int i = 0; i < nTeams/2; i++){
            int nextLocation = in.getGame(ret[index]->getDepth()+1, i, false);
            nextNodes[i] = new ReturnType(ret[index], in.getDist(ret[index]->getLocation(), nextLocation), nextLocation);
        }

        DFS_GPU<<<1, nTeams/2>>>(in, nextNodes/*, v, w*/);
        
        //set this ret to the best possible (or nullptr if none are possible)
        int minDistance = 0x7fffffff;
        ret[index] = nullptr;
        //wait for results from next level before continuing
        cudaDeviceSynchronize();
        for (int i = 0; i < nTeams/2; i++){
            if (nextNodes[i] != nullptr &&
                nextNodes[i]->getDistance() < minDistance &&
                // nextNodes[i]->getDepth() == nRounds - 1 &&
                beenEverywhere(nextNodes[i])
            ){
                minDistance = nextNodes[i]->getDistance();
                ret[index] = nextNodes[i];
            }
        }
        //delete all unneeded nodes
        for (int i = 0; i < nTeams/2; i++){
            if(nextNodes[i] != ret[index] /*&& nextNodes[i] != nullptr*/){
                delete nextNodes[i];
                // nextNodes[i] = nullptr;
            }
        }
        free (nextNodes);
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



__global__ void test(int* i){
    if(*i < 14){
        printf("%d\n", *i);
        int* j = new int(*i + 1);
        test<<<1, 2>>>(j);
    }
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

    ReturnType** tmp = (ReturnType**) malloc(sizeof(tmp[0]));
    cudaMalloc(&tmp[0], sizeof(tmp[0][0]));

    ReturnType** t_gpu = 0;
    cudaMalloc(&t_gpu, sizeof(t_gpu[0]));
    
    cudaMemcpy(t_gpu, tmp, sizeof(t_gpu[0]), cudaMemcpyHostToDevice);
    cudaMemcpy(tmp[0], t_element, sizeof(t_gpu[0][0]), cudaMemcpyHostToDevice);
    
    free(tmp);



    DFS_GPU<<<1, 1>>>(in, t_gpu/*, 0, w*/);
    cudaDeviceSynchronize();
    std::cout << cudaGetErrorString(cudaGetLastError()) << std::endl;

    //TODO copy mem to CPU

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