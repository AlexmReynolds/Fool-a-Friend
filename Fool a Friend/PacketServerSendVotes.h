//
//  PackerServerSendVotes.h
//  Fool a Friend
//
//  Created by Alex Reynolds on 5/18/13.
//  Copyright (c) 2013 Alex Reynolds. All rights reserved.
//

#import "Packet.h"

@interface PacketServerSendVotes : Packet
@property (nonatomic, copy) NSArray *votes;

+(id) packetWithVotes:(NSArray *)votes;
@end
