//
//  PacketServerReady.h
//  Snap
//
//  Created by Alex Reynolds on 5/6/13.
//  Copyright (c) 2013 AlexReynolds. All rights reserved.
//

#import "Packet.h"

@interface PacketServerReady : Packet

@property (nonatomic,strong) NSMutableDictionary *players;

+(id)packetWithPlayers:(NSMutableDictionary *)player;
@end
