#include <fstream>
#include <iostream>
#include <string>

#include "conv_gold_tiled.cpp"

using namespace std;

template <int OY1, int OY0, int OX1, int OX0, int OC1, int OC0, int IC1, int IC0, int FX, int FY, int STRIDE>
void run_layer(string layer_name){
    std::cout << "Running: " << layer_name << std::endl;
    
    std::ifstream ifmap_file;
    ifmap_file.open("data/" + layer_name + "_ifmap.txt");	

    int16_t ifmap[(OY1*OY0-1)*STRIDE+FY][(OX1*OX0-1)*STRIDE+FX][IC1*IC0];
    for(int i = 0; i < (OY1*OY0-1)*STRIDE+FX; i++){
        for(int j = 0; j < (OX1*OX0-1)*STRIDE+FX; j++){
            for(int k = 0; k < IC1*IC0; k++){
                ifmap_file >> ifmap[i][j][k];
            }
        }
    }

    std::ifstream weights_file;
    weights_file.open("data/" + layer_name + "_weights.txt");
    int16_t weights[FY][FX][IC1*IC0][OC1*OC0];
    for(int i = 0; i < FY; i++){
        for(int j = 0; j < FX; j++){
            for(int k = 0; k < IC1*IC0; k++){
                for(int l = 0; l < OC1*OC0; l++){
                    weights_file >> weights[i][j][k][l];
                }
            }
        }
    }

    int32_t ofmap[OY1*OY0][OX1*OX0][OC1*OC0];
    conv_gold_tiled<OY1, OY0, OX1, OX0, OC1, OC0, IC1, IC0, FX, FY, STRIDE>
      (ifmap, weights, ofmap);          

    std::ofstream ofmap_file;
    ofmap_file.open("data/" + layer_name + "_ofmap.txt");
    for(int i = 0; i < OY1*OY0; i++){
        for(int j = 0; j < OX1*OX0; j++){
            for(int k = 0; k < OC1*OC0; k++){
                ofmap_file << ofmap[i][j][k] << "\n";
            }
        }
    }
    ofmap_file.close();

    
    std::ifstream gold_ofmap_file;
    gold_ofmap_file.open("data/" + layer_name + "_gold_ofmap.txt");
    for(int i = 0; i < OY1*OY0; i++){
        for(int j = 0; j < OX1*OX0; j++){
            for(int k = 0; k < OC1*OC0; k++){
                int32_t tmp;
                gold_ofmap_file >> tmp;

                if(tmp != ofmap[i][j][k]){
                    std::cout << "Error! Output does not match gold" << std::endl;
                    return;
                }
            }
        }
    }

    std::cout << "[OK]" << std::endl;
}

int main(){
  run_layer <8/*OY1*/, 14/*OY0*/, 8/*OX1*/, 14/*OX0*/, 4/*OC1*/, 16/*OC0*/, 1/*IC1*/, 3/*IC0*/, 7/*FX*/,  7/*FY*/, 2/*STRIDE*/> ("layer1");
  run_layer <4/*OY1*/, 14/*OY0*/, 4/*OX1*/, 14/*OX0*/, 4/*OC1*/, 16/*OC0*/, 4/*IC1*/, 16/*IC0*/, 3/*FX*/,  3/*FY*/, 1/*STRIDE*/> ("layer2");
  run_layer <4/*OY1*/, 7/*OY0*/, 4/*OX1*/, 7/*OX0*/, 8/*OC1*/, 16/*OC0*/, 8/*IC1*/, 16/*IC0*/, 3/*FX*/,  3/*FY*/, 1/*STRIDE*/> ("layer3");
}
