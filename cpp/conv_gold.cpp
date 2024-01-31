#include <stdio.h>
#include <cassert>
#include <string.h>
#include <cstdint>

template <int OY, int OX, int OC, int IC, int FY, int FX, int STRIDE>
void conv_gold(int16_t ifmap[(OY-1)*STRIDE+FY][(OX-1)*STRIDE+FX][IC],
               int16_t weight[FY][FX][IC][OC],
               int32_t ofmap[OY][OX][OC]){

	for (int oc = 0; oc < OC; oc++) {
		for (int oy = 0; oy < OY; oy++) {
			for (int ox = 0; ox < OX; ox++) {
				ofmap[oy][ox][oc] = 0;
                for (int ic = 0; ic < IC; ic++) {
					for (int fy = 0; fy < FY; fy++) {
						for (int fx = 0; fx < FX; fx++) {
							ofmap[oy][ox][oc] += 
							(int32_t) ifmap[STRIDE*oy + fy][STRIDE*ox + fx][ic] * 
							(int32_t) weight[fy][fx][ic][oc];
						}}}}}}

}
