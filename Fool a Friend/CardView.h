//
//  CardView.h
//  Snap
//
//  Created by Alex Reynolds on 5/6/13.
//  Copyright (c) 2013 AlexReynolds. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Card.h"
#import "Player.h"
const CGFloat CardWidth;
const CGFloat CardHeight;

@interface CardView : UIView{
    UIImageView *_backImageView;
    UIImageView *_frontImageView;
    CGFloat _angle;
}

@property (nonatomic, strong) Card *card;
-(void) animateTurningOverForPlayer:(Player *)player;
-(void) animateDealingWithDelay:(NSTimeInterval)delay;
- (void)animateCloseAndMoveFromPlayer:(Player *)fromPlayer toPlayer:(Player *)toPlayer withDelay:(NSTimeInterval)delay;
- (void)animateRecycleForPlayer:(Player *)player withDelay:(NSTimeInterval)delay;
@end
