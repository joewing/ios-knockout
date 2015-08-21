//
//  KnockoutAppDelegate.h
//  Knockout
//
//  Created by Joe Wingbermuehle on 8/4/08.
//  Copyright Joe Wingbermuehle 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Settings;
@class BoardView;
@class MenuView;
@class SettingsView;
@class HelpView;
@class TransitionView;

@interface KnockoutAppDelegate : NSObject <UIApplicationDelegate> {
   UIWindow *window;
   BoardView *board_view;
   MenuView *menu_view;
   SettingsView *settings_view;
   HelpView *help_view;
   Settings *settings;
   TransitionView *transition_view;
}

- (void)pause;

- (void)gameEnded:(unsigned int)score;

- (void)resetScores;

@end

