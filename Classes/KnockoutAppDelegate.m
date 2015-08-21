//
//  KnockoutAppDelegate.m
//  Knockout
//
//  Created by Joe Wingbermuehle on 8/4/08.
//  Copyright Joe Wingbermuehle 2008. All rights reserved.
//

#import "KnockoutAppDelegate.h"
#import "BoardView.h"
#import "MenuView.h"
#import "SettingsView.h"
#import "HelpView.h"
#import "TransitionView.h"
#import "Settings.h"

@implementation KnockoutAppDelegate

- (void)applicationDidFinishLaunching:(UIApplication*)application {   

   // Set our orientation.
   application.statusBarOrientation = UIInterfaceOrientationLandscapeRight;

   // Load settings.
   settings = [[Settings alloc] init];

   CGRect rect = CGRectMake(0, 0, 320, 480);
   transition_view = [[TransitionView alloc] initWithFrame:rect];

   menu_view = [[MenuView alloc] initWithFrame:rect];
   board_view = [[BoardView alloc] initWithFrame:rect];
   settings_view = [[SettingsView alloc] initWithFrame:rect];
   help_view = [[HelpView alloc] initWithFrame:rect];
   [transition_view setDelegate:menu_view];
   [transition_view addSubview:menu_view];

   [window addSubview:transition_view];
   [window bringSubviewToFront:transition_view];
   [window makeKeyAndVisible];


}

- (void)applicationWillTerminate:(UIApplication*)application {
   [settings save];
   [menu_view save];
   [board_view save];
}

- (void)dealloc {
   [window release];
   [transition_view release];
   [board_view release];
   [menu_view release];
   [settings_view release];
   [help_view release];
   [settings release];
   [super dealloc];
}

- (void)newGame {
   [transition_view replace:menu_view with:board_view];
   [board_view newGame];
}

- (void)pause {
   [transition_view replace:board_view with:menu_view];
}

- (void)resume {
   [transition_view replace:menu_view with:board_view];
   [board_view resume];
}

- (void)gameEnded:(unsigned int)score {
   [transition_view replace:board_view with:menu_view];
   [menu_view gameEnded:score];
}

- (void)showSettings {
   [transition_view replace:menu_view with:settings_view];
}

- (void)closeSettings {
   [transition_view replace:settings_view with:menu_view];
}

- (void)showHelp {
   [transition_view replace:menu_view with:help_view];
}

- (void)closeHelp {
   [transition_view replace:help_view with:menu_view];
}

- (void)resetScores {
   [menu_view resetScores];
}

@end

