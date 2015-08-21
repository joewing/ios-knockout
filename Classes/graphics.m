
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CGContext.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#include <math.h>

#import "graphics.h"
#import "scene.h"
#import "Ball.h"
#import "level.h"

static GLuint block_textures[BLOCK_COUNT];
static GLuint bg_texture;
static GLuint ball_texture;
static GLuint game_over_texture;
static GLuint complete_texture;
static GLuint win_texture;
static GLuint scoreboard_texture;
static GLuint death_texture;
static GLuint arrow_texture;
static GLuint number_textures[10];
static GLuint countdown_textures[3];
static int bg_size;

static void *buffer;
static size_t buffer_size;

static const CFStringRef blocks_name = CFSTR("blocks");
static const CFStringRef bg_name = CFSTR("bg");
static const CFStringRef ball_name = CFSTR("ball");
static const CFStringRef game_over_name = CFSTR("game_over");
static const CFStringRef complete_name = CFSTR("level_complete");
static const CFStringRef win_name = CFSTR("win");
static const CFStringRef scoreboard_name = CFSTR("scoreboard");
static const CFStringRef death_name = CFSTR("block_skull_h");
static const CFStringRef arrow_name = CFSTR("arrow");

static const CFStringRef countdown_names[] = {
   CFSTR("one"),
   CFSTR("two"),
   CFSTR("three")
};

// Block vertices.
static const GLfloat vertices[] = {

   // Blocks
   0.0,  0.0,
   32.0, 0.0,
   0.0,  32.0,
   32.0, 32.0,

   // Lives
   0.0,  0.0,
   10.0, 0.0,
   0.0,  10.0,
   10.0, 10.0,

   // Numbers
   0.0,  0.0,
   64.0, 0.0,
   0.0,  64.0,
   64.0, 64.0,

   // Background
   0.0,     0.0,
   320.0,   0.0,
   0.0,     416.0,
   320.0,   416.0,

   // Scoreboard
   0.0,     0.0,
   512.0,   0.0,
   0.0,     64.0,
   512.0,   64.0,

   // Ball
   0.0,  0.0,
   16.0, 0.0,
   0.0,  16.0,
   16.0, 16.0,

   // Win/Lose
   0.0,     0.0,
   64.0,    0.0,
   0.0,     256.0,
   64.0,    256.0,

   // Complete
   0.0,     0.0,
   128.0,   0.0,
   0.0,     256.0,
   128.0,   256.0,

   // Countdown
   0.0,     0.0,
   128.0,   0.0,
   0.0,     128.0,
   128.0,   128.0

};

#define BLOCK_VERTEX_OFFSET      (0 * 4)
#define LIVES_VERTEX_OFFSET      (1 * 4)
#define NUM_VERTEX_OFFSET        (2 * 4)
#define BG_VERTEX_OFFSET         (3 * 4)
#define SB_VERTEX_OFFSET         (4 * 4)
#define BALL_VERTEX_OFFSET       (5 * 4)
#define OVER_VERTEX_OFFSET       (6 * 4)
#define COMPLETE_VERTEX_OFFSET   (7 * 4)
#define COUNTDOWN_VERTEX_OFFSET  (8 * 4)
#define ARROW_VERTEX_OFFSET      NUM_VERTEX_OFFSET

// Block texture coordinates.
static GLshort texture_coordinates[] = {

   // Block
   0, 0, 1, 0, 0, 1, 1, 1,

   // Lives
   0, 0, 1, 0, 0, 1, 1, 1,

   // Numbers
   0, 0, 1, 0, 0, 1, 1, 1,

   // Background
   0, 0, 1, 0, 0, 1, 1, 1,

   // Scoreboard
   0, 0, 1, 0, 0, 1, 1, 1,

   // Ball
   0, 0, 1, 0, 0, 1, 1, 1,

   // Win/Lose
   0, 0, 1, 0, 0, 1, 1, 1,

   // Level Complete
   0, 0, 1, 0, 0, 1, 1, 1,

   // Countdown
   0, 0, 1, 0, 0, 1, 1, 1

};

