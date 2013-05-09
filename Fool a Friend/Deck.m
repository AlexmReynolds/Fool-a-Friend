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
    for(Suit suit = SuitClubs; suit <= SuitSpades; ++suit){
        for (int value = CardAce; value <= CardKing; ++value){
            Card *card = [[Card alloc] initWithSuit:suit value:value];
            [_cards addObject:card];
        }
    }
}
-(id) init{
    self = [super init];
    if (self){
        _cards = [NSMutableArray arrayWithCapacity:52];
        [self setUpCards];
    }
    return self;
}
-(void) shuffle
{
    NSUInteger count = [_cards count];
    NSMutableArray *shuffled = [NSMutableArray arrayWithCapacity:52];
    
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
