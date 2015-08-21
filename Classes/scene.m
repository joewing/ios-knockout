
#import "scene.h"
#import "level.h"
#import "Ball.h"
#import "Settings.h"
#import "audio.h"

#import <stdio.h>
#import <stdlib.h>
#import <string.h>

#define BALL_MAX_X (13 * 32 - 16)
#define BALL_MAX_Y (320 - 16)

Scene *current_scene = NULL;

unsigned int bonus_count_down;
int count_down;
GameStateType game_state;
int killerx, killery;

static void CheckCollisions();
static void HandleCollision(int x, int y, BlockType active);

void StartGame() {
   NextLevel(start_level - 1);
   current_scene->balls_left = 5;
   current_scene->score = 0;
}

void NextLevel(int level) {

   Level *lp;
   int x, y;
   int startx, starty;

   if(level + 1 > max_level) {
      bonus_count_down = MAX_BONUS;
      game_state = STATE_WIN;
      return;
   }
   ++level;
   if(level > highest_level) {
      highest_level = level;
   }

   if(current_scene) {
      DestroyScene();
   }
   current_scene = (Scene*)malloc(sizeof(Scene));
   lp  = GetLevel(level - 1);

   memcpy(current_scene->scene, lp->scene, sizeof(current_scene->scene));

   startx = 8;
   starty = 8;
   current_scene->level = level;
   current_scene->block_count = 0;
   current_scene->last_block_count = 0;
   current_scene->first_block_count = 0;
   for(y = 0; y < SCENE_HEIGHT; y++) {
      for(x = 0; x < SCENE_WIDTH; x++) {
         switch(current_scene->scene[y][x]) {
         case BLOCK_NONE:
         case BLOCK_SKULL:
         case BLOCK_WALL:
         case BLOCK_GREEN_S:
         case BLOCK_RED_S:
         case BLOCK_BLUE_S:
         case BLOCK_YELLOW_S:
         case BLOCK_CYAN_S:
         case BLOCK_PURPLE_S:
            break;
         case BLOCK_BALL:
            startx = 32 * x + 8;
            starty = 32 * y + 8;
            current_scene->scene[y][x] = BLOCK_NONE;
            break;
         case BLOCK_FIRST:
            ++current_scene->first_block_count;
            break;
         case BLOCK_LAST:
            ++current_scene->last_block_count;
            break;
         default:
            ++current_scene->block_count;
            break;
         }
      }
   }

   current_scene->startx = startx;
   current_scene->starty = starty;
   current_scene->ballx = startx;
   current_scene->bally = starty;

   count_down = 2;
   game_state = STATE_COUNTDOWN;
   current_scene->bonus_counter = MAX_BONUS;
   bonus_count_down = 0;
   if(current_scene->first_block_count == 0
      && current_scene->block_count == 0) {
      current_scene->active_block = BLOCK_LAST;
   } else {
      current_scene->active_block = BLOCK_FIRST;
   }

}

void DestroyScene() {
   if(current_scene) {
      free(current_scene);
      current_scene = NULL;
   }
}

void RestartScene() {
   current_scene->ballx = current_scene->startx;
   current_scene->bally = current_scene->starty;
   if(   current_scene->first_block_count == 0
      && current_scene->block_count == 0) {
      current_scene->active_block = BLOCK_LAST;
   } else {
      current_scene->active_block = BLOCK_FIRST;
   }
   if(current_scene->balls_left > 0) {
      --current_scene->balls_left;
      count_down = 2;
      game_state = STATE_COUNTDOWN;
   } else {
      bonus_count_down = MAX_BONUS;
      game_state = STATE_LOSE;
   }
}

void MoveBall(float *deltax, float *deltay) {

   static const int offsets[] = {
      0,    0,
      15,   0,
      0,    15,
      15,   15
   };

   int damped;
   int index;
   int tempx, tempy;
   float newx, newy;
   float dx, dy;
   int can_move;
   BlockType type;

   // See if we can update the x-coordinate.
   damped = 0;
   dx = *deltax;
   while(dx >= 1.0 || dx <= -1.0) {
      can_move = 1;
      for(index = 0; index < 8; index += 2) {
         newx = current_scene->ballx + offsets[index + 0] + dx;
         newy = current_scene->bally + offsets[index + 1];
         tempx = (int)newx / 32;
         tempy = (int)newy / 32;
         if(tempx >= 0 && tempx < BALL_MAX_X) {
            if(tempy >= 0 && tempy < BALL_MAX_Y) {
               type = current_scene->scene[tempy][tempx];
               if(type != BLOCK_NONE) {
                  if(type != current_scene->active_block) {
                     damped = 1;
                     can_move = 0;
                     break;
                  }
               }
            }
         }
      }
      if(can_move) {
         tempx = current_scene->ballx + dx;
         if(tempx > BALL_MAX_X) {
            tempx = BALL_MAX_X;
         }
         if(tempx < 0) {
            tempx = 0;
         }
         current_scene->ballx = tempx;
         break;
      }
      if(dx > 0.0) {
         dx -= 1.0;
      } else {
         dx += 1.0;
      }
   }
   if(damped) {
      *deltax = 0.0;
   }

   // See if we can update the y-coordinate.
   damped = 0;
   dy = *deltay;
   while(dy >= 1.0 || dy <= -1.0) {
      can_move = 1;
      for(index = 0; index < 8; index += 2) {
         newx = current_scene->ballx + offsets[index + 0];
         newy = current_scene->bally + offsets[index + 1] + dy;
         tempx = (int)newx / 32;
         tempy = (int)newy / 32;
         if(tempx >= 0 && tempx < BALL_MAX_X) {
            if(tempy >= 0 && tempy < BALL_MAX_Y) {
               type = current_scene->scene[tempy][tempx];
               if(type != BLOCK_NONE) {
                  if(type != current_scene->active_block) {
                     damped = 1;
                     can_move = 0;
                     break;
                  }
               }
            }
         }
      }
      if(can_move) {
         tempy = current_scene->bally + dy;
         if(tempy > BALL_MAX_Y) {
            tempy = BALL_MAX_Y;
         }
         if(tempy < 0) {
            tempy = 0;
         }
         current_scene->bally = tempy;
         break;
      }
      if(dy > 0.0) {
         dy -= 1.0;
      } else {
         dy += 1.0;
      }
   }
   if(damped) {
      *deltay = 0.0;
   }

   CheckCollisions();

}

