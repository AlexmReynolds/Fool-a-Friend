//
//  Deck.m
//  Full of it
//
//  Created by Alex Reynolds on 5/8/13.
//  Copyright (c) 2013 Alex Reynolds. All rights reserved.
//

#import "Deck.h"

@implementation Deck

-(void) setUpCards
{
    NSDictionary *card1 = [[NSDictionary alloc] initWithObjectsAndKeys:@"What is 7 * 7?",@"question",@"49",@"answer",Events,@"category", nil];
    NSDictionary *card2 = [[NSDictionary alloc] initWithObjectsAndKeys:@"What is Godzilla about?",@"question",@"Movie about monster",@"answer",Movies,@"category", nil];
    NSDictionary *card3 = [[NSDictionary alloc] initWithObjectsAndKeys:@"It is illegal for a dog to?",@"question",@"Sleep indoors",@"answer",Laws,@"category", nil];
    
    NSArray *cards = [NSArray arrayWithObjects:card1,card2,card3, nil];
    
    for (NSDictionary *basecard in cards){
        Card *card = [[Card alloc] initWithQuestion:[basecard objectForKey:@"question"] answer:[basecard objectForKey:@"answer"] andCategory:(CardCategory)[basecard valueForKey:@"category"]];
        [_cards addObject:card];
    }
}
-(id) init{
    self = [super init];
    if (self){
        _cards = [NSMutableArray arrayWithCapacity:200];
        [self setUpCards];
    }
    return self;
}
-(void) shuffle
{
    NSUInteger count = [_cards count];
    NSMutableArray *shuffled = [NSMutableArray arrayWithCapacity:200];
    
    for (int t=0; t <count; ++t){
        int i = arc4random() % [self cardsRemaining];
        Card *card = [_cards objectAtIndex:i];
        [shuffled addObject:card];
        [_cards removeObjectAtIndex:i];
    }
    
    NSAssert([self cardsRemaining] == 0, @"Original Deck should now be empty");
    _cards = shuffled;
}
-(Card *)draw
{
    NSAssert([self cardsRemaining] > 0, @"No more cards in deck");
    Card *card = [_cards lastObject];
    [_cards removeLastObject];
    return card;
}
-(int)cardsRemaining
{
    return [_cards count];
}
@end
