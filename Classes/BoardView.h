
#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@class Ball;

@interface BoardView : UIView {

@private

   GLint backingWidth, backingHeight;
   EAGLContext *context;
   GLuint viewRenderbuffer, viewFramebuffer;

   Ball *ball;
   int initialized;
   int running;

}

- (void)drawView;

- (void)newGame;

- (void)resume;

- (void)load;

- (void)save;

@end

