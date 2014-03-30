//
//  SAMHUDView.h
//  SAMHUDView
//
//  Created by Sam Soffes on 9/29/09.
//  Copyright 2009-2014 Sam Soffes. All rights reserved.
//

@interface SAMHUDView : UIView

@property (nonatomic, readonly) UILabel *textLabel;
@property (nonatomic, readonly) UIActivityIndicatorView *activityIndicator;
@property (nonatomic) CGSize hudSize;
@property (nonatomic, getter=isLoading) BOOL loading;
@property (nonatomic, getter=isSuccessful) BOOL successful;
@property (nonatomic) BOOL hidesVignette;
@property (nonatomic, strong) UIImage *completeImage;
@property (nonatomic, strong) UIImage *failImage;

- (id)initWithTitle:(NSString *)aTitle;
- (id)initWithTitle:(NSString *)aTitle loading:(BOOL)isLoading;

- (void)show;
- (void)dismiss;
- (void)dismissAnimated:(BOOL)animated;

- (void)completeWithTitle:(NSString *)aTitle;
- (void)completeAndDismissWithTitle:(NSString *)aTitle;
- (void)completeQuicklyWithTitle:(NSString *)aTitle;

- (void)failWithTitle:(NSString *)aTitle;
- (void)failAndDismissWithTitle:(NSString *)aTitle;
- (void)failQuicklyWithTitle:(NSString *)aTitle;

@end
