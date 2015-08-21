
#import <UIKit/UIKit.h>

#define HIGHSCORE_COUNT 5

@protocol HighScoresDelegate

- (void)disable;

- (void)enable;

@end

@interface HighScores : UIView <UITextFieldDelegate> {

@private

   UILabel *title;
   UILabel *names[HIGHSCORE_COUNT];
   UILabel *scores[HIGHSCORE_COUNT];

   UITextField *input;

   int new_pos;
   unsigned int new_score;

   id <HighScoresDelegate> delegate;

}

- (void)setDelegate:(id <HighScoresDelegate>)d;

- (void)newScore:(unsigned int)score;

- (void)load;

- (void)save;

- (void)reset;

@end

