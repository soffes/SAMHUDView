//
//  SAMHUDView.m
//  SAMHUDView
//
//  Created by Sam Soffes on 9/29/09.
//  Copyright 2009-2014 Sam Soffes. All rights reserved.
//

#import "SAMHUDView.h"
#import "SAMHUDWindow.h"
#import "SAMHUDWindowViewController.h"

#import <QuartzCore/QuartzCore.h>

static SAMHUDWindow *kHUDWindow = nil;
static CGFloat kIndicatorSize = 40.0;

@interface SAMHUDView ()
@property (nonatomic, readonly) SAMHUDWindow *hudWindow;
@property (nonatomic, strong) UIWindow *keyWindow;

- (void)setTransformForCurrentOrientation:(BOOL)animated;
- (void)deviceOrientationChanged:(NSNotification *)notification;
- (void)removeWindow;
@end

@implementation SAMHUDView

#pragma mark - Accessors

@synthesize textLabel = _textLabel;
@synthesize activityIndicator = _activityIndicator;
@synthesize hudSize = _hudSize;
@synthesize loading = _loading;
@synthesize successful = _successful;
@synthesize completeImage = _completeImage;
@synthesize failImage = _failImage;
@synthesize keyWindow = _keyWindow;

- (void)setLoading:(BOOL)isLoading {
	_loading = isLoading;
	self.activityIndicator.alpha = _loading ? 1.0 : 0.0;
	[self setNeedsDisplay];
}


- (BOOL)hidesVignette {
	return self.hudWindow.hidesVignette;
}


- (void)setHidesVignette:(BOOL)hide {
	self.hudWindow.hidesVignette = hide;
}


- (UIActivityIndicatorView *)activityIndicator {
	if (!_activityIndicator) {
		_activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		_activityIndicator.alpha = 0.0;
	}
	return _activityIndicator;
}


- (UILabel *)textLabel {
	if (!_textLabel) {
		_textLabel = [[UILabel alloc] init];
		_textLabel.font = [UIFont boldSystemFontOfSize:14];
		_textLabel.backgroundColor = [UIColor clearColor];
		_textLabel.textColor = [UIColor whiteColor];
		_textLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.7f];
		_textLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
		_textLabel.textAlignment = NSTextAlignmentCenter;
		_textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
		_textLabel.adjustsFontSizeToFitWidth = YES;
	}
	return _textLabel;
}


- (SAMHUDWindow *)hudWindow {
	if (!kHUDWindow) {
		kHUDWindow = [[SAMHUDWindow alloc] init];
	}
	return kHUDWindow;
}


#pragma mark - NSObject

- (id)init {
	return (self = [self initWithTitle:nil loading:YES]);
}


- (void)dealloc {
    [self dismiss];
}


#pragma mark - UIView

- (id)initWithFrame:(CGRect)frame {
	return (self = [self initWithTitle:nil loading:YES]);
}


- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();

	// Draw rounded rectangle
	CGContextSetRGBFillColor(context, 0.0f, 0.0f, 0.0f, 0.5f);
	CGRect rrect = CGRectMake(0.0f, 0.0f, self.hudSize.width, self.hudSize.height);
	[[UIBezierPath bezierPathWithRoundedRect:rrect cornerRadius:14.0f] fill];

	// Image
	if (self.loading == NO) {
		[[UIColor whiteColor] set];

		UIImage *image = self.successful ? self.completeImage : self.failImage;

		if (image) {
			CGSize imageSize = image.size;
			CGRect imageRect = CGRectMake(roundf((self.hudSize.width - imageSize.width) / 2.0f),
										  roundf((self.hudSize.height - imageSize.height) / 2.0f),
										  imageSize.width, imageSize.height);
			[image drawInRect:imageRect];
			return;
		}

		NSString *dingbat = self.successful ? @"✔" : @"✘";
		NSDictionary *attributes = @{
			NSFontAttributeName: [UIFont systemFontOfSize:60.0f],
			NSForegroundColorAttributeName: [UIColor whiteColor]
		};
		CGSize dingbatSize = [dingbat sizeWithAttributes:attributes];
		CGRect dingbatRect = CGRectMake(roundf((self.hudSize.width - dingbatSize.width) / 2.0f),
										roundf((self.hudSize.height - dingbatSize.height) / 2.0f),
										dingbatSize.width, dingbatSize.height);
		[dingbat drawInRect:dingbatRect withAttributes:attributes];
	}
}


