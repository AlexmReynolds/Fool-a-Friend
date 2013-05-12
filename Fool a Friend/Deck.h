//
//  Deck.h
//  Full of it
//
//  Created by Alex Reynolds on 5/8/13.
//  Copyright (c) 2013 Alex Reynolds. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card.h"
@interface Deck : NSObject{
    NSMutableArray *_cards;
}
-(id) initWithCards:(NSArray *)cards;
-(void)shuffle;
-(Card *)draw;
-(int)cardsRemaining;
-(NSArray *) getAllCards;

@end
