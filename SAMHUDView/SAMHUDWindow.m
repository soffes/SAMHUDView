//
//  SAMHUDWindow.m
//  SAMHUDView
//
//  Created by Sam Soffes on 3/17/11.
//  Copyright 2011-2014 Sam Soffes. All rights reserved.
//

#import "SAMHUDWindow.h"
#import "SAMHUDWindowViewController.h"

static SAMHUDWindow *kHUDWindow = nil;

@implementation SAMHUDWindow

@synthesize hidesVignette = _hidesVignette;

#pragma mark - Accessors

- (void)setHidesVignette:(BOOL)hide {
	_hidesVignette = hide;
	self.userInteractionEnabled = !hide;
	[self setNeedsDisplay];
}


#pragma mark - Class Methods

+ (SAMHUDWindow *)defaultWindow {
	if (!kHUDWindow) {
		kHUDWindow = [[SAMHUDWindow alloc] init];
	}
	return kHUDWindow;
}


#pragma mark - NSObject

- (id)init {
	if ((self = [super initWithFrame:[[UIScreen mainScreen] bounds]])) {
		self.backgroundColor = [UIColor clearColor];
		self.windowLevel = UIWindowLevelStatusBar + 1.0f;
		self.rootViewController = [[SAMHUDWindowViewController alloc] init];
	}
	return self;
}


#pragma mark - UIView

- (void)drawRect:(CGRect)rect {
	if (self.hidesVignette) {
		return;
	}

	CGContextRef context = UIGraphicsGetCurrentContext();
	NSArray *colors = @[(id)[UIColor colorWithWhite:0.0f alpha:0.1f].CGColor, (id)[UIColor colorWithWhite:0.0f alpha:0.5f].CGColor];
	CGGradientRef gradient = CGGradientCreateWithColors(CGColorGetColorSpace((__bridge CGColorRef)colors[0]), (__bridge CFArrayRef)colors, NULL);
    CGPoint centerPoint  = CGPointMake(self.bounds.size.width / 2.0 , self.bounds.size.height / 2.0);
    CGContextDrawRadialGradient(context, gradient, centerPoint, 0.0f, centerPoint, fmaxf(self.bounds.size.width, self.bounds.size.height) / 2.0f, kCGGradientDrawsAfterEndLocation);
	CGGradientRelease(gradient);
}

@end
