//
//  PacketClientSubmitVote.h
//  Fool a Friend
//
//  Created by Alex Reynolds on 5/18/13.
//  Copyright (c) 2013 Alex Reynolds. All rights reserved.
//

#import "Packet.h"

@interface PacketClientSubmitVote : Packet

@property (nonatomic, copy) NSString *peerID;

+ (id)packetWithVote:(NSString *)vote;

@end
