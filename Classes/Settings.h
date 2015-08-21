
#import <Foundation/NSObject.h>

#define MAX_USER_NAME_LENGTH  64

extern unsigned int start_level;
extern unsigned int highest_level;
extern int audio_enabled;
extern char default_user_name[MAX_USER_NAME_LENGTH + 1];

@interface Settings : NSObject {
}

- (id)init;

- (void)load;

- (void)save;

@end

