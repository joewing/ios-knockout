
#import <UIKit/UIKit.h>

@class BoardView;

extern float accelx, accely;

void InitBall(BoardView *view);
void ResetBall();
void StartBall();
void StopBall();
void DestroyBall();

