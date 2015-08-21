
#import "MenuView.h"
#import "KnockoutAppDelegate.h"
#import "HighScores.h"
#import "LevelPicker.h"
#import "Settings.h"

@implementation MenuView

- (id)initWithFrame:(CGRect)rect {

   self = [super initWithFrame:rect];
   if(self) {

      KnockoutAppDelegate *d = [UIApplication sharedApplication].delegate;

      // Top score table.
      scores = [[HighScores alloc]
                  initWithFrame:CGRectMake(32, 92, 200, 180)];
      [scores setDelegate:self];
      [self addSubview:scores];

      const float startx = 240;
      const float pickerx = startx + 48;
      const float picker_width = (480 - startx) - (pickerx - startx) * 2;
      const float buttonx = startx + 48;
      const float button_width = (480 - startx) - (buttonx - startx) * 2;

      // "New Game" button.
      new_game_button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
      new_game_button.frame = CGRectMake(buttonx, 36, button_width, 40);
      [new_game_button setTitle:@"New Game" forState:0];
      [new_game_button addTarget:d action:@selector(newGame)
                       forControlEvents:UIControlEventTouchUpInside];
      [self addSubview:new_game_button];

      // "Resume" button.
      resume_button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
      resume_button.frame = CGRectMake(buttonx, 96, button_width, 40);
      [resume_button setTitle:@"Resume" forState:0];
      [resume_button addTarget:d action:@selector(resume)
                     forControlEvents:UIControlEventTouchUpInside];
      [self addSubview:resume_button];

      // "Settings" button.
      settings_button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
      settings_button.frame = CGRectMake(buttonx, 156, button_width, 40);
      [settings_button addTarget:d action:@selector(showSettings)
                       forControlEvents:UIControlEventTouchUpInside];
      [settings_button setTitle:@"Settings" forState:0];
      [self addSubview:settings_button];

      // "Help" button.
      help_button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
      help_button.frame = CGRectMake(buttonx, 216, button_width, 40);
      [help_button setTitle:@"Help" forState:0];
      [help_button addTarget:d action:@selector(showHelp)
                   forControlEvents:UIControlEventTouchUpInside];
      [self addSubview:help_button];

      // Level picker.
      level_picker = [[LevelPicker alloc]
                        initWithFrame:CGRectMake(pickerx, 266,
                                                 picker_width, 40)];
      [self addSubview:level_picker];

      self.opaque = YES;
      self.backgroundColor = [UIColor darkGrayColor];
      new_score = 0;

   }
   return self;

}

- (void)drawRect:(CGRect)rect {
   [super drawRect:rect];
}

- (void)disable {
   new_game_button.enabled = NO;
   resume_button.enabled = NO;
   help_button.enabled = NO;
}

- (void)enable {
   new_game_button.enabled = YES;
   resume_button.enabled = YES;
   help_button.enabled = YES;
}

- (void)gameEnded:(unsigned int)score {
   new_score = score;
}

- (void)transitionComplete {
   if(new_score) {
      [scores newScore:new_score];
      new_score = 0;
   }
}

- (void)save {
   [scores save];
}

- (void)resetScores {
   [scores reset];
}

- (void)dealloc {
   [resume_button release];
   [new_game_button release];
   [settings_button release];
   [scores release];
   [level_picker release];
   [super dealloc];
}

@end

