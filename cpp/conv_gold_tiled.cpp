#include <stdio.h>
#include <cassert>
#include <string.h>
#include <cstdint>

template <int OY1, int OY0, int OX1, int OX0, int OC1, int OC0, int IC1, int IC0, int FX, int FY, int STRIDE>
void conv_gold_tiled(int16_t ifmap[(OY1*OY0-1)*STRIDE+FY][(OX1*OX0-1)*STRIDE+FX][IC1*IC0],
               int16_t weights[FY][FX][IC1*IC0][OC1*OC0],
               int32_t ofmap[OY1*OY0][OX1*OX0][OC1*OC0]) {


}
