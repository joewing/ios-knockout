
#import "scene.h"

typedef struct Level {
   BlockType scene[SCENE_HEIGHT][SCENE_WIDTH];
} Level;

extern const unsigned int max_level;

Level *GetLevel(int level);

