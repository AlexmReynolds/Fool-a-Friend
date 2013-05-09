//
//  Card.h
//  Snap
//
//  Created by Alex Reynolds on 5/6/13.
//  Copyright (c) 2013 AlexReynolds. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum
{
    SuitClubs,
    SuitDiamonds,
    SuitHeart,
    SuitSpades
}Suit;

#define CardAce   1
#define CardJack  11
#define CardQueen 12
#define CardKing  13

@interface Card : NSObject

@property (nonatomic, readonly, assign) Suit suit;
@property (nonatomic, readonly, assign) int value;
@property (nonatomic, assign) BOOL isTurnedOver;
- (id) initWithSuit:(Suit)suit value:(int)value;
- (BOOL)isEqualToCard:(Card *)otherCard;
@end
