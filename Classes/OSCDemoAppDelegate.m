//
//  OSCDemoAppDelegate.m
//  OSCDemo
//
//  Created by georg on 12/04/2010.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "OSCDemoAppDelegate.h"
#import "OSCDemoViewController.h"

@implementation OSCDemoAppDelegate

@synthesize window;
@synthesize viewController;

 
- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
    
    [UIApplication sharedApplication].idleTimerDisabled=YES;
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"app will resign active");
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"app did enter background");
    [viewController loadView];
  //  [OSCDemoViewController refresh];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSLog(@"app will enter foreground");
      [viewController loadView];
   // [OSCDemoViewController refresh:NULL];
}

- (void)dealloc {
 //   [viewController release];
//    [window release];
//    
}


@end
