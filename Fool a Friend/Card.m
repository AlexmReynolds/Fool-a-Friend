//
//  Card.m
//  Snap
//
//  Created by Alex Reynolds on 5/6/13.
//  Copyright (c) 2013 AlexReynolds. All rights reserved.
//

#import "Card.h"

@implementation Card
@synthesize question = _question;
@synthesize answer = _answer;
@synthesize category = _category;
@synthesize isTurnedOver = _isTurnedOver;

-(id) initWithQuestion:(NSString *)question answer:(NSString *)answer andCategory:(CardCategory)category
{
    NSLog(@"category from initwithquestion %i", category);
    NSAssert (question.length > 0 && answer.length > 0, @"Invalid card value");
    self = [super init];
    if (self){
        _question = question;
        _answer = answer;
        _category = category;
    }
    return self;
}
- (BOOL)isEqualToCard:(Card *)otherCard
{
	return (otherCard.question == self.question && otherCard.answer == self.answer);
}

-(NSString *)getCategoryText
{
    NSString *catText;
    switch(self.category){
        case Laws:
            catText = @"Laws";
            break;
        case Movies:
            catText = @"Movies";
            break;
        case Events:
            catText = @"Events";
            break;
        case People:
            catText = @"People";
            break;
            
    }
    return catText;
}
@end
