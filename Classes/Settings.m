
#import "Settings.h"
#import "level.h"

unsigned int start_level;
unsigned int highest_level;
int audio_enabled;
char default_user_name[MAX_USER_NAME_LENGTH + 1];

static NSString *settings_file = @"settings.dat";

typedef struct {
   unsigned int start_level;
   unsigned int highest_level;
   int audio_enabled;
   char default_user_name[MAX_USER_NAME_LENGTH];
} FileNode;

@implementation Settings

- (id)init {
   self = [super init];
   [self load];
   return self;
}

- (void)load {

   // Set the defaults.
   start_level = 1;
   highest_level = max_level;
   audio_enabled = 1;
   strncpy(default_user_name, "nobody", MAX_USER_NAME_LENGTH);
   default_user_name[MAX_USER_NAME_LENGTH] = 0;

   // Get the file to open.
   NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                        NSUserDomainMask, YES);
   NSString *dir = [paths objectAtIndex:0];
   NSString *path = [dir stringByAppendingPathComponent:settings_file];

   // Open the file.
   FILE *fd = fopen([path UTF8String], "rb");
   if(fd) {

      // Read the selected level.
      FileNode node;
      size_t sz = fread(&node, sizeof(node), 1, fd);
      if(sz == 1) {
         start_level = node.start_level;
         highest_level = node.highest_level;
         audio_enabled = node.audio_enabled;
         memcpy(default_user_name, node.default_user_name,
                MAX_USER_NAME_LENGTH);
         default_user_name[MAX_USER_NAME_LENGTH] = 0;
         if(highest_level > max_level) {
            highest_level = 1;
         }
         if(start_level > highest_level) {
            start_level = 1;
         }
      }

      fclose(fd);
   }
}

- (void)save {

   // Get the file to open.
   NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                        NSUserDomainMask, YES);
   NSString *dir = [paths objectAtIndex:0];
   NSString *path = [dir stringByAppendingPathComponent:settings_file];

   // Open the file.
   FILE *fd = fopen([path UTF8String], "wb");
   if(fd) {

      // Write the selected level.
      FileNode node;
      node.start_level = start_level;
      node.highest_level = highest_level;
      node.audio_enabled = audio_enabled;
      memcpy(node.default_user_name, default_user_name,
             MAX_USER_NAME_LENGTH);
      fwrite(&node, sizeof(node), 1, fd);

      fclose(fd);
   }
}

@end

