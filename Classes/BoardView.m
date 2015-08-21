
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>

#import "KnockoutAppDelegate.h"
#import "BoardView.h"
#import "Ball.h"
#import "graphics.h"
#import "audio.h"
#import "scene.h"

static NSString *scene_file = @"scene.dat";

// Extension for private methods.
@interface BoardView ()

- (BOOL)createFramebuffer;
- (void)destroyFramebuffer;

@end

@implementation BoardView

+ (Class)layerClass {
   return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)rect {

   self = [super initWithFrame:rect];
   if(self) {

      CAEAGLLayer *layer = (CAEAGLLayer*)self.layer;
      layer.opaque = YES;
      layer.drawableProperties = [NSDictionary
         dictionaryWithObjectsAndKeys: [NSNumber numberWithBool:NO],
         kEAGLDrawablePropertyRetainedBacking,
         kEAGLColorFormatRGBA8,
         kEAGLDrawablePropertyColorFormat, nil];

      context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];

      if(!context || ![EAGLContext setCurrentContext:context]) {
         [self release];
         return nil;
      }

      InitializeGraphics();
      InitializeAudio();

      InitBall(self);

      initialized = 0;

   }
   return self;

}

- (void)newGame {

   StartGame();
    StartBall();

}

- (void)resume {

   if(!initialized) {
      [self load];
   }

   if(current_scene) {
       StartBall();
   } else {
      [self newGame];
   }

}

- (void)drawView {

   if(!current_scene) {
      return;
   }

   [EAGLContext setCurrentContext: context];
   glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
   glViewport(0, 0, backingWidth, backingHeight);

   if(!initialized) {

      initialized = 1;

      // Set the projection.
      glMatrixMode(GL_PROJECTION);
      glLoadIdentity();

      // Screen size is 480 by 320 pixels.
      glOrthof(320.0, 0.0, 480.0, 0.0, -1.0, 1.0);

      // Background is white.
      glClearColor(1.0, 1.0, 1.0, 1.0);

      glMatrixMode(GL_MODELVIEW);
      glLoadIdentity();

   }

   RenderScene();

   glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
   [context presentRenderbuffer: GL_RENDERBUFFER_OES];

   if(game_state == STATE_WIN || game_state == STATE_LOSE) {
      if(bonus_count_down == 0) {
         [ball stop];
         KnockoutAppDelegate *d = [UIApplication sharedApplication].delegate;
         const unsigned int score = current_scene->score;
         [d gameEnded:score];
         DestroyScene();
      }
   }

}

- (void)layoutSubviews {
   [EAGLContext setCurrentContext: context];
   [self destroyFramebuffer];
   [self createFramebuffer];
   [self drawView];
}

- (BOOL)createFramebuffer {

   glGenFramebuffersOES(1, &viewFramebuffer);
   glGenRenderbuffersOES(1, &viewRenderbuffer);

   glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
   glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);

   [context renderbufferStorage: GL_RENDERBUFFER_OES
            fromDrawable: (CAEAGLLayer*)self.layer];

   glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES,
                                GL_RENDERBUFFER_OES, viewRenderbuffer);

   glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES,
                                   GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
   glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES,
                                   GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);

   if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES)
      != GL_FRAMEBUFFER_COMPLETE_OES) {

      NSLog(@"failed to make complete framebuffer object %x",
            glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
      return NO;
   }

   return YES;

}

- (void)destroyFramebuffer {
   glDeleteFramebuffersOES(1, &viewFramebuffer);
   viewFramebuffer = 0;
   glDeleteRenderbuffersOES(1, &viewRenderbuffer);
   viewRenderbuffer = 0;
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {

   [ball stop];

   KnockoutAppDelegate *d = [UIApplication sharedApplication].delegate;
   [d pause];

}

- (void)load {

   // Get the file name.
   NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                        NSUserDomainMask, YES);
   NSString *dir = [paths objectAtIndex:0];
   NSString *path = [dir stringByAppendingPathComponent:scene_file];

   LoadScene([path UTF8String]);

}

- (void)save {

   // Get the file name.
   NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                        NSUserDomainMask, YES);
   NSString *dir = [paths objectAtIndex:0];
   NSString *path = [dir stringByAppendingPathComponent:scene_file];

   SaveScene([path UTF8String]);
}

- (void)dealloc {

    StopBall();

   DestroyAudio();
   DestroyGraphics();

 DestroyBall();

   if ([EAGLContext currentContext] == context) {
      [EAGLContext setCurrentContext:nil];
   }
   [context release];
   [super dealloc];

}

@end