static void DrawBlock(int x, int y, BlockType type);
static void DrawLives();
static void DrawArrow();
static void DrawTexture(int x, int y, GLint offset, GLuint texture);
static GLuint LoadTexture(CFStringRef name, int *size);
static void LoadBlocks();
static GLuint CreateTextTexture(int width, int height, const char *str);
static void DrawNumber(unsigned int y, unsigned int n);
static void *GetBuffer(size_t size);

void InitializeGraphics() {

   // Clear out the buffer used for loading textures.
   // This will be allocated and resized as necessary.
   buffer = NULL;
   buffer_size = 0;

   // Load the block textures.
   LoadBlocks();

   // Load the background texture.
   bg_size = 1024;
   bg_texture = LoadTexture(bg_name, &bg_size);
   texture_coordinates[BG_VERTEX_OFFSET * 2 + 0] = 0;
   texture_coordinates[BG_VERTEX_OFFSET * 2 + 1] = 0;
   texture_coordinates[BG_VERTEX_OFFSET * 2 + 2]
      = (320 + bg_size - 1) / bg_size;
   texture_coordinates[BG_VERTEX_OFFSET * 2 + 3] = 0;
   texture_coordinates[BG_VERTEX_OFFSET * 2 + 4] = 0;
   texture_coordinates[BG_VERTEX_OFFSET * 2 + 5]
      = (416 + bg_size - 1) / bg_size;
   texture_coordinates[BG_VERTEX_OFFSET * 2 + 6]
      = (320 + bg_size - 1) / bg_size;
   texture_coordinates[BG_VERTEX_OFFSET * 2 + 7]
      = (416 + bg_size - 1) / bg_size;

   // Load the ball texture.
   ball_texture = LoadTexture(ball_name, NULL);

   // Load end-game textures.
   game_over_texture = LoadTexture(game_over_name, NULL);
   complete_texture = LoadTexture(complete_name, NULL);
   win_texture = LoadTexture(win_name, NULL);

   // Load number textures.
   int x;
   for(x = 0; x < 10; x++) {
      char temp[2];
      temp[0] = (char)('0' + x);
      temp[1] = 0;
      number_textures[x] = CreateTextTexture(64, 64, temp);
   }

   // Load count-down textures.
   for(x = 0; x < 3; x++) {
      countdown_textures[x] = LoadTexture(countdown_names[x], NULL);
   }

   // Load the scoreboard image.
   scoreboard_texture = LoadTexture(scoreboard_name, NULL);

   // Load the hit skull texture.
   death_texture = LoadTexture(death_name, NULL);

   arrow_texture = LoadTexture(arrow_name, NULL);

   // Done loading textures. Free the buffer.
   if(buffer) {
      free(buffer);
      buffer = NULL;
      buffer_size = 0;
   }

   // Alpha testing.
   glEnable(GL_ALPHA_TEST);
   glAlphaFunc(GL_GREATER, 0.75);

   // Set the vertices we will use.
   glVertexPointer(2, GL_FLOAT, 0, vertices);
   glEnableClientState(GL_VERTEX_ARRAY);

   // Set the texture coordinates.
   glTexCoordPointer(2, GL_SHORT, 0, texture_coordinates);
   glEnableClientState(GL_TEXTURE_COORD_ARRAY);

}

void DestroyGraphics() {
   glDeleteTextures(BLOCK_COUNT, block_textures);
   glDeleteTextures(1, &bg_texture);
   glDeleteTextures(1, &ball_texture);
   glDeleteTextures(1, &game_over_texture);
   glDeleteTextures(1, &complete_texture);
   glDeleteTextures(1, &win_texture);
   glDeleteTextures(1, &scoreboard_texture);
   glDeleteTextures(1, &death_texture);
   glDeleteTextures(1, &arrow_texture);
   glDeleteTextures(10, number_textures);
   glDeleteTextures(3, countdown_textures);
}