- (void)layoutSubviews {
	self.activityIndicator.frame = CGRectMake(roundf((self.hudSize.width - kIndicatorSize) / 2.0f),
										  roundf((self.hudSize.height - kIndicatorSize) / 2.0f),
										  kIndicatorSize, kIndicatorSize);

	if (self.textLabel.hidden) {
		self.textLabel.frame = CGRectZero;
	} else {
		CGSize textSize = [self.textLabel sizeThatFits:self.bounds.size];
		self.textLabel.frame = CGRectMake(0.0f, roundf(self.hudSize.height - textSize.height - 10.0f), self.hudSize.width, textSize.height);
	}
}


#pragma mark - HUD

- (id)initWithTitle:(NSString *)aTitle {
	return [self initWithTitle:aTitle loading:YES];
}


- (id)initWithTitle:(NSString *)aTitle loading:(BOOL)isLoading {
	if ((self = [super initWithFrame:CGRectZero])) {
		self.backgroundColor = [UIColor clearColor];

		self.hudSize = CGSizeMake(172.0f, 172.0f);

		// Activity indicator
		[self.activityIndicator startAnimating];
		[self addSubview:self.activityIndicator];

		// Text Label
		self.textLabel.text = aTitle ? aTitle : NSLocalizedString(@"Loading…", nil);
		[self addSubview:self.textLabel];

		// Loading
		self.loading = isLoading;

		// Images
		self.completeImage = [UIImage imageNamed:@"SAMHUDView-Check"];
		self.failImage = [UIImage imageNamed:@"SAMHUDView-X"];

		// Orientation
		[self setTransformForCurrentOrientation:NO];
	}
	return self;
}


- (void)show {
	id<UIApplicationDelegate> delegate = [[UIApplication sharedApplication] delegate];
	if ([delegate respondsToSelector:@selector(window)]) {
        self.keyWindow = [delegate performSelector:@selector(window)];
	} else {
		// Unable to get main window from app delegate
		self.keyWindow = [[UIApplication sharedApplication] keyWindow];
	}

	SAMHUDWindowViewController *viewController = (SAMHUDWindowViewController *)self.hudWindow.rootViewController;
	viewController.statusBarStyle = [[UIApplication sharedApplication] statusBarStyle];

	self.hudWindow.alpha = 0.0f;
	self.alpha = 0.0f;
	[self.hudWindow addSubview:self];
	[self.hudWindow makeKeyAndVisible];

	[UIView beginAnimations:@"SAMHUDViewFadeInWindow" context:nil];
	self.hudWindow.alpha = 1.0f;
	[UIView commitAnimations];

	CGSize windowSize = self.hudWindow.frame.size;
	CGRect contentFrame = CGRectMake(roundf((windowSize.width - self.hudSize.width) / 2.0f),
									 roundf((windowSize.height - self.hudSize.height) / 2.0f) + 10.0f,
									 self.hudSize.width, self.hudSize.height);


    static CGFloat const offset = 20.0f;
    if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
		contentFrame.origin.y += offset;
    } else {
        contentFrame.origin.x += offset;
    }
	self.frame = contentFrame;

	[UIView beginAnimations:@"SAMHUDViewFadeInContentAlpha" context:nil];
	[UIView setAnimationDelay:0.1];
	[UIView setAnimationDuration:0.2];
	self.alpha = 1.0f;
	[UIView commitAnimations];

	[UIView beginAnimations:@"SAMHUDViewFadeInContentFrame" context:nil];
	[UIView setAnimationDelay:0.1];
	[UIView setAnimationDuration:0.3];
	self.frame = contentFrame;
	[UIView commitAnimations];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
}