void CheckCollisions() {

   // Check for a block under with the following offsets from the ball
   // coordinates (to take into account the size of the ball).
   const float offsets[] = {

      // Top left
      -1.5,    0.0,
      0.0,     -1.5,

      // Bottom right
      16.5,    15.0,
      15.0,    16.5,

      // Top right
      16.5,    0.0,
      15.0,    -1.5,

      // Bottom left
      -1.5,    15.0,
      0.0,     16.5,

      // Lastly, we apply coordinates at the tangents.
      // This is done in case we are between two switcher blocks.
      // Left
      -1.5,    8.0,

      // Right
      16.5,    8.0,

      // Top
      8.0,     -1.5,

      // Bottom
      8.0,     16.5

   };
   const int offset_count = (int)(sizeof(offsets) / sizeof(float));

   int index;
   int tempx, tempy;

   const BlockType active = current_scene->active_block;
   for(index = 0; index < offset_count; index += 2) {

      // Get the ball pixel offset.
      tempx = (int)(current_scene->ballx + offsets[index + 0]);
      tempy = (int)(current_scene->bally + offsets[index + 1]);

      // Convert pixels to blocks.
      tempx /= 32;
      tempy /= 32;

      // Check the block.
      if(tempx >= 0 && tempx < SCENE_WIDTH) {
         if(tempy >= 0 && tempy < SCENE_HEIGHT) {
            if(current_scene->scene[tempy][tempx] != BLOCK_NONE) {
               HandleCollision(tempx, tempy, active);
            }
         }
      }

   }

   if(active != current_scene->active_block) {
      if(   current_scene->active_block != BLOCK_SKULL
         && current_scene->active_block != BLOCK_NONE) {
         PlaySwitch();
      }
   }

}

void HandleCollision(int x, int y, BlockType active) {

   const BlockType type = current_scene->scene[y][x];

   switch(type) {
   case BLOCK_GREEN:
   case BLOCK_RED:
   case BLOCK_BLUE:
   case BLOCK_YELLOW:
   case BLOCK_CYAN:
   case BLOCK_PURPLE:
      if(active == type) {
         current_scene->scene[y][x] = BLOCK_NONE;
         --current_scene->block_count;
         if(   current_scene->block_count == 0
            && current_scene->first_block_count == 0) {
            if(current_scene->last_block_count > 0) {
               current_scene->active_block = BLOCK_LAST;
            } else {
               current_scene->active_block = BLOCK_NONE;
            }
         }
         UpdateScore(1);
         PlayClick();
      }
      break;
   case BLOCK_FIRST:
      if(active == type) {
         current_scene->scene[y][x] = BLOCK_NONE;
         --current_scene->first_block_count;
         if(   current_scene->first_block_count == 0
            && current_scene->block_count == 0) {
            current_scene->active_block = BLOCK_NONE;
         }
         UpdateScore(1);
         PlayClick();
      }
      break;
   case BLOCK_LAST:
      if(active == type) {
         current_scene->scene[y][x] = BLOCK_NONE;
         --current_scene->last_block_count;
         if(current_scene->last_block_count == 0) {
            current_scene->active_block = BLOCK_NONE;
         }
         UpdateScore(1);
         PlayClick();
      }
      break;
   case BLOCK_GREEN_S:
   case BLOCK_RED_S:
   case BLOCK_BLUE_S:
   case BLOCK_YELLOW_S:
   case BLOCK_CYAN_S:
   case BLOCK_PURPLE_S:
      if(current_scene->active_block != BLOCK_LAST) {
         current_scene->active_block = type - 1;
      }
      break;
   case BLOCK_SKULL:
      current_scene->active_block = BLOCK_SKULL;
      killerx = x * 32;
      killery = y * 32;
      break;
   default:
      break;
   }

}

void UpdateScore(unsigned int amount) {
   current_scene->score += amount;
}

void LoadScene(const char *name) {

   FILE *fd = fopen(name, "rb");
   if(fd) {
      DestroyScene();
      current_scene = (Scene*)malloc(sizeof(Scene));
      size_t sz = fread(current_scene, sizeof(Scene), 1, fd);
      if(sz != 1) {
         DestroyScene();
      }
      fclose(fd);
   }

}

void SaveScene(const char *name) {

   FILE *fd = fopen(name, "wb");
   if(fd) {
      if(current_scene) {
         fwrite(current_scene, sizeof(Scene), 1, fd);
      }
      fclose(fd);
   }

}

int IsSwitcher(BlockType type) {

   switch(type) {
   case BLOCK_GREEN_S:
   case BLOCK_RED_S:
   case BLOCK_BLUE_S:
   case BLOCK_YELLOW_S:
   case BLOCK_CYAN_S:
   case BLOCK_PURPLE_S:
      return 1;
   default:
      return 0;
   }

}

