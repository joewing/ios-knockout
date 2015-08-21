
#import "HighScores.h"
#import <CFNetwork/CFHTTPMessage.h>
#import <CFNetwork/CFHTTPStream.h>

#import "Settings.h"

typedef struct {
   char name[64];
   char score[8];
} FileNode;

static NSString *score_file = @"scores.dat";

@implementation HighScores

- (id)initWithFrame:(CGRect)rect {

   self = [super initWithFrame:rect];
   if(!self) {
      return self;
   }

   UIColor *bg_color = [UIColor clearColor];
   UIColor *fg_color = [UIColor whiteColor];

   const float spacing = 8.0;
   const float sp_per = spacing / 2.0;
   const float item_height = rect.size.height / (HIGHSCORE_COUNT + 1);
   const float name_width = 2.0 * rect.size.width / 3.0;
   const float score_width = rect.size.width - name_width;

   CGRect title_frame = CGRectMake(0, 0, rect.size.width, item_height);
   title = [[UILabel alloc] initWithFrame:title_frame];
   title.text = @"Top Scores";
   title.textAlignment = UITextAlignmentCenter;
   title.opaque = NO;
   title.backgroundColor = bg_color;
   title.textColor = fg_color;
   [self addSubview:title];

   int y;
   for(y = 0; y < HIGHSCORE_COUNT; y++) {

      const float yoffset = (y + 1) * item_height;
      CGRect name_frame = CGRectMake(0, yoffset,
                                     name_width - sp_per, item_height);
      CGRect score_frame = CGRectMake(name_width + sp_per, yoffset,
                                      score_width - sp_per, item_height);

      names[y] = [[UILabel alloc] initWithFrame:name_frame];
      names[y].text = @"Nobody";
      names[y].textAlignment = UITextAlignmentLeft;
      names[y].opaque = NO;
      names[y].backgroundColor = bg_color;
      names[y].textColor = fg_color;
      [self addSubview:names[y]];

      scores[y] = [[UILabel alloc] initWithFrame:score_frame];
      scores[y].text = @"0";
      scores[y].textAlignment = UITextAlignmentRight;
      scores[y].opaque = NO;
      scores[y].backgroundColor = bg_color;
      scores[y].textColor = fg_color;
      [self addSubview:scores[y]];

   }

   CGRect input_frame = CGRectMake(0, item_height,
                                   rect.size.width, item_height);
   input = [[UITextField alloc] initWithFrame:input_frame];
   input.hidden = YES;
   input.delegate = self;
   input.backgroundColor = [UIColor whiteColor];
   input.opaque = YES;
   [self addSubview:input];

   [self load];

   delegate = nil;

   return self;

}

- (void)setDelegate:(id <HighScoresDelegate>)d {
   delegate = d;
}

- (void)newScore:(unsigned int)score {

   // Determine if this is a new high score and where
   // to insert it if so.
   int pos;
   for(pos = 0; pos < HIGHSCORE_COUNT; pos++) {
      unsigned int temp = atoi(scores[pos].text.UTF8String);
      if(score > temp) {
         break;
      }
   }
   if(pos >= HIGHSCORE_COUNT) {
      // Not a new high score.
      return;
   }

   // A new high score.

   // Disable controls on the delegate.
   [delegate disable];

   // Move everything pos -> pos + 1.
   int x;
   for(x = HIGHSCORE_COUNT - 1; x > pos; x--) {
      names[x].text = names[x - 1].text;
      scores[x].text = scores[x - 1].text;
   }

   // Set the new score.
   char temp[8];
   sprintf(temp, "%u", score);
   scores[pos].text = [NSString stringWithUTF8String:temp];

   // Clear out the old name.
   names[pos].text = @"";

   // Get the user's name.
   new_score = score;
   new_pos = pos;
   input.hidden = NO;
   input.text = [NSString stringWithUTF8String:default_user_name];
   [input becomeFirstResponder];

}

- (BOOL)textFieldShouldReturn:(UITextField*)textField {

  input.hidden = YES;
  names[new_pos].text = input.text;
  [input resignFirstResponder];
  [delegate enable];

   return NO;

}

- (void)load {

   // Get the file to open.
   NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                        NSUserDomainMask, YES);
   NSString *dir = [paths objectAtIndex:0];
   NSString *hs_path = [dir stringByAppendingPathComponent:score_file];

   // Open the file.
   FILE *fd = fopen([hs_path UTF8String], "rb");
   if(fd) {

      // Read the scores.
      int x = 0;
      for(x = 0; x < HIGHSCORE_COUNT; x++) {
         FileNode node;
         size_t sz = fread(&node, sizeof(node), 1, fd);
         if(sz != 1) {
            break;
         }
         node.name[sizeof(node.name) - 1] = 0;
         node.score[sizeof(node.score) - 1] = 0;
         names[x].text = [NSString stringWithUTF8String:node.name];
         scores[x].text = [NSString stringWithUTF8String:node.score];
      }

      fclose(fd);
   }

}

- (void)save {

   // Get the file to open.
   NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                        NSUserDomainMask, YES);
   NSString *dir = [paths objectAtIndex:0];
   NSString *hs_path = [dir stringByAppendingPathComponent:score_file];

   // Open the file.
   FILE *fd = fopen([hs_path UTF8String], "wb");
   if(fd) {

      // Write the scores.
      int x = 0;
      for(x = 0; x < HIGHSCORE_COUNT; x++) {
         FileNode node;
         memset(&node, 0, sizeof(node));
         strncpy(node.name, [names[x].text UTF8String],
                 sizeof(node.name) - 1);
         strncpy(node.score, [scores[x].text UTF8String],
                 sizeof(node.score) - 1);
         fwrite(&node, sizeof(node), 1, fd);
      }

      fclose(fd);
   }

}

- (void)reset {
   UIAlertView *alert;
   alert = [[UIAlertView alloc] initWithTitle:@"Reset" 
                                message:@"Reset scores?"
                                delegate:self
                                cancelButtonTitle:@"No"
                                otherButtonTitles:@"Yes", nil];
   [alert show];
}

- (void)alertView:(UIAlertView*)alertView
        clickedButtonAtIndex:(NSInteger)buttonIndex {

   // The only way buttonIndex == 1 is if the reset alert was displayed
   // and "Yes" was selected.
   if(buttonIndex == 1) {
      int x;
      for(x = 0; x < HIGHSCORE_COUNT; x++) {
         names[x].text = @"Nobody";
         scores[x].text = @"0";
      }
   }

   [alertView autorelease];

}

- (void)dealloc {

   [title dealloc];

   int x;
   for(x = 0; x < HIGHSCORE_COUNT; x++) {
      [names[x] dealloc];
      [scores[x] dealloc];
   }

   [super dealloc];

}

@end

