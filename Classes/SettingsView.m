
#import "SettingsView.h"
#import "KnockoutAppDelegate.h"
#import "Settings.h"

@interface SettingsView ()
- (void)toggleSound;
- (void)updateAudioButton;
- (void)registerUser;
@end

@implementation SettingsView

- (id)initWithFrame:(CGRect)rect {

   self = [super initWithFrame:rect];
   if(self) {

      KnockoutAppDelegate *d = [UIApplication sharedApplication].delegate;

      user_field = [[UITextField alloc] init];
      user_field.frame = CGRectMake(256, 96, 160, 32);
      user_field.text = [NSString stringWithUTF8String:default_user_name];
      user_field.borderStyle = UITextBorderStyleBezel;
      user_field.opaque = YES;
      user_field.backgroundColor = [UIColor whiteColor];
      user_field.adjustsFontSizeToFitWidth = YES;
      user_field.delegate = self;
      [self addSubview:user_field];

      register_button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
      register_button.frame = CGRectMake(64, 152, 160, 40);
      [register_button setTitle:@"Register User" forState:0];
      [register_button addTarget:self action:@selector(registerUser)
                       forControlEvents:UIControlEventTouchUpInside];
      [self addSubview:register_button];

      audio_button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
      audio_button.frame = CGRectMake(64, 208, 160, 40);
      [audio_button addTarget:self action:@selector(toggleSound)
                    forControlEvents:UIControlEventTouchUpInside];
      [self updateAudioButton];
      [self addSubview:audio_button];

      reset_button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
      reset_button.frame = CGRectMake(256, 208, 160, 40);
      [reset_button setTitle:@"Reset Scores" forState:0];
      [reset_button addTarget:d action:@selector(resetScores)
                    forControlEvents:UIControlEventTouchUpInside];
      [self addSubview:reset_button];

      done_button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
      done_button.frame = CGRectMake(176, 264, 160, 40);
      [done_button setTitle:@"Close" forState:0];
      [done_button addTarget:d action:@selector(closeSettings)
                   forControlEvents:UIControlEventTouchUpInside];
      [self addSubview:done_button];

      self.opaque = YES;
      self.backgroundColor = [UIColor darkGrayColor];

   }
   return self;

}

- (void)drawRect:(CGRect)rect {

   [super drawRect:rect];

   CGContextRef context = UIGraphicsGetCurrentContext();
   CGContextSetTextPosition(context, 0, 0);
   CGContextSaveGState(context);
   CGContextSelectFont(context, "Helvetica-Bold", 16.0,
                       kCGEncodingMacRoman);
   CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0); 
   CGContextTranslateCTM(context, 78, 116);
   CGContextScaleCTM(context, 1.0, -1.0);
   CGContextShowText(context, "Default User:", 13);
   CGContextRestoreGState(context);

}

- (void)toggleSound {
   if(audio_enabled) {
      audio_enabled = 0;
   } else {
      audio_enabled = 1;
   }
   [self updateAudioButton];
}

- (void)updateAudioButton {
   if(audio_enabled) {
      [audio_button setTitle:@"Sound: ON" forState:0];
   } else {
      [audio_button setTitle:@"Sound: OFF" forState:0];
   }
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField {

   const char *temp = [user_field.text UTF8String];
   strncpy(default_user_name, temp, MAX_USER_NAME_LENGTH);
   default_user_name[MAX_USER_NAME_LENGTH] = 0;
   user_field.text = [NSString stringWithUTF8String:default_user_name];

   [user_field resignFirstResponder];

   return NO;
}

- (void)dealloc {
   [user_field release];
   [register_button release];
   [audio_button release];
   [reset_button release];
   [done_button release];
   [super dealloc];
}

@end

