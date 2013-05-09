//
//  Stack.m
//  Snap
//
//  Created by Alex Reynolds on 5/6/13.
//  Copyright (c) 2013 AlexReynolds. All rights reserved.
//

#import "Stack.h"

@implementation Stack
-(id)init
{
    self = [super init];
    if(self){
        _cards = [NSMutableArray arrayWithCapacity:26];
    }
    return self;
}
-(void)addCardToTop:(Card *)card
{
    NSAssert(card != nil, @"Card cannot be nil");
    NSAssert([_cards indexOfObject:card] == NSNotFound, @"Already have this card");
    [_cards addObject:card];
}
-(NSUInteger)cardCount
{
    return [_cards count];
}
-(NSArray *)array
{
    return [_cards copy];
}
-(Card*)cardAtIndex:(NSUInteger)index
{
    return [_cards objectAtIndex:index];
}
-(void)addCardsFromArray:(NSArray *)array
{
    _cards = [array mutableCopy];
}
-(Card *)topMostCard{
    return [_cards lastObject];
}
-(void) removeTopMostCard
{
    [_cards removeLastObject];
}
-(void)removeAllCards
{
    [_cards removeAllObjects];
}
-(void) addCardToBottom:(Card *)card
{
    NSAssert(card != nil,@"Card cannot be nil");
    NSAssert([_cards indexOfObject:card] == NSNotFound, @"Already have this card");
    [_cards insertObject:card atIndex:0];
}
@end
