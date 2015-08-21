
#import "LevelPicker.h"
#import "Settings.h"

@implementation LevelPicker

- (id)initWithFrame:(CGRect)rect {

   self = [super initWithFrame:rect];
   if(!self) {
      return self;
   }

   const float item_width = rect.size.width / 3.0;
   const float item_height = rect.size.height;

   UIColor *bg_color = [UIColor clearColor];
   UIColor *fg_color = [UIColor whiteColor];

   // "<-" button.
   UIImage *left_image = [UIImage imageNamed:@"left.png"];
   left_button = [UIButton buttonWithType:UIButtonTypeCustom];
   left_button.frame = CGRectMake(0.0, 0.0, item_width, item_height);
   left_button.opaque = NO;
   left_button.backgroundColor = bg_color;
   [left_button setImage:[left_image autorelease] forState:0];
   [left_button addTarget:self action:@selector(decrement)
                forControlEvents:UIControlEventTouchDown];
   [self addSubview:left_button];

   // Label.
   label = [[UILabel alloc] initWithFrame:CGRectMake(item_width, 0.0,
                                                     item_width, item_height)];
   label.textAlignment = UITextAlignmentCenter;
   label.text = @"1";
   label.opaque = NO;
   label.backgroundColor = bg_color;
   label.textColor = fg_color;
   [self addSubview:label];

   // "->" button.
   UIImage *right_image = [UIImage imageNamed:@"right.png"];
   right_button = [UIButton buttonWithType:UIButtonTypeCustom];
   right_button.frame = CGRectMake(2.0 * item_width, 0.0,
                                   item_width, item_height);
   right_button.opaque = NO;
   right_button.backgroundColor = bg_color;
   [right_button setImage:[right_image autorelease] forState:0];
   [right_button addTarget:self action:@selector(increment)
                 forControlEvents:UIControlEventTouchDown];
   [self addSubview:right_button];

   [self draw];

   return self;

}

- (void)increment {
   if(start_level < highest_level) {
      ++start_level;
   } else {
      start_level = 1;
   }
   [self draw];
}

- (void)decrement {
   if(start_level > 1) {
      --start_level;
   } else {
      start_level = highest_level;
   }
   [self draw];
}

- (void)draw {
   char temp[8];
   sprintf(temp, "%u", start_level);
   label.text = [NSString stringWithUTF8String:temp];
}

- (void)dealloc {
   [label release];
   [left_button release];
   [right_button release];
   [super dealloc];
}

@end

