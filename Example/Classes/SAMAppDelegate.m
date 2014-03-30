//
//  SAMAppDelegate.m
//  Example
//
//  Created by Sam Soffes on 3/29/14.
//  Copyright (c) 2014 Sam Soffes. All rights reserved.
//

#import "SAMAppDelegate.h"
#import "SAMExampleViewController.h"

@implementation SAMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.window.backgroundColor = [UIColor whiteColor];
	self.window.rootViewController = [[SAMExampleViewController alloc] init];
	[self.window makeKeyAndVisible];
	return YES;
}

@end
