
#import <AudioToolbox/AudioToolbox.h>

#import "audio.h"
#import "Settings.h"

static SystemSoundID LoadSound(CFStringRef name);
static void DestroySound(SystemSoundID sid);

static CFStringRef click_name = CFSTR("click");
static SystemSoundID click_sound;

static CFStringRef complete_name = CFSTR("complete");
static SystemSoundID complete_sound;

static CFStringRef switch_name = CFSTR("switch");
static SystemSoundID switch_sound;

static CFStringRef die_name = CFSTR("die");
static SystemSoundID die_sound;

static CFStringRef lose_name = CFSTR("lose");
static SystemSoundID lose_sound;

void InitializeAudio() {
   AudioSessionInitialize(NULL, NULL, NULL, NULL);
   const UInt32 value = kAudioSessionCategory_UserInterfaceSoundEffects;
   AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                          sizeof(value), &value);
   AudioSessionSetActive(true);
   click_sound = LoadSound(click_name);
   complete_sound = LoadSound(complete_name);
   switch_sound = LoadSound(switch_name);
   die_sound = LoadSound(die_name);
   lose_sound = LoadSound(lose_name);
}

void DestroyAudio() {
   DestroySound(click_sound);
   DestroySound(complete_sound);
   DestroySound(switch_sound);
   DestroySound(die_sound);
   DestroySound(lose_sound);
   AudioSessionSetActive(false);
}

void PlayClick() {
   if(audio_enabled) {
      AudioServicesPlaySystemSound(click_sound);
   }
}

void PlayComplete() {
   if(audio_enabled) {
      AudioServicesPlaySystemSound(complete_sound);
   }
}

void PlayLose() {
   if(audio_enabled) {
      AudioServicesPlaySystemSound(lose_sound);
   }
}

void PlayDie() {
   if(audio_enabled) {
      AudioServicesPlaySystemSound(die_sound);
   }
}

void PlaySwitch() {
   if(audio_enabled) {
      AudioServicesPlaySystemSound(switch_sound);
   }
}

SystemSoundID LoadSound(CFStringRef name) {

   SystemSoundID sid;
   CFBundleRef bundle;
   CFURLRef url;

   bundle = CFBundleGetMainBundle();

   // Get a URL for the sound.
   url = CFBundleCopyResourceURL(bundle, name, CFSTR("wav"), NULL);

   OSStatus rc = AudioServicesCreateSystemSoundID(url, &sid);
   if(rc) {
      sid = 0;
   }

   CFRelease(url);

   return sid;

}

void DestroySound(SystemSoundID sid) {
   AudioServicesDisposeSystemSoundID(sid);
}

