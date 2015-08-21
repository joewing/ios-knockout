
#import "level.h"

static Level levels[] = {

#include "../levels/level1.lvl"
#include "../levels/level2.lvl"
#include "../levels/level3.lvl"
#include "../levels/level4.lvl"
#include "../levels/level5.lvl"
#ifndef LITE_VERSION
#include "../levels/level6.lvl"
#include "../levels/level7.lvl"
#include "../levels/level8.lvl"
#include "../levels/level9.lvl"
#include "../levels/level10.lvl"
#include "../levels/level11.lvl"
#include "../levels/level12.lvl"
#include "../levels/level13.lvl"
#include "../levels/level14.lvl"
#include "../levels/level15.lvl"
#include "../levels/level16.lvl"
#include "../levels/level17.lvl"
#include "../levels/level18.lvl"
#include "../levels/level19.lvl"
#include "../levels/level20.lvl"
#include "../levels/level21.lvl"
#include "../levels/level22.lvl"
#include "../levels/level23.lvl"
#include "../levels/level24.lvl"
#include "../levels/level25.lvl"
#include "../levels/level26.lvl"
#include "../levels/level27.lvl"
#include "../levels/level28.lvl"
#include "../levels/level29.lvl"
#include "../levels/level30.lvl"
#endif // LITE_VERSION

};

const unsigned int max_level = (unsigned int)(sizeof(levels) / sizeof(Level));

Level *GetLevel(int level) {
   return &levels[level];
}

