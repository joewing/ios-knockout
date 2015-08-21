
#import "HelpView.h"
#import "KnockoutAppDelegate.h"

static const char *help_message[] = {
 "Tilt to move the ball. The object is to clear all solid",
 "blocks as quickly as possible. Blocks with a dot switch",
 "the color of the block to clear. Blocks with a skull take",
 "away a ball. Dark gray blocks must be cleared first and",
 "light gray blocks cleared last."
};

static const int help_line_count =
   sizeof(help_message) / sizeof(help_message[0]);

@implementation HelpView

- (id)initWithFrame:(CGRect)rect {

   self = [super initWithFrame:rect];
   if(self) {

      KnockoutAppDelegate *d = [UIApplication sharedApplication].delegate;

      ok_button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
      ok_button.frame = CGRectMake(240 - 64, 240, 128, 40);
      [ok_button setTitle:@"Close" forState:0];
      [ok_button addTarget:d action:@selector(closeHelp)
                 forControlEvents:UIControlEventTouchUpInside];
      [self addSubview:ok_button];

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

   int line;
   for(line = 0; line < help_line_count; line++) {
      CGContextSaveGState(context);
      CGContextSetTextPosition(context, 0.0, 0.0);
      CGContextTranslateCTM(context, 32, 128 + (16 + 2) * line);
      CGContextScaleCTM(context, 1.0, -1.0);
      CGContextShowText(context, help_message[line],
                        strlen(help_message[line]));
      CGContextRestoreGState(context);
   }

   CGContextRestoreGState(context);

}

- (void)dealloc {
   [ok_button release];
   [super dealloc];
}

@end

