//
//  FoolAFriendTextView.m
//  Fool a Friend
//
//  Created by Alex Reynolds on 5/12/13.
//  Copyright (c) 2013 Alex Reynolds. All rights reserved.
//

#import "FoolAFriendTextView.h"
#import <QuartzCore/QuartzCore.h>

@implementation FoolAFriendTextView

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self){
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 10.0f;
        self.layer.borderWidth = 2.0f;
        self.layer.borderColor = [[UIColor colorWithWhite:0.7 alpha:1.0] CGColor];
    }
    return self;
}

@end
