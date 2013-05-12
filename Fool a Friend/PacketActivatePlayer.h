//
//  PacketActivatePlayer.h
//  Snap
//
//  Created by Alex Reynolds on 5/7/13.
//  Copyright (c) 2013 AlexReynolds. All rights reserved.
//

#import "Packet.h"

@interface PacketActivatePlayer : Packet

@property (nonatomic, copy) NSString *peerID;

+ (id) packetWithPeerID:(NSString *)peerID;
@end
