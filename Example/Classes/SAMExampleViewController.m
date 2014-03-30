//
//  SAMExampleViewController.m
//  Example
//
//  Created by Sam Soffes on 3/29/14.
//  Copyright (c) 2014 Sam Soffes. All rights reserved.
//

#import "SAMExampleViewController.h"
#import <SAMHUDView/SAMHUDView.h>

@implementation SAMExampleViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	self.view.backgroundColor = [UIColor grayColor];

	SAMHUDView *hud = [[SAMHUDView alloc] initWithTitle:@"Loading…" loading:YES];
	[hud show];
}


- (UIStatusBarStyle)preferredStatusBarStyle {
	return UIStatusBarStyleLightContent;
}

@end
