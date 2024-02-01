#include <stdio.h>
#include <cassert>
#include <string.h>
#include <cstdint>

template <int OY1, int OY0, int OX1, int OX0, int OC1, int OC0, int IC1, int IC0, int FX, int FY, int STRIDE>
void conv_gold_tiled(int16_t ifmap[(OY1*OY0-1)*STRIDE+FY][(OX1*OX0-1)*STRIDE+FX][IC1*IC0],
               int16_t weights[FY][FX][IC1*IC0][OC1*OC0],
               int32_t ofmap[OY1*OY0][OX1*OX0][OC1*OC0]) {

	for (int i = 0; i < OY1*OY0; i++) {
		for (int j = 0; j < OX1*OX0; j++) {
			for (int k = 0; k < OC1*OC0; k++) {
				ofmap[i][j][k] = 0;
			}
		}
	}

    // OY1, OX1, OC1, IC1, FY, FX, OY0, OX0, OC0, IC0
    for (int oy1 = 0; oy1 < OY1; oy1++) {
        for (int ox1 = 0; ox1 < OX1; ox1++) {
            for (int oc1 = 0; oc1 < OC1; oc1++) {
                for (int ic1 = 0; ic1 < IC1; ic1++) {
                    for (int fy = 0; fy < FY; fy++) {
                        for (int fx = 0; fx < FX; fx++) {
                            for (int oy0 = 0; oy0 < OY0; oy0++) {
                                for (int ox0 = 0; ox0 < OX0; ox0++) {
                                    for (int oc0 = 0; oc0 < OC0; oc0++) { // unrolled
                                        int oy = oy1*OY0 + oy0;
                                        int ox = ox1*OX0 + ox0;
                                        int oc = oc1*OC0 + oc0;
                                        for(int ic0 = 0; ic0 < IC0; ic0++) { // unrolled
                                            int ic = ic1*IC0 + ic0;

											ofmap[oy][ox][oc] += 
											(int32_t) ifmap[STRIDE*oy + fy][STRIDE*ox + fx][ic] * 
											(int32_t) weights[fy][fx][ic][oc];
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
}
