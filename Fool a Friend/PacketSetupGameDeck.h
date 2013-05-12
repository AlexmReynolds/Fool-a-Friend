//
//  PacketSetupGameDeck.h
//  Fool a Friend
//
//  Created by Alex Reynolds on 5/11/13.
//  Copyright (c) 2013 Alex Reynolds. All rights reserved.
//

#import "Packet.h"
#import "Deck.h"
#import "Player.h"
@class Player;
@interface PacketSetupGameDeck : Packet

@property (nonatomic, strong)NSArray *cards;
@property (nonatomic, copy) NSString *startingPeerID;

+(id)packetWithCards:(NSArray *)cards startingWithPlayerPeerID:(NSString *)startingPeerID;
@end
