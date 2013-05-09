//
//  Stack.h
//  Snap
//
//  Created by Alex Reynolds on 5/6/13.
//  Copyright (c) 2013 AlexReynolds. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card.h"

@interface Stack : NSObject{
    NSMutableArray *_cards;
}

-(void)addCardToTop:(Card*)card;
-(NSUInteger)cardCount;
-(NSArray *)array;
-(Card *)cardAtIndex:(NSUInteger)index;
-(void)addCardsFromArray:(NSArray *)array;
-(Card *)topMostCard;
-(void)removeTopMostCard;
-(void) removeAllCards;
-(void)addCardToBottom:(Card *)card;
@end