void RenderScene() {

   int x, y;

   // Draw the background.
   glBindTexture(GL_TEXTURE_2D, bg_texture);
   glLoadIdentity();
   glDrawArrays(GL_TRIANGLE_STRIP, BG_VERTEX_OFFSET, 4);

   // Draw the blocks.
   for(y = 0; y < SCENE_HEIGHT; y++) {
      glLoadIdentity();
      glTranslatef(32.0 * y, -32.0, 0.0);
      for(x = 0; x < SCENE_WIDTH; x++) {
         const BlockType type = current_scene->scene[y][x];
         glTranslatef(0.0, 32.0, 0.0);
         if(type != BLOCK_NONE) {
            if(IsSwitcher(type) && current_scene->first_block_count > 0) {
               glBindTexture(GL_TEXTURE_2D, block_textures[type - 1]);
               glDrawArrays(GL_TRIANGLE_STRIP, BLOCK_VERTEX_OFFSET, 4);
               glEnable(GL_BLEND);
               glBlendFunc(GL_DST_COLOR, GL_SRC_COLOR);
               glBindTexture(GL_TEXTURE_2D, block_textures[BLOCK_SKULL]);
               glDrawArrays(GL_TRIANGLE_STRIP, BLOCK_VERTEX_OFFSET, 4);
               glDisable(GL_BLEND);
            } else {
               glBindTexture(GL_TEXTURE_2D, block_textures[type]);
               glDrawArrays(GL_TRIANGLE_STRIP, BLOCK_VERTEX_OFFSET, 4);
            }
         }
      }
   }

   // Highlight the hit skull block.
   if(game_state == STATE_BALL || game_state == STATE_LOSE) {
      DrawTexture(killerx, killery, BLOCK_VERTEX_OFFSET, death_texture);
   }

   // Draw the ball.
   DrawTexture(current_scene->ballx, current_scene->bally,
               BALL_VERTEX_OFFSET, ball_texture); 

   // Draw the scoreboard background.
   DrawTexture(13 * 32, 0, SB_VERTEX_OFFSET, scoreboard_texture);

   // Draw the bonus.
   DrawNumber(24, current_scene->bonus_counter);

   // Draw the current level.
   DrawNumber(76, current_scene->level);

   // Draw the score.
   DrawNumber(124, current_scene->score);

   // Display the number of balls left.
   DrawLives();

   // Draw the active block.
   DrawBlock(432, 184, current_scene->active_block);

   // Display the arrow.
   DrawArrow();

   switch(game_state) {
   case STATE_WIN:
   case STATE_BONUS:
      if(current_scene->level >= max_level) {
         DrawTexture(80, 96, OVER_VERTEX_OFFSET, win_texture);
      } else {
         DrawTexture(80, 96, COMPLETE_VERTEX_OFFSET, complete_texture);
      }
      break;
   case STATE_LOSE:
      DrawTexture(80, 96, OVER_VERTEX_OFFSET, game_over_texture);
      break;
   case STATE_COUNTDOWN:
      DrawTexture(144, 96, COUNTDOWN_VERTEX_OFFSET,
                  countdown_textures[count_down]);
      break;
   default:
      break;
   }

}

void DrawBlock(int x, int y, BlockType type) {

   if(type) {
      glLoadIdentity();
      glTranslatef((GLfloat)y, (GLfloat)x, 0.0);
      glBindTexture(GL_TEXTURE_2D, block_textures[type]);
      glDrawArrays(GL_TRIANGLE_STRIP, BLOCK_VERTEX_OFFSET, 4);
   }

}