- (void)completeWithTitle:(NSString *)aTitle {
	self.successful = YES;
	self.loading = NO;
	self.textLabel.text = aTitle;
}


- (void)completeAndDismissWithTitle:(NSString *)aTitle {
	[self completeWithTitle:aTitle];
	double delayInSeconds = 1.0;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		[self dismiss];
	});
}


- (void)completeQuicklyWithTitle:(NSString *)aTitle {
	[self completeWithTitle:aTitle];
	[self show];
	double delayInSeconds = 1.05;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		[self dismiss];
	});
}


- (void)failWithTitle:(NSString *)aTitle {
	self.successful = NO;
	self.loading = NO;
	self.textLabel.text = aTitle;
}


- (void)failAndDismissWithTitle:(NSString *)aTitle {
	[self failWithTitle:aTitle];
	double delayInSeconds = 1.0;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		[self dismiss];
	});
}


- (void)failQuicklyWithTitle:(NSString *)aTitle {
	[self failWithTitle:aTitle];
	[self show];
	double delayInSeconds = 1.05;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		[self dismiss];
	});
}


- (void)dismiss {
	[self dismissAnimated:YES];
}


- (void)dismissAnimated:(BOOL)animated {
	if (!self.superview) {
		return;
	}

	[UIView beginAnimations:@"SAMHUDViewFadeOutContentFrame" context:nil];
	[UIView setAnimationDuration:0.2];
	CGRect contentFrame = self.frame;
    CGFloat offset = 20.0f;
    if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
		contentFrame.origin.y += offset;
    } else {
		contentFrame.origin.x += offset;
    }
	self.frame = contentFrame;
	[UIView commitAnimations];

	[UIView beginAnimations:@"SAMHUDViewFadeOutContentAlpha" context:nil];
	[UIView setAnimationDelay:0.1];
	[UIView setAnimationDuration:0.2];
	self.alpha = 0.0f;
	[UIView commitAnimations];

	[UIView beginAnimations:@"SAMHUDViewFadeOutWindow" context:nil];
	self.hudWindow.alpha = 0.0f;
	[UIView commitAnimations];

	if (animated) {
		double delayInSeconds = 0.3;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			[self removeWindow];
		});
	} else {
		[self removeWindow];
	}
}


#pragma mark - Private

- (void)setTransformForCurrentOrientation:(BOOL)animated {
	CGFloat rotation = 0.0f;
	switch ([UIApplication sharedApplication].statusBarOrientation) {
		case UIInterfaceOrientationPortrait: {
			// Zero
			break;
		}

		case UIInterfaceOrientationLandscapeLeft: {
			rotation = 0;
			break;
		}

		case UIInterfaceOrientationLandscapeRight: {
			rotation = 0;
			break;
		}

		case UIInterfaceOrientationPortraitUpsideDown: {
			rotation = M_PI;
			break;
		}
	}

    CGAffineTransform rotationTransform = CGAffineTransformMakeRotation(rotation);

	if (animated) {
		[UIView beginAnimations:@"SAMHUDViewRotationTransform" context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:0.3];
	}

	[self setTransform:rotationTransform];

    if (animated) {
		[UIView commitAnimations];
	}
}


- (void)deviceOrientationChanged:(NSNotification *)notification {
    [self setTransformForCurrentOrientation:YES];
	[self setNeedsDisplay];
}


- (void)removeWindow {
	[self removeFromSuperview];
	[self.hudWindow resignKeyWindow];

	// Return focus to the main window
	[self.keyWindow makeKeyWindow];
	self.keyWindow = nil;
	kHUDWindow = nil;

	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

@end
