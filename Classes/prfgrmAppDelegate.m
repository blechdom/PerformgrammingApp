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
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
