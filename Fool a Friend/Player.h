//
//  Player.h
//  Full of it
//
//  Created by Alex Reynolds on 5/8/13.
//  Copyright (c) 2013 Alex Reynolds. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Stack.h"

@interface Player : NSObject
@property (nonatomic, assign) int lastPacketNumberReceived;
@property (nonatomic,strong,readonly) Stack *closedCards;
@property (nonatomic,strong,readonly) Stack *openCards;
@property (nonatomic) int gamesWon;
@property (nonatomic) BOOL receivedResponse;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *peerID;

-(Card*)turnOverTopCard;
-(BOOL)shouldRecycle;
-(NSArray *)recycleCards;
-(int)totalCardCount;
@end