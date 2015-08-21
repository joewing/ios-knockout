
#define SCENE_WIDTH 13
#define SCENE_HEIGHT 10
#define MAX_BONUS 120

typedef unsigned char BlockType;
#define BLOCK_NONE      0
#define BLOCK_FIRST     1
#define BLOCK_SKULL     2
#define BLOCK_LAST      3
#define BLOCK_WALL      4
#define BLOCK_GREEN     5
#define BLOCK_GREEN_S   6
#define BLOCK_RED       7
#define BLOCK_RED_S     8
#define BLOCK_BLUE      9
#define BLOCK_BLUE_S    10
#define BLOCK_YELLOW    11
#define BLOCK_YELLOW_S  12
#define BLOCK_CYAN      13
#define BLOCK_CYAN_S    14
#define BLOCK_PURPLE    15
#define BLOCK_PURPLE_S  16
#define BLOCK_COUNT     17
#define BLOCK_BALL      255

typedef struct Scene {
   float ballx, bally;
   int startx, starty;
   int bonus_counter;
   int score;
   BlockType active_block;
   int level;
   int balls_left;
   int block_count;
   int last_block_count;
   int first_block_count;
   BlockType scene[SCENE_HEIGHT][SCENE_WIDTH];
} Scene;

typedef enum {
   STATE_COUNTDOWN,
   STATE_PLAY,
   STATE_BONUS,
   STATE_WIN,
   STATE_LOSE,
   STATE_BALL
} GameStateType;

extern Scene *current_scene;

extern unsigned int bonus_count_down;
extern GameStateType game_state;
extern int count_down;
extern int killerx, killery;

void LoadScene(const char *name);
void SaveScene(const char *name);

void StartGame();
void NextLevel(int level);
void RestartScene();
void DestroyScene();

void MoveBall(float *deltax, float *deltay);
void UpdateScore(unsigned int amount);

int IsSwitcher(BlockType type);

