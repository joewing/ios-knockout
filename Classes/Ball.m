
#import <CoreGraphics/CGContext.h>
#import <CoreMotion/CMMotionManager.h>
#import <sys/time.h>

#import "Ball.h"
#import "BoardView.h"
#import "scene.h"
#import "graphics.h"
#import "audio.h"

// The frequency to poll for accelerometer updates in seconds.
// Note that this can be no faster than 1/100.
#define BASE_SPEED (1.0 / 60.0)

// The acceleration constant.
// This should be a value greater than 0.0.
#define ACCELERATION 15.0

// The friction of the ball.
// This should be a value between 0.0 and 1.0.
#define FRICTION 0.25

// The maximum velocity of the ball in pixels.
// This should be a value between 1.0 and 32.0.
#define MAX_VELOCITY 20.0

// The speed of the bonus timer in ticks per update.
// This should be approximately once per second.
#define SLOW_TICKS ((int)(1.0 / ACCEL_UPDATE_SPEED + 0.5))

// The speed of the count down in ticks per update.
#define MEDIUM_TICKS ((int)((SLOW_TICKS + 1) / 2))

// The speed to update the bonus timer in ticks per update.
#define FAST_TICKS 1

// The frequency to move the ball in seconds.
// This should be half of the BASE_SPEED.
#define ACCEL_UPDATE_SPEED (2.0 * BASE_SPEED)

float accelx, accely;

static BoardView *board_view = NULL;
static CMMotionManager *motion_manager = NULL;
static NSOperationQueue *motion_queue = NULL;
static unsigned int bonus_ticks = 0;
static char running = 0;
static float sumx = 0.0;
static float sumy = 0.0;
static int tick = 0;
static float velocityx = 0.0;
static float velocityy = 0.0;

static int UpdateBonus();
static void (^BallMotionHandler)(CMAccelerometerData *data, NSError *error);

void InitBall(BoardView *view) {
   running = 0;
   board_view = view;
   motion_manager = [[CMMotionManager alloc] init];
   motion_manager.accelerometerUpdateInterval = BASE_SPEED;
   motion_queue = [[NSOperationQueue alloc] init];
}

void StartBall() {

   // Disable the idle timer.
   [UIApplication sharedApplication].idleTimerDisabled = YES;

   // Attach to the accelerometer.
   [motion_manager startAccelerometerUpdatesToQueue: motion_queue
                   withHandler: BallMotionHandler];

   ResetBall();
   game_state = STATE_COUNTDOWN;
   count_down = 2;
   bonus_ticks = MEDIUM_TICKS;
   running = 1;

   [board_view drawView];

}

void StopBall() {

   // Detach from the accelerometer.
   [motion_manager stopAccelerometerUpdates];
   [motion_queue release];

   running = 0;

   // Enable the idle timer.
   [UIApplication sharedApplication].idleTimerDisabled = NO;

}

void ResetBall() {
   running = 0;
   accelx = 0.0;
   accely = 0.0;
   sumx = 0.0;
   sumy = 0.0;
   tick = 0;
   velocityx = 0.0;
   velocityy = 0.0;
}

static void (^BallMotionHandler)(CMAccelerometerData *data, NSError *error)
    = ^(CMAccelerometerData *data, NSError *error){

   sumx += data.acceleration.y;
   sumy += data.acceleration.x;
   if(tick == 0) {
      tick = 1;
      return;
   }
   accelx = sumx * ACCELERATION / 2.0;
   accely = sumy * ACCELERATION / 2.0;
   sumx = 0.0;
   sumy = 0.0;
   tick = 0;

   if(!running) {
      return;
   }

   if(game_state == STATE_PLAY) {

      velocityx = velocityx * (1.0 - FRICTION) - accelx;
      velocityy = velocityy * (1.0 - FRICTION) - accely;

      if(velocityx > MAX_VELOCITY) {
         velocityx = MAX_VELOCITY;
      } else if(velocityx < -MAX_VELOCITY) {
         velocityx = -MAX_VELOCITY;
      }

      if(velocityy > MAX_VELOCITY) {
         velocityy = MAX_VELOCITY;
      } else if(velocityy < -MAX_VELOCITY) {
         velocityy = -MAX_VELOCITY;
      }

      MoveBall(&velocityx, &velocityy);

      if(current_scene->active_block == BLOCK_NONE) {
         ResetBall();
         game_state = STATE_BONUS;
         bonus_count_down = MAX_BONUS;
         PlayComplete();
      } else if(current_scene->active_block == BLOCK_SKULL) {
         if(current_scene->balls_left > 0) {
            game_state = STATE_BALL;
            bonus_ticks = SLOW_TICKS;
            PlayDie();
         } else {
            game_state = STATE_LOSE;
            bonus_count_down = MAX_BONUS;
            bonus_ticks = FAST_TICKS;
            PlayLose();
         }
      }

   }

   if(bonus_ticks > 0) {
      --bonus_ticks;
   } else if(UpdateBonus()) {
      StartBall();
   }

   [board_view drawView];

};

void DestroyBall() {
   [motion_manager release];
}

int UpdateBonus() {
   int should_restart = 0;
   unsigned int temp;
   switch(game_state) {
   case STATE_BONUS:
      if(bonus_count_down > 0) {
         bonus_ticks = FAST_TICKS;
         temp = current_scene->bonus_counter > 3
              ? 3 : current_scene->bonus_counter;
         UpdateScore(temp);
         current_scene->bonus_counter -= temp;
         temp = bonus_count_down > 3 ? 3 : bonus_count_down;
         bonus_count_down -= temp;
      } else {
         bonus_ticks = MEDIUM_TICKS;
         NextLevel(current_scene->level);
      }
      break;
   case STATE_WIN:
   case STATE_LOSE:
      if(bonus_count_down > 0) {
         bonus_ticks = FAST_TICKS;
         temp = bonus_count_down > 3 ? 3 : bonus_count_down;
         bonus_count_down -= temp;
      }
      break;
   case STATE_COUNTDOWN:
      if(count_down > 0) {
         --count_down;
         bonus_ticks = MEDIUM_TICKS;
      } else {
         game_state = STATE_PLAY;
         bonus_ticks = SLOW_TICKS;
      }
      break;
   case STATE_BALL:
      RestartScene();
      should_restart = 1;
      break;
   default: // STATE_PLAY
      if(current_scene->bonus_counter > 0) {
         --current_scene->bonus_counter;
         bonus_ticks = SLOW_TICKS;
      }
      break;
   }
   return should_restart;
}

