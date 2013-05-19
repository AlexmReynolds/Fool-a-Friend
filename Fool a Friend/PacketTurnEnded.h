//
//  PacketTurnEnded.h
//  Fool a Friend
//
//  Created by Alex Reynolds on 5/18/13.
//  Copyright (c) 2013 Alex Reynolds. All rights reserved.
//

#import "Packet.h"

@interface PacketTurnEnded : Packet
@property (nonatomic,strong) NSMutableDictionary *players;

+(id)packetWithPlayers:(NSMutableDictionary *)player;
@end
