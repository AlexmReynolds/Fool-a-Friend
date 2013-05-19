//
//  Player.m
//  Full of it
//
//  Created by Alex Reynolds on 5/8/13.
//  Copyright (c) 2013 Alex Reynolds. All rights reserved.
//

#import "Player.h"

@implementation Player
@synthesize name = _name;
@synthesize peerID = _peerID;
@synthesize receivedResponse = _receivedResponse;
@synthesize points = _points;
@synthesize closedCards = _closedCards;
@synthesize openCards = _openCards;
@synthesize lastPacketNumberReceived = _lastPacketNumberReceived;
@synthesize position = _position;
@synthesize hasVoted = _hasVoted;
-(id) init
{
    self =[super init];
    if (self){
        _lastPacketNumberReceived = -1;
        _points = 0;
        _closedCards = [[Stack alloc] init];
        _openCards = [[Stack alloc] init];
    }
    return self;
}
- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ peerID = %@, name = %@", [super description], self.peerID, self.name];
}
-(Card *)turnOverTopCard
{
    NSAssert([self.closedCards cardCount] > 0, @"No more cards");
    
    Card *card = [self.closedCards topMostCard];
    card.isTurnedOver = YES;
    [self.openCards addCardToTop:card];
    [self.closedCards removeTopMostCard];
    
    return card;
}
-(BOOL)shouldRecycle
{
    return ([self.closedCards cardCount] == 0) && ([self.openCards cardCount] > 1);
}
-(NSArray *)recycleCards
{
    return [self giveAllOpenCardsToPlayer:self];
}
-(NSArray * )giveAllOpenCardsToPlayer:(Player *)otherPlayer
{
    NSUInteger count = [self.openCards cardCount];
    NSMutableArray *movedCards = [NSMutableArray arrayWithCapacity:count];
    
    for(NSUInteger t = 0; t <count; t++){
        Card *card = [self.openCards cardAtIndex:t];
        card.isTurnedOver = NO;
        [otherPlayer.closedCards addCardToBottom:card];
        [movedCards addObject:card];
    }
    [self.openCards removeAllCards];
    return movedCards;
}
- (int)totalCardCount
{
	return [self.closedCards cardCount] + [self.openCards cardCount];
}
@end
