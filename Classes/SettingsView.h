
#import "BaseView.h"

@interface SettingsView : BaseView <UITextFieldDelegate> {

@private

   UITextField *user_field;
   UIButton *register_button;
   UIButton *audio_button;
   UIButton *reset_button;
   UIButton *done_button;

}

@end

