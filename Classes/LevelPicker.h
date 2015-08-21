
#import <UIKit/UIKit.h>

@interface LevelPicker : UIView {

@private

   UILabel *label;
   UIButton *left_button;
   UIButton *right_button;

}

- (void)increment;

- (void)decrement;

- (void)draw;

@end

