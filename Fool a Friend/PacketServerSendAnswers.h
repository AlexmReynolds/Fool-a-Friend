//
//  PacketServerSendAnswers.h
//  Fool a Friend
//
//  Created by Alex Reynolds on 5/13/13.
//  Copyright (c) 2013 Alex Reynolds. All rights reserved.
//

#import "Packet.h"

@interface PacketServerSendAnswers : Packet

@property (nonatomic, copy) NSArray *answers;

+(id) packetWithAnswers:(NSArray *)answers;
@end
