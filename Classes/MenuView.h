
#import <UIKit/UIKit.h>

#import "BaseView.h"
#import "HighScores.h"
#import "TransitionView.h"

@class LevelPicker;

@interface MenuView : BaseView <HighScoresDelegate> {

@private

   UIButton *new_game_button;
   UIButton *resume_button;
   UIButton *settings_button;
   UIButton *help_button;
   HighScores *scores;
   LevelPicker *level_picker;

   unsigned int new_score;

}

- (void)gameEnded:(unsigned int)score;

- (void)save;

- (void)resetScores;

@end

