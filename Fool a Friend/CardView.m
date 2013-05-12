//
//  CardView.m
//  Snap
//
//  Created by Alex Reynolds on 5/6/13.
//  Copyright (c) 2013 AlexReynolds. All rights reserved.
//

#import "CardView.h"
const CGFloat CardWidth = 67.0f;
const CGFloat CardHeight = 99.0f;
@implementation CardView

@synthesize card = _card;

-(id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self){
        self.backgroundColor = [UIColor clearColor];
        [self loadBack];
    }
    return self;
}
-(void)loadBack{
    if (_backImageView == nil){
        _backImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _backImageView.image = [UIImage imageNamed:@"Back"];
        _backImageView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:_backImageView];
    }
}
-(void) animateDealingWithDelay :(NSTimeInterval)delay
{
    self.frame = CGRectMake(-100.0f, -100.0f, CardWidth, CardHeight);
    self.transform = CGAffineTransformMakeRotation(M_PI);
    
    CGRect rect = self.superview.bounds;
    CGFloat midX = CGRectGetMidX(rect);
    CGFloat midY = CGRectGetMidY(rect);
    CGFloat maxX = CGRectGetMaxX(rect);
    CGFloat maxY = CGRectGetMaxY(rect);
    NSLog(@"midx %f midy %f", midX, midY);
    
    CGPoint point = CGPointMake(midX ,midY);
    _angle = (-0.5f + RANDOM_FLOAT()) / 4.0f;
    
    [UIView animateWithDuration:0.2f
                          delay:delay
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.center = point;
                         self.transform = CGAffineTransformMakeRotation(_angle);
                     } completion:nil];
}
- (void)unloadFront
{
	[_frontImageView removeFromSuperview];
	_frontImageView = nil;
}

-(void) loadFront
{
    if(_frontImageView == nil){
        _frontImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _frontImageView.contentMode = UIViewContentModeScaleToFill;
        _frontImageView.hidden = YES;
    }
}
-(void) unloadBack
{
    [_backImageView removeFromSuperview];
    _backImageView = nil;
}
@end