GLuint LoadTexture(CFStringRef name, int *size) {

   GLuint result;
   size_t width, height;
   CGImageRef image;
   CGContextRef context;
   GLubyte *data;

   CFBundleRef bundle;
   CFURLRef url;
   CGDataProviderRef provider;

   bundle = CFBundleGetMainBundle();

   // Get a URL for the image.
   url = CFBundleCopyResourceURL(bundle, name, CFSTR("png"), NULL);

   // Create the data provider.
   provider = CGDataProviderCreateWithURL(url);
   CFRelease(url);

   // Create the image.
   image = CGImageCreateWithPNGDataProvider(provider, NULL, true,
                        kCGRenderingIntentDefault);
   CGDataProviderRelease(provider);

   if(!image) {
      NSLog(@"could not load image");
      return 0;
   }

   // Allocate space for the bitmap data.
   width = CGImageGetWidth(image);
   height = CGImageGetHeight(image);
   if(size) {
      *size = width;
   }
   data = (GLubyte*)GetBuffer(width * height * 4);
   if(!data) {
      return 0;
   }

   // Create a context.
   context = CGBitmapContextCreate(data, height, width, 8, height * 4,
                                   CGImageGetColorSpace(image),
                                   kCGImageAlphaPremultipliedLast);

   // Translation for the right orientation.
   CGContextTranslateCTM(context, 0, width);
   CGContextScaleCTM(context, 1.0, -1.0);
   CGContextTranslateCTM(context, height, 0.0);
   CGContextRotateCTM(context, M_PI_2);

   // Draw the image in our context.
   CGContextDrawImage(context, CGRectMake(0.0, 0.0, width, height), image);
   CGContextRelease(context);

   // Create the OpenGL texture.
   glGenTextures(1, &result);
   glBindTexture(GL_TEXTURE_2D, result);
   glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, height, width, 0,
                GL_RGBA, GL_UNSIGNED_BYTE, data);
   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
   glEnable(GL_TEXTURE_2D);

   // Clean up.
   CGImageRelease(image);

   return result;

}

void LoadBlocks() {

   size_t width, height;
   CGImageRef image;
   CGContextRef context;
   GLubyte *data;
   size_t x;

   CFBundleRef bundle;
   CFURLRef url;
   CGDataProviderRef provider;

   bundle = CFBundleGetMainBundle();

   // Get a URL for the image.
   url = CFBundleCopyResourceURL(bundle, blocks_name, CFSTR("png"), NULL);

   // Create the data provider.
   provider = CGDataProviderCreateWithURL(url);
   CFRelease(url);

   // Create the image.
   image = CGImageCreateWithPNGDataProvider(provider, NULL, true,
                        kCGRenderingIntentDefault);
   CGDataProviderRelease(provider);

   if(!image) {
      NSLog(@"could not load block images");
      return;
   }

   // Allocate space for the bitmap data.
   width = CGImageGetWidth(image);
   height = CGImageGetHeight(image);
   data = (GLubyte*)GetBuffer(width * height * 4);
   if(!data) {
      return;
   }

   // Create a context.
   context = CGBitmapContextCreate(data, height, width, 8, height * 4,
                                   CGImageGetColorSpace(image),
                                   kCGImageAlphaPremultipliedLast);

   // Translation for the right orientation.
   CGContextTranslateCTM(context, 0, width);
   CGContextScaleCTM(context, 1.0, -1.0);
   CGContextTranslateCTM(context, height, 0.0);
   CGContextRotateCTM(context, M_PI_2);

   // Draw the image in our context.
   CGContextDrawImage(context, CGRectMake(0.0, 0.0, width, height), image);
   CGContextRelease(context);

   // Create the OpenGL textures.
   glGenTextures(BLOCK_COUNT, block_textures);
   for(x = 0; x < BLOCK_COUNT; x++) {
      glBindTexture(GL_TEXTURE_2D, block_textures[x]);
      glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 32, 32, 0,
                   GL_RGBA, GL_UNSIGNED_BYTE, &data[32 * 32 * 4 * x]);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
      glEnable(GL_TEXTURE_2D);
   }

   // Clean up.
   CGImageRelease(image);

}

GLuint CreateTextTexture(int width, int height, const char *str) {

   void *data;
   CGContextRef context;
   CGColorSpaceRef color_space;
   GLuint texture;
   const float font_size = 16.0;

   data = GetBuffer(width * height * 4);
   if(!data) {
      return 0;
   }

   color_space = CGColorSpaceCreateDeviceRGB();
   context = CGBitmapContextCreate(data, height, width, 8, height * 4,
                                   color_space, kCGImageAlphaPremultipliedLast);
   CGColorSpaceRelease(color_space);
   CGContextSaveGState(context);

   // Translation necessry for displaying the string in the right place.
   CGContextTranslateCTM(context, 0.0, width);
   CGContextScaleCTM(context, 1.0, -1.0);
   CGContextTranslateCTM(context, font_size, 0.0);
   CGContextRotateCTM(context, M_PI_2);

   // Font properties.
   CGContextSelectFont(context, "Helvetica-Bold", font_size,
                       kCGEncodingMacRoman);
   CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 1.0); 

   // Display the string.
   CGContextShowText(context, str, strlen(str));

   CGContextRestoreGState(context);
   CGContextRelease(context);

   // Create the OpenGL texture.
   glGenTextures(1, &texture);
   glBindTexture(GL_TEXTURE_2D, texture);
   glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, height, width, 0,
                GL_RGBA, GL_UNSIGNED_BYTE, data);
   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
   glEnable(GL_TEXTURE_2D);

   return texture;

}

