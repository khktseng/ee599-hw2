#include <fstream>
#include <iostream>
#include <string>

#include "conv_gold.cpp"

using namespace std;

template <int OY, 
          int OX, 
          int OC, 
          int IC, 
          int FX, 
          int FY, 
          int STRIDE>
void run_layer(string layer_name){
    std::cout << "Running: " << layer_name << std::endl;
    
    std::ifstream ifmap_file;
    ifmap_file.open("data/" + layer_name + "_ifmap.txt");

    int16_t ifmap[(OY-1)*STRIDE+FY][(OX-1)*STRIDE+FX][IC];
    for(int i = 0; i < (OY-1)*STRIDE+FY; i++){
        for(int j = 0; j < (OX-1)*STRIDE+FX; j++){
            for(int k = 0; k < IC; k++){
                ifmap_file >> ifmap[i][j][k];
            }
        }
    }

    std::ifstream weights_file;
    weights_file.open("data/" + layer_name + "_weights.txt");
    int16_t weights[FY][FX][IC][OC];
    for(int i = 0; i < FY; i++){
        for(int j = 0; j < FX; j++){
            for(int k = 0; k < IC; k++){
                for(int l = 0; l < OC; l++){
                    weights_file >> weights[i][j][k][l];
                }
            }
        }
    }

    int32_t ofmap[OY][OX][OC];
    conv_gold<OY, OX, OC, IC, FY, FX, STRIDE>(ifmap, weights, ofmap);

    std::ofstream ofmap_file;
    ofmap_file.open("data/" + layer_name + "_ofmap.txt");
    for(int i = 0; i < OY; i++){
        for(int j = 0; j < OX; j++){
            for(int k = 0; k < OC; k++){
                ofmap_file << ofmap[i][j][k] << "\n";
            }
        }
    }
    ofmap_file.close();

    
    std::ifstream gold_ofmap_file;
    gold_ofmap_file.open("data/" + layer_name + "_gold_ofmap.txt");
    for(int i = 0; i < OY; i++){
        for(int j = 0; j < OX; j++){
            for(int k = 0; k < OC; k++){
                int32_t tmp;
                gold_ofmap_file >> tmp;

                if(tmp != ofmap[i][j][k]){
			
			printf("i=%d, j=%d, k=%d, tmp=%d, ofmap=%d\n", i, j, k, tmp, ofmap[i][j][k]);

                    std::cout << "Error! Output does not match gold" << std::endl;
                    return;
                }
            }
        }
    }

    std::cout << "[OK]" << std::endl;
}

int main(){
  run_layer<112, 112, 64, 3, 7, 7, 2>("layer1");
  run_layer<56, 56, 64, 64, 3, 3, 1>("layer2");
  run_layer<28, 28, 128, 128, 3, 3, 1>("layer3");
}
