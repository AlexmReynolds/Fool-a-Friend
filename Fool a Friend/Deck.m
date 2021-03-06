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
    NSLog(@"here");
    NSDictionary *card1 = [[NSDictionary alloc] initWithObjectsAndKeys:@"What is 7 * 7?",@"question",@"49",@"answer",[NSNumber numberWithInt:Events],@"category", nil];
    NSDictionary *card2 = [[NSDictionary alloc] initWithObjectsAndKeys:@"What is Godzilla about?",@"question",@"Movie about monster",@"answer",[NSNumber numberWithInt:Movies],@"category", nil];
    NSDictionary *card3 = [[NSDictionary alloc] initWithObjectsAndKeys:@"It is illegal for a dog to?",@"question",@"Sleep indoors",@"answer",[NSNumber numberWithInt:Laws],@"category", nil];
    NSLog(@"Get Temp cards");
    NSDictionary *card4 = [[NSDictionary alloc] initWithObjectsAndKeys:@"It is Card4 for a dog to?",@"question",@"Run indoors",@"answer",[NSNumber numberWithInt:Laws],@"category", nil];
    NSLog(@"Get Temp cards");
    NSDictionary *card5 = [[NSDictionary alloc] initWithObjectsAndKeys:@"It is Card5 for a dog to?",@"question",@"Talk indoors",@"answer",[NSNumber numberWithInt:Laws],@"category", nil];
    NSLog(@"Get Temp cards");
    NSArray *cards = [NSArray arrayWithObjects:card1,card2,card3,card4,card5, nil];
    
    for (NSDictionary *basecard in cards){
        NSLog(@"load cards into deck card cat %i",[[basecard valueForKey:@"category"] intValue]);
        Card *card = [[Card alloc] initWithQuestion:[basecard objectForKey:@"question"] answer:[basecard objectForKey:@"answer"] andCategory:[[basecard valueForKey:@"category"]intValue ]];
        [_cards addObject:card];
    }
}
-(id) init{
    self = [super init];
    if (self){
        _cards = [NSMutableArray arrayWithCapacity:200];
        NSLog(@"now setup cards from Deck.m");
        [self setUpCards];
    }
    return self;
}
-(id) initWithCards:(NSArray *)cards
{
    self = [super init];
    if (self){
        _cards = [NSMutableArray arrayWithCapacity:[cards count]];
        [_cards addObjectsFromArray:cards];
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
-(NSArray *) getAllCards
{
    return _cards;
}
-(Card *)draw
{
    NSAssert([self cardsRemaining] > 0, @"No more cards in deck");
    Card *card = [_cards lastObject];
    [_cards removeLastObject];
    [_cards insertObject:card atIndex:0];
    return card;
}
-(int)cardsRemaining
{
    return [_cards count];
}
@end