void DrawTexture(int x, int y, GLint offset, GLuint texture) {
   glLoadIdentity();
   glTranslatef((GLfloat)y, (GLfloat)x, 0.0);
   glBindTexture(GL_TEXTURE_2D, texture);
   glDrawArrays(GL_TRIANGLE_STRIP, offset, 4);
}

void DrawLives() {

   const int x_offset = 13 * 32 + 7;
   const int y_offset = 157;
   const int x_scale = 10;

   glBindTexture(GL_TEXTURE_2D, ball_texture);
   glLoadIdentity();
   glTranslatef(y_offset, x_offset, 0.0);
   switch(current_scene->balls_left) {
   default:
      // Fall through.
   case 5:
      glDrawArrays(GL_TRIANGLE_STRIP, LIVES_VERTEX_OFFSET, 4);
      glTranslatef(0.0, x_scale, 0.0);
      // Fall through.
   case 4:
      glDrawArrays(GL_TRIANGLE_STRIP, LIVES_VERTEX_OFFSET, 4);
      glTranslatef(0.0, x_scale, 0.0);
      // Fall through.
   case 3:
      glDrawArrays(GL_TRIANGLE_STRIP, LIVES_VERTEX_OFFSET, 4);
      glTranslatef(0.0, x_scale, 0.0);
      // Fall through.
   case 2:
      glDrawArrays(GL_TRIANGLE_STRIP, LIVES_VERTEX_OFFSET, 4);
      glTranslatef(0.0, x_scale, 0.0);
      // Fall through.
   case 1:
      // Fall through.
      glDrawArrays(GL_TRIANGLE_STRIP, LIVES_VERTEX_OFFSET, 4);
   case 0:
      break;
   }

}

void DrawArrow() {

   // The location of the arrow.
   const float x = 416;
   const float y = 226;

   // Compute the size of the arrow.
   float scale = hypotf(accelx, accely) / 2.0;
   if(scale < 0.2) {
      return;
   } else if(scale > 1.0) {
      scale = 1.0;
   }

   // Determine the angle.
   // tan(theta) = y / x -> theta = atan(y / x)
   const float angle_radians = atan2f(accelx, accely);
   const float angle_degrees = angle_radians * (180.0 * M_1_PI);

   glLoadIdentity();
   glTranslatef(y + 32, x + 32, 0);
   glRotatef(angle_degrees, 0, 0, 1);
   glScalef(scale, scale, 1.0);
   glTranslatef(-32, -32, 0);
   glBindTexture(GL_TEXTURE_2D, arrow_texture);
   glDrawArrays(GL_TRIANGLE_STRIP, ARROW_VERTEX_OFFSET, 4);

}

void DrawNumber(unsigned int y, unsigned int n) {

   const unsigned int digit_count = 4;
   const unsigned int digit_width = 10;
   const unsigned int startx = 13 * 32 + 7;
   const unsigned int endx = startx + (digit_count * digit_width);

   unsigned int x;
   unsigned int temp;

   for(x = endx; x >= startx; x -= digit_width) {
      temp = n % 10;
      n /= 10;
      DrawTexture(x, y, NUM_VERTEX_OFFSET, number_textures[temp]);
   }

}

void *GetBuffer(size_t size) {
   if(size > buffer_size) {
      if(buffer) {
         free(buffer);
      }
      buffer = malloc(size);
   }
   return buffer;
}

